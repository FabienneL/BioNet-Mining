#!/bin/bash

# The script executes the ParSeMiS graph mining with parameters set in the config

# ____________________________________________________________________________
# Reading config-file (must be in the same directory)
echo "Reading config...."
source config
echo "Path to ParSeMiS is set to $pathToParSeMiS, minimum frequency for pattern detection is $minimumFrequency and maximum frequency $maximumFrequency, main path is $mainPath, path for results  is ${mainPath}/Results"

# ____________________________________________________________________________
# Check if mainPath (specified in config) exists and exit script if not exists
if [[ ! -e $mainPath ]]; then
    echo "$mainPath does not exist! Please check the path in the config-file or execute step 1 before this step! Stopping script..."
    exit 1
fi
# if mainPath already exists: existing files in the main path with same name will be overwritten! Always change the main path for a new workflow iteration!

# ____________________________________________________________________________
# Check if Results directory in mainPath exists and exit script if not exists
if [[ ! -e ${mainPath}/Results ]]; then
    echo "${mainPath}/Results does not exist, the file named 1_networks.dot must be in this directory to proceed. Execute step 1 first to create this file! Stopping script..."
    exit 1
fi

# ____________________________________________________________________________
# Check if "1_networks.dot" is in directory Results and exit script if not exists
if [[ ! -e ${mainPath}/Results/1_networks.dot ]]; then
    echo "${mainPath}/Results/1_networks.dot does not exist. Execute step 1 first to create this file! Stopping script..."
    exit 1
fi

# ____________________________________________________________________________
# Execute ParSeMiS
echo "Running ParSeMiS graph mining..."
java -jar $pathToParSeMiS --graphFile=${mainPath}/Results/1_networks.dot --outputFile=${mainPath}/Results/2_patterns.dot --minimumFrequency=$minimumFrequency --maximumFrequency=$maximumFrequency