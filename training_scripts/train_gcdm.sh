#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <dataset> <mode>"
    echo "Datasets: qm9, geom, zinc"
    echo "Modes: baseline, conditional"
    exit 1
fi

DATASET=$1
MODE=$2

conda activate bio-diffusion

cp ../datasets_config.py ../bio-diffusion/src/datamodules/components/edm/datasets_config.py
cd bio-diffusion
if [ "$DATASET" == "qm9" ]; then
    if [ "$MODE" == "baseline" ]; then
        python src/train.py experiment=qm9_mol_gen_ddpm.yaml datamodule.dataloader_cfg.data_dir='qm9'
    elif [ "$MODE" == "conditional" ]; then
        python3 src/train.py experiment=qm9_mol_gen_conditional_ddpm.yaml model.module_cfg.conditioning=[scramble] datamodule.dataloader_cfg.data_dir='qm9_distorted' datamodule.dataloader_cfg.dataset='qm9'
    else
        echo "Invalid mode: $MODE"
        exit 1
    fi
elif [ "$DATASET" == "geom" ]; then
    if [ "$MODE" == "baseline" ]; then
        python src/train.py experiment=geom_mol_gen_ddpm.yaml datamodule.dataloader_cfg.data_dir='geom'
    elif [ "$MODE" == "conditional" ]; then
        python3 src/train.py experiment=qm9_mol_gen_conditional_ddpm.yaml model.module_cfg.conditioning=[scramble] datamodule.dataloader_cfg.data_dir='geom_distorted' datamodule.dataloader_cfg.dataset='geom' trainer.min_epochs=50 trainer.max_epochs=3000 callbacks.early_stopping.patience=20 model.model_cfg.e_hidden_dim=16 model.model_cfg.xi_hidden_dim=8 model.model_cfg.num_encoder_layers=4 model.diffusion_cfg.norm_values=[]
    else
        echo "Invalid mode: $MODE"
        exit 1
    fi
elif [ "$DATASET" == "zinc" ]; then
    if [ "$MODE" == "baseline" ]; then
        python src/train.py experiment=qm9_mol_gen_ddpm.yaml datamodule.dataloader_cfg.data_dir='zinc' datamodule.dataloader_cfg.dataset='zinc'
    elif [ "$MODE" == "conditional" ]; then
        python3 src/train.py experiment=qm9_mol_gen_conditional_ddpm.yaml model.module_cfg.conditioning=[scramble] datamodule.dataloader_cfg.data_dir='zinc_distorted' datamodule.dataloader_cfg.dataset='zinc'
    else
        echo "Invalid mode: $MODE"
        exit 1
    fi
else
    echo "Invalid dataset: $DATASET"
    exit 1

fi