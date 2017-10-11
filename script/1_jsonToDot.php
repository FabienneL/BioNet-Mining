<?php

# PHP Script which is used by the processNetworks-script; converts the json-format to a dot-format that can then be used by ParSeMiS

$json = json_decode (file_get_contents ($argv[1]));
$returns = $json->data;

echo "digraph { \n";
foreach ($returns as $tuple)
{
	echo $tuple[0] . " [label=\"SBML_REACTION\"];" . "\n";
	echo $tuple[2] . " [label=\"SBML_SPECIES\"];" . "\n";
	if ( $tuple[1] == "HAS_REACTANT") {
		echo $tuple[2] . " -> " . $tuple[0] . " [label=\"IS_REACTANT\"];" . "\n";
	} elseif ( $tuple[1] == "HAS_MODIFIER") {
		echo $tuple[2] . " -> " . $tuple[0] . " [label=\"IS_MODIFIER\"];" . "\n";
	} else {
		echo $tuple[0] . " -> " . $tuple[2] . " [label=\"HAS_PRODUCT\"];" . "\n";
	}
}
echo "} \n";

?>
