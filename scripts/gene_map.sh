# Request an interactive node with X11 for RStudio visuals
srun --account=PAS2880 --time=01:00:00 --mem=4G --x11 --pty /bin/bash
# Load the R module
module load R/4.4.0
# Launch R
R
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