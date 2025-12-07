# Starfish Analysis Project

**Goal:** Identify giant mobile genetic elements (Starships) in a fungal genome. For this particular project, I will be using the genome of an endophyte isolated from *Plantago lanceolata* of an unknown species in the *Pyronemataceae* family.  
**Location:** OSC Pitzer cluster, project path: `/fs/ess/PAS2880/users/kstarr791/final_project/`
**Software Source:** [Starfish GitHub Repository](`https://github.com/egluckthaler/starfish/wiki`)

## Data
*   **Genome Assembly:** `BUSCO_P_DX_prelim_2008299642.scaffolds.fasta`
*   **Gene Annotation:** `BUSCO_P_DX_prelim_2008299642.final.gff3`

## Analysis Workflow
1.  **Setup**: Software is obtained via apptainer container (`apptainer pull starfish.sif oras://ghcr.io/egluckthaler/starfish:latest`)
2. **Input Preparation**: Genome and annotation files are placed in the appropriate directories and formatted as needed. The genome assembly must end in `.final.fasta` and the annotation file in `.final.gff3`.

    Create ome2*.txt files detailing the absolute path to each genome's gff3 and assembly. These serve as control files used by multiple commands to find input data:
    ```
    realpath assembly/* | perl -pe 's/^(.+?([^\/]+?).fasta)$/\2\t\1/' > ome2assembly.txt
    realpath gff3/* | perl -pe 's/^(.+?([^\/]+?).final.gff3)$/\2\t\1/' > ome2gff.txt
    ```

    make a blastn database for easy sequence searching:

    ```
    # Make a directory for the blast database, if it doesn't already exist
    mkdir -p blastdb

    # Create the BLAST database input file directly from your single assembly
    cp analysis/assembly/BUSCO_P_DX_prelim_2008299642.scaffolds.fasta analysis/blastdb/BUSCO_P_DX_prelim_2008299642.assemblies.fna
    ```

    Build the BLAST database inside the Apptainer container.
    ```
    # This is a light computation, safe for the login node.
    apptainer exec software/containers/starfish.sif makeblastdb \
    -in analysis/blastdb/BUSCO_P_DX_prelim_2008299642.assemblies.fna \
    -out analysis/blastdb/BUSCO_P_DX_prelim_2008299642.assemblies \
    -parse_seqids \
    -dbtype nucl
    ```

    If annotating Starships on a per-genome level, the focal genome must be included in the blast database

    (Optional) Calculate GC content using the container's script.
    ```
    # This is also safe for the login node.
    apptainer exec software/containers/starfish.sif /opt/conda/envs/starfish/aux/seq-gc.sh \
    -Nbw 1000 \
    analysis/blastdb/BUSCO_P_DX_prelim_2008299642.assemblies.fna \
    > BUSCO_P_DX_prelim_2008299642.assemblies.gcContent_w1000.bed
    ```
    **Note** *This command failed from the apptainer version due to `"line 31: getopt: command not found"` but, thankfully this is option and can be calculated by other means.*

3.  **Gene Finder Module:** Identifies candidate 'captain' genes (tyrosine recombinases).

`gene_finder.sh` contains the script for this module. 

```
# make executable. 
chmod +x scripts/gene_finder.sh
```

```
    # Execute
    sbatch scripts/gene_finder.sh
```

The script is below: 
    ```
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

    # JOB SETUP
    echo "Starting Slurm Job"
    echo "Job ID: $SLURM_JOB_ID"
    echo "Start Time: $(date)"
    echo "Working Directory: $(pwd)"

    # Ensure the output directory for logs exists (Slurm will fail silently if it doesn't)
    mkdir -p analysis/logs

    # ANALYSIS 

    # Navigate to the analysis directory. This ensures all relative paths are correct.
    cd /fs/ess/PAS2880/users/kstarr791/final_project/analysis

    # Run the starfish annotate command.
    # The '-o geneFinder/' will create 'analysis/geneFinder/' as the result directory.
    apptainer exec ../software/containers/starfish.sif \
        /opt/conda/envs/starfish/bin/starfish annotate \
        -T 4 \
        -x BUSCO_tyr \
        -a ome2assembly.txt \
        -g ome2gff.txt \
        -p /opt/conda/envs/starfish/db/YRsuperfams.p1-512.hmm \
        -P /opt/conda/envs/starfish/db/YRsuperfamRefs.faa \
        -i tyr \
        -o geneFinder/

    # JOB COMPLETION

    echo "Job finished successfully at: $(date)"
    ```

    ```
    # Check status
    squeue -u $USER
    ```

4.  **Element Finder Module:** Predicts mobile element boundaries around captains.



5.  **Region Finder Module:** Contextualizes elements across genomic regions.
