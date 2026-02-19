#!/bin/bash

# Check for required environment variables
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable is required"
    exit 1
fi

# if [ -z "$GITHUB_REPOSITORY" ]; then
#     echo "Error: GITHUB_REPOSITORY environment variable is required (format: owner/repo)"
#     exit 1
# fi

# Set defaults
RUNNER_NAME=${RUNNER_NAME:-"docker-runner-$(hostname)"}
RUNNER_LABELS=${RUNNER_LABELS:-"docker"}

# Get registration token
echo "Requesting registration token..."
# REGISTRATION_TOKEN=$(curl -sX POST \
#     -H "Authorization: token ${GITHUB_TOKEN}" \
#     -H "Accept: application/vnd.github.v3+json" \
#     "https://api.github.com/repos/${GITHUB_REPOSITORY}/actions/runners/registration-token" | jq -r .token)

REGISTRATION_TOKEN=$(
    curl -sX \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/orgs/${GITHUB_ORGANIZATION}/actions/runners/registration-token | jq -r .token
)

if [ -z "$REGISTRATION_TOKEN" ] || [ "$REGISTRATION_TOKEN" == "null" ]; then
    echo "Error: Failed to get registration token"
    exit 1
fi

echo "Configuring GitHub Actions Runner..."
./config.sh --url "https://github.com/${GITHUB_ORGANIZATION}" \
    --token "${REGISTRATION_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --labels "${RUNNER_LABELS}" \
    --work "_work" \
    --unattended \
    --replace

# Cleanup function
# cleanup() {
#     echo "Removing runner..."
#     ./config.sh remove --token "${REGISTRATION_TOKEN}"
# }

cleanup() {
    echo "Removing runner..."
    # Get a fresh removal token
    REM_TOKEN=$(curl -sX POST \
      -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -H "Accept: application/vnd.github+json" \
      https://api.github.com/orgs/${GITHUB_ORGANIZATION}/actions/runners/remove-token | jq -r .token)
    
    ./config.sh remove --token "${REM_TOKEN}"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Start the runner
echo "Starting GitHub Actions Runner..."
./run.sh & wait $!
