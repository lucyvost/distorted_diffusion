#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <dataset> <mode>"
    echo "Datasets: qm9, geom, zinc"
    echo "Modes: baseline, conditional"
    exit 1
fi

DATASET=$1
MODE=$2

source ~/.bashrc
conda activate bio-diffusion

cp dataset_config_files/datasets_config.py efm_gen/configs/datasets_config.py
cd efm_gen
if [ "$DATASET" == "qm9" ]; then
    if [ "$MODE" == "baseline" ]; then
        python main_qm9.py --exp_name baseline_qm9 --datadir  qm9 --test_epochs 1 --dataset qm9
    elif [ "$MODE" == "conditional" ]; then
        python main_qm9.py --exp_name conditional_qm9 --datadir  qm9_distorted --test_epochs 1 --dataset qm9 --conditional scramble
    else
        echo "Invalid mode: $MODE"
        exit 1
    fi
elif [ "$DATASET" == "geom" ]; then
    if [ "$MODE" == "baseline" ]; then
        python main_qm9.py --exp_name baseline_geom --datadir  geom --test_epochs 1 --dataset geom_no_h
    elif [ "$MODE" == "conditional" ]; then
        python main_qm9.py --exp_name baseline_geom --datadir  geom_distorted --test_epochs 1 --dataset geom_no_h --conditional scramble
    else
        echo "Invalid mode: $MODE"
        exit 1
    fi
elif [ "$DATASET" == "zinc" ]; then
    if [ "$MODE" == "baseline" ]; then
        python main_qm9.py --exp_name baseline_zinc --datadir  zinc --test_epochs 1 --dataset zinc
    elif [ "$MODE" == "conditional" ]; then
        python main_qm9.py --exp_name baseline_zinc --datadir  zinc --test_epochs 1 --dataset zinc --conditional scramble
    else
        echo "Invalid mode: $MODE"
        exit 1
    fi
else
    echo "Invalid dataset: $DATASET"
    exit 1
fi