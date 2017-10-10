# BioNet-Mining Project (under construction!)
The repository contains the scripts for a workflow that identifies frequent structural patterns in biochemical reaction networks encoded in the Systems Biology Markup Language. 
The workflow utilises the frequent subgraph mining algorithm gSpan to detect frequent network patterns. To this end the ParSeMiS project is used, which can be found on https://github.com/timtadh/parsemis. Given a set of graphs, frequent subgraph mining (abbrv. FSM) is an approach to find the subgraphs within these graphs that pass a given frequency threshold. GSpan is an extension based algorithm that takes a graph set as its input and produces all frequent connected subgraphs according to the given frequency threshold.
Once patterns are identified, the textual pattern description can automatically be converted into a graphical representation. 
Furthermore, information about the distribution of patterns among the selected set of models can be retrieved.
The workflow can be applied to a custom set of models or to models already existing in the graph database MaSyMoS.

## Proceeding
The following illustrates the proceeding from getting an appropriate input file for working with ParSeMiS to the post-processing for image files of the patterns found and computing the pattern distribution. For every step the bash command line is used to invoke scripts and tools. The config-file contains the required parameters and must be adapted. The script-names contain the number of the step in their name.  Execute for every step the corresponding shell-script.

### Step 1
The shell-script queries MaSyMoS to get the reaction networks of all SBML models existing in the database as json-file. As input for ParSeMiS a dot-file is used. Therefore, the json-file gets converted into the dot-format by a php-script. The resulting file contains one big graph with all nodes and edges. Because the nodes from different models are unconnected, the big graph is split into its unconnected subgraphs. 

### Step 2
By executing the shell-script, ParSemiS runs with the parameters specified in the config, namely a minimum and maximum frequency. The output is a dot file, which contains all the patterns fulfilling the given frequency interval.

### Step 3a
Appearence properties are added to the found patterns for the visualisation. Finally, the file is split into separate files and an image file is created for each pattern.

### Step 3b
In this step the frequency of the patterns within each model are determined
#### Part 1
For every pattern a Cypher-query gets created that will return the frequency per model.
#### Part 2
Each Cypher-query is executed on MaSyMoS.

## Exemplary Application
We analyzed Release 29 of BioModels Database (in the following referred to as R29) containing 575 curated models and, in addition, compared the results to BioModels first release containing only 30 curated models (in the following referred to as R1).
Each reaction or species belongs to exactly one SBML-model. For R29 there exist 18852 reaction nodes and 16843 species nodes in total.
Compared with the first release (R1), the rapid growth of models becomes obvious.
Data set R1 contains only 30 curated models having 736 reactions and 425 species, respectively.
An examplary pattern we found is the smallest biologically meaningful circle with two species and two reactions, where each species is a reactant for one reaction and a product of the other reaction. This circle is contained in 330 models of data set R29 and in 25 models of data set R1.
