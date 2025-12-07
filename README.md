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
    cp assembly/BUSCO_P_DX_prelim_2008299642.scaffolds.fasta blastdb/BUSCO_P_DX_prelim_2008299642.assemblies.fna
    ```

    Build the BLAST database INSIDE the Apptainer container.
    ```
    # This is a light computation, safe for the login node.
    apptainer exec ../software/containers/starfish.sif makeblastdb \
    -in blastdb/BUSCO_P_DX_prelim_2008299642.assemblies.fna \
    -out blastdb/BUSCO_P_DX_prelim_2008299642.assemblies \
    -parse_seqids \
    -dbtype nucl
    ```

    If annotating Starships on a per-genome level, the focal genome must be included in the blast database

    (Optional) Calculate GC content using the container's script.
    ```
    # This is also safe for the login node.
    apptainer exec ../software/containers/starfish.sif /opt/conda/envs/starfish/aux/seq-gc.sh \
    -Nbw 1000 \
    blastdb/BUSCO_P_DX_prelim_2008299642.assemblies.fna \
    > BUSCO_P_DX_prelim_2008299642.assemblies.gcContent_w1000.bed
    ```

3.  **Gene Finder Module:** Identifies candidate 'captain' genes (tyrosine recombinases).

    ```
    #!/bin/bash
    #SBATCH --job-name=starfish_annotate
    #SBATCH --account=PAS2880
    #SBATCH --time=04:00:00          # Adjust time as needed
    #SBATCH --nodes=1
    #SBATCH --cpus-per-task=4        # Must match the -T value below
    #SBATCH --mem=16G
    #SBATCH --output=logs/annotate_%j.out
    #SBATCH --error=logs/annotate_%j.err

    # Navigate to your analysis directory
    cd /fs/ess/PAS2880/users/kstarr791/final_project/analysis

    # Ensure output directory exists
    mkdir -p geneFinder

    # Run the starfish annotate command from the container
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
    ```

4.  **Element Finder Module:** Predicts mobile element boundaries around captains.



5.  **Region Finder Module:** Contextualizes elements across genomic regions.
