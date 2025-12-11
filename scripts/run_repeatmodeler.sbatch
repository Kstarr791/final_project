#!/bin/bash
#SBATCH --job-name=repeatmodeler
#SBATCH --account=PAS2880
#SBATCH --time=18:00:00     # Your target: 18 hours
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32  # Increased to 32 cores for parallel speed
#SBATCH --mem=96G           # Slightly increased memory for more threads
#SBATCH --output=analysis/logs/repeatmodeler_%j.out
#SBATCH --error=analysis/logs/repeatmodeler_%j.err

set -euo pipefail
echo "=== Starting RepeatModeler (Optimized) ==="
echo "Job ID: $SLURM_JOB_ID | Genome: ~126 Mbp"
echo "Start Time: $(date)"

# Load and activate Conda
module load miniconda3/24.1.2-py310
conda activate repeatmodeler_env

cd /fs/ess/PAS2880/users/kstarr791/final_project/analysis/assembly

echo "1. Building database..."
BuildDatabase -name "BUSCO_repeats_fast" -engine ncbi BUSCO_P_DX_prelim_2008299642.scaffolds.fasta

echo "2. Running RepeatModeler with $SLURM_CPUS_PER_TASK cores (-pa $((SLURM_CPUS_PER_TASK / 4)))..."
RepeatModeler -database BUSCO_repeats_fast -pa $((SLURM_CPUS_PER_TASK / 4)) 2>&1 | tee repeatmodeler_fast.log
echo "Job finished at: $(date)"