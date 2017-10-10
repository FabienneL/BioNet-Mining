#!/bin/bash

# The script sets in the pattern-file attributes for visualisation and creates a visualisation file for each pattern

# ____________________________________________________________________________
# Reading config-file (must be in the same directory)
echo "Reading config...."
source config
echo "Main path is set to $mainPath, temporary files will be in ${mainPath}/Temp, path for script results  is ${mainPath}/Results/3a_Visualisation"

# ____________________________________________________________________________
# Check if mainPath (specified in config) exists and exit script if not exists
if [[ ! -e $mainPath ]]; then
    echo "$mainPath does not exist! Please check the path in the config-file! Stopping script..."
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
# Check if 3a_Visualisation directory in mainPath/Results exists, create it if not exists
if [[ ! -e ${mainPath}/Results/3a_Visualisation ]]; then
    echo "${mainPath}/Results/3a_Visualisation does not exist, creating the directory ..."
    mkdir ${mainPath}/Results/3a_Visualisation
fi

# ____________________________________________________________________________
# Set attributes like colors and shapes for visualisation in a file named "patternsVisualAttributes.dot" in the Temp directory
echo "Set visualisation attributes..."
sed -e "s/label=\"SBML_REACTION\"/label=\"\",comment=\"SBML_REACTION\",shape=box,height=0.25,width=0.25,style=filled,fillcolor=turquoise/g" ${mainPath}/Results/2_patterns.dot | 
sed -e "s/label=\"SBML_SPECIES\"/label=\"\",comment=\"SBML_SPECIES\",shape=box,style=\"filled,rounded\",fillcolor=lightyellow,height=0.3/g" |
sed -e "s/label=\"HAS_PRODUCT\"/comment=\"HAS_PRODUCT\",penwidth=1/g" | 
sed -e "s/label=\"IS_REACTANT\"/comment=\"IS_REACTANT\",dir=none, penwidth=1/g" | 
sed -e "s/label=\"IS_MODIFIER\"/comment=\"IS_MODIFIER\",penwidth=1,arrowhead=odot,arrowsize=1.2/g" > ${mainPath}/Temp/patternsVisualAttributes.dot

# ____________________________________________________________________________
# Create temporary file with frequencies of patterns (the frequency in the ParSeMiS dot-file is a comment after symbol  # )
grep "#" ${mainPath}/Temp/patternsVisualAttributes.dot | sed -e "s/}# => //g" | sed -e "s/\[.*//g" > ${mainPath}/Temp/frequOfPatterns.txt

# ____________________________________________________________________________
# Create a visualisation file for each pattern in "patternsVisualAttributes.dot", each file has a name consisting of "patternFrequ" + occurrence frequency (number of graphs) + an id (to distinguish patterns with same frequency)
csplit --quiet --elide-empty-files --prefix=tmpFragments ${mainPath}/Temp/patternsVisualAttributes.dot "/}/+1" "{*}" 
id=$(printf "%02d" 0)
echo "Create image files..."
while read line
do
	#create .png
	dot -Tpng tmpFragments$id > ${mainPath}/Results/3a_Visualisation/patternFrequ$line-$id.png && rm -f tmpFragments$id
	let id=10#$id+1
	id=$(printf "%02d" $id)
done < ${mainPath}/Temp/frequOfPatterns.txt
