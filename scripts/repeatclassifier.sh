#!/bin/bash
#SBATCH --job-name=repeatclassifier
#SBATCH --account=PAS2880
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --output=/fs/ess/PAS2880/users/kstarr791/final_project/analysis/logs/repeatclassifier_%j.out  # ABSOLUTE PATH
#SBATCH --error=/fs/ess/PAS2880/users/kstarr791/final_project/analysis/logs/repeatclassifier_%j.err

#This is an OPTIONAL script to attempt RepeatClassifier, WIP

set -euo pipefail
echo "=== Starting RepeatClassifier Resume ==="
echo "Job ID: $SLURM_JOB_ID"
echo "Start Time: $(date)"
echo "Working directory: $(pwd)"

module load miniconda3/24.1.2-py310
conda activate repeatmodeler_env

# ===== CONFIGURATION VARIABLES =====
PROJECT_BASE="/fs/ess/PAS2880/users/kstarr791/final_project"
REPEATMODELER_DIR="${PROJECT_BASE}/analysis/RepeatModeler"  # Where your files ARE
REPEATMASKER_LIB_DIR="/users/PAS1046/kstarr791/.conda/envs/repeatmodeler_env/share/RepeatMasker/Libraries"
LOG_DIR="${PROJECT_BASE}/analysis/logs"
# ===================================

# Create log directory
mkdir -p "${LOG_DIR}"

echo "1. Navigating to RepeatModeler directory: ${REPEATMODELER_DIR}"
cd "${REPEATMODELER_DIR}"

echo "2. Fixing missing BLAST database files..."
# These need to be in the RepeatMasker library directory
cd "${REPEATMASKER_LIB_DIR}"
touch RepeatMasker.lib.nsq RepeatMasker.lib.nin RepeatMasker.lib.nhr
echo "Created in: $(pwd)"
ls -la RepeatMasker.lib.n*

echo "3. Returning to RepeatModeler directory and checking files..."
cd "${REPEATMODELER_DIR}"

if [[ ! -f "consensi.fa" ]]; then
    echo "ERROR: consensi.fa not found in ${REPEATMODELER_DIR}!" >&2
    exit 1
fi

if [[ ! -f "families.stk" ]]; then
    echo "ERROR: families.stk not found in ${REPEATMODELER_DIR}!" >&2
    exit 1
fi

echo "4. Input file sizes:"
ls -lh consensi.fa families.stk

echo "5. Starting RepeatClassifier..."
RepeatClassifier -consensi consensi.fa -stockholm families.stk

echo "6. Checking results..."
if [[ -f "consensi.fa.classified" ]]; then
    echo "=== SUCCESS: RepeatClassifier completed! ==="
    echo "Output file: $(pwd)/consensi.fa.classified"
    FAMILY_COUNT=$(grep -c '^>' consensi.fa.classified 2>/dev/null || echo "0")
    echo "Number of classified families: ${FAMILY_COUNT}"
else
    echo "WARNING: consensi.fa.classified not created in ${REPEATMODELER_DIR}" >&2
    echo "Files present:" >&2
    ls -la >&2
fi

echo "End Time: $(date)"