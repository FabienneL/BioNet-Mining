#!/bin/bash

# This script combines previously created CSVs to create a feature matrix. The matrix consists of a feature vector per row containing for a model the number of all occurrences of the patterns described in the columns

# ____________________________________________________________________________
# Reading config-file (must be in the same directory)
echo "Reading config...."
source config
echo "Main path is set to $mainPath, path for script result  is ${mainPath}/Results/3b_PatternDistribution"

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
    echo "${mainPath}/Results/3b_PatternDistribution/2_QueryResults does not exist, the files resulting from executing the Cypher queries must be in this directory to proceed. Execute step 3b_2 and 3b_3 first to create these files! Stopping script..."
    exit 1
fi

# ____________________________________________________________________________
# Check if file Results/3b_PatternDistribution/2_QueryResults/models.csv in mainPath exists & not empty and exit script if not exists/empty
if [[ ! -s ${mainPath}/Results/3b_PatternDistribution/2_QueryResults/models.csv ]]; then
	echo "${mainPath}/Results/3b_PatternDistribution/2_QueryResults/models.csv does not exist or is empty. Please check if scripts for step 3b_2 and 3b_3 were executed correctly! Cannot create feature matrix..."
	exit 1
fi

# ____________________________________________________________________________
# Check if at least one csv-file Results/3b_PatternDistribution/2_QueryResults/patternFrequ*_query.csv in mainPath exist & not empty and exit script if not exists/empty
for file in ${mainPath}/Results/3b_PatternDistribution/2_QueryResults/patternFrequ*_query.csv
do
	if [[ ! -s ${file} ]]; then
		echo "There are no CSV-files (patternFrequ*) with pattern frequencies in ${mainPath}/Results/3b_PatternDistribution/2_QueryResults or a CSV-file is empty. Please check if scripts for step 3b_3 were executed correctly! Cannot create feature matrix..."
		exit 1
	else
		break
	fi
done

# variable containing the path for resulting feature matrix
outFilePath=${mainPath}/Results/3b_PatternDistribution

# ____________________________________________________________________________
# Create column headers for feature matrix
echo "creating column headers for feature matrix"

# first headers are the internal model ID and Biomodels ID
echo -n "InternalModelID,BioModelsID" > ${outFilePath}/featureMatrix.csv

# Further column headers is the identifier in the names of the patterns found (frequency + unique number)
for file in ${outFilePath}/2_QueryResults/patternFrequ*_query.csv
do
	# the identifier of the pattern is a number + a hyphen + a number in the file name
	patternFrequency=$(echo $file | sed 's/.*patternFrequ\([0-9]*\-[0-9]*\).*/\1/')
	echo -n ", $patternFrequency" >> ${outFilePath}/featureMatrix.csv
done

# ____________________________________________________________________________
# For each model in models.csv check the pattern frequencies in all the csv-files. If a pattern occurs in the model, write the frequency to the feature matrix, else write 0

echo "reading models.csv..."
while read line
do
	echo "writing feature vector for model with IDs $line"
	echo "" >> ${outFilePath}/featureMatrix.csv
	# Find out BioModelsID for this row: a line contains two comma separated values, the second value is the BioModelsID (in regex the first grouping by parenthesis)
	biomID=$(echo $line | sed 's/.*, \(.*\)$/\1/')
	# write BioModelsID to matrix
	echo -n "$biomID" >> ${outFilePath}/featureMatrix.csv

	# for each pattern csv ...
	for file in ${outFilePath}/2_QueryResults/patternFrequ*_query.csv
	do
		# search for the frequency of the pattern in the current model ($line): the file contains lines with comma separated values, search for the line that starts with the two values in models.csv ($line) followed by a comma and a frequency
		frequency=$(grep "$line,[0-9]*$" $file | sed 's/.*,\([0-9]*\)$/\1/')
		# if the pattern does NOT occur in the model, no such lines in the pattern file exist and the variable frequency will be empty
		if [ "$frequency" = "" ]
			then
				echo -n ", 0" >> ${outFilePath}/featureMatrix.csv
			else
				echo -n ", $frequency" >> ${outFilePath}/featureMatrix.csv
		fi
	done
done < ${outFilePath}/2_QueryResults/models.csv