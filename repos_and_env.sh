#!/bin/bash
OS=$(uname -s)
ARCH=$(uname -m)
INSTALLER="Miniforge3-24.11.3-0-${OS}-${ARCH}.sh"

wget "https://github.com/conda-forge/miniforge/releases/latest/download/${INSTALLER}" -O Miniforge.sh
bash Miniforge.sh -b -p $HOME/miniforge  # accept all terms and install to the default location
rm Miniforge.sh  # (optionally) remove installer after using it
source $HOME/miniforge/bin/activate  # alternatively, one can restart their shell session to achieve the same result
conda activate bio-diffusion
# clone project
git clone https://github.com/BioinfoMachineLearning/bio-diffusion
cd bio-diffusion

# create conda environment
mamba env create -f environment.yaml
conda activate bio-diffusion  # note: one still needs to use `conda` to (de)activate environments

# install local project as package
pip3 install -e .
pip3 install torchdiffeq
pip3 install zuko
cd ..
git clone https://github.com/ehoogeboom/e3_diffusion_for_molecules.git


# download and extract the code.tar.gz from the specified link
wget -O supplementary_material.zip "https://openreview.net/attachment?id=hHUZ5V9XFu&name=supplementary_material"
unzip supplementary_material.zip
rm supplementary_material.zip
tar -xzf code.tar.gz
rm code.tar.gz
rm Flow_Matching_Generation_with_Appendix.pdf  # delete the PDF file