#!/bin/bash
python download_qm9.py
#code is from the bio-diffusion repository
wget https://zenodo.org/record/7881981/files/EDM.tar.gz
tar -xzf EDM.tar.gz

rm EDM.tar.gz
mv data/EDM/GEOM/GEOM_permutation.npy data/EDM/GEOM/geom_permutation.npy
wget https://zenodo.org/records/14825440/files/zinc_dataset.tar.gz
mkdir zinc
tar -xzvf zinc_dataset.tar.gz -C zinc/
rm zinc_dataset.tar.gz
mv zinc data/ZINC