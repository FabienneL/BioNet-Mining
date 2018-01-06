# BioNet-Mining Project
The repository contains the scripts for a workflow that identifies frequent structural patterns in biochemical reaction networks encoded in the Systems Biology Markup Language. 
The workflow utilises the frequent subgraph mining algorithm gSpan to detect frequent network patterns. To this end the ParSeMiS project is used, which can be found on https://github.com/timtadh/parsemis. Given a set of graphs, frequent subgraph mining (abbrv. FSM) is an approach to find the subgraphs within these graphs that pass a given frequency threshold. GSpan is an extension based algorithm that takes a graph set as its input and produces all frequent connected subgraphs according to the given frequency threshold.
The workflow can be applied to a custom set of models or to models already existing in our graph database MaSyMoS (core: https://github.com/ronhenkel/masymos-core, data: https://github.com/FabienneL/BioNet-Mining/tree/master/data). 
Once patterns are identified, the textual pattern description can automatically be converted into a graphical representation. 
Furthermore, information about the distribution of patterns among the selected set of models can be retrieved.

## Exemplary Application
We detected patterns for Releases 1, 26, and 29 of BioModels Database. All visualisations of exemplary patterns can be found in https://github.com/FabienneL/BioNet-Mining/tree/master/exemplaryApplication). We further analysed Release 29 of BioModels Database (in the following referred to as R29) containing 575 curated models and, in addition, compared the results to BioModels first release containing only 30 curated models (in the following referred to as R1).
Each reaction or species belongs to exactly one SBML-model. For R29 there exist 18852 reaction nodes and 16843 species nodes in total.
Compared with the first release (R1), the rapid growth of models becomes obvious.
Data set R1 contains only 30 curated models having 736 reactions and 425 species, respectively.
An examplary pattern we found is the smallest biologically meaningful circle with two species and two reactions, where each species is a reactant for one reaction and a product of the other reaction. This circle is contained in 330 models of data set R29 and in 25 models of data set R1.
[![Exemplary pattern in R1](/exemplaryApplication/bioModelsR1/visualisation/splittedFragments26-19.png)](https://github.com/FabienneL/BioNet-Mining/blob/master/exemplaryApplication/bioModelsR1/visualisation) 

Furthermore, it is possible to adapt the scripts to regard semantics for the patterns. A downside is that only 116 out of 575 models in R29 have reaction networks annotated with SBO terms. The following example shows a pattern with species and reactions that are annotated with SBO-terms, particularly it shows the phosphorylation and de-phosphorylation of a polypeptide chain. The pattern is contained in 15 networks retrieved from R29.

[![Exemplary SBO-pattern](/exemplaryApplication/SBO-patterns/visualisation/splittedFragments15-03.png)](https://github.com/FabienneL/BioNet-Mining/tree/master/exemplaryApplication/SBO-patterns/visualisation) 
