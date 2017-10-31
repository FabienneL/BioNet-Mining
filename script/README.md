# Getting started
The following illustrates the procedure from getting an appropriate input file for working with ParSeMiS to the post-processing for image files of the patterns retrieved and computing the pattern distribution. For every step the bash command line is used to invoke scripts and tools. The config-file contains the required parameters and must be adapted. The script-names contain the number of the step in their name.  Execute for every step the corresponding shell-script.

## Step 1
The shell-script queries MaSyMoS to get the reaction networks of all SBML models existing in the database as json-file. As input for ParSeMiS a dot-file is used. Therefore, the json-file gets converted into the dot-format by a php-script. The resulting file contains one big graph with all nodes and edges. Because the nodes from different models are unconnected, the big graph is split into its unconnected subgraphs. 

## Step 2
By executing the shell-script, ParSemiS runs with the parameters specified in the config, namely a minimum and maximum frequency. The output is a dot file, which contains all the patterns fulfilling the given frequency interval.

## Step 3a
Appearence properties are added to the retrieved patterns for the visualisation. Finally, the file is split into separate files and an image file is created for each pattern.

## Step 3b
In this step the frequency of the patterns within each model are determined.
* For every pattern a Cypher-query gets created that will return the frequency per model
* Each Cypher-query is executed on MaSyMoS
* The resulting json-files are converted to csv
* A feature matrix is created that contains in each row a model and the frequencies of the patterns
