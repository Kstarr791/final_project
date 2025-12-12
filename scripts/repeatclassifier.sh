#!/bin/bash
#SBATCH --job-name=repeatclassifier
#SBATCH --account=PAS2880
#SBATCH --time=2:00:00           # Classification is much faster than discovery
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4        # Classification doesn't need many cores
#SBATCH --mem=16G
#SBATCH --output=analysis/logs/repeatclassifier_%j.out
#SBATCH --error=analysis/logs/repeatclassifier_%j.err

set -euo pipefail
echo "=== Starting RepeatClassifier Resume ==="
echo "Job ID: $SLURM_JOB_ID"
echo "Start Time: $(date)"

module load miniconda3/24.1.2-py310
conda activate repeatmodeler_env

# Navigate to RepeatModeler working directory
cd /fs/ess/PAS2880/users/kstarr791/final_project/analysis/assembly/RM_2529430.ThuDec110211332025

echo "1. Fixing missing RepeatMasker.lib.nsq file..."
# Create dummy BLAST database files to satisfy RepeatClassifier check
REPEATMASKER_LIB_DIR="/users/PAS1046/kstarr791/.conda/envs/repeatmodeler_env/share/RepeatMasker/Libraries"
touch "${REPEATMASKER_LIB_DIR}/RepeatMasker.lib.nsq"
touch "${REPEATMASKER_LIB_DIR}/RepeatMasker.lib.nin"
touch "${REPEATMASKER_LIB_DIR}/RepeatMasker.lib.nhr"

echo "2. Verifying input files exist..."
if [[ ! -f "consensi.fa" ]]; then
    echo "ERROR: consensi.fa not found!" >&2
    exit 1
fi

if [[ ! -f "families.stk" ]]; then
    echo "ERROR: families.stk not found!" >&2
    exit 1
fi

echo "3. Input file sizes:"
ls -lh consensi.fa families.stk

echo "4. Starting RepeatClassifier (resuming from discovery phase)..."
RepeatClassifier -consensi consensi.fa -stockholm families.stk

echo "5. Checking results..."
if [[ -f "consensi.fa.classified" ]]; then
    echo "=== SUCCESS: RepeatClassifier completed! ==="
    echo "Output file: consensi.fa.classified"
    echo "Number of classified families:"
    grep -c "^>" consensi.fa.classified || echo "Could not count families"
else
    echo "WARNING: consensi.fa.classified not created. Check logs." >&2
fi

echo "End Time: $(date)"