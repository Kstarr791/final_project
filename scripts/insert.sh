#!/bin/bash
#SBATCH --job-name=starfish_insert
#SBATCH --account=PAS2880
#SBATCH --time=06:00:00          # This step involves BLAST searches, allocate more time
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --output=analysis/logs/insert_%j.out
#SBATCH --error=analysis/logs/insert_%j.err

set -euo pipefail

# ===== CONFIGURATION VARIABLES =====
# Project structure
PROJECT_BASE="/fs/ess/PAS2880/users/kstarr791/final_project"
ANALYSIS_DIR="${PROJECT_BASE}/analysis"
LOG_DIR="${ANALYSIS_DIR}/logs"
OUTPUT_DIR="${ANALYSIS_DIR}/elementFinder_sensitive"

# Container and software
CONTAINER_PATH="${PROJECT_BASE}/software/containers/starfish.sif"
STARFISH_EXEC="/opt/conda/envs/starfish/bin/starfish"

cd "${ANALYSIS_DIR}"

# Use a CLEAN output directory
mkdir -p "${OUTPUT_DIR}"

echo "=== Starting Element Finder (insert) Job ==="
echo "Job ID: $SLURM_JOB_ID"
echo "Start Time: $(date)"# Run starfish insert
apptainer exec "${CONTAINER_PATH}" \
    "${STARFISH_EXEC}" insert \
    -T 2 \
    -a ome2assembly.txt \
    -d blastdb/BUSCO_P_DX_prelim_2008299642.assemblies \
    -b geneFinder/BUSCO.bed \
    -i tyr \
    -x BUSCO \
    -o "${OUTPUT_DIR}"

echo "Job finished successfully at: $(date)"