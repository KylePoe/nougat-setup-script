# Nougat Installation & Setup

This directory contains scripts produce a working [Nougat](https://github.com/facebookresearch/nougat) environment.

## Contents

*   `setup.sh`: The main installation script.
*   `environment.yml`: Conda environment definition (Python, PyTorch, CUDA).
*   `requirements.txt`: Python package dependencies (Nougat, Transformers, API).
*   `apply_patches.py`: Script to apply necessary fixes to the `nougat` source code.

## Installation

1.  Ensure you have Conda installed.
2.  Run the setup script:

    ```bash
    ./setup.sh
    ```

    **Optional: Custom Environment Name**
    To specify a custom name for the conda environment (default is `nougat`), use the `--name` flag:

    ```bash
    ./setup.sh --name my_nougat_env
    ```

    **Optional: Custom Model Directory**
    To specify a custom directory for storing model weights (instead of `~/.cache/torch`), use the `--model-dir` flag:

    ```bash
    ./setup.sh --model-dir /path/to/shared/storage
    ```

    This will:
    *   Create a conda environment named `nougat` (or the name you specified).
    *   Install PyTorch 2.5.1 with CUDA 11.8.
    *   Install Nougat and its dependencies.
    *   Apply critical patches for `pypdfium2` compatibility and API stability.
    *   (If specified) Configure the environment to store models in the provided directory.

## Usage

Activate the environment:

```bash
conda activate nougat
```

### CLI Usage

```bash
nougat input.pdf --out output_dir --model 0.1.0-base
```

### API Usage

Start the server:

```bash
nougat_api --host 127.0.0.1 --port 8503
```

## Notes

*   **Model Weights**: The first time you run Nougat, it will download model weights to `~/.cache/torch/hub/`. If you have limited home directory space, consider moving this folder to a larger partition and symlinking it back.
*   **Segfaults**: You may see a `Segmentation fault` at the very end of execution. This is a known issue with library cleanup and does not affect the output.
