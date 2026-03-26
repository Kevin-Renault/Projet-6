#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ENV_FILE="$SCRIPT_DIR/../.env"

DEFAULT_ANGULAR_DIR=Frontend
DEFAULT_JAVA_DIR=Backend

if [ -f "$ENV_FILE" ]; then
    set -o allexport
    source "$ENV_FILE"
    set +o allexport
fi

: "${ANGULAR_DIR:=$DEFAULT_ANGULAR_DIR}"
: "${JAVA_DIR:=$DEFAULT_JAVA_DIR}"

echo "ANGULAR_DIR=$ANGULAR_DIR" >> "$GITHUB_ENV"
echo "JAVA_DIR=$JAVA_DIR" >> "$GITHUB_ENV"

