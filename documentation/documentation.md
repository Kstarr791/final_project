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
Interestingly though, the output log says: 

*[Sat Dec  6 22:09:43 2025] running metaeuk easy-predict for 1 assemblies..
[Sat Dec  6 22:13:11 2025] running hmmsearch on metaeuk annotations..
[Sat Dec  6 22:13:19 2025] filtering metaeuk annotations based on hmmsearch results..
[Sat Dec  6 22:13:19 2025] checking formatting of GFFs in ome2gff.txt..
[Sat Dec  6 22:13:19 2025] lifting over names of overlapping feature from GFFs in ome2gff.txt to metaeuk annotations with bedtools..
[Sat Dec  6 22:13:24 2025] no metaeuk genes intersect with gene features in ome2gff.txt, so there are no gene names to lift over
**[Sat Dec  6 22:13:24 2025] found 21 new tyr genes and 0 tyr genes that overlap with 0 existing genes
[Sat Dec  6 22:13:24 2025] done***

It seems to have identified 21 tyr genes, but I'm concerned about the formatting errors. I will need to refer to the manual and reconvene. 

It seems that this error is explaining that naming conventions and the "lifting over" function is a way to transfer gene names from an existing annotation to a new one based on overlapping coordinates (tyr genes found). This might be relevant if any of the tyr genes that were found overlap with existing genes in the original annotation, but it does say that 0 tyr genes overlap with existing genes. Therefore, this should not be a problem. 

### Consolidate

I am ready to continue the pipeline. It is now time to consolidate. I have created the script for this step `scripts/consolidate.sh`.

I submitted a job using `sbatch scripts/consolidate.sh` and I am checking the status of the job using `squeue -u $USER`. It is not showing up in the queue, but no job failure message was generated in the terminal. It is meant to be a pretty fast step, so I will check the outputs. The expected file, `analysis/BUSCO_tyr.filt.consolidated.gff` does exist, and is populated with over 2000 lines of text, so I will consider this step to have completed successfully. 

### Sketch

Instead of creating a new slurm script for the next step, I am using a simple chain of commands from the tutorial, which are as follows:

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

This was successful, it merged any tyr regions that were within 10000 bp of each other, bringing our 21 suspected tyr genes to 19 gene "neighborhoods". 

This concludes the Gene Finder module. 

## Element Finder Module

We now create a script for the first step of the module, `insert.sh` located in `scripts/`

I ran this script and it was finished in a surprisingly short time - perhaps this is because we are working with only a single genome. Time to check the outputs. 

This file was created: final_project/analysis/elementFinder/checkpoints/BUSCO.insert.element_upstream_search.checkpoint, it is the only thing inside elementFinder/

But it cannot be read using head command. 

I checked the logs. out: "=== Starting Element Finder (insert) Job ===
Job ID: 42420743
Start Time: Tue Dec  9 02:42:05 AM EST 2025
[Tue Dec  9 02:42:09 2025] executing command: starfish insert -T 2 -a ome2assembly.txt -d blastdb/BUSCO_P_DX_prelim_2008299642.assemblies -b geneFinder/BUSCO.bed -i tyr -x BUSCO -o elementFinder/
Key parameters:
--upstream             0-8000
--downstream           0-5000
--length               15000-800000
--pid                  90
--hsp                  1000
minDR                  4
maxDR                  40
maxEmptySiteLength     2000
maxElementLengthFlag   800000
minElementLengthFlag   15000
maxInsertCoverage      0.25
maxUpDownCoverage      0.25
blastn                 -task dc-megablast -evalue 0.0001 -max_target_seqs 1000000
nucmer                 --mum
delta-filt             -m -l 1000 -i 90

[Tue Dec  9 02:42:09 2025] reading in data..
[Tue Dec  9 02:42:10 2025] parsing upstream regions of 19 candidate tyr captains..
[Tue Dec  9 02:42:10 2025] searching for hits to the upstream regions of 19 candidate tyr captains..
Job finished successfully at: Tue Dec  9 02:42:10 AM EST 2025"

error log: "found 0 tyr captains with candidate insertion sites, exiting.."

Alright, this is a problem. I will consult the manual as well as DeepSeek AI to help me reconcile the issue. 

I shared the relevant steps of the tutorial and my outputs with DeepSeek, and here is its response:

```
The results for your starfish insert job indicate the core search worked, but the tool found zero candidate mobile elements. This is not necessarily an error with your setup, but a specific biological outcome that needs investigation. None of the provided search results could directly address the Starfish pipeline or this specific issue.

Since the primary issue is likely biological (e.g., low sequence similarity, unique genome biology, or data-specific factors), here is a detailed diagnostic plan and a potential solution for you to follow.

🔍 Diagnosing the "Found 0 Captains" Result
The starfish insert command uses a BLAST-based search to find the upstream boundary of an element. The message "found 0 tyr captains with candidate insertion sites" means none of your 19 candidate neighborhoods passed the initial filtering criteria. This could be due to several reasons related to your unique genome data:

Stringent Default BLAST Parameters: The job log shows default parameters like --pid 90 (90% sequence identity) and --hsp 1000 (1000 bp high-scoring pair length). Your Macrophomina phaseolina sequences may not share 90% identity over 1000 bp stretches with any sequence in the BLAST database (which is just your own genome).

Unique or Divergent Genome: Mobile elements in your strain might be highly divergent from any consensus or reference sequences the algorithm expects, or they may have a very different structure.

BLAST Database Content: The BLAST database only contains your single genome. The algorithm searches for self-similarity (upstream regions matching elsewhere in the same genome). If the mobile elements are unique or recent insertions, they may not have paralogous sequences to match against.
```

This is frustrating, but the AI is trying to produce some ideas for continuing. 

```
Step 1: Check the Tutorial's Notes on Single-Genome Analysis
Re-examine the tutorial, particularly the note you mentioned earlier: "Note that if you are annotating Starships on a per-genome level, the focal genome must be included in the blast database." Your setup is correct here. The tutorial's successful example used 6 genomes, providing a richer database for finding homologous sequences. Your single-genome analysis is inherently more challenging.

Step 2: Modify Parameters and Re-run starfish insert
The most direct action is to relax the search parameters in a new Slurm script. Focus on lowering the percent identity (--pid) and the required alignment length.

Here is an example of how to modify your command for a more sensitive search:

bash
apptainer exec ../software/containers/starfish.sif /opt/conda/envs/starfish/bin/starfish insert \
    -T 4 \
    -a ome2assembly.txt \
    -d blastdb/BUSCO_P_DX_prelim_2008299642.assemblies \
    -b geneFinder/BUSCO.bed \
    -i tyr \
    -x BUSCO \
    -o elementFinder/ \
    --pid 70 \          # Lower identity threshold from 90% to 70%
    --hsp 500           # Lower HSP length from 1000 bp to 500 bp
Create a new script (e.g., scripts/04_insert_relaxed.sbatch) with these changes, increase the time limit, and submit it.

Step 3: Consult the Manual for Additional Parameters
Look for other tunable parameters in the starfish manual under the insert command. Parameters controlling the upstream/downstream search window (--upstream, --downstream) or alignment significance (-evalue for the internal blastn command) could also be relevant.
```

I fed back the relevant manual portion to the AI and this was its recommendation:

```
Thank you for sharing the manual. It provides crucial context and confirms that your script adjustment is exactly the right first step. The issue lies in the stringent default filters—specifically the --pid 90 (90% identity) and --hsp 1000 (1000 bp alignment length) parameters you saw in the logs. For divergent sequences or a single-genome analysis, these are often too strict.

🔬 Key Insight from the Manual
The manual explains the algorithm searches for alignments between "flanking regions" in different genomes. Since your BLAST database contains only your single genome, the tool is looking for self-similarity (e.g., paralogous sequences or repeated elements within your own genome). If your elements are unique or recently inserted, they may not have strong internal repeats meeting the 90%/1000bp threshold.

✅ Recommended Action: Adjust Parameters and Re-run
Your plan to modify the script is the most efficient path forward. Relaxing the filters will allow the algorithm to detect more divergent or shorter homologous sequences, which is essential for a single-genome search.
```

The note about highly divergent genomes is interesting, because the one that I am working with is an unknown species in an unknown genus. Only the family is known with confidence, so it might be that there is a large dissimilarity that is causing issues here. The Starfish software is still in v1.0.0, and the manual states 

*"For each possible alignment between two different genomes for a given element, the single longest blastn alignment is chosen and all others ignored. This may not always be the best way to identify a homologous pairwise alignment, especially between more divergent genomes. This feature may be improved in future releases, e.g., by chaining together alignments within a certain distance of each other and identifying the longest of such alignment neighborhoods."*

Okay. I will proceed with the adapted script with relaxed parameters and see what happens. 

```
Here are the specific adjustments to make in your new Slurm script:

bash
apptainer exec ../software/containers/starfish.sif /opt/conda/envs/starfish/bin/starfish insert \
    -T 4 \
    -a ome2assembly.txt \
    -d blastdb/BUSCO_P_DX_prelim_2008299642.assemblies \
    -b geneFinder/BUSCO.bed \
    -i tyr \
    -x BUSCO \
    -o elementFinder_relaxed/ \  # Use a NEW output directory
    --pid 70 \          # Lower percent identity from 90% to 70%
    --hsp 500 \         # Lower HSP length from 1000 bp to 500 bp
    --flankcov 0.7      # Consider lowering if alignments are short (default likely 0.8)
Crucial Steps:

Use a New Output Directory: The manual warns that checkpoint files from the previous run must be removed if parameters change. Using a new directory (e.g., elementFinder_relaxed/) is the safest way to ensure a clean restart.

Remove Old Checkpoints: If you reuse elementFinder/, you must delete the checkpoint file first: rm -rf analysis/elementFinder/checkpoints/.
```

First, I give the AI context that my genome is a novel species and genus, and I also recommend including more closely related genomes to my pipeline to give more robust pairwise alignments for the tools. Here is the response:

```
Your genome's phylogenetic novelty is likely the core reason why the stringent default parameters (--pid 90, --hsp 1000) failed. Mobile elements in an uncharacterized, divergent lineage are far less likely to have highly conserved, long stretches of self-similarity within its own genome.

🎯 Re-evaluating Your Options in Light of Novelty
Given this new information, here's how your two options weigh:

Adjusting Parameters (Path 1): This becomes even more critical. You will likely need to relax the thresholds substantially to find divergent, genus-specific mobile elements. Parameters like --pid 70 and --hsp 500 may still be too strict. You might need to go as low as --pid 50 and --hsp 200 as an initial exploratory search.

Adding Related Genomes (Path 2): This strategy faces a major hurdle. If your genome is from an unknown genus sister to Tarzetta, the available "closely related" genomes in public databases (likely other Tarzetta species) may still be too evolutionarily distant. The mobile elements you're looking for might be genus- or even species-specific, meaning they wouldn't be shared with Tarzetta, making the cross-genome search ineffective.

✅ Action Plan: Start with a Broad Parameter Sweep
Given the challenges with Path 2, I recommend a focused, stepwise approach with Path 1.

Step 1: Run a Highly Sensitive Exploratory Search
Create and submit a new Slurm script designed to cast a very wide net. We'll dramatically lower the thresholds and also consider adjusting the search windows.

bash
#!/bin/bash
#SBATCH --job-name=starfish_insert_sensitive
#SBATCH --account=PAS2880
#SBATCH --time=12:00:00          # Allow more time for a broader search
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --output=analysis/logs/insert_sensitive_%j.out
#SBATCH --error=analysis/logs/insert_sensitive_%j.err

set -euo pipefail

cd /fs/ess/PAS2880/users/kstarr791/final_project/analysis

# Use a CLEAN output directory
OUT_DIR="elementFinder_sensitive"
mkdir -p $OUT_DIR

echo "=== Starting SENSITIVE Element Finder Search ==="
echo "Genome context: Novel, phylogenetically divergent"
echo "Parameters set for high sensitivity (low pid, short hsp)"

apptainer exec ../software/containers/starfish.sif /opt/conda/envs/starfish/bin/starfish insert \
    -T 4 \
    -a ome2assembly.txt \
    -d blastdb/BUSCO_P_DX_prelim_2008299642.assemblies \
    -b geneFinder/BUSCO.bed \
    -i tyr \
    -x BUSCO_sensitive \
    -o $OUT_DIR \
    --pid 50 \          # Very low identity threshold
    --hsp 200 \         # Very short alignment threshold
    --flankcov 0.5      # Reduced flank alignment coverage filter
    --upstream 0-12000 \ # Widen the search window upstream
    --downstream 0-8000  # Widen the search window downstream

echo "Job finished at: $(date)"
Step 2: Interpret the Results

If this search finds candidates: Success! You can then gradually tighten the parameters (e.g., --pid 60, --hsp 300) in subsequent runs to find the optimal balance between sensitivity and specificity for your novel genome.

If this search still finds 0 candidates: It becomes strong evidence that either:
a) Your genome truly lacks the specific type of Starship elements Starfish is designed to find, or
b) The elements are so novel that even a self-similarity search within one genome fails, and a different methodological approach may be needed.
```
I'll try this latest suggestion first. 

Still failed. 
Now seems we are having unexpected issues with syntax.

```
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
    --flankcov 0.5 \
    --upstream 0-20000 \  # Search up to 20kb upstream (default was 0-8000)
    --downstream 0-15000  # Search up to 15kb downstream (default was 0-5000)

echo "Job finished at: $(date)"
```

The option `--flankcov` is being flagged as unknown. I noticed that the command to find the version of Starfish accepted "starfish version" rather than "starfish --version", so I began to suspect something was weird with the syntax. 
DeepSeek AI gave me this command to check the actual updated list of arguments and options:

```
apptainer exec software/containers/starfish.sif /opt/conda/envs/starfish/bin/starfish insert -h
```

And indeed the `--flankcov` option is missing entirely!
It seems that the manual on github might be outdated compared to the actual software's operation now, at least through apptainer. The new options show `--updowncov` has replaced `--flankcov`  We will adjust the script again. --flankcov is removed from the updated script and rerun. 

Unfortunately, despite seeming to run properly this time with no script errors, it still says it found 0 tyr captains with candidate insertion sites. 

This is DeepSeek's response to this information:

"The result is now clear: even with significantly relaxed parameters (--pid 50, --hsp 200), the starfish insert algorithm found zero candidate mobile elements in your novel genome.

This is a definitive computational result, not a script error. It provides strong evidence for a key biological conclusion about your data.
Interpreting the "0" Result
The starfish insert command is designed to find large, discrete mobile elements (Starships) by detecting self-similarity—specifically, long, high-identity DNA repeats that flank a "captain" gene.

Finding 0 candidates with sensitive settings means one of the following is true for your genome:

The genome lacks this specific type of element. The tyrosine recombinase ("tyr") genes you found may not be part of large, bounded Starships. They could be solitary, part of smaller elements, or associated with different repeat structures that Starfish doesn't target.

The elements are too novel or degraded. Any flanking repeats may be so divergent, short, or fragmented that they fall below even your relaxed detection thresholds (<50% identity or <200 bp).

The single-genome approach is a limitation. The algorithm may rely heavily on finding the same element inserted in multiple locations within or across genomes. A unique, single insertion in one genome is invisible to this method."

At this point, I have tried 5 different versions of the `insert` script. All are documented in `scripts/`, the various attempts were made to essentially widen the search for the candidate repeats associated with the 19 tyr genes from previous steps. We still have a null result. 

I will continue the software pipeline just for the sake of completion. 

### `summarize`

Inserting an empty `.insert.bed` file for the program to continue. 

```
cd /fs/ess/PAS2880/users/kstarr791/final_project/analysis
touch elementFinder_sensitive/empty_insert.bed
```

Construct the adapted summarize Command

```
apptainer exec ../software/containers/starfish.sif /opt/conda/envs/starfish/bin/starfish summarize \
    -a ome2assembly.txt \
    -b elementFinder_sensitive/empty_insert.bed \
    -x BUSCO \
    -o elementFinder_sensitive/ \
    -g ome2consolidatedGFF.txt \
    -t geneFinder/BUSCO_tyr.filt.ids
```

We have removed `-S elementFinder/*.insert.stats` (there is no stats file) and `-A ann/*.gene2emap.txt`. 

Terminal output:
```
identifying large mobile genetic elements by their boundary features..
identifying nested and overlapping elements..
we have for a total of 0 elements
found 0 elements nested/overlapping with 0 other elements
printing data..
done
```

It produced output files that are empty, as expected. 

All downstream processes will continue to produce empty files, so I am going to terminate the process and focus on seeing if I can produce any useful graphics from what was already achieved. 

### R visualization 
I will try to make a gene position plot with R studio to see the tyrosine recombinase genes that were located mapped in the genome. 

```
# Load necessary libraries (install if needed)
if (!require("ggplot2")) install.packages("ggplot2", repos="http://cran.r-project.org")
if (!require("gggenes")) install.packages("gggenes", repos="http://cran.r-project.org")
library(ggplot2)
library(gggenes)

# --- SET YOUR PATHS HERE ---
# The path to your GFF file on OSC
gff_file <- "/fs/ess/PAS2880/users/kstarr791/final_project/analysis/geneFinder/BUSCO_tyr.filt.gff"
# Where to save the plot
output_plot <- "/fs/ess/PAS2880/users/kstarr791/final_project/figures/tyr_gene_map.png"
# ---------------------------

# Read the GFF file. We only need columns: scaffold, source, feature, start, end, strand.
tyr_data <- read.table(gff_file, sep="\t", header=FALSE, comment.char="#")
# Keep only relevant columns (adjust indices if your GFF format differs)
tyr_genes <- tyr_data[, c(1, 3, 4, 5, 7)]
colnames(tyr_genes) <- c("scaffold", "feature", "start", "end", "strand")

# Create a basic gene arrow map
p <- ggplot(tyr_genes, aes(xmin = start, xmax = end, y = scaffold, 
                            fill = strand, forward = (strand == "+"))) +
    geom_gene_arrow(arrowhead_height = unit(3, "mm"), arrowhead_width = unit(2, "mm")) +
    facet_wrap(~ scaffold, scales = "free_y", ncol = 1) +
    theme_genes() +
    labs(title = "Distribution of Predicted Tyrosine Recombinase (tyr) Genes",
         x = "Genomic Position (bp)", y = "Scaffold") +
    scale_fill_manual(values = c("+" = "steelblue", "-" = "coral2"))

# Save the plot
dir.create(dirname(output_plot), showWarnings = FALSE, recursive = TRUE)
ggsave(output_plot, plot = p, width = 12, height = 8, dpi = 300)
print(paste("Plot saved to:", output_plot))
```

This output a plot in `final_project/figures`. Interestingly, the size of the tyr genes all seem to be fairly short in bp, with one exception in scaffold 776. I might attempt to do more analyss on this. I'm not yet sure what the relevance of that finding could be, if any. 

I will try to use a standalone tool called RepeatModeler that can look for genomic repeats, perhaps mapping those and overlaying them if possible would give some insights into the possibility of Starfish's features being not well suited for this particular genome. 

