try:
    from rdkit import Chem
except ModuleNotFoundError:
    pass

import numpy as np
import os
import sys
from tqdm import tqdm

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../e3_diffusion_for_molecules')))

import build_geom_dataset
from configs.datasets_config import geom_with_h

# Load dataset
data_file = 'geom_data/geom_drugs_no_h_30.npy'
dataset_info = geom_with_h
split_data = build_geom_dataset.load_split_data(data_file, val_proportion=0.1, test_proportion=0.1)

# Create output directory
output_dir = "geom"
os.makedirs(output_dir, exist_ok=True)

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
        to_pad = 200 - len(arr)
        
        new_dict['num_atoms'].append(len(arr))
        new_dict['charges'].append(np.append(charges, np.zeros(to_pad)))
        new_dict['positions'].append(np.append(positions, np.zeros([to_pad, 3])).reshape((200, 3)))
    
    for key in new_dict:
        new_dict[key] = np.array(new_dict[key])
    
    save_path = os.path.join(output_dir, f'{["train", "test", "valid"][i]}.npz')
    np.savez(save_path, **new_dict)
    print(f'Saved {save_path}')