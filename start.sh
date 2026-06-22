#!/bin/bash
# Exit immediately if any command returns a non-zero exit status
set -e

# Validation: Ensure that the organization URL for the agent has been configured
if [ -z "$DO_URL" ] || [ "$DO_URL" == "null" ]; then
  echo 1>&2 "error: organization url empty or not configured"
  
  exit 1
fi

# Validation: Ensure the Personal Access Token (PAT) is provided
if [ -z "$DO_PAT_FILE" ]; then
  if [ -z "$DO_PAT" ]; then
    echo 1>&2 "error: missing DO_PAT environment variable"
    
    exit 1
  fi
  # Store the token safely in a temporary file inside the container
  DO_PAT_FILE=/DOA/.token
  
  echo -n "$DO_PAT" > "$DO_PAT_FILE"
fi

# Unset the raw token variable from memory for basic security hardening and showing PAT for debug
unset DO_PAT

# Required by Microsoft to bypass the block preventing the agent from running as root
export AGENT_ALLOW_RUNASROOT="1"

# Parse the download URL from the JSON response using jq
DOA_DOWNLOAD_URL='https://download.agent.dev.azure.com/agent/4.274.1/vsts-agent-linux-x64-4.274.1.tar.gz'

if [ -z "$DOA_DOWNLOAD_URL" ] || [ "$DOA_DOWNLOAD_URL" == "null" ]; then
  echo 1>&2 "error: agent download url empty or not configured"
  
  exit 1
fi

echo "2. Downloading and extracting the official agent tarball..."
curl -LsS $DOA_DOWNLOAD_URL | tar -xz

# Load environment variables exported by the extracted agent package
source ./env.sh

echo "3. Registering and configuring the agent against Azure DevOps..."
./config.sh --unattended \
  --agent "${DO_AGENT_NAME:-DOA-Docker-"$(hostname)"}" \
  --url "$DO_URL" \
  --auth PAT \
  --token $(cat "$DO_PAT_FILE") \
  --pool "${DO_POOL:-Default}" \
  --work _work \
  --replace \
  --acceptteeeula

echo "4. Agent successfully configured. Launching worker listener..."
# Switch execution to the listener loop (keeps the container alive and waiting for pipeline jobs)
./run.sh "$@" # Questo aggiunge la possibilità di ereditare i parametri dalla shell, se scrivo "--once" quando do il run, lo passa allo script "run.sh" all'interno del container