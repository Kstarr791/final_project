#!/bin/bash
# /fs/ess/PAS2880/users/kstarr791/final_project/project_env.sh

# Base directory
export PROJECT_DIR="/fs/ess/PAS2880/users/kstarr791/final_project"

# Container location
export STARFISH_CONTAINER="$PROJECT_DIR/software/containers/starfish.sif"

# Data directories
export RAW_DATA="$PROJECT_DIR/data/raw"
export PROCESSED_DATA="$PROJECT_DIR/data/processed"
export RESULTS="$PROJECT_DIR/data/results"

# Add your scripts to PATH so you can run them from anywhere
export PATH="$PROJECT_DIR/scripts:$PATH"

# Create a shortcut command for running starfish tools
alias starfish_run="apptainer exec $STARFISH_CONTAINER"