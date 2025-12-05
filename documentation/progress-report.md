## Scripts overview

Right now, I have a single script prepared that is for the setup of the environment. It is located in the /final_projects directory, it is named project_env.sh. It sets variables as exported paths for standardized access to data, scripts, and results directories.

Going forward, I plan to compile the commands into sensible scripts (or simply chains of commands, if not truly scripts per se, from the software manual) that will be broken up per-module. 

In the end, I do hope to have an R script that can help to visualize whatever results I obtain from the analyses. If it turns out that the entire process cannot be completed by the final project due date due to unexpected issues, then I will try to use an R script to maybe visualize some of the intermediate outputs, such as putative proteins identified from the genomic data that will be used in the Gene finder module, and the resulting annotated tyrosine recombinases and mobile elements. 

## To-do list

1. Continue with installing dependencies and preparing the workspace

2. Begin the step by step tutorial (https://github.com/egluckthaler/starfish/wiki/Step-by-step-tutorial#element-finder-module) - This is the bulk of the work here, following the tutorial as it exists, and preparing to troubleshoot where needed. Last time I attempted to use this software, I encountered several issues, and did not even get to a clean installation. I already feel more prepared this time. 

3. Consider development of bash scripts and slurm jobs that can handle some parts of the modules/execution of some commands.

4. Consider development of relevant R scripts for data visualization - what kind of visualization will depend on how far I get in this project and the resulting outputs. 

## Notes

I know that for the first part of this assignment, (expected scripts) so far only contains one script that is not very complex. As was noted in my proposal feedback, the process for using the software will not depend on much of my own script, but rather my execution of the provided tools and workflows. I will try to implement some attempts at writing relevant scripts as I continue, as noted above in the to-do list. 