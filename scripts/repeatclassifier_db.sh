#!/bin/bash
#SBATCH --job-name=repeatclassifier_db_build
#SBATCH --account=PAS2880
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --output=/fs/ess/PAS2880/users/kstarr791/final_project/analysis/logs/repeatclassifier_db_%j.out  # ABSOLUTE PATH
#SBATCH --error=/fs/ess/PAS2880/users/kstarr791/final_project/analysis/logs/repeatclassifier_db_%j.err

# OPTIONAL script to build BLAST DB for RepeatClassifier and run it *before* re-running RepeatClassifier.

set -euo pipefail
echo "=== Starting RepeatClassifier with BLAST DB BUILD ==="
echo "Job ID: $SLURM_JOB_ID"
echo "Start Time: $(date)"

# ===== CONFIGURATION VARIABLES =====
PROJECT_BASE="/fs/ess/PAS2880/users/kstarr791/final_project"  # Changed from PROJECT_DIR
CONDA_ENV="repeatmodeler_env"
REPEATMASKER_LIB_DIR="/users/PAS1046/kstarr791/.conda/envs/${CONDA_ENV}/share/RepeatMasker/Libraries"
REPEATMODELER_DIR="${PROJECT_BASE}/analysis/RepeatModeler"  # Changed from PROJECT_DIR
LOG_DIR="${PROJECT_BASE}/analysis/logs"
# ===================================

module load miniconda3/24.1.2-py310
conda activate "${CONDA_ENV}"

# Create log directory
mkdir -p "${LOG_DIR}"

echo "1. Navigating to RepeatModeler directory: ${REPEATMODELER_DIR}"
cd "${REPEATMODELER_DIR}"

echo "2. Creating proper BLAST database from existing library..."
echo "Library directory: ${REPEATMASKER_LIB_DIR}"
cd "${REPEATMASKER_LIB_DIR}"

# Check what library files we have
echo "Available library files:"
ls -la RepeatMaskerLib.embl Dfam.embl

# Use the EMBL library file to create BLAST database
if [[ -f "RepeatMaskerLib.embl" ]]; then
    echo "Creating BLAST database from RepeatMaskerLib.embl..."
    # Convert EMBL to FASTA for makeblastdb
    perl -ne 'if(/^ID\s+(\S+)/){$id=$1} if(/^SQ/){$in_seq=1; print ">$id\n"; next} if(/^\/\//){$in_seq=0} if($in_seq && !/^SQ/){s/\s+//g; print}' RepeatMaskerLib.embl > RepeatMasker.lib.fa
    
    # Create BLAST database
    makeblastdb -in RepeatMasker.lib.fa -dbtype nucl -out RepeatMasker.lib
    echo "BLAST database created successfully"
elif [[ -f "Dfam.embl" ]]; then
    echo "Creating BLAST database from Dfam.embl..."
    perl -ne 'if(/^ID\s+(\S+)/){$id=$1} if(/^SQ/){$in_seq=1; print ">$id\n"; next} if(/^\/\//){$in_seq=0} if($in_seq && !/^SQ/){s/\s+//g; print}' Dfam.embl > RepeatMasker.lib.fa
    makeblastdb -in RepeatMasker.lib.fa -dbtype nucl -out RepeatMasker.lib
    echo "BLAST database created successfully"
else
    echo "ERROR: No EMBL library file found!" >&2
    echo "Available files:" >&2
    ls -la >&2
    exit 1
fi

echo "3. Verifying BLAST database was created..."
ls -la RepeatMasker.lib.n*

echo "4. Returning to RepeatModeler directory and verifying input files..."
cd "${REPEATMODELER_DIR}"

CONSENSI_FILE="consensi.fa"
STOCKHOLM_FILE="families.stk"

if [[ ! -f "${CONSENSI_FILE}" ]]; then
    echo "ERROR: ${CONSENSI_FILE} not found in ${REPEATMODELER_DIR}!" >&2
    exit 1
fi

if [[ ! -f "${STOCKHOLM_FILE}" ]]; then
    echo "ERROR: ${STOCKHOLM_FILE} not found in ${REPEATMODELER_DIR}!" >&2
    exit 1
fi

echo "5. Input file sizes:"
ls -lh "${CONSENSI_FILE}" "${STOCKHOLM_FILE}"

echo "6. Starting RepeatClassifier..."
RepeatClassifier -consensi "${CONSENSI_FILE}" -stockholm "${STOCKHOLM_FILE}"

echo "7. Checking results..."
CLASSIFIED_FILE="consensi.fa.classified"
if [[ -f "${CLASSIFIED_FILE}" ]]; then
    echo "=== SUCCESS: RepeatClassifier completed! ==="
    echo "Output file: ${CLASSIFIED_FILE}"
    FAMILY_COUNT=$(grep -c '^>' "${CLASSIFIED_FILE}" 2>/dev/null || echo "0")
    echo "Number of classified families: ${FAMILY_COUNT}"
    echo "First few classifications:"
    grep "^>" "${CLASSIFIED_FILE}" | head -10
else
    echo "WARNING: ${CLASSIFIED_FILE} not created." >&2
    echo "Check error log for details." >&2
    echo "Files in directory:"
    ls -la
fi

echo "End Time: $(date)"