# Installation Guide

Complete installation guide for the Dual-Output Image Compressor.

## 🚀 Quick Installation

### Automated Installation (Recommended)

The easiest way to install is using our automated installation script:

```bash
# Clone the repository
git clone https://github.com/your-username/dual-output-image-compressor.git
cd dual-output-image-compressor

# Run installation script
./scripts/install.sh
```

The installation script will:
- ✅ Check system compatibility
- ✅ Install Homebrew (if needed)
- ✅ Install ImageMagick and bc
- ✅ Set proper permissions
- ✅ Create system-wide symlink (`dual-compressor`)
- ✅ Verify installation

After installation, you can use either:
```bash
dual-compressor [options]                              # System command
./bin/dual_output_image_compressor.sh [options]       # Direct script
```

## 🔧 Manual Installation

### Step 1: System Requirements

**Supported Systems:**
- macOS 10.15+ (optimized for Apple Silicon M4 Ultra)
- Linux (Ubuntu 20.04+, CentOS 8+, etc.)
- Other Unix-like systems

**Minimum Hardware:**
- 4 CPU cores (8+ recommended)
- 8GB RAM (16GB+ recommended)
- 10GB free disk space for processing

### Step 2: Install Dependencies

**macOS (via Homebrew):**
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install imagemagick bc
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install imagemagick bc
```

**CentOS/RHEL:**
```bash
sudo yum update
sudo yum install ImageMagick bc
```

**Fedora:**
```bash
sudo dnf update
sudo dnf install ImageMagick bc
```

### Step 3: Download and Setup

```bash
# Clone repository
git clone https://github.com/your-username/dual-output-image-compressor.git
cd dual-output-image-compressor

# Make scripts executable
chmod +x bin/dual_output_image_compressor.sh
chmod +x scripts/install.sh
chmod +x examples/batch-processing.sh
```

### Step 4: Verify Installation

```bash
# Test dependencies
magick -version
bc --version

# Test script
./bin/dual_output_image_compressor.sh -h
```

## ⚙️ Configuration

### Hardware Optimization

The script is pre-configured for Apple M4 Ultra, but you can optimize for your hardware:

**Edit the script or create a config file:**
```bash
# Copy example configuration
cp examples/config.example.sh config.local.sh

# Edit for your hardware
nano config.local.sh
```

**Common Hardware Configurations:**

| Hardware | Cores | Max Jobs | Memory Limit |
|----------|-------|----------|--------------|
| M4 Ultra | 28 | 20 | 20GB |
| M4 Pro | 14 | 10 | 10GB |
| M4 | 10 | 7 | 6GB |
| Intel 16-core | 16 | 12 | 12GB |
| Intel 8-core | 8 | 6 | 6GB |

### Environment Variables

You can override default settings with environment variables:

```bash
# Set custom parallel jobs
export MAX_JOBS=12

# Set custom memory limits
export MAGICK_MEMORY_LIMIT="8GB"
export MAGICK_MAP_LIMIT="4GB"

# Run with custom settings
./bin/dual_output_image_compressor.sh ~/Photos ~/Output
```

## 🏗️ Advanced Installation

### System-wide Installation

Create a system-wide installation that all users can access:

```bash
# Install to /opt (requires sudo)
sudo mkdir -p /opt/dual-compressor
sudo cp -r . /opt/dual-compressor/

# Create system symlink
sudo ln -s /opt/dual-compressor/bin/dual_output_image_compressor.sh /usr/local/bin/dual-compressor

# Make accessible to all users
sudo chmod +x /usr/local/bin/dual-compressor
```

### Docker Installation

For containerized deployment:

```bash
# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    imagemagick \
    bc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .
RUN chmod +x bin/dual_output_image_compressor.sh

ENTRYPOINT ["./bin/dual_output_image_compressor.sh"]
EOF

# Build container
docker build -t dual-compressor .

# Run with volume mounts
docker run -v "$(pwd)/input:/input" -v "$(pwd)/output:/output" \
    dual-compressor /input /output -m1
```

## 🔍 Troubleshooting

### Common Issues

**"ImageMagick fehlt" Error**
```bash
# macOS
brew install imagemagick

# Ubuntu
sudo apt install imagemagick

# CentOS
sudo yum install ImageMagick
```

**"bc fehlt" Error**
```bash
# macOS
brew install bc

# Ubuntu
sudo apt install bc

# CentOS
sudo yum install bc
```

**Permission Denied**
```bash
chmod +x bin/dual_output_image_compressor.sh
```

**Memory Allocation Errors**
```bash
# Reduce memory limits in script
export MAGICK_MEMORY_LIMIT="4GB"
export MAGICK_MAP_LIMIT="2GB"
```

**Slow Performance**
- Check CPU usage: `top -p $(pgrep dual_output)`
- Verify ImageMagick is using multiple threads
- Consider reducing `MAX_JOBS` for systems with limited RAM
- Ensure input/output directories are on fast storage (SSD)

### System-Specific Notes

**macOS Monterey and later:**
- Gatekeeper may block execution of downloaded scripts
- Run: `sudo spctl --master-disable` (temporarily)
- Or: Right-click → "Open With" → Terminal

**Linux with SELinux:**
- May need to set proper SELinux contexts
- Run: `sudo setsebool -P use_nfs_home_dirs on` (if using NFS)

**Network Attached Storage:**
- Processing over network storage will be slower
- Consider copying files locally first, then processing
- Use faster network protocols (NFS vs SMB)

### Performance Tuning

**For Maximum Speed:**
```bash
# Use local SSD storage
mkdir -p /tmp/processing
cp -r ~/large_photo_directory /tmp/processing/
dual-compressor /tmp/processing /tmp/output -m1
mv /tmp/output ~/final_output/
rm -rf /tmp/processing
```

**For Memory-Constrained Systems:**
```bash
# Reduce parallel jobs
export MAX_JOBS=4
dual-compressor ~/Photos ~/Output -k500
```

**For Large Batch Jobs:**
```bash
# Process in smaller chunks
find ~/Photos -name "*.jpg" | head -100 | xargs -I {} cp {} ./batch1/
dual-compressor ./batch1 ./output1 -m1

find ~/Photos -name "*.jpg" | tail -n +101 | head -100 | xargs -I {} cp {} ./batch2/
dual-compressor ./batch2 ./output2 -m1
```

## 📋 Verification Checklist

After installation, verify everything works:

- [ ] `magick -version` shows ImageMagick 7.x
- [ ] `bc --version` shows calculator version
- [ ] `./bin/dual_output_image_compressor.sh -h` displays help
- [ ] Test processing creates both JPEG and PNG outputs
- [ ] System resources are utilized efficiently during processing
- [ ] Output file sizes match target specifications

## 🔄 Updates

### Updating to Latest Version

```bash
# In project directory
git fetch origin
git pull origin main

# Re-run installation if needed
./scripts/install.sh
```

### Version Checking

```bash
# Check current version (look for version in script comments)
head -20 bin/dual_output_image_compressor.sh | grep -i version

# Check for updates
git remote show origin
```

## 📞 Support

If you encounter issues during installation:

1. **Check the logs**: Most errors are displayed with helpful messages
2. **Verify dependencies**: Ensure ImageMagick and bc are properly installed
3. **Check permissions**: Scripts must be executable
4. **Review system requirements**: Ensure sufficient RAM and CPU
5. **Open an issue**: [GitHub Issues](https://github.com/your-username/dual-output-image-compressor/issues)

---

**Ready to compress? Start with:** `dual-compressor ~/Pictures ~/compressed_output -m1` 🚀