import random
import numpy as np
import argparse
import os
import sys
from tqdm import tqdm

# Add e3_diffusion_for_molecules to the Python path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), 'e3_diffusion_for_molecules')))

import build_geom_dataset
from configs.datasets_config import geom_with_h

def scramble_coordinates_3d(coordinates, max_scramble):
    """
    Scramble a list of 3D coordinates by a random amount between 0 and max_scramble.

    Parameters:
    - coordinates: A list of tuples, each containing (x, y, z) coordinates.
    - max_scramble: The maximum amount to scramble (0 to 1).

    Returns:
    - A new list of scrambled 3D coordinates.
    """
    scrambled_coordinates = []
    for x, y, z in coordinates:
        # Generate random offsets within the specified range for each dimension
        offset_x = random.uniform(-max_scramble, max_scramble)
        offset_y = random.uniform(-max_scramble, max_scramble)
        offset_z = random.uniform(-max_scramble, max_scramble)

        # Apply the offsets to the coordinates
        scrambled_x = x + offset_x
        scrambled_y = y + offset_y
        scrambled_z = z + offset_z

        scrambled_coordinates.append([scrambled_x, scrambled_y, scrambled_z])

    return np.array(scrambled_coordinates)

def process_split(data, max_dist, ratio_distorted_mols, split_name, output_dir):
    print(f"Processing {split_name} split...")
    conditional_dict = {'positions': [], 'charges': [], 'scramble': [], 'num_atoms': []}
    all_positions = data['positions']
    all_charges = data['charges']
    
    for idx, mol in tqdm(enumerate(all_charges), total=len(all_charges)):
        conditional_dict['positions'].append(all_positions[idx])
        conditional_dict['charges'].append(all_charges[idx])
        conditional_dict['scramble'].append(0)
        conditional_dict['num_atoms'].append(len(np.where(mol != 0)[0]))

        # One slightly messed up version every ratio_distorted_mols molecules
        if idx % ratio_distorted_mols == 0:
            slight_mess = random.uniform(0, max_dist)
            conditional_dict['charges'].append(all_charges[idx])
            conditional_dict['scramble'].append(slight_mess)
            new_coords = scramble_coordinates_3d(all_positions[idx], max_scramble=slight_mess)
            num_atoms = len(np.where(mol != 0)[0])
            new_coords = new_coords[:num_atoms]
            to_pad = 200 - num_atoms
            new_coords = np.append(new_coords, np.zeros([to_pad, 3])).reshape((200, 3))
            conditional_dict['positions'].append(new_coords)
            conditional_dict['num_atoms'].append(num_atoms)

    split_dict = {
        'positions': np.array(conditional_dict['positions']),
        'charges': np.array(conditional_dict['charges']),
        'scramble': np.array(conditional_dict['scramble']),
        'num_atoms': np.array(conditional_dict['num_atoms'])
    }

    save_path = os.path.join(output_dir, f'{split_name}.npz')
    np.savez(save_path, **split_dict)
    print(f"Saved {split_name} split to {save_path}")

def main(datadir, max_dist, ratio_distorted_mols):
    # Remove trailing slash from datadir if it exists
    if datadir.endswith('/'):
        datadir = datadir[:-1]

    output_dir = f"{datadir}_distorted"
    os.makedirs(output_dir, exist_ok=True)

    print("Loading train split...")
    train = np.load(os.path.join(datadir, 'train.npz'))
    process_split(train, max_dist, ratio_distorted_mols, 'train', output_dir)

    print("Loading test split...")
    test = np.load(os.path.join(datadir, 'test.npz'))
    process_split(test, max_dist, ratio_distorted_mols, 'test', output_dir)

    print("Loading valid split...")
    valid = np.load(os.path.join(datadir, 'valid.npz'))
    process_split(valid, max_dist, ratio_distorted_mols, 'valid', output_dir)

    print("All splits processed and saved.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('--datadir', type=str, required=True, help='Directory containing train.npz, test.npz, and valid.npz')
    parser.add_argument('--max_dist', type=float, required=True, help='Maximum distortion value')
    parser.add_argument('--ratio_distorted_mols', type=int, required=True, help='Ratio of distorted molecules')

    args = parser.parse_args()
    main(args.datadir, args.max_dist, args.ratio_distorted_mols)


# Determine padding value based on datadir name
datadir = os.path.basename(os.path.dirname(data_file)).lower()
if 'qm9' in datadir:
    pad_value = 50
elif 'zinc' in datadir:
    pad_value = 100
elif 'geom' in datadir:
    pad_value = 200
else:
    raise ValueError("Unknown dataset directory name. Please ensure it contains 'qm9', 'zinc', or 'geom'.")

# Process and save each split
for i, split_arr in enumerate(split_data):
    new_dict = {
        'positions': [],
        'charges': [],
        'num_atoms': []
    }
    
    for arr in tqdm(split_arr, desc=f'Processing split {i+1}/{len(split_data)}'):
        charges = np.array(arr[:, 0])
        positions = np.array(arr[:, 1:4])
        to_pad = pad_value - len(arr)
        
        new_dict['num_atoms'].append(len(arr))
        new_dict['charges'].append(np.append(charges, np.zeros(to_pad)))
        new_dict['positions'].append(np.append(positions, np.zeros([to_pad, 3])).reshape((pad_value, 3)))
    
    for key in new_dict:
        new_dict[key] = np.array(new_dict[key])
    
    save_path = os.path.join(output_dir, f'{["train", "test", "valid"][i]}.npz')
    np.savez(save_path, **new_dict)
    print(f'Saved {save_path}')