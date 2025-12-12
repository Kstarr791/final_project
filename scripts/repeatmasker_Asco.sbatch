#!/bin/bash
#SBATCH --job-name=repeatmasker
#SBATCH --account=PAS2880
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --output=analysis/logs/repeatmasker_%j.out
#SBATCH --error=analysis/logs/repeatmasker_%j.err

set -euo pipefail
echo "=== Starting RepeatMasker (Ascomycota-specific) ==="
echo "Job ID: $SLURM_JOB_ID"
echo "Start Time: $(date)"

module load miniconda3/24.1.2-py310
conda activate repeatmodeler_env

# Change to your working directory
cd /fs/ess/PAS2880/users/kstarr791/final_project/analysis/assembly/RM_2529430.ThuDec110211332025

# Create output directory (optional - RepeatMasker's -dir will create it)
OUTPUT_DIR="./repeat_annotations_ascomycota"
mkdir -p "${OUTPUT_DIR}"

INPUT_GENOME="../BUSCO_P_DX_prelim_2008299642.scaffolds.fasta"

echo "Starting RepeatMasker with species='ascomycota'..."
RepeatMasker -pa 8 \
             -species "ascomycota" \
             -gff \
             -a \
             -no_is \
             -engine rmblast \
             -dir "${OUTPUT_DIR}" \
             "${INPUT_GENOME}"

echo "=== RepeatMasker finished successfully ==="
echo "End Time: $(date)"
echo "Main output files are in: ${OUTPUT_DIR}/"
echo "  - .out: Tabular annotation"
echo "  - .gff: GFF format annotations"
echo "  - .masked: Masked genome sequence"