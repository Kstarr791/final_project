#!/bin/bash
#SBATCH --job-name=repeatmasker
#SBATCH --account=PAS2880
#SBATCH --time=12:00:00      # 12 hours - safe for mapping & slow with custom lib
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8    # RepeatMasker scales moderately well
#SBATCH --mem=32G            # 32 GB should be ample
#SBATCH --output=analysis/logs/repeatmasker_%j.out
#SBATCH --error=analysis/logs/repeatmasker_%j.err

# This is an OPTIONAL script to run RepeatMasker with general library, WIP


set -euo pipefail
echo "=== Starting RepeatMasker ==="
echo "Job ID: $SLURM_JOB_ID"
echo "Start Time: $(date)"

module load miniconda3/24.1.2-py310
conda activate repeatmodeler_env

cd /fs/ess/PAS2880/users/kstarr791/final_project/analysis/assembly/RM_2529430.ThuDec110211332025

# Create output directory
mkdir -p repeat_annotations

echo "Starting RepeatMasker with custom library..."
RepeatMasker -lib consensi.fa \
             -gff \
             -dir ./repeat_annotations \
             -engine rmblast \
             ../BUSCO_P_DX_prelim_2008299642.scaffolds.fasta

echo "RepeatMasker finished. GFF file in: repeat_annotations/"