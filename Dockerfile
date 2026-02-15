FROM mcr.microsoft.com/playwright:v1.41.0-focal

WORKDIR /app

# Install ffmpeg, Xvfb, PulseAudio, and process management utilities
RUN apt-get update && apt-get install -y \
    ffmpeg \
    xvfb \
    x11vnc \
    fluxbox \
    pulseaudio \
    pulseaudio-utils \
    alsa-utils \
    libasound2-plugins \
    psmisc \
    procps \
    coreutils \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package*.json ./
RUN npm install

# Copy the recording script
COPY recorder.js .

# Install Playwright browsers
RUN npx playwright install chromium

# Start script that launches all services
COPY start.sh .
RUN chmod +x start.sh

CMD ["./start.sh"]