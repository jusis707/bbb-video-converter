#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

cd /root/pl
RECORDING_ID=$1


# This ensures this script always uses a unique stack for this ID
export COMPOSE_PROJECT_NAME="rec_${RECORDING_ID}"
# ---------------------

BASE_URL="https://bbb-worker.XX/playback/presentation/2.3"
METADATA_PATH="/var/bigbluebutton/published/presentation/$RECORDING_ID/metadata.xml"

if [ -z "$RECORDING_ID" ]; then
    echo "Usage: ./run-recorder.sh <recording_id>"
    exit 1
fi

# Extract duration logic...
if [ -f "$METADATA_PATH" ]; then
    RAW_DURATION=$(grep -oPm1 "(?<=<duration>)[^<]+" "$METADATA_PATH")
    export RECORDING_DURATION=$(( (RAW_DURATION / 1000) + 15 ))
    echo "✅ Found metadata. Recording Duration: $RECORDING_DURATION seconds."
else
    echo "⚠️ Metadata not found. Using default 60s."
    export RECORDING_DURATION=60
fi

export RECORDING_ID="$RECORDING_ID"
export PRESENTATION_URL="$BASE_URL/$RECORDING_ID"

echo "🚀 Starting Docker Compose for Project: $COMPOSE_PROJECT_NAME"

docker compose run --rm -u 0 bbb-recorder