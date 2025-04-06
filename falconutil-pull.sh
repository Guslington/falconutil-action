#!/usr/bin/env bash

# This script is used to pull the Falcon Container Sensor container image.
# Uses the falcon-container-sensor-pull.sh script to pull the image.

set -o errexit
set -o nounset
set -o pipefail

log() {
    local log_level=${2:-INFO}
    echo "[$(date +'%Y-%m-%dT%H:%M:%S')] $log_level: $1" >&2
}

validate_required_inputs() {
    local invalid=false
    local -a required_inputs=(
        "INPUT_FALCON_CLIENT_ID"
        "FALCON_CLIENT_SECRET"
        "INPUT_FALCON_REGION"
    )

    for input in "${required_inputs[@]}"; do
        if [[ -z "${!input:-}" ]]; then
            log "Missing required input/env variable '${input#INPUT_}'. Please see the actions's documentation for more details." "ERROR"
            invalid=true
        fi
    done

    [[ "$invalid" == "true" ]] && exit 1
}

validate_required_inputs

# Download the falcon-container-sensor-pull.sh script
curl -O https://raw.githubusercontent.com/CrowdStrike/falcon-scripts/main/bash/containers/falcon-container-sensor-pull/falcon-container-sensor-pull.sh

# Check if the version is provided
VERSION=${INPUT_VERSION:+"--version ${INPUT_VERSION}"}

output=$(bash falcon-container-sensor-pull.sh -u "${INPUT_FALCON_CLIENT_ID}" -r "${INPUT_FALCON_REGION}" -t falcon-container "${VERSION}")

# Extract the image name from the output
image_name=$(echo "$output" | grep "^registry.*.com/falcon-container" | tail -n 1)

# Check if the image name is empty
if [ -z "$image_name" ]; then
    echo "Failed to get the image name."
    exit 1
fi

FALCONUTIL_BIN_PATH=/opt/crowdstrike/bin
# Make sure the directory exists
mkdir -p $FALCONUTIL_BIN_PATH
id=$(docker create "$image_name")
docker cp "$id:/usr/bin/falconutil" $FALCONUTIL_BIN_PATH

# Ensure the binary exists
if [ ! -f $FALCONUTIL_BIN_PATH/falconutil ]; then
    echo "Failed to copy the FCS binary."
    exit 1
fi

log "Successfully pulled Falcon Container Sensor image: $image_name"

# Set the bin path as an output
echo "FALCONUTIL_BIN=$FALCONUTIL_BIN_PATH/falconutil" >> "$GITHUB_OUTPUT"
# Set the image name as an output
echo "FALCON_IMAGE_URI=$image_name" >> "$GITHUB_OUTPUT"
