#!/bin/bash
#SBATCH --job-name=starfish_insert_sensitive
#SBATCH --account=PAS2880
#SBATCH --time=04:00:00           # Reduced from 12 hours. Will start smaller.
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2         # Matches the command's -T 2 flag.
#SBATCH --mem=8G                  # Reduced from 16G; BLAST is not extremely memory-heavy for your dataset.
#SBATCH --output=analysis/logs/insert_sensitive_%j.out
#SBATCH --error=analysis/logs/insert_sensitive_%j.err

set -euo pipefail

cd /fs/ess/PAS2880/users/kstarr791/final_project/analysis

# Use a CLEAN output directory
OUT_DIR="elementFinder_sensitive"
mkdir -p $OUT_DIR

# We are removing the flankcov option which was flagged

echo "=== Starting SENSITIVE Element Finder Search ==="
echo "Genome context: Novel, phylogenetically divergent"
echo "Parameters set for high sensitivity (low pid, short hsp)"
apptainer exec ../software/containers/starfish.sif /opt/conda/envs/starfish/bin/starfish insert \
    -T 2 \
    -a ome2assembly.txt \
    -d blastdb/BUSCO_P_DX_prelim_2008299642.assemblies \
    -b geneFinder/BUSCO.bed \
    -i tyr \
    -x BUSCO_sensitive \
    -o elementFinder_sensitive \
    --pid 50 \
    --hsp 200 \
    --upstream 0-20000 \
    --downstream 0-15000

    echo "Job finished at: $(date)"