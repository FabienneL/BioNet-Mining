#!/bin/bash

# The script loads all SBML-model edges (reaction->species), converts the resulting json-file to the dot-format and splits the reaction networks to connected graphs

# ____________________________________________________________________________
# Reading config-file (must be in the same directory)
echo "Reading config...."
source config
echo "URL for MaSyMoS is set to $masymosURL, main path is set to $mainPath, temporary files will be in ${mainPath}/Temp, path for script results  is ${mainPath}/Results"

# ____________________________________________________________________________
# Check if mainPath (specified in config) exist and create it if not exist
if [[ ! -e $mainPath ]]; then
    echo "$mainPath does not exist, creating directories ..."
    mkdir $mainPath
fi
# if mainPath already exists: existing files in the main path with same name will be overwritten! Always change the main path for a new workflow iteration!

# ____________________________________________________________________________
# Check if Temp and Results directory in mainPath exist, create it if not exists
if [[ ! -e ${mainPath}/Temp ]]; then
    echo "${mainPath}/Temp does not exist, creating the directory ..."
    mkdir ${mainPath}/Temp
fi
if [[ ! -e ${mainPath}/Results ]]; then
    echo "${mainPath}/Results does not exist, creating the directory ..."
    mkdir ${mainPath}/Results
fi

# ____________________________________________________________________________
# Load all edges, which connect a reaction to a species, from MaSyMoS and save them into a json-file called jsonNetworks.json
echo "Sending Cypher-query to receive all reaction networks as json-file ..."
curl -X POST -d '{ "query": "MATCH (r:SBML_REACTION)-[h]->(s:SBML_SPECIES) RETURN ID(r),TYPE(h),ID(s)", "params": {} }' ${masymosURL}/db/data/cypher -H "Content-Type: application/json" > ${mainPath}/Temp/networks.json

# ____________________________________________________________________________
# execute the jsonToDot script (must be in the same directory) that  converts temporary json-file named "networks.json" into a .dot format and use ccomps to split the data to connected graphs
# Output file named "1_networks.dot" will be saved in the main path (see config) in the directory "Results"
echo "Converting json to dot format and group connected networks into graphs..."
php 1_jsonToDot.php ${mainPath}/Temp/networks.json | ccomps -x > ${mainPath}/Results/1_networks.dot
