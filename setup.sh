#!/bin/bash
set -e

ENV_NAME="nougat"
CONDA_CMD="conda"
MODEL_DIR=""

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -n|--name) ENV_NAME="$2"; shift ;;
        -m|--model-dir) MODEL_DIR="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

echo "========================================"
echo "Nougat Environment Setup Script"
echo "========================================"

# Check if conda is available
if ! command -v $CONDA_CMD &> /dev/null; then
    echo "Error: 'conda' command not found."
    echo "Please ensure Conda is installed and initialized."
    exit 1
fi

# Check if environment exists
if $CONDA_CMD env list | grep -q "^$ENV_NAME "; then
    echo "Environment '$ENV_NAME' already exists."
    read -p "Do you want to remove it and reinstall? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing environment..."
        $CONDA_CMD env remove -n $ENV_NAME
    else
        echo "Skipping environment creation."
    fi
fi

# Create environment if it doesn't exist
if ! $CONDA_CMD env list | grep -q "^$ENV_NAME "; then
    echo "Creating conda environment from environment.yml..."
    $CONDA_CMD env create -f environment.yml -n "$ENV_NAME"
fi

# Configure Model Directory if provided
if [ -n "$MODEL_DIR" ]; then
    echo "Configuring custom model directory: $MODEL_DIR"
    mkdir -p "$MODEL_DIR"
    # Set TORCH_HOME to the parent of the model dir so that hub/nougat ends up in the right place?
    # Actually, torch.hub.get_dir() defaults to $TORCH_HOME/hub.
    # If user gives /data/models, they probably want the models IN /data/models.
    # But torch hub enforces a structure.
    # If we set TORCH_HOME=/data/models, models go to /data/models/hub/nougat-...
    # This is probably fine.
    
    echo "Setting TORCH_HOME environment variable in conda env..."
    $CONDA_CMD env config vars set TORCH_HOME="$MODEL_DIR" -n $ENV_NAME
    
    echo "Note: Models will be stored in $MODEL_DIR/hub/nougat-..."
fi

echo "Configuring environment isolation..."
# Ensure user site packages are ignored to prevent dependency conflicts
$CONDA_CMD env config vars set PYTHONNOUSERSITE=1 -n "$ENV_NAME"

echo "Installing pip dependencies from requirements.txt..."
# Using conda run to execute pip within the environment
# We explicitly set PYTHONNOUSERSITE=1 here to ensure it applies immediately during install
PYTHONNOUSERSITE=1 $CONDA_CMD run -n "$ENV_NAME" pip install -r requirements.txt

echo "Applying patches to nougat installation..."
$CONDA_CMD run -n "$ENV_NAME" python apply_patches.py

echo "========================================"
echo "Setup Complete!"
echo "========================================"
echo "To use the environment, run:"
echo "  conda activate $ENV_NAME"
echo ""
echo "To run the API:"
echo "  nougat_api --host 127.0.0.1 --port 8503"
