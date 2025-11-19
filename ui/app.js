// Dual-Output Image Compressor - Web UI JavaScript

// State management
let compressionProcess = null;
let startTime = null;
let timerInterval = null;

// Initialize slider value display
document.addEventListener('DOMContentLoaded', function() {
    const slider = document.getElementById('parallel-jobs');
    const valueDisplay = document.getElementById('jobs-value');

    slider.addEventListener('input', function() {
        valueDisplay.textContent = this.value;
    });

    addLog('Bereit zum Starten...', 'info');
});

// Directory selection (browser-based file selection)
function selectDirectory(inputId) {
    // Note: Full directory access requires Electron or similar framework
    // For now, we'll use a simple prompt
    const currentValue = document.getElementById(inputId).value;
    const message = inputId === 'input-dir'
        ? 'Geben Sie den Pfad zum Eingabeverzeichnis ein:'
        : 'Geben Sie den Pfad zum Ausgabeverzeichnis ein:';

    const newPath = prompt(message, currentValue || '');

    if (newPath) {
        document.getElementById(inputId).value = newPath;
        addLog(`${inputId === 'input-dir' ? 'Eingabe' : 'Ausgabe'}verzeichnis gesetzt: ${newPath}`, 'info');
    }
}

// Quick preset configurations
function setPreset(preset) {
    const sizeValue = document.getElementById('size-value');
    const sizeUnit = document.getElementById('size-unit');

    switch(preset) {
        case 'web':
            sizeValue.value = '300';
            sizeUnit.value = 'k';
            addLog('Web-Preset aktiviert: 300KB Zielgröße', 'info');
            break;
        case 'social':
            sizeValue.value = '800';
            sizeUnit.value = 'k';
            addLog('Social Media-Preset aktiviert: 800KB Zielgröße', 'info');
            break;
        case 'standard':
            sizeValue.value = '1';
            sizeUnit.value = 'm';
            addLog('Standard-Preset aktiviert: 1MB Zielgröße', 'info');
            break;
        case 'quality':
            sizeValue.value = '2';
            sizeUnit.value = 'm';
            addLog('Hohe Qualität-Preset aktiviert: 2MB Zielgröße', 'info');
            break;
        case 'print':
            sizeValue.value = '3';
            sizeUnit.value = 'm';
            addLog('Druck-Preset aktiviert: 3MB Zielgröße', 'info');
            break;
    }
}

// Start compression process
async function startCompression() {
    const inputDir = document.getElementById('input-dir').value;
    const outputDir = document.getElementById('output-dir').value;
    const sizeValue = document.getElementById('size-value').value;
    const sizeUnit = document.getElementById('size-unit').value;
    const parallelJobs = document.getElementById('parallel-jobs').value;

    // Validation
    if (!inputDir) {
        addLog('Fehler: Bitte Eingabeverzeichnis angeben', 'error');
        alert('Bitte geben Sie ein Eingabeverzeichnis an!');
        return;
    }

    if (!outputDir) {
        addLog('Fehler: Bitte Ausgabeverzeichnis angeben', 'error');
        alert('Bitte geben Sie ein Ausgabeverzeichnis an!');
        return;
    }

    // Show progress section
    document.getElementById('progress-section').style.display = 'block';

    // Update button states
    document.getElementById('start-btn').disabled = true;
    document.getElementById('stop-btn').disabled = false;

    // Reset progress
    updateProgress('jpeg', 0);
    updateProgress('png', 0);
    updateStats(0, 0);

    // Start timer
    startTime = Date.now();
    timerInterval = setInterval(updateTimer, 1000);

    // Log start
    const sizeParam = `-${sizeUnit}${sizeValue}`;
    addLog(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`, 'info');
    addLog(`Starte Kompression...`, 'info');
    addLog(`Eingabe: ${inputDir}`, 'info');
    addLog(`Ausgabe: ${outputDir}`, 'info');
    addLog(`Zielgröße: ${sizeValue}${sizeUnit.toUpperCase()}B`, 'info');
    addLog(`Parallel Jobs: ${parallelJobs}`, 'info');
    addLog(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`, 'info');

    try {
        // In a real implementation, this would call a backend API
        // For demonstration, we'll simulate the process
        await simulateCompression(inputDir, outputDir, sizeParam);

        addLog('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', 'success');
        addLog('✓ Kompression erfolgreich abgeschlossen!', 'success');
        addLog(`Ausgabeverzeichnis: ${outputDir}`, 'success');
        addLog('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', 'success');

    } catch (error) {
        addLog(`✗ Fehler: ${error.message}`, 'error');
    } finally {
        // Stop timer
        if (timerInterval) {
            clearInterval(timerInterval);
            timerInterval = null;
        }

        // Reset button states
        document.getElementById('start-btn').disabled = false;
        document.getElementById('stop-btn').disabled = true;
    }
}

// Simulate compression for demonstration
async function simulateCompression(inputDir, outputDir, sizeParam) {
    // This is a simulation - in production, this would call the actual bash script
    // via a backend service (e.g., Node.js server, Python Flask, etc.)

    addLog('⚙️ Initialisiere Kompression...', 'info');
    await sleep(1000);

    const totalFiles = Math.floor(Math.random() * 20) + 10;
    updateStats(0, totalFiles);

    addLog(`📊 ${totalFiles} Bilder gefunden`, 'info');
    await sleep(500);

    // Simulate processing
    for (let i = 0; i < totalFiles; i++) {
        const jpegProgress = Math.min(((i + 1) / totalFiles) * 100, 100);
        const pngProgress = Math.min((i / totalFiles) * 100, 100);

        updateProgress('jpeg', jpegProgress);
        updateProgress('png', pngProgress);
        updateStats(i + 1, totalFiles);

        if (i % 5 === 0) {
            addLog(`Verarbeite Bild ${i + 1}/${totalFiles}...`, 'info');
        }

        await sleep(200);
    }

    // Complete PNG
    updateProgress('png', 100);
    await sleep(500);
}

// Stop compression
function stopCompression() {
    if (timerInterval) {
        clearInterval(timerInterval);
        timerInterval = null;
    }

    addLog('⚠️ Kompression abgebrochen', 'warning');

    document.getElementById('start-btn').disabled = false;
    document.getElementById('stop-btn').disabled = true;
}

// Update progress bar
function updateProgress(type, percentage) {
    const progressBar = document.getElementById(`${type}-progress`);
    const progressText = document.getElementById(`${type}-progress-text`);

    progressBar.style.width = `${percentage}%`;
    progressText.textContent = `${Math.round(percentage)}%`;
}

// Update statistics
function updateStats(processed, total) {
    document.getElementById('processed-files').textContent = processed;
    document.getElementById('total-files').textContent = total;

    // Calculate estimated time
    if (startTime && processed > 0) {
        const elapsed = Date.now() - startTime;
        const avgTimePerFile = elapsed / processed;
        const remaining = (total - processed) * avgTimePerFile;

        document.getElementById('estimated-time').textContent = formatTime(remaining);
    }
}

// Update timer
function updateTimer() {
    if (startTime) {
        const elapsed = Date.now() - startTime;
        document.getElementById('elapsed-time').textContent = formatTime(elapsed);
    }
}

// Format time in MM:SS
function formatTime(milliseconds) {
    const seconds = Math.floor(milliseconds / 1000);
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;

    return `${String(minutes).padStart(2, '0')}:${String(remainingSeconds).padStart(2, '0')}`;
}

// Add log entry
function addLog(message, type = 'info') {
    const logContent = document.getElementById('log-content');
    const timestamp = new Date().toLocaleTimeString('de-DE');

    const logEntry = document.createElement('div');
    logEntry.className = `log-entry ${type}`;

    const timeSpan = document.createElement('span');
    timeSpan.className = 'timestamp';
    timeSpan.textContent = `[${timestamp}] `;

    logEntry.appendChild(timeSpan);
    logEntry.appendChild(document.createTextNode(message));

    logContent.appendChild(logEntry);

    // Auto-scroll to bottom
    logContent.scrollTop = logContent.scrollHeight;
}

// Clear log
function clearLog() {
    const logContent = document.getElementById('log-content');
    logContent.innerHTML = '';
    addLog('Protokoll gelöscht', 'info');
}

// Helper function for delays
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// Backend integration notes:
//
// To connect this UI to the actual bash script, you would need:
//
// 1. A local web server (Node.js/Express, Python Flask, etc.)
// 2. API endpoints that:
//    - Accept compression parameters
//    - Execute the bash script with child_process.spawn() or subprocess
//    - Stream progress updates via WebSocket or Server-Sent Events
//    - Return results when complete
//
// Example Node.js endpoint structure:
//
// POST /api/compress
//   Body: { inputDir, outputDir, sizeParam, parallelJobs }
//   Response: WebSocket stream with progress updates
//
// Example implementation snippet (Node.js):
//
// const { spawn } = require('child_process');
//
// app.post('/api/compress', (req, res) => {
//   const { inputDir, outputDir, sizeParam } = req.body;
//   const process = spawn('./bin/dual_output_image_compressor.sh',
//                          [inputDir, outputDir, sizeParam]);
//
//   process.stdout.on('data', (data) => {
//     // Parse progress and send to frontend via WebSocket
//     ws.send(JSON.stringify({ type: 'progress', data: data.toString() }));
//   });
// });
