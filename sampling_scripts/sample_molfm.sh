#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <path_to_checkpoints> <mode>"
    echo "Modes: baseline, conditional"
    exit 1
fi

CHECKPOINTS=$1
MODE=$2

conda activate bio-diffusion

cp ../datasets_config.py ../efm_gen/configs/datasets_config.py
cd ../efm_gen

if [ "$MODE" == "baseline" ]; then
    python eval_sample.py --model_path $CHECKPOINTS --n_samples 1000
elif [ "$MODE" == "conditional" ]; then
    python eval_conditional_qm9.py --generators_path $CHECKPOINTS --property scramble --n_sweeps 1000 --task qualitative
else
    echo "Invalid mode: $MODE"
    exit 1
fi