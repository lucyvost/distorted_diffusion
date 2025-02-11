# Improving Structural Plausibility in 3D Molecule Generation via Property-Conditioned Training with Distorted Molecules

This repository accompanies the paper "Improving Structural Plausibility in 3D Molecule Generation via Property-Conditioned Training with Distorted Molecules" ([preprint here](https://www.biorxiv.org/content/10.1101/2024.09.17.613136v1)). Our approach involves introducing distorted molecules into training datasets and annotating each molecule with a label that reflects its level of distortion, and consequently, its structural quality. By training generative models to distinguish between high- and low-quality molecular conformations, we enable selective sampling from high-quality regions of the learned space, resulting in an improvement in the validity of generated molecules. 


![image](https://github.com/user-attachments/assets/0ea71839-6e0e-4b65-bd1f-4743d876610c)

# Models
Our conditional method has been tested on the following models:

### EDM (E(3) Diffusion Model)

[GitHub Repo](https://github.com/ehoogeboom/e3_diffusion_for_molecules/tree/main) 

[Paper](https://proceedings.mlr.press/v162/hoogeboom22a/hoogeboom22a.pdf)

### GCDM (Geometry-Complete Diffusion Model)

[GitHub Repository](https://github.com/BioinfoMachineLearning/bio-diffusion)

[Paper](https://www.nature.com/articles/s42004-024-01233-z)

### MolFM

[GitHub Repository](https://github.com/AlgoMole/MolFM)

[Paper](https://arxiv.org/pdf/2312.07168)

Each model can be trained and sampled using its original source code without modification. To set up an environment that is compatible for all of these modules and clone all three repos, use the repos_and_envs script:
```sh
git clone https://github.com/lucyvost/distorted_diffusion.git
cd distorted_diffusion
bash repos_and_env.sh
```
This environment was created by the authors of GCDM, and works for training and sampling all three models discussed. It uses mamba, so once created, you may need to add the location of miniforge to your path to activate the environment. For more details, please check out [their repo](https://github.com/BioinfoMachineLearning/bio-diffusion). 

# Datasets

## Downloading datasets

We use three molecular datasets for evaluation. To enable comparison with the pretrained baseline models, we follow the same processing and splitting regimes.

All three datasets can be downloaded and processed using the download_datasets.sh script. Beware that this takes around 40 mins, and will occupy ~70GB.

```sh
bash download_datasets.sh
```

Alternatively, QM9 and GEOM can be individually downloaded and processed using the EDM repo:

QM9: downloaded and processed using [this EDM script](https://github.com/ehoogeboom/e3_diffusion_for_molecules/tree/main/qm9/data/prepare/qm9.py)

GEOM: downloaded and processed following instructions [here](https://github.com/ehoogeboom/e3_diffusion_for_molecules/tree/main/data/geom/)



## Adding distortion to datasets

To add distorted molecules and labels to a downloaded and preprocessed dataset, run:

```sh
python distort_molecules.py --datadir $datadir --max_dist 0.25 --ratio_distorted_mols 50
```

# Reproducing paper results 

## EDM



After downloading the datasets, train the model on any dataset using `training_scripts/train_edm.sh`, specifying the dataset name (qm9, geom or zinc) and the mode (baseline or conditional). 

```sh
bash training_scripts/train_edm.sh $dataset $mode
```

Sample the model using `sampling_scripts/sample_edm.sh`, specifying the location of the checkpoints.

```sh
bash sampling_scripts/sample_edm.sh $path_to_checkpoints
```


### GCDM

After downloading the datasets, train the model on any dataset using `training_scripts/train_gcdm.sh`, specifying the dataset name (qm9, geom or zinc) and the mode (baseline or conditional). 

```sh
bash training_scripts/train_gcdm.sh $dataset $mode
```

Sample the model using `sampling_scripts/sample_edm.sh`, specifying the location of the checkpoints.

```sh
bash sampling_scripts/sample_gcdm.sh $path_to_checkpoints
```


### MolFM

Note: since this work was carried out, the authors have released a docker container for their model. For this work, we used the code provided by them as supplementary information [here](https://github.com/AlgoMole/MolFM/issues/1). Below is a guide to running this version of the code - for the new version, please follow the guidance on their repo.

After downloading the datasets, train the model on any dataset using `training_scripts/train_molfm.sh`, specifying the dataset name (qm9, geom or zinc) and the mode (baseline or conditional). 

```sh
bash training_scripts/train_molfm.sh $dataset $mode
```

Sample the model using `sampling_scripts/sample_edm.sh`, specifying the location of the checkpoints.

```sh
bash sampling_scripts/sample_molfm.sh $path_to_checkpoints
```


## Sampling pretrained models

We provide checkpoints for all of the models assessed in the manuscript in [checkpoints](https://github.com/lucyvost/distorted_diffusion/checkpoints). These can each be sampled using the corresponding shell scripts as shown above.

The two pretrained models we used can be found and downloaded at the links below:

[EDM - QM9](https://github.com/ehoogeboom/e3_diffusion_for_molecules/tree/main/outputs/edm_qm9)

[GCDM - GEOM](https://zenodo.org/record/13375913/files/GCDM_Checkpoints.tar.gz)



##  Assessing generated molecules

The molecules we generated with each model are available in the `generated_molecules` folder. To reproduce the results shown in tables 1-3 of the manuscript, run

```sh
python assess_molecules.py $path_to_generations
```

This will return a table with individual PoseBusters pass rates as well as 95% confidence intervals. Note that due to the large number of molecules and energy calculations of PoseBusters, this script can take up 40 minutes to run for a single set of molecules.

