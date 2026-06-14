#!/bin/bash
#SBATCH --ntasks-per-node 16
#SBATCH -J of3_grp
#SBATCH -o run_grp_test.out
#SBATCH -e run_grp_test.err
#SBATCH -p q3
#SBATCH --gres=gpu:1
set -e
cd "${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
PIXI="${PIXI:-$([ -x ../.pixi-bin/pixi ] && echo ../.pixi-bin/pixi || echo pixi)}"
export PATH="$HOME/.local/bin:$PATH"
export OPENFOLD_CACHE="${OPENFOLD_CACHE:-$HOME/.openfold3}"
rm -rf out_grp_test
"$PIXI" run -e openfold3-cuda12 run_openfold predict --query-json grp_test.json --output-dir out_grp_test --num-diffusion-samples 1 --use-msa-server false --use-templates false > run_grp_test.log 2>&1 || { echo "of3 FAILED:"; tail -n 40 run_grp_test.log; exit 1; }
grep -iE "built spec|setup:|finalize" run_grp_test.log || true
CIF=$(find out_grp_test -name '*.cif' | head -1); echo "CIF: $CIF"
GP=../chai-lab_restr/.venv/bin/python
"$GP" ../check_angle.py "$CIF" 5-84 90-180 186-224 || true
"$GP" ../check_dihedral.py "$CIF" 5-50 51-100 101-150 151-224 || true
echo done
