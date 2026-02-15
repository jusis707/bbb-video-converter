#!/bin/bash
set -e

echo "=== Starting BBB Recorder with Audio Routing ==="

# 1. Start PulseAudio
pulseaudio -D --exit-idle-time=-1 --system=false --disallow-exit=true

# 2. Wait for PulseAudio to be ready
while ! pactl info >/dev/null 2>&1; do
    sleep 1
done

# 3. Create Virtual Sink
pactl load-module module-null-sink sink_name=virtual_sink sink_properties=device.description=Virtual_Sink

# 4. Route the Sink's Monitor to the default source
pactl set-default-sink virtual_sink
pactl set-default-source virtual_sink.monitor

# 5. Start Xvfb and Fluxbox
Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &
fluxbox &
sleep 2

export DISPLAY=:99

# --- AUTO-KILL LOGIC ---
# Buffer increased from 20 to 120 for long recordings
BUFFER=120
KILL_LIMIT=$((RECORDING_DURATION + BUFFER))

echo "🚀 Recorder starting. Expected duration: ${RECORDING_DURATION}s."
echo "⏱️  Hard safety timeout set to ${KILL_LIMIT}s."
echo "versija 1.1 - Long Recording Fix"

# Use timeout to prevent orphaned containers if node hangs
timeout --foreground ${KILL_LIMIT}s node recorder.js || {
    EXIT_STATUS=$?
    if [ $EXIT_STATUS -eq 124 ]; then
        echo "⚠️  TIMEOUT: Safety limit reached. Force killing."
    else
        echo "ℹ️  Recorder exited with status $EXIT_STATUS"
    fi
}

# Final cleanup
echo "Cleaning up processes..."
killall -9 node ffmpeg Xvfb fluxbox pulseaudio 2>/dev/null || true
exit 0