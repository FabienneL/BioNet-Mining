#!/bin/bash

# The script takes a dot-file created by ParSeMiS, which contains frequent patterns. It generates a Cypher query for each pattern to receive the number of its occurrences per model

# ____________________________________________________________________________
# Reading config-file (must be in the same directory)
echo "Reading config...."
source config
echo "Main path is set to $mainPath, temporary files will be in ${mainPath}/Temp, path for script results  is ${mainPath}/Results/3b_PatternDistribution/1_CypherQueries"

# ____________________________________________________________________________
# Check if mainPath (specified in config) exists and exit script if not exists
if [[ ! -e $mainPath ]]; then
    echo "$mainPath does not exist! Please check the path in the config-file or execute step 1 and 2 before this step! Stopping script..."
    exit 1
fi
# if mainPath already exists: existing files in the main path with same name will be overwritten! Always change the main path for a new workflow iteration!

# ____________________________________________________________________________
# Check if Results directory in mainPath exists and exit script if not exists
if [[ ! -e ${mainPath}/Results ]]; then
    echo "${mainPath}/Results does not exist, the file named 2_patterns.dot must be in this directory to proceed. Execute step 1 and 2 first to create this file! Stopping script..."
    exit 1
fi

# ____________________________________________________________________________
# Check if "2_patterns.dot" is in directory Results and exit script if not exists
if [[ ! -e ${mainPath}/Results/2_patterns.dot ]]; then
    echo "${mainPath}/Results/2_patterns.dot does not exist. Execute step 2 to create this file! Stopping script..."
    exit 1
fi

# ____________________________________________________________________________
# Check if Temp directory in mainPath exists, create it if not exists
if [[ ! -e ${mainPath}/Temp ]]; then
    echo "${mainPath}/Temp does not exist, creating the directory ..."
    mkdir ${mainPath}/Temp
fi

# ____________________________________________________________________________
# Check if 3b_PatternDistribution/1_CypherQueries directory in mainPath/Results exists, create it if not exists
if [[ ! -e ${mainPath}/Results/3b_PatternDistribution ]]; then
    echo "${mainPath}/Results/3b_PatternDistribution does not exist, creating the directory and subdirectory 1_CypherQueries..."
    mkdir ${mainPath}/Results/3b_PatternDistribution
    mkdir ${mainPath}/Results/3b_PatternDistribution/1_CypherQueries
fi
if [[ ! -e ${mainPath}/Results/3b_PatternDistribution/1_CypherQueries ]]; then
    echo "${mainPath}/Results/3b_PatternDistribution/1_CypherQueries does not exist, creating the directory ..."
    mkdir ${mainPath}/Results/3b_PatternDistribution/1_CypherQueries
fi


echo "Create temporary files for Cypher-queries..."
# ____________________________________________________________________________
# Create temporary file with frequencies of patterns (in ParSeMiS dot-file always as comment after symbol  # )
grep "#" ${mainPath}/Results/2_patterns.dot | sed -e "s/}# => //g" | sed -e "s/\[.*//g" > ${mainPath}/Temp/frequOfPatterns.txt

# ____________________________________________________________________________
# Create a temporary file for each pattern in "2_patterns.dot" that contains only information relevant for generating queries (nodes, edges, edge types)
# each file has a name consisting of "queryInfo" + occurrence frequency (number of graphs) + an identifier (to distinguish patterns with same frequency)
csplit --quiet --elide-empty-files --prefix=tmpFragments ${mainPath}/Results/2_patterns.dot "/}/+1" "{*}" 
id=$(printf "%02d" 0)
while read line
do
	# write the type (reaction or species) of Node_0 in the file
	egrep "Node_0 \[label=\"SBML" tmpFragments$id | egrep -o "SBML[^]]*" > ${mainPath}/Temp/queryInfo$line-$id
	# extract all edges (lines with "->"); write the corresponding nodes and edge types to the file
	grep "\->" tmpFragments$id | sed -e "s/\-> //g" | sed -e "s/	N/N/g" | sed -e "s/\[label=\"//g" | sed -e "s/\"\];//g" >> ${mainPath}/Temp/queryInfo$line-$id
	# create temporary file "NodeCountFREQUENCY-ID" that contains for the certain pattern the number of nodes contained; delete tmpFragments-file
	egrep -c "SBML_SPECIES|SBML_REACTION" tmpFragments$id > ${mainPath}/Temp/NodeCount$line-$id && rm -f tmpFragments$id
	# increment id
	let id=10#$id+1
	# desired id format
	id=$(printf "%02d" $id)
done < ${mainPath}/Temp/frequOfPatterns.txt

# ____________________________________________________________________________
# Method to write a query; is called hereafter for each queryInfo-file
createCypher()
{
	# filter numbers from file (format is "Frequency-ID")
	fileNameNumber=$(echo $1 | sed 's/.*queryInfo\([0-9]*\-[0-9]*\)/\1/')

	# variable containing the path for resulting query
 	outFilePath=${mainPath}/Results/3b_PatternDistribution/1_CypherQueries/patternFrequ${fileNameNumber}_query

	# write starting text to the file for automatically sending a query later: { "query": "CYPHER_QUERY", "params":{} }
	echo "{" > ${outFilePath}
	echo -n "  \"query\":\"MATCH (m:SBML_MODEL)-->(d:DOCUMENT), " >> ${outFilePath}

	# get the first line of the file, it contains information about the type of the first node Node_0
	myvar=($(head $1))
	# write first edge to query depending on the type of Node_0 (species or reaction)
	if [[ ${myvar[0]} ==  *REACTION* ]]; then echo -n "(m)-[HAS_REACTION]->(Node_0)" >> ${outFilePath}; 
		else echo -n "(m)-[HAS_SPECIES]->(Node_0)" >> ${outFilePath}; fi
	# write other lines (all edges in the pattern) to temporary file named "...tail"
	tail -n +2 "$1" > $1tail

	# in the temporary file named "...tail" each line represents one edge; write edges of graph in Cypher-format to query-file
	while read line
	do
		myvar=($line)
		echo -n ", (${myvar[0]})-[:${myvar[2]}]->(${myvar[1]})" >> ${outFilePath}
	done < $1tail
	# delete temporary file "...tail"
	rm "$1tail"

	# variable for number of all nodes contained in the NodeCount-file
	nodeCount=$(head ${mainPath}/Temp/NodeCount${fileNameNumber})
	# is later used as index (from 0 to nodeCount-1)
	nodeCount=$((nodeCount-1))

	# if several nodes are contained in the pattern, insert WHERE-clause to query to ensure that all nodes are unequal
	if [[ ${nodeCount} > 0 ]]; then echo -n " WHERE" >> ${outFilePath}; fi
	for ((i=0; i<${nodeCount}; i++))
	do
		for((j=($i+1); j<=${nodeCount}; j++))
		do
			echo -n " Node_$i<>Node_$j" >> ${outFilePath}
			if [ $i !=  $((nodeCount-1)) ] || [ $j != ${nodeCount} ]; then echo -n " AND" >> ${outFilePath}; fi
		done
	done

	# insert RETURN-clause (last part of Cypher-query)
	echo " RETURN DISTINCT ID(m) AS InternalModelID, d.FILENAME AS BioModelsID, COUNT(Node_0) AS Frequency ORDER BY sum DESC\"," >> ${outFilePath}
	# write last text elements to the query-file required for automatically executing the query later
	echo "  \"params\":{}" >> ${outFilePath}
	echo -n "}" >> ${outFilePath}
}

# ____________________________________________________________________________
# Call for each temporary pattern-file the method to write the query
echo "Create query-files..."
for file in ${mainPath}/Temp/queryInfo*
do
	if [ -s $file ]
	then
	        createCypher "$file"
	else
	        echo "Temporary file $file required for creating query is empty. Please check content of file 2_patterns.dot! Cannot create query..."
	fi
done