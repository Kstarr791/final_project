#!/bin/bash
#SBATCH --job-name=starfish_annotate
#SBATCH --account=PAS2880
#SBATCH --time=04:00:00          # Adjust time as needed, selected a large amount of time to be safe on first run. 
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4        # Must match the -T value below
#SBATCH --mem=16G
#SBATCH --output=analysis/logs/annotate_%j.out  # Logs go to analysis/logs/
#SBATCH --error=analysis/logs/annotate_%j.err   # Errors go to analysis/logs/
set -euo pipefail  # Exit on error, undefined variable, or pipeline failure

# ===== CONFIGURATION VARIABLES =====
# Project structure
PROJECT_BASE="/fs/ess/PAS2880/users/kstarr791/final_project"
ANALYSIS_DIR="${PROJECT_BASE}/analysis"
LOG_DIR="${ANALYSIS_DIR}/logs"
OUTPUT_DIR="${ANALYSIS_DIR}/geneFinder"

# Container and software
CONTAINER_PATH="${PROJECT_BASE}/software/containers/starfish.sif"
STARFISH_EXEC="/opt/conda/envs/starfish/bin/starfish"

# JOB SETUP
echo "Starting Slurm Job"
echo "Job ID: $SLURM_JOB_ID"
echo "Start Time: $(date)"
echo "Working Directory: $(pwd)"

# Ensure the output directory for logs exists (Slurm will fail silently if it doesn't)
mkdir -p "${LOG_DIR}"

# ANALYSIS 

# Navigate to analysis directory
echo "Changing to analysis directory: ${ANALYSIS_DIR}"
cd "${ANALYSIS_DIR}"

# 1. CREATE the output directory before running starfish
mkdir -p geneFinder

# 2. Run the starfish annotate command.
apptainer exec "${CONTAINER_PATH}" \
    "${STARFISH_EXEC}" annotate \
    -T 4 \
    -x BUSCO_tyr \
    -a ome2assembly.txt \
    -g ome2gff.txt \
    -p /opt/conda/envs/starfish/db/YRsuperfams.p1-512.hmm \
    -P /opt/conda/envs/starfish/db/YRsuperfamRefs.faa \
    -i tyr \
    -o "${OUTPUT_DIR}/"

# JOB COMPLETION

echo "Job finished successfully at: $(date)"