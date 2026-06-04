#!/bin/bash
#SBATCH --ntasks-per-node 16
#SBATCH -J of3_ex
#SBATCH -o run_restr_example.out
#SBATCH -e run_restr_example.err
#SBATCH -p q1
#SBATCH --gres=gpu:1
# openfold-3 RGI example runner (pixi env). GPU work must go through sbatch.
# Submit from THIS repo directory:  cd openfold-3_restr && sbatch run_restr_example.sh
set -e
cd "${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# pixi.toml needs pixi >=0.68; the system pixi may be older. Prefer a fresh binary if the
# workspace ships one (../.pixi-bin/pixi), else fall back to PATH. Override with PIXI=...
PIXI="${PIXI:-$([ -x ../.pixi-bin/pixi ] && echo ../.pixi-bin/pixi || echo pixi)}"
export PATH="$HOME/.local/bin:$PATH"
export OPENFOLD_CACHE="${OPENFOLD_CACHE:-$HOME/.openfold3}"

rm -rf out_restr_example
# restr_example.json carries `restraints_config` per query. RGI: rgi_utils minimizes
# distance + conformer restraints on the x0 prediction each diffusion step.
"$PIXI" run -e openfold3-cuda12 run_openfold predict \
    --query-json restr_example.json \
    --output-dir out_restr_example \
    --num-diffusion-samples 2 --use-msa-server false --use-templates false

CIF=$(find out_restr_example -name '*.cif' | head -1)
echo "prediction: $CIF"
echo done
