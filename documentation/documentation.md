## Getting Started

See README.md for an overview of the project goals, data, and analysis workflow step by step.

I will start with the installation page of the github for the Starfish suite of tools. (https://github.com/egluckthaler/starfish/wiki/Installation) 

For installation, I will try the apptainer option, since that is what we have been working with the most in the class:
```
apptainer pull starfish.sif oras://ghcr.io/egluckthaler/starfish:latest
```


 First, I will set up some folders under Final_Project to try to start out organized.
 I will use /software, /software/containers, /data, /scripts, /documentation
 

 Now I will cd into software/containers and try to pull the apptainer image there. 

It appears to be working, but it does say that it will take 1 hour. I will let it run and check back later.

It seems to have worked. I will set up a github repository for this project and try to test the apptainer's installation.

Unfortunately, I started my github repository while my pwd was final_project/software/containers. 
When I then tried to start back up at /final_project, two levels up, I got errors about nested repositories.
I consulted DeepSeek AI to remedy this situation. Its recommendations:

```
# Step 1: Verify the nested repo exists:
# From your project root
cd /fs/ess/PAS2880/users/kstarr791/final_project

# Check for multiple .git directories
find . -name ".git" -type d

# You should see at least two: ./.git and ./software/containers/.git
```
True, I do see both.

```
# Step 2: Remove the nested .git directory:

# Remove the accidental git repository
rm -rf software/containers/.git

# Verify it's gone
find . -name ".git" -type d
# Should now only show: ./.git
```

Also true, that is what I see. 

The recommendation from DeepSeek for testing the apptainer is this:
```
# Test if the container is valid and can run
apptainer exec starfish.sif echo "Hello from Starfish container!"
```

The output:

```
[kstarr791@p0219 final_project]$ cd software/containers/
[kstarr791@p0219 containers]$ apptainer exec starfish.sif echo "Hello from Starfish container!"
INFO:    gocryptfs not found, will not be able to use gocryptfs
source: /opt/conda/envs/starfish/etc/conda/activate.d/activate-binutils_linux-64.sh:10:40: parameter expansion requires a literal
source: /opt/conda/envs/starfish/etc/conda/activate.d/activate-gcc_linux-64.sh:10:40: parameter expansion requires a literal
source: /opt/conda/envs/starfish/etc/conda/activate.d/activate-gxx_linux-64.sh:10:40: parameter expansion requires a literal
Hello from Starfish container!
```

So far so good, I think!

I also received a recommendation from DeepSeek regarding organization and set up, to make a script that sets up the environment.
I think this is a smart choice, as it seems that it will simplify some things later. Some of the recommendations are new to me, so I made sure to learn a bit more about them. 

Here is the script:

```
#!/bin/bash
# /fs/ess/PAS2880/users/kstarr791/final_project/project_env.sh

# Base directory
export PROJECT_DIR="/fs/ess/PAS2880/users/kstarr791/final_project"

# Container location (after your 1-hour download completes)
export STARFISH_CONTAINER="$PROJECT_DIR/software/containers/starfish.sif"

# Data directories
export RAW_DATA="$PROJECT_DIR/data/raw"
export PROCESSED_DATA="$PROJECT_DIR/data/processed"
export RESULTS="$PROJECT_DIR/data/results"

# Add your scripts to PATH so you can run them from anywhere
export PATH="$PROJECT_DIR/scripts:$PATH"

# Create a shortcut command for running starfish tools
alias starfish_run="apptainer exec $STARFISH_CONTAINER"
```

I'm familiar from this course with setting variables to avoid typing long file paths repeatedly, and for ease of reproducibility.
However, the export and alias functions are new to me. The export command seems to make the contents of this project more accessible and easy to move later.
This might be useful to me if I choose to move this to another project in the future for further analyses if I get Starfish working. 

I also think this might be useful, since the Starfish software seems to use conda, which I know operates on "environments" as well, so I'm wondering if this might help everything work together smoothly. I'm not sure if that is related in this way, I still need to do some learning and clarifying about what exactly environments are. 

## Preparing workspace

I have copied the 2 files for my genome assembly and annotation to /data/input

```
conda activate starfish
```
That failed with an error, and the tutorial does say that depending on how Starfish was installed, some things might vary. 

I installed this via apptainer, so I will need to recall what we did with these in previous classes.

```
# Running a Starfish command directly from the container
apptainer exec software/containers/starfish.sif /opt/conda/envs/starfish/bin/starfish --help
```

Okay, yes that worked. 

I will need to be sure that I am clarifying any deviations from the tutorial. The tutorial seems to assume that you installed via Conda. 

DeepSeek says:
"Any command in the tutorial that references $STARFISHDIR/aux/some_script.pl needs to be run inside the container and use the full path."

I think that I might need to rely on DeepSeek a fair amount due to all of these changes from the step-by-step tutorial. I intend to use the AI's responses as a way to learn as I go. 

```
# Create a clean 'test' or 'analysis' directory
mkdir -p analysis
cd analysis

# Create the required subdirectories
mkdir -p assembly gff3 blastdb

# Copy your files into the expected directory structure
cp ../data/input/BUSCO_P_DX_prelim_2008299642.scaffolds.fa assembly/
cp ../data/input/BUSCO_P_DX_prelim_2008299642.gff3 gff3/

# Rename your files to match the tutorial's expected pattern.

mv gff3/BUSCO_P_DX_prelim_2008299642.gff3 gff3/BUSCO_P_DX_prelim_2008299642.final.gff3

mv assembly/BUSCO_P_DX_prelim_2008299642.scaffolds.fa assembly/BUSCO_P_DX_prelim_2008299642.scaffolds.fasta
```
I did follow these steps exactly. 


```
# Create the ome2*.txt Control Files
# Now, run the adapted realpath commands. These commands create simple tables that starfish uses to find your data.

# Create the assembly index file
realpath assembly/* | perl -pe 's/^(.+?([^\/]+?).fasta)$/\2\t\1/' > ome2assembly.txt

# Create the GFF3 index file (note the .final.gff3 pattern)
realpath gff3/* | perl -pe 's/^(.+?([^\/]+?).final.gff3)$/\2\t\1/' > ome2gff.txt

# Check the files were created correctly
cat ome2assembly.txt
cat ome2gff.txt
```

So far so good. 

Executed commands for the BLAST database:

```
apptainer exec software/containers/starfish.sif makeblastdb \
    -in analysis/blastdb/BUSCO_P_DX_prelim_2008299642.assemblies.fna \
    -out analysis/blastdb/BUSCO_P_DX_prelim_2008299642.assemblies \
    -parse_seqids \
    -dbtype nucl
```

Files were created in `final_project/analysis/blastdb` successfully. 

Performed this step:
(Optional) Calculate GC content using the container's script.
    ```
    # This is also safe for the login node.
    apptainer exec software/containers/starfish.sif /opt/conda/envs/starfish/aux/seq-gc.sh \
    -Nbw 1000 \
    analysis/blastdb/BUSCO_P_DX_prelim_2008299642.assemblies.fna \
    > BUSCO_P_DX_prelim_2008299642.assemblies.gcContent_w1000.bed
    ```
But, it seems to not have worked. Checked with 
```
head data/intermediate/BUSCO_P_DX_prelim_2008299642.assemblies.gcContent_w1000.bed
```
No output. 
```
cat -n data/intermediate/BUSCO_P_DX_prelim_2008299642.assemblies.gcContent_w1000.bed
```
No output. 

Confirmed the file ending in assemblies.fna exists at the expected location..

Ran commands again and got this message in the terminal: "/opt/conda/envs/starfish/aux/seq-gc.sh: line 31: getopt: command not found"

This is okay, the GC content is optional, and I have already calculated this previously if I need it later. 

## Gene Finder Module

`gene_finder.sh` contains the script for this module, it is located in /scripts 

```
# make executable. 
chmod +x scripts/gene_finder.sh
```

Ready to be run, it is a slurm batch job. 

```
sbatch scripts/gene_finder.sh
```

```
# Check status
squeue -u $USER
```

Okay, good news is that the script ran fine! Bad news is that there was an error related to the file paths. I need to update the script. 

The script is updated and the job is re-submitted. The first failed attempt ran for less than 10 seconds. At present, the updated script has been running for over a minute. 

The script ran successfully this time. There are a lot of error messages in the error log (located at analysis/logs), almost 12600 lines that say some variation of "[Sat Dec  6 22:13:19 2025] error: scaffold_1	funannotate	mRNA	68859	72555	.	+	.	ID=FUN_000001-T1;Parent=FUN_000001;product=hypothetical protein; in /fs/ess/PAS2880/users/kstarr791/final_project/analysis/gff3/BUSCO_P_DX_prelim_2008299642.final.gff3 does not have a parse-able featureID using namefield 'Name='. Make sure ALL gene feature names are are stored in the attributes column like <namefield><geneName>"

It appears that the original file is not formatted correctly for this analysis. 
Interestingly though, the output log says "[Sat Dec  6 22:09:43 2025] running metaeuk easy-predict for 1 assemblies..
[Sat Dec  6 22:13:11 2025] running hmmsearch on metaeuk annotations..
[Sat Dec  6 22:13:19 2025] filtering metaeuk annotations based on hmmsearch results..
[Sat Dec  6 22:13:19 2025] checking formatting of GFFs in ome2gff.txt..
[Sat Dec  6 22:13:19 2025] lifting over names of overlapping feature from GFFs in ome2gff.txt to metaeuk annotations with bedtools..
[Sat Dec  6 22:13:24 2025] no metaeuk genes intersect with gene features in ome2gff.txt, so there are no gene names to lift over
[Sat Dec  6 22:13:24 2025] found 21 new tyr genes and 0 tyr genes that overlap with 0 existing genes
[Sat Dec  6 22:13:24 2025] done"

It seems to have identified tyr genes, but I'm concerned about the formatting errors. I will need to refer to the manual and reconvene. 