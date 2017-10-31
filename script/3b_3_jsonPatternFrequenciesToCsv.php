<?php

# PHP script that converts each json-file resulting from the Cypher queries to receive the pattern frequencies per model to csv-format

$json = json_decode (file_get_contents ($argv[1]));

$columns = $json->columns;
echo $columns[0] . "," . $columns[1] . "," . $columns[2] . "\n";

$data = $json->data;
foreach ($data as $tuple)
{
	echo $tuple[0] . "," . $tuple[1] . "," . $tuple[2] . "\n";
}

?>