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

if [ "$DATASET" == "qm9" ]; then
    if [ "$MODE" == "baseline" ]; then
        python src/train_qm9_baseline.py
    elif [ "$MODE" == "conditional" ]; then
        python src/train_qm9_conditional.py
    else
        echo "Invalid mode: $MODE"
        exit 1
    fi
elif [ "$DATASET" == "geom" ]; then
    if [ "$MODE" == "baseline" ]; then
        python src/train_geom_baseline.py
    elif [ "$MODE" == "conditional" ]; then
        python src/train_geom_conditional.py
    else
        echo "Invalid mode: $MODE"
        exit 1
    fi
elif [ "$DATASET" == "zinc" ]; then
    if [ "$MODE" == "baseline" ]; then
        python src/train_zinc_baseline.py
    elif [ "$MODE" == "conditional" ]; then
        python src/train_zinc_conditional.py
    else
        echo "Invalid mode: $MODE"
        exit 1
    fi
else
    echo "Invalid dataset: $DATASET"
    exit 1

fi