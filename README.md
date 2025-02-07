# Improving Structural Plausibility in 3D Molecule Generation via Property-Conditioned Training with Distorted Molecules

This repository accompanies the paper "Improving Structural Plausibility in 3D Molecule Generation via Property-Conditioned Training with Distorted Molecules" ([preprint here](https://www.biorxiv.org/content/10.1101/2024.09.17.613136v1)). Our approach involves introducing distorted molecules into training datasets and annotating each molecule with a label that reflects its level of distortion, and consequently, its structural quality. By training generative models to distinguish between high- and low-quality molecular conformations, we enable selective sampling from high-quality regions of the learned space, resulting in an improvement in the validity of generated molecules. 


![image](https://github.com/user-attachments/assets/0ea71839-6e0e-4b65-bd1f-4743d876610c)


# Datasets

We use three molecular datasets for evaluation. These can be downloaded using the download_datasets.sh script:

```clone git@github.com:lucyvost/distorted_diffusion.git
bash download_datasets.sh```

Alternatively, QM9 and GEOM can be downloaded using the EDM repo:

QM9: downloaded and processed using [this EDM script](https://github.com/ehoogeboom/e3_diffusion_for_molecules/tree/main/qm9/data/prepare/qm9.py)

GEOM: downloaded and processed following instructions [here](https://github.com/ehoogeboom/e3_diffusion_for_molecules/tree/main/data/geom/)




# Models
Our conditional method has been tested on the following models:

EDM (E(3) Diffusion Model)

[GitHub Repo](https://github.com/ehoogeboom/e3_diffusion_for_molecules/tree/main) 

[Paper](https://proceedings.mlr.press/v162/hoogeboom22a/hoogeboom22a.pdf)

GCDM (Geometry-Complete Diffusion Model)

[GitHub Repository](https://github.com/BioinfoMachineLearning/bio-diffusion)

[Paper](https://www.nature.com/articles/s42004-024-01233-z)

MolFM

[GitHub Repository](https://github.com/AlgoMole/MolFM)

[Paper](https://arxiv.org/pdf/2312.07168)

Each model can be trained and sampled using its original source code without any modifications. Setup instructions for each model's required environment can be found in their respective repositories. 






