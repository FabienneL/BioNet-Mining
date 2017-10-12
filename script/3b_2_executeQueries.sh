#!/bin/bash

# The script loads and saves the IDs of all models from MaSyMoS and executes the Cypher queries previously created. For each pattern it receives as result the number of the pattern occurrences per model.

# ____________________________________________________________________________
# Reading config-file (must be in the same directory)
echo "Reading config...."
source config
echo "URL for MaSyMoS is set to $masymosURL, main path is set to $mainPath, temporary files will be in ${mainPath}/Temp, path for script results  is ${mainPath}/Results/3b_PatternDistribution/1_QueryResults"

# ____________________________________________________________________________
# Check if mainPath (specified in config) exists and exit script if not exists
if [[ ! -e $mainPath ]]; then
    echo "$mainPath does not exist! Please check the path in the config-file or execute prior scripts before this step! Stopping script..."
    exit 1
fi
# if mainPath already exists: existing files in the main path with same name will be overwritten! Always change the main path for a new workflow iteration!

# ____________________________________________________________________________
# Check if Results directory in mainPath exists and exit script if not exists
if [[ ! -e ${mainPath}/Results ]]; then
    echo "${mainPath}/Results does not exist. Execute the prior scripts to create the directory and the required files! Stopping script..."
    exit 1
fi

# ____________________________________________________________________________
# Check if Results/3b_PatternDistribution/1_CypherQueries directory in mainPath exists and exit script if not exists
if [[ ! -e ${mainPath}/Results/3b_PatternDistribution/1_CypherQueries ]]; then
    echo "${mainPath}/Results/3b_PatternDistribution/1_CypherQueries does not exist, the query files must be in this directory to proceed. Execute step 3b_1 first to create these files! Stopping script..."
    exit 1
fi

# ____________________________________________________________________________
# Check if Temp directory in mainPath exists, create it if not exists
if [[ ! -e ${mainPath}/Temp ]]; then
    echo "${mainPath}/Temp does not exist, creating the directory ..."
    mkdir ${mainPath}/Temp
fi

#____________________________________________________________________________
# Check if Results/3b_PatternDistribution/1_QueryResults directory in mainPath exists, create it if not exists
if [[ ! -e ${mainPath}/Results/3b_PatternDistribution/1_QueryResults ]]; then
    echo "${mainPath}/Results/3b_PatternDistribution/1_QueryResults does not exist, creating the directory ..."
    mkdir ${mainPath}/Results/3b_PatternDistribution/1_QueryResults
fi

# variable containing the path for query results
outFilePath=${mainPath}/Results/3b_PatternDistribution/1_QueryResults

# ____________________________________________________________________________
# loading models

echo "loading list of models as models.json"

# Load for all SBML-models with Species or Reaction(s) the internal ID and BioModels ID and save as models.json
curl -X POST -d '{ "query": "MATCH (m:SBML_MODEL)-->(d:DOCUMENT) WHERE ((m)-[:HAS_SPECIES]->(:SBML_SPECIES) OR (m)-[:HAS_REACTION]->(:SBML_REACTION)) RETURN DISTINCT ID(m) AS InternalModelID, d.FILENAME AS BioModelsID", "params": {} }' ${masymosURL}/db/data/cypher -H "Content-Type: application/json" > ${outFilePath}/models.json

# ____________________________________________________________________________
# method to execute query
executeCypher()
{
	curl -X POST -H "Content-Type: application/json" -d @$1 ${masymosURL}/db/data/cypher > ${outFilePath}/$1.json
}

# ____________________________________________________________________________
# for each query in the directory check if file is empty, print file name that will be executed and call the method to execute it
for file in ${mainPath}/Results/3b_PatternDistribution/1_CypherQueries/splittedFragments*_query
do
	if [ -s $file ]
	then
	        echo "Executing file $file"
		executeCypher "$file"
	else
	        echo "Query file $file is empty. Please check if the createQueries script was executed correctly! Cannot execute query..."
	fi
done
