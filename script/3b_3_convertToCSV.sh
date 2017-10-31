#!/bin/bash

# The script converts the previously created models.json and Cypher query results for patterns to a CSV-format

# ____________________________________________________________________________
# Reading config-file (must be in the same directory)
echo "Reading config...."
source config
echo "Main path is set to $mainPath, path for script results  is ${mainPath}/Results/3b_PatternDistribution/2_QueryResults"

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
# Check if Results/3b_PatternDistribution/2_QueryResults directory in mainPath exists and exit script if not exists
if [[ ! -e ${mainPath}/Results/3b_PatternDistribution/2_QueryResults ]]; then
    echo "${mainPath}/Results/3b_PatternDistribution/2_QueryResults does not exist, the json files resulting from executing the Cypher queries must be in this directory to proceed. Execute step 3b_2 first to create these files! Stopping script..."
    exit 1
fi

# variable containing the path for conversion results
outFilePath=${mainPath}/Results/3b_PatternDistribution/2_QueryResults

# ____________________________________________________________________________
# converting models.json to csv

echo "converting models.json to models.csv"

# call php script to convert the models.json to csv-format (containing for all SBML-models with Species or Reaction(s) the internal ID and BioModels ID)
php 3b_3_jsonModelsToCsv.php ${outFilePath}/models.json > ${outFilePath}/models.csv

# ____________________________________________________________________________
# for each Cypher-result (in json-format) with frequencies of patterns in each model call php script to convert to a csv-file
for file in ${outFilePath}/patternFrequ*_query.json
do
	# variable for resulting file path (csv instead of json)
	csvName=$(echo $file | sed 's/\.json/\.csv/')

	if [ -s $file ]
	then
	        echo "Converting file $file"

		# call php script to convert to csv
		php 3b_3_jsonPatternFrequenciesToCsv.php "$file" > $csvName
	else
	        echo "Json-file $file is empty. Please check if the executeQueries script was executed correctly! Cannot convert file..."
	fi
done
