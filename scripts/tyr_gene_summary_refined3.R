# ============================================
# R Script: Summary of tyr Genes & Neighborhoods
# Saves plot to: final_project/figures/tyr_summary.png
# ============================================

# 1. Install & Load required libraries
# Define a list of required packages
required_packages <- c("ggplot2", "dplyr", "patchwork")

# Check for and install any missing packages
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, repos = "http://cran.r-project.org")
    library(pkg, character.only = TRUE) # Load immediately after installing
  } else {
    library(pkg, character.only = TRUE) # Load if already installed
  }
}

# 2. SET YOUR PATHS (Update if needed)
project_path <- "/fs/ess/PAS2880/users/kstarr791/final_project/analysis/"
setwd(project_path)

# 3. Read and prepare tyr gene data
tyr_gff <- read.table("geneFinder/BUSCO_tyr.filt.gff", sep="\t", comment.char="#")
colnames(tyr_gff)[c(1,4,5,7)] <- c("scaffold", "start", "end", "strand")
tyr_genes <- tyr_gff %>%
  mutate(length_kb = (end - start) / 1000,
         gene_id = paste0("tyr_", 1:n())) # Create simple IDs

# 4. Read and prepare neighborhood data (8-column custom BED)
neighborhood_bed <- read.table("geneFinder/BUSCO.bed", sep="\t", header = FALSE, 
                               stringsAsFactors = FALSE, fill = TRUE)

# Assign names for 8 columns
colnames(neighborhood_bed) <- c("scaffold", "start", "end", "gene_name", "gene_type",
                                "strand", "neighborhood_name", "placeholder")

# Now group by neighborhood to get actual neighborhood spans
neighborhoods <- neighborhood_bed %>%
  # Calculate individual gene length if needed
  mutate(gene_length = end - start) %>%
  # Group by the actual neighborhood identifier
  group_by(neighborhood_name) %>%
  summarise(
    scaffold = first(scaffold),
    neighborhood_start = min(start),
    neighborhood_end = max(end),
    neighborhood_size_kb = (max(end) - min(start)) / 1000,
    tyr_count = n(),  # Number of tyr genes in this neighborhood
    .groups = 'drop'
  ) %>%
  # Add a simple ID like N1, N2 for plotting
  mutate(neighborhood_id = paste0("N", 1:n()))

# 5. Find which neighborhood contains the LARGEST tyr gene
largest_tyr <- tyr_genes[which.max(tyr_genes$length_kb), ]
# Simple overlap check: find neighborhood where the gene's start is within bounds
containing_neighborhood <- neighborhoods %>%
  filter(scaffold == largest_tyr$scaffold,
         neighborhood_start <= largest_tyr$start,
         neighborhood_end >= largest_tyr$end) %>%
  pull(neighborhood_name)

# Mark that neighborhood for highlighting
neighborhoods$is_large_gene_home <- neighborhoods$neighborhood_id %in% containing_neighborhood

# 6. CREATE THE PLOTS
# Plot A: Histogram of tyr gene lengths
plot_a <- ggplot(tyr_genes, aes(x = length_kb * 1000)) +  # Convert back to bp
  geom_histogram(binwidth = 100, fill = "steelblue", alpha = 0.8) +  # 100 bp bins
  geom_vline(xintercept = largest_tyr$length_kb * 1000, color = "coral2", 
             size = 1, linetype = "dashed") +
  labs(title = "A. Length of Predicted tyr Genes",
       x = "Gene Length (base pairs)", y = "Count") +  # Update axis label
  theme_minimal()

# Plot B: tyr gene positions on scaffolds
plot_b <- ggplot(tyr_genes, aes(x = start / 1e3, y = reorder(scaffold, start), color = strand)) +
  geom_point(size = 2) +
  labs(title = "B. Genomic Positions of tyr Genes",
       x = "Position on Scaffold (Kilobases)",  # Update label
       y = "Scaffold",
       color = "Strand") +
  scale_color_manual(values = c("+" = "darkgreen", "-" = "purple")) +
  theme_minimal() +
  theme(axis.text.y = element_text(size = 6))

# Calculate highlight_scaffold BEFORE building the plot
highlight_scaffold <- neighborhoods$scaffold[neighborhoods$neighborhood_name == containing_neighborhood]

# Plot C: Bar chart of neighborhood sizes
plot_c <- ggplot(neighborhoods, 
                 aes(x = reorder(neighborhood_id, neighborhood_size_kb), 
                     y = neighborhood_size_kb,
                     fill = is_large_gene_home)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("FALSE" = "gray70", "TRUE" = "coral2"),
                    guide = "none") +
  labs(title = "C. Genomic Neighborhood Sizes",
       x = "Neighborhood ID", 
       y = "Size (kilobases)",
       subtitle = paste("Largest tyr gene (", round(largest_tyr$length_kb, 1), " kb) is in ",
                        neighborhoods$neighborhood_id[neighborhoods$neighborhood_name == containing_neighborhood],
                        " on ", highlight_scaffold, 
                        " (neighborhood: ", containing_neighborhood, ")", sep = "")) +
  coord_flip() +
  theme_minimal()

# 7. COMBINE AND SAVE ALL PLOTS
final_plot <- plot_a / plot_b / plot_c +  # Stack vertically
  plot_layout(heights = c(1, 1.5, 2))    # Adjust panel heights

# Save the figure
figure_path <- "../figures/tyr_gene_summary_refined3.png"
dir.create(dirname(figure_path), showWarnings = FALSE, recursive = TRUE)
ggsave(figure_path, plot = final_plot, width = 10, height = 12, dpi = 300)

print(paste("✅ Summary figure saved to:", figure_path))
print(paste("   Largest tyr gene is", round(largest_tyr$length_kb, 2),
            "kb long on scaffold", largest_tyr$scaffold))