# Starfish Analysis Project

**Goal:** Identify giant mobile genetic elements (Starships) in a fungal genome. For this particular project, I will be using the genome of an endophyte isolated from *Plantago lanceolata* of an unknown species in the *Pyronemataceae* family.  
**Location:** OSC Pitzer cluster, project path: `/fs/ess/PAS2880/users/kstarr791/final_project/`
**Software Source:** [Starfish GitHub Repository](`https://github.com/egluckthaler/starfish/wiki`)

## Data
*   **Genome Assembly:** `BUSCO_P_DX_prelim_2008299642.scaffolds.fasta`
*   **Gene Annotation:** `BUSCO_P_DX_prelim_2008299642.final.gff3` 

## Analysis Workflow:

## 1.  **Setup**: 
Software is obtained via apptainer container (`apptainer pull starfish.sif oras://ghcr.io/egluckthaler/starfish:latest`)

---
## 2. **Input Preparation**: 
Genome and annotation files are placed in the appropriate directories and formatted as needed. The genome assembly must end in `.final.fasta` (and is found in `final_project/analysis/assembly`) and the annotation file in `.final.gff3` (found in `final_project/analysis/gff3`). 

 Create ome2*.txt files detailing the absolute path to each genome's gff3 and assembly. These serve as control files used by multiple commands to find input data:

    ```
    realpath assembly/* | perl -pe 's/^(.+?([^\/]+?).fasta)$/\2\t\1/' > ome2assembly.txt
    realpath gff3/* | perl -pe 's/^(.+?([^\/]+?).final.gff3)$/\2\t\1/' > ome2gff.txt
    ```

Make a blastn database for easy sequence searching:

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

---
## 3.  **Gene Finder Module:** 
Identifies candidate 'captain' genes (tyrosine recombinases).

`gene_finder.sh` contains the script for this module, it is located in `/scripts` 

```
# make executable. 
chmod +x scripts/gene_finder.sh
```

```
# Execute
sbatch scripts/gene_finder.sh
```

```
# Check status
squeue -u $USER
```

### Consolidate
`scripts/consolidate.sh` is the slurm script. 
Job will be submitted as above using `sbatch scripts/consolidate.sh`

### Sketch

```
cd analysis
apptainer exec ../software/containers/starfish.sif /opt/conda/envs/starfish/bin/starfish sketch \
    -m 10000 \
    -q geneFinder/BUSCO_tyr.filt.ids \
    -g ome2consolidatedGFF.txt \
    -i s \
    -x BUSCO \
    -o geneFinder/
```
This was a simple chain of commands, but it can also be prepared as a slurm script like `gene_finder` and `consolidate` before. New files should be generated in the `geneFinder/` dir with suffixes .bed and .mat.

Gene Finder Module is now complete.

4.  **Element Finder Module:** Predicts mobile element boundaries around captains.



5.  **Region Finder Module:** Contextualizes elements across genomic regions.
