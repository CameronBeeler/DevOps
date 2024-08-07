#!/bin/bash

mkdir -p ${BUILD_SOURCESDIRECTORY}/reference
echo "Explore text output file test" > ${BUILD_SOURCESDIRECTORY}/reference/explore_out.txt
echo "$BUILD_SOURCEBRANCHNAME" > ${BUILD_SOURCESDIRECTORY}/reference/branch_name.txt