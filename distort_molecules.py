import random
import numpy as np
import argparse
from rdkit import Chem
from tqdm import tqdm

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

def main(datadir, max_dist, ratio_distorted_mols):
    # Load any 3D molecular dataset in dictionary form as taken in by EDM
    train = np.load(f'{datadir}/train.npz')
    test = np.load(f'{datadir}/test.npz')
    valid = np.load(f'{datadir}/valid.npz')

    # Create a new npz file to combine the data
    combined_file = 'all_data.npz'
    combined_data = {}
    # Iterate through keys and combine the data
    for key in test.keys():
        combined_data[key] = np.concatenate([train[key], test[key], valid[key]], axis=0)

    # Add some distorted molecules to the dataset
    conditional_dict = {'positions': [], 'charges': [], 'scramble': [], 'num_atoms': []}
    # Load all the data first so we don't need to re-load the whole dictionary every time
    all_positions = combined_data['positions']
    all_charges = combined_data['charges']
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
            to_pad = 100 - num_atoms
            new_coords = np.append(new_coords, np.zeros([to_pad, 3])).reshape((100, 3))
            conditional_dict['positions'].append(new_coords)
            conditional_dict['num_atoms'].append(num_atoms)

    # Split data back into train, test, and valid sets
    train_size = len(train['charges'])
    test_size = len(test['charges'])
    valid_size = len(valid['charges'])

    train_dict = {
        'positions': np.array(conditional_dict['positions'][:train_size]),
        'charges': np.array(conditional_dict['charges'][:train_size]),
        'scramble': np.array(conditional_dict['scramble'][:train_size]),
        'num_atoms': np.array(conditional_dict['num_atoms'][:train_size])
    }

    test_dict = {
        'positions': np.array(conditional_dict['positions'][train_size:train_size + test_size]),
        'charges': np.array(conditional_dict['charges'][train_size:train_size + test_size]),
        'scramble': np.array(conditional_dict['scramble'][train_size:train_size + test_size]),
        'num_atoms': np.array(conditional_dict['num_atoms'][train_size:train_size + test_size])
    }

    valid_dict = {
        'positions': np.array(conditional_dict['positions'][train_size + test_size:]),
        'charges': np.array(conditional_dict['charges'][train_size + test_size:]),
        'scramble': np.array(conditional_dict['scramble'][train_size + test_size:]),
        'num_atoms': np.array(conditional_dict['num_atoms'][train_size + test_size:])
    }

    # Save datasets
    for split, data in zip(['train_dist', 'test_dist', 'valid_dist'], [train_dict, test_dict, valid_dict]):
        np.savez(f'{split}.npz', **data)

    print("You now have a set of dictionaries you can use to train a conditional model on the 'scramble' property!")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('--datadir', type=str, required=True, help='Directory containing train.npz, test.npz, and valid.npz')
    parser.add_argument('--max_dist', type=float, required=True, help='Maximum distortion value')
    parser.add_argument('--ratio_distorted_mols', type=int, required=True, help='Ratio of distorted molecules')

    args = parser.parse_args()
    main(args.datadir, args.max_dist, args.ratio_distorted_mols)