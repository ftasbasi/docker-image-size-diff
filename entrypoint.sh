#!/bin/bash

set -e

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Input parameters
REPO_LIST="${REPO_LIST}"
LAST_RELEASE="${LAST_RELEASE}"
NEW_RELEASE="${NEW_RELEASE}"

# Check if the repo_list value is provided, otherwise set a default value
if [ -z "$REPO_LIST" ]; then
  echo -e "${RED}Error: REPO_LIST input is required.${NC}"
  exit 1
fi

for repo in $REPO_LIST
do
    # Obtain image layers data from Docker Hub and store locally.
    # Immediately pipe to jq as it handles empty results more gracefully
    docker manifest inspect $repo:$LAST_RELEASE | yq -r '.' | jq '.layers' > old_layers.txt
    docker manifest inspect $repo:$NEW_RELEASE | yq -r '.' | jq '.layers' > new_layers.txt

    # Don't perform this operation against lazy built manifests
    if [ $(wc -l < "old_layers.txt") -eq 1 ]; then
        echo -e "${YELLOW}${repo}: old_layers.txt manifest contains no layers, skipping image${NC}"
        continue
    fi

    if [ $(wc -l < "new_layers.txt") -eq 1 ]; then
        echo -e "${YELLOW}${repo}: new_layers.txt manifest contains no layers, skipping image${NC}"
        continue
    fi

    # Save layer digest information for matching
    jq '.[].digest' old_layers.txt > old_image_digests.txt
    jq '.[].digest' new_layers.txt > new_image_digests.txt

    # Find digests that don't exist in the old image, comma separate and escape double quotes
    NEW_DIGESTS=$(grep -v -x -f old_image_digests.txt new_image_digests.txt | paste -sd, - | sed 's/"/\"/g')

    # Get the sizes of all digests that we filtered and convert to megabytes
    echo -e "${GREEN}${repo}:${NC}"
    jq "[.[] | select( .digest | IN($NEW_DIGESTS)) | .size] | add | tonumber/1048576" new_layers.txt | { bc | tr -d '\n' ; echo -e "${NC} MB"; }
    echo
done
