# BigBlueButtonv.3 Video Converter

A high-performance, containerized tool designed to transform BigBlueButton (BBB) playback presentations into standalone, shareable MP4 video files.

By leveraging **Playwright** for browser automation, **Xvfb** for virtual display management, and **FFmpeg** for high-quality encoding, this tool captures both presentation visuals and synchronized audio in a headless environment.

---

## 🚀 Key Features

* **Automated Metadata Extraction**: Automatically detects recording duration from BBB `metadata.xml`.
* **Virtual Audio Routing**: Uses PulseAudio null-sinks to capture clean system audio without hardware requirements.
* **Resilient Encoding**: Uses FFmpeg with fragmented MP4 flags to ensure video integrity even if a process is interrupted.
* **Concurrency Ready**: Utilizes unique Docker Compose project names to allow multiple recording tasks on the same host.
* **Headless Execution**: Runs entirely inside Docker, requiring no physical monitor or audio hardware.

---

## 🛠️ Prerequisites

* **Docker** and **Docker Compose** installed.
* Access to a BigBlueButton server (the tool reads from `/var/bigbluebutton/published/`).
* A user with permissions to execute Docker commands.

---

## ⚙️ Configuration

Before running the converter, update the variables in `run-recorder.sh` to match your environment:

```bash
# The directory where you cloned this repository
WORK_FOLDER="/root/pl"

# The base URL for your BBB playback (usually ends in /playback/presentation/2.3)
BASE_URL="[https://your-bbb-domain.com/playback/presentation/2.3](https://your-bbb-domain.com/playback/presentation/2.3)"

Usage: ./run-recorder.sh <recording_id>
