#!/bin/bash


#this is the setup script for bio-diffusion

wget "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"
bash Mambaforge-$(uname)-$(uname -m).sh  # accept all terms and install to the default location
rm Mambaforge-$(uname)-$(uname -m).sh  # (optionally) remove installer after using it
source ~/.bashrc  # alternatively, one can restart their shell session to achieve the same result

# clone project
git clone https://github.com/BioinfoMachineLearning/bio-diffusion
cd bio-diffusion

# create conda environment
mamba env create -f environment.yaml
conda activate bio-diffusion  # note: one still needs to use `conda` to (de)activate environments

# install local project as package
pip3 install -e .
cd ..
git clone https://github.com/ehoogeboom/e3_diffusion_for_molecules.git


# download and extract the code.tar.gz from the specified link
wget -O supplementary_material.zip "https://openreview.net/attachment?id=hHUZ5V9XFu&name=supplementary_material"
unzip supplementary_material.zip
rm supplementary_material.zip
tar -xzf code.tar.gz
rm code.tar.gz
rm supplementary_material.pdf  # delete the PDF file