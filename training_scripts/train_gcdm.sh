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

cp datasets_config.py ../bio-diffusion/src/datamodules/components/edm/datasets_config.py

if [ "$MODE" == "baseline" ]; then
    python src/train.py --dataset $DATASET --mode baseline
elif [ "$MODE" == "conditional" ]; then
    python src/train.py --dataset $DATASET --mode conditional
else
    echo "Invalid mode: $MODE"
    exit 1
fi