#!/bin/bash

# Source the shell configuration file to apply conda changes
source ~/.bashrc

# Activate the conda environment
conda activate bio-diffusion

echo 'downloading and preparing QM9 dataset...'
python data_scripts/download_qm9.py
rm qm9/dsgdb9nsd.xyz.tar.bz2

echo 'downloading and preparing GEOM dataset...'
echo 'warning! this dataset is large and will take a while to download and process'
wget https://zenodo.org/records/14843543/files/geom_data.tar.gz
tar -xzvf geom_data.tar.gz 
rm geom_data.tar.gz
python data_scripts/process_GEOM.py

rm -r geom_data


echo 'downloading and preparing ZINC subset...'
wget https://zenodo.org/records/14825440/files/zinc_dataset.tar.gz
mkdir zinc
tar -xzvf zinc_dataset.tar.gz -C zinc/
rm zinc_dataset.tar.gz