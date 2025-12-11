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

echo "=== Starting Element Finder (insert) Job ==="
echo "Job ID: $SLURM_JOB_ID"
echo "Start Time: $(date)"

cd /fs/ess/PAS2880/users/kstarr791/final_project/analysis

# Create output directory, if it doesn't exist
mkdir -p elementFinder

# Run starfish insert
apptainer exec ../software/containers/starfish.sif /opt/conda/envs/starfish/bin/starfish insert \
    -T 2 \
    -a ome2assembly.txt \
    -d blastdb/BUSCO_P_DX_prelim_2008299642.assemblies \
    -b geneFinder/BUSCO.bed \
    -i tyr \
    -x BUSCO \
    -o elementFinder/

echo "Job finished successfully at: $(date)"