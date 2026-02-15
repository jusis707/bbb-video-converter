const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

async function recordPresentation() {
  const url = process.env.PRESENTATION_URL;
  const duration = parseInt(process.env.RECORDING_DURATION || '30');
  const recordingId = process.env.RECORDING_ID || 'output';
  
  console.log(`\n=== BBB RECORDER: ${recordingId} ===`);
  console.log(`📹 URL: ${url}`);
  console.log(`⏱️  Duration: ${duration} seconds`);

  // Create directories if missing
  ['videos', 'screenshots'].forEach(dir => {
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  });

  const videoPath = path.join('/app/videos', `${recordingId}.mp4`);

  const browser = await chromium.launch({
    headless: false,
    args: [
      `--app=${url}`, // Fullscreen mode
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-background-timer-throttling', // Fix for long recordings
      '--disable-backgrounding-occluded-windows',
      '--disable-renderer-backgrounding',
      '--start-maximized',
      '--window-size=800,600',
      '--autoplay-policy=no-user-gesture-required'
    ]
  });

  const context = await browser.newContext({ viewport: { width: 800, height: 600 } });
  const page = await context.newPage();
  
  // Increase navigation timeout for slow BBB servers
  await page.goto(url, { waitUntil: 'networkidle', timeout: 60000 });

  console.log('🎤 Starting FFmpeg with Fragmented MP4 Fix...');
  const ffmpeg = spawn('ffmpeg', [
    '-y',
    '-f', 'x11grab',
    '-video_size', '800x600',
    '-framerate', '30',
    '-i', ':99.0',
    '-f', 'pulse',
    '-i', 'default',
    '-af', 'aresample=async=1,adelay=3000|3000',
    '-c:v', 'libx264',
    '-preset', 'ultrafast',
    '-vsync', '1',
    '-pix_fmt', 'yuv420p',
    // movflags fix: ensures the video is playable even if process is killed
    '-movflags', '+frag_keyframe+empty_moov+faststart', 
    videoPath
  ]);

  // Log FFmpeg errors for debugging
  ffmpeg.stderr.on('data', (data) => {
    if (data.toString().includes('Error')) {
       console.error(`FFmpeg Error: ${data}`);
    }
  });

  // Start playback
  try {
    const playButton = page.locator('button[aria-label="Play"], .vjs-big-play-button').first();
    await playButton.click();
    console.log('▶️ Playback started');
  } catch (e) {
    await page.evaluate(() => {
      const v = document.querySelector('video');
      if (v) v.play();
    });
  }

  // Wait for the duration
  await page.waitForTimeout(duration * 1000);

  console.log('⏹️ Stopping Recording...');
  
  // Clean shutdown sequence
  await browser.close();
  
  // Sending SIGINT (Ctrl+C) is cleaner for FFmpeg than writing 'q'
  ffmpeg.kill('SIGINT');
  
  ffmpeg.on('close', (code) => {
    console.log(`✅ Final video saved as: ${videoPath} (Exit Code: ${code})`);
    process.exit(0);
  });
}

recordPresentation();