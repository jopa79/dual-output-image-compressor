# GUI Installation Guide

## Installing the Modern Python GUI

The Dual-Output Image Compressor features a beautiful, modern GUI built with CustomTkinter.

### Prerequisites

- Python 3.8 or higher
- pip (Python package manager)
- macOS, Linux, or Windows

### Installation Steps

#### 1. Check Python Version

```bash
python3 --version
```

Make sure you have Python 3.8 or higher installed.

#### 2. Install Dependencies

Navigate to the project directory and install the required Python packages:

```bash
# From the project root directory
pip3 install -r requirements.txt
```

This will install:
- **customtkinter**: Modern UI framework
- **Pillow**: Image processing library (dependency of customtkinter)

#### 3. Verify Installation

```bash
python3 -c "import customtkinter; print('CustomTkinter installed successfully!')"
```

If you see "CustomTkinter installed successfully!", you're ready to go!

### Running the GUI

```bash
python3 ./bin/dual_output_image_compressor_gui.py
```

Or make it executable and run directly:

```bash
chmod +x ./bin/dual_output_image_compressor_gui.py
./bin/dual_output_image_compressor_gui.py
```

## GUI Features

### Main Features

- **🎨 Modern Dark Mode Interface**: Beautiful gradient-based design
- **📁 Directory Browser**: Easy point-and-click directory selection
- **⚡ Quick Presets**: One-click presets for common use cases
- **🎚️ Interactive Slider**: Adjust parallel jobs with visual feedback
- **📊 Real-time Progress**: Live progress bar and status updates
- **📝 Integrated Log**: Color-coded log viewer with auto-scroll
- **🔴 Process Control**: Start/Stop buttons for full control

### Preset Options

1. **🌐 Web** - 300KB (optimized for web delivery)
2. **📱 Social Media** - 800KB (perfect for social platforms)
3. **📄 Standard** - 1MB (balanced quality/size)
4. **✨ High Quality** - 2MB (superior quality)
5. **🖨️ Print** - 3MB (print-ready files)

### Interface Layout

```
┌─────────────────────────────────────────────┐
│  🚀 Dual-Output Image Compressor            │
│  Hochleistungs-Bildkompression              │
├─────────────────────────────────────────────┤
│  ⚙️ Konfiguration                           │
│  📁 Input Directory:  [Browse]              │
│  💾 Output Directory: [Browse]              │
│  📏 Target Size: [100] [KB|MB]              │
│  ⚡ Parallel Jobs: [●────────] 20 Jobs      │
├─────────────────────────────────────────────┤
│  ⚡ Quick Presets                           │
│  [🌐 Web] [📱 Social] [📄 Std] [✨ HQ] [🖨️] │
├─────────────────────────────────────────────┤
│  [🚀 Start Compression] [⏹️ Stop]          │
├─────────────────────────────────────────────┤
│  📊 Status                                  │
│  Progress: [████████░░] 80%                │
│  📝 Log:                                    │
│  ┌───────────────────────────────────────┐ │
│  │ [10:30:15] Starting compression...    │ │
│  │ [10:30:16] Processing image 1/50...   │ │
│  │ [10:30:17] ✓ Image 1 completed        │ │
│  └───────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

## Troubleshooting

### Issue: "No module named 'customtkinter'"

**Solution:**
```bash
pip3 install customtkinter
```

### Issue: "No module named 'PIL'"

**Solution:**
```bash
pip3 install Pillow
```

### Issue: GUI window is too small

**Solution:**
The GUI has a minimum size of 800x700 pixels and can be resized. If your screen is smaller, you can modify the minimum size in the script.

### Issue: Script not found error

**Solution:**
Make sure you're running the GUI from the project root directory, or that the `dual_output_image_compressor.sh` script exists in the `bin/` directory.

### Issue: Permission denied

**Solution:**
```bash
chmod +x ./bin/dual_output_image_compressor_gui.py
chmod +x ./bin/dual_output_image_compressor.sh
```

## System-Specific Notes

### macOS

CustomTkinter works great on macOS with both Intel and Apple Silicon processors.

```bash
# If you encounter SSL certificate issues:
pip3 install --upgrade certifi
```

### Linux

On some Linux distributions, you may need to install tkinter separately:

```bash
# Ubuntu/Debian
sudo apt-get install python3-tk

# Fedora
sudo dnf install python3-tkinter

# Arch Linux
sudo pacman -S tk
```

### Windows

CustomTkinter works on Windows 10 and 11. Make sure to use `python` instead of `python3`:

```bash
python -m pip install -r requirements.txt
python ./bin/dual_output_image_compressor_gui.py
```

## Advanced Usage

### Creating a Desktop Shortcut (macOS)

1. Open Automator
2. Create a new "Application"
3. Add "Run Shell Script" action
4. Enter:
   ```bash
   cd /path/to/dual-output-image-compressor
   python3 ./bin/dual_output_image_compressor_gui.py
   ```
5. Save as "Image Compressor" in Applications

### Creating an Alias

Add to your `.bashrc` or `.zshrc`:

```bash
alias compressor-gui='python3 /path/to/dual-output-image-compressor/bin/dual_output_image_compressor_gui.py'
```

Then run from anywhere:
```bash
compressor-gui
```

## Updating

To update to the latest version of CustomTkinter:

```bash
pip3 install --upgrade customtkinter
```

## Uninstalling

To remove the Python dependencies:

```bash
pip3 uninstall customtkinter Pillow
```

## Support

For issues specific to the GUI:
- Check the log viewer in the application
- Ensure all dependencies are installed
- Verify the bash script works independently

For CustomTkinter-specific issues:
- Visit: https://github.com/TomSchimansky/CustomTkinter

---

**Enjoy the modern GUI experience! 🚀**
