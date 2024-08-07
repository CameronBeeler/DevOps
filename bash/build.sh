#!/bin/bash

echo build.sh executed here!


echo "$CAMERON is the secret value"

echo "$CAMERON is a secret" >> exposed.txt
echo "$Kim is a secret" >> exposed.txt

echo cat exposed.txt file here vvv
echo `cat exposed.txt`
echo cat exposed.txt file here ^^^
cat exposed.txt