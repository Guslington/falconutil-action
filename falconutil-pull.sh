#!/usr/bin/env bash

# This script is used to pull the Falcon Container Sensor container image.
# Uses the falcon-container-sensor-pull.sh script to pull the image.

set -o errexit
set -o nounset
set -o pipefail

# Download the falcon-container-sensor-pull.sh script
curl -O https://raw.githubusercontent.com/CrowdStrike/falcon-scripts/main/bash/containers/falcon-container-sensor-pull/falcon-container-sensor-pull.sh

# Check if the version is provided
VERSION=${INPUT_VERSION:+"--version ${INPUT_VERSION}"}

output=$(bash falcon-container-sensor-pull.sh -u ${INPUT_FALCON_CLIENT_ID} -r ${INPUT_FALCON_REGION} -t falcon-container ${VERSION})

# Extract the image name from the output
image_name=$(echo "$output" | grep ^registry.crowdstrike.com/falcon-container | tail -n 1)

# Check if the image name is empty
if [ -z "$image_name" ]; then
    echo "Failed to get the image name."
    exit 1
fi

# TBD: For the container image, let's extract and copy the binary
FALCONUTIL_BIN_PATH=/usr/bin
# Make sure the directory exists
mkdir -p $FALCONUTIL_BIN_PATH
id=$(docker create "$image_name")
docker cp $id:$FALCONUTIL_BIN_PATH/falconutil $FALCONUTIL_BIN_PATH

# Ensure the binary exists
if [ ! -f $FALCONUTIL_BIN_PATH/falconutil ]; then
    echo "Failed to copy the FCS binary."
    exit 1
fi

# Set the bin path as an output
echo "FALCONUTIL_BIN=$FALCONUTIL_BIN_PATH/fcs" >> $GITHUB_OUTPUT
