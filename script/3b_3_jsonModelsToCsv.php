<?php

# PHP script that converts the models.json to a csv-format

$json = json_decode (file_get_contents ($argv[1]));

$data = $json->data;
foreach ($data as $tuple)
{
	echo $tuple[0] . "," . $tuple[1] . PHP_EOL;
}

?>