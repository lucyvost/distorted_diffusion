# Improving Structural Plausibility in 3D Molecule Generation via Property-Conditioned Training with Distorted Molecules

This repository accompanies the paper "Improving Structural Plausibility in 3D Molecule Generation via Property-Conditioned Training with Distorted Molecules" ([preprint here](https://www.biorxiv.org/content/10.1101/2024.09.17.613136v1)). Our approach involves introducing distorted molecules into training datasets and annotating each molecule with a label that reflects its level of distortion, and consequently, its structural quality. By training generative models to distinguish between high- and low-quality molecular conformations, we enable selective sampling from high-quality regions of the learned space, resulting in an improvement in the validity of generated molecules. 


![image](https://github.com/user-attachments/assets/0ea71839-6e0e-4b65-bd1f-4743d876610c)


# Datasets

## Downloading datasets

We use three molecular datasets for evaluation. To enable comparison with the pretrained baseline models, we follow the same processing and splitting regimes.

All three datasets can be downloaded and processed using the download_datasets.sh script:

```sh
clone git@github.com:lucyvost/distorted_diffusion.git
bash download_datasets.sh
```

Alternatively, QM9 and GEOM can be downloaded and processed using the EDM repo:

QM9: downloaded and processed using [this EDM script](https://github.com/ehoogeboom/e3_diffusion_for_molecules/tree/main/qm9/data/prepare/qm9.py)

GEOM: downloaded and processed following instructions [here](https://github.com/ehoogeboom/e3_diffusion_for_molecules/tree/main/data/geom/)

## Adding distortion to datasets

To add distorted molecules and labels to a downloaded and preprocessed dataset, run:

```sh
bash distort_molecules.bash $dataset_folder
```


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

Each model can be trained and sampled using its original source code without any modifications. To set up an environment that is compatible for all of these modules and clone all three repos, use the repos_and_envs script:
```sh
bash repos_and_envs.sh
```

# Reproducing paper results 

## EDM

### Baseline


After downloading the GEOM dataset (either with the supplied script or following the repo instructions), train the model on the hydrogen-free GEOM dataset as follows:

```sh
python main_geom_drugs.py --n_epochs 3000 --exp_name unconditional_geom_no_h --datadir geom --n_stability_samples 500 --diffusion_noise_schedule polynomial_2 --diffusion_steps 1000 --diffusion_noise_precision 1e-5 --diffusion_loss_type l2 --batch_size 64 --nf 256 --n_layers 4 --lr 1e-4 --normalize_factors [1,4,10] --test_epochs 1 --ema_decay 0.9999 --normalization_factor 1 --model egnn_dynamics --visualize_every_batch 10000
```

and sample using

```sh
python eval_sample.py --model_path outputs/unconditional_geom_no_h/
```
For the ZINC dataset, train the model using

```sh
python main_qm9.py --n_epochs 3000 --exp_name unconditional_zinc --n_stability_samples 500 --diffusion_noise_schedule polynomial_2 --diffusion_steps 1000 --diffusion_noise_precision 1e-5 --diffusion_loss_type l2 --batch_size 64 --nf 256 --n_layers 4 --lr 1e-4 --normalize_factors [1,4,10] --test_epochs 1 --ema_decay 0.9999 --normalization_factor 1 --model egnn_dynamics --visualize_every_batch 10000 
```

and sample using

```sh
python eval_sample.py --model_path outputs/no_scramble_zinc
```


### Conditional 

To train a conditional model, run

```sh
python main_qm9.py --conditioning distortion --dataset qm9_second_half --exp_name conditional_qm9  --model egnn_dynamics --lr 1e-4  --nf 192 --n_layers 9 --save_model True --diffusion_steps 1000 --sin_embedding False --n_epochs 3000 --n_stability_samples 500 --diffusion_noise_schedule polynomial_2 --diffusion_noise_precision 1e-5 --dequantization deterministic --include_charges False --diffusion_loss_type l2 --batch_size 64 --normalize_factors [1,8,1] 
```

To generate samples for different property values, run

```sh
python eval_conditional_qm9.py --generators_path outputs/exp_cond_alpha --property distortion --n_sweeps 10 --task qualitative
```

## GCDM

### Baseline



### Conditional

## MolFM

### Baseline

### Conditional

## Sampling and assessing pretrained models

We provide checkpoints for all of the models assessed in the manuscript in [checkpoints](https://github.com/lucyvost/distorted_diffusion/checkpoints). These can each be sampled using the corresponding models code above.

The two pretrained models we used can be found and downloaded at the links below:

[EDM - QM9](https://github.com/ehoogeboom/e3_diffusion_for_molecules/tree/main/outputs/edm_qm9)

[GCDM - GEOM](https://zenodo.org/record/13375913/files/GCDM_Checkpoints.tar.gz)




