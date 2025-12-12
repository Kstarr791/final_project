#!/bin/bash
#SBATCH --job-name=starfish_consolidate
#SBATCH --account=PAS2880
#SBATCH --time=01:00:00          # This step should be very quick
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --output=analysis/logs/consolidate_%j.out
#SBATCH --error=analysis/logs/consolidate_%j.err
set -euo pipefail

# ===== CONFIGURATION VARIABLES =====
# Project structure
PROJECT_BASE="/fs/ess/PAS2880/users/kstarr791/final_project"
ANALYSIS_DIR="${PROJECT_BASE}/analysis"
LOG_DIR="${ANALYSIS_DIR}/logs"
OUTPUT_DIR="${ANALYSIS_DIR}/consolidate"

# Container and software
CONTAINER_PATH="${PROJECT_BASE}/software/containers/starfish.sif"
STARFISH_EXEC="/opt/conda/envs/starfish/bin/starfish"

# JOB SETUP
echo "=== Starting Consolidation Job ==="
echo "Job ID: $SLURM_JOB_ID"
echo "Start Time: $(date)"
echo "Working Directory: $(pwd)"

# Ensure the log directory exists or it could fail silently
mkdir -p "${LOG_DIR}"

# CORE ANALYSIS: CONSOLIDATE ANNOTATIONS

# Navigate to the analysis directory
cd "${ANALYSIS_DIR}"

echo "Running: starfish consolidate"
apptainer exec "${CONTAINER_PATH}" \
    "{$STARFISH_EXEC}" consolidate \
    -o "${OUTPUT_DIR}/" \
    -g gff3/BUSCO_P_DX_prelim_2008299642.final.gff3 \
    -G geneFinder/BUSCO_tyr.filt.gff

echo "Consolidate command finished."

# CREATE NEW CONTROL FILE

echo "Creating new control file: ome2consolidatedGFF.txt"

# Use the consolidated GFF file that was just created
realpath BUSCO_tyr.filt.consolidated.gff | perl -pe 's/^/BUSCO_P_DX_prelim_2008299642\t/' > ome2consolidatedGFF.txt

# Verify the file was created
echo "New control file preview:"
cat ome2consolidatedGFF.txt

# JOB COMPLETION

echo "Job finished successfully at: $(date)"
echo "Consolidated GFF: tyr.filt.consolidated.gff"
echo "New GFF index: ome2consolidatedGFF.txt" 