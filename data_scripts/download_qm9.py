import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../e3_diffusion_for_molecules')))
from qm9.data.prepare.qm9 import download_dataset_qm9


# Download and preprocess the QM9 dataset
download_dataset_qm9('.', "qm9",calculate_thermo=False)