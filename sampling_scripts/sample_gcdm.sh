#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <path_to_checkpoints> <dataset> <mode>"
    echo "Datasets: qm9, geom, zinc"
    echo "Modes: baseline, conditional"
    exit 1
fi

CHECKPOINTS=$1
DATASET=$2
MODE=$3

source ~/.bashrc
conda activate bio-diffusion

cp dataset_config_files/datasets_config_gcdm.py bio-diffusion/src/datamodules/components/edm/datasets_config.py
cd bio-diffusion

if [ "$DATASET" == "qm9" ]; then
    if [ "$MODE" == "baseline" ]; then
        python3 src/mol_gen_sample.py datamodule=edm_qm9 model=qm9_mol_gen_ddpm logger=csv trainer.accelerator=gpu trainer.devices=[0] ckpt_path=$CHECKPOINTS num_samples=250 num_nodes=19 all_frags=true sanitize=false relax=false num_resamplings=1 jump_length=1 num_timesteps=1000 output_dir="./" seed=123
    elif [ "$MODE" == "conditional" ]; then
        python3 src/mol_gen_eval_conditional_qm9.py datamodule=edm_qm9 model=qm9_mol_gen_ddpm logger=csv trainer.accelerator=gpu trainer.devices=[0] datamodule.dataloader_cfg.num_workers=1 model.diffusion_cfg.sample_during_training=false generator_model_filepath=$CHECKPOINTS property=scramble iterations=100 batch_size=100 sweep_property_values=true num_sweeps=10 output_dir="./" seed=123
    else
        echo "Invalid mode: $MODE"
        exit 1
    fi
elif [ "$DATASET" == "geom" ]; then
    if [ "$MODE" == "baseline" ]; then
        python3 src/mol_gen_sample.py datamodule=edm_geom model=geom_mol_gen_ddpm logger=csv trainer.accelerator=gpu trainer.devices=[0] ckpt_path=$CHECKPOINTS num_samples=1000 num_nodes=19 all_frags=true sanitize=false relax=false num_resamplings=1 jump_length=1 num_timesteps=1000 seed=123
    elif [ "$MODE" == "conditional" ]; then
        python3 src/mol_gen_eval_conditional_qm9.py datamodule=edm_qm9 model=qm9_mol_gen_ddpm logger=csv datamodule.dataloader_cfg.data_dir='../geom_distorted' trainer.accelerator=gpu trainer.devices=[0] datamodule.dataloader_cfg.num_workers=1 model.diffusion_cfg.sample_during_training=false generator_model_filepath=$CHECKPOINTS property=scramble iterations=10 batch_size=10 sweep_property_values=True num_sweeps=1000  seed=123
    else
        echo "Invalid mode: $MODE"
        exit 1
    fi
elif [ "$DATASET" == "zinc" ]; then
    if [ "$MODE" == "baseline" ]; then
        python3 src/mol_gen_sample.py datamodule=edm_qm9 model=qm9_mol_gen_ddpm logger=csv trainer.accelerator=gpu trainer.devices=[0]  num_samples=1000 num_nodes=19 all_frags=true sanitize=false relax=false num_resamplings=1 jump_length=1 num_timesteps=1000 datamodule.dataloader_cfg.include_charges=false datamodule.dataloader_cfg.dataset='zinc' ckpt_path=$CHECKPOINTS seed=123
    elif [ "$MODE" == "conditional" ]; then
        python3 src/mol_gen_eval_conditional_qm9.py datamodule=edm_qm9 model=qm9_mol_gen_ddpm logger=csv datamodule.dataloader_cfg.dataset='zinc'  datamodule.dataloader_cfg.data_dir='../zinc_distorted' trainer.accelerator=gpu trainer.devices=[0] datamodule.dataloader_cfg.num_workers=1 datamodule.dataloader_cfg.num_atom_types=10 model.diffusion_cfg.sample_during_training=false generator_model_filepath=$CHECKPOINTS  property=scramble iterations=100 experiment_name='zinc_cond' batch_size=100 sweep_property_values=True num_sweeps=1000 output_dir='.' seed=123
    else
        echo "Invalid mode: $MODE"
        exit 1
    fi
else
    echo "Invalid dataset: $DATASET"
    exit 1
fi