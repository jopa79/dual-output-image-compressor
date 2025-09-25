#!/bin/bash

# Example configuration file for Dual-Output Image Compressor
# Copy this to config.local.sh and modify as needed
# config.local.sh is ignored by git for personal settings

# =============================================================================
# HARDWARE CONFIGURATION
# =============================================================================

# Processor Configuration (adjust based on your hardware)
# Apple M4 Ultra: 28 cores
# Apple M4 Pro: 14 cores
# Apple M4: 10 cores
# Intel/AMD: Check with `nproc` or `sysctl -n hw.ncpu`
TOTAL_CORES=28

# Maximum parallel jobs
# Recommended: 70-80% of total cores for dual processing
# M4 Ultra: 20 jobs (allows for 2 sub-processes per job)
# M4 Pro: 10 jobs
# M4: 7 jobs
MAX_JOBS=20

# =============================================================================
# TARGET SIZE PRESETS
# =============================================================================

# Default target size in bytes (1MB = 1048576 bytes)
DEFAULT_TARGET_SIZE=1048576

# Predefined size presets (in bytes)
SIZE_THUMBNAIL=204800      # 200KB - thumbnails, icons
SIZE_SOCIAL=819200         # 800KB - social media posts
SIZE_WEB=1048576          # 1MB - web images
SIZE_PORTFOLIO=2097152    # 2MB - portfolio images
SIZE_PRINT=5242880        # 5MB - print-ready images
SIZE_ARCHIVE=3145728      # 3MB - archive quality

# Tolerance as percentage of target size (5% = 0.05)
TOLERANCE_PERCENTAGE=0.05

# =============================================================================
# IMAGEMAGICK OPTIMIZATION
# =============================================================================

# Memory limits for ImageMagick
# Adjust based on available RAM
# 16GB RAM: Use 10GB memory, 5GB map, 20GB disk
# 32GB RAM: Use 20GB memory, 10GB map, 40GB disk
# 64GB RAM: Use 40GB memory, 20GB map, 80GB disk
MAGICK_MEMORY_LIMIT="10GB"
MAGICK_MAP_LIMIT="5GB"
MAGICK_DISK_LIMIT="20GB"

# Thread limits (usually = TOTAL_CORES)
MAGICK_THREAD_LIMIT=$TOTAL_CORES
OMP_NUM_THREADS=$TOTAL_CORES

# =============================================================================
# JPEG OPTIMIZATION SETTINGS
# =============================================================================

# Quality range for iterative JPEG optimization
JPEG_MIN_QUALITY=20
JPEG_MAX_QUALITY=95
JPEG_DEFAULT_QUALITY=75

# Maximum iterations for binary search
JPEG_MAX_ITERATIONS=5

# Gaussian blur amount (0.05 = subtle noise reduction)
JPEG_GAUSSIAN_BLUR=0.05

# Chroma subsampling (4:2:0 = standard web compression)
JPEG_SAMPLING_FACTOR="4:2:0"

# =============================================================================
# PNG OPTIMIZATION SETTINGS
# =============================================================================

# Color reduction levels by strategy
PNG_STRATEGY_1_COLORS=256    # Conservative
PNG_STRATEGY_2_COLORS=128    # Moderate
PNG_STRATEGY_3_COLORS=64     # Aggressive

# Posterization levels
PNG_POSTERIZE_MODERATE=8
PNG_POSTERIZE_AGGRESSIVE=6

# Scale factors for size optimization
PNG_SCALE_FACTORS=(100 90 80)  # 100%, 90%, 80%

# =============================================================================
# OUTPUT CONFIGURATION
# =============================================================================

# Default output subdirectories
DEFAULT_JPEG_SUBDIR="jpeg_compressed"
DEFAULT_PNG_SUBDIR="png_compressed"

# Filename suffix for compressed images
COMPRESSED_SUFFIX="_compressed"

# =============================================================================
# PERFORMANCE MONITORING
# =============================================================================

# Progress update interval in seconds
PROGRESS_UPDATE_INTERVAL=2

# Enable performance logging (true/false)
ENABLE_PERFORMANCE_LOGGING=false

# Performance log directory
PERFORMANCE_LOG_DIR="./logs"

# =============================================================================
# BATCH PROCESSING PRESETS
# =============================================================================

# Web optimization preset
WEB_PRESET_SIZE=$SIZE_WEB
WEB_PRESET_OUTPUT="./web_optimized"

# Social media preset
SOCIAL_PRESET_SIZE=$SIZE_SOCIAL
SOCIAL_PRESET_OUTPUT="./social_ready"

# Portfolio preset
PORTFOLIO_PRESET_SIZE=$SIZE_PORTFOLIO
PORTFOLIO_PRESET_OUTPUT="./portfolio_ready"

# Thumbnail preset
THUMBNAIL_PRESET_SIZE=$SIZE_THUMBNAIL
THUMBNAIL_PRESET_OUTPUT="./thumbnails_ready"

# =============================================================================
# ADVANCED SETTINGS
# =============================================================================

# Temporary directory for processing
# Leave empty to use system default (/tmp)
CUSTOM_TEMP_DIR=""

# Enable verbose output (true/false)
VERBOSE_OUTPUT=false

# Skip existing files (true/false)
SKIP_EXISTING=false

# Cleanup temporary files after processing (true/false)
CLEANUP_TEMP=true

# Enable color output (true/false)
ENABLE_COLORS=true

# =============================================================================
# EXAMPLE USAGE WITH CUSTOM CONFIG
# =============================================================================

# To use this config, copy it to config.local.sh and source it:
#
# cp config.example.sh config.local.sh
# # Edit config.local.sh with your settings
#
# Then modify your scripts to source the config:
# source ./config.local.sh 2>/dev/null || echo "Using default settings"

# =============================================================================
# HARDWARE-SPECIFIC PRESETS
# =============================================================================

# Uncomment and modify the preset for your hardware:

# # Apple M4 Ultra (28 cores, 64GB+ RAM)
# TOTAL_CORES=28
# MAX_JOBS=20
# MAGICK_MEMORY_LIMIT="20GB"
# MAGICK_MAP_LIMIT="10GB"

# # Apple M4 Pro (14 cores, 32GB RAM)
# TOTAL_CORES=14
# MAX_JOBS=10
# MAGICK_MEMORY_LIMIT="10GB"
# MAGICK_MAP_LIMIT="5GB"

# # Apple M4 (10 cores, 16GB RAM)
# TOTAL_CORES=10
# MAX_JOBS=7
# MAGICK_MEMORY_LIMIT="6GB"
# MAGICK_MAP_LIMIT="3GB"

# # Intel/AMD High-end (16+ cores, 32GB+ RAM)
# TOTAL_CORES=16
# MAX_JOBS=12
# MAGICK_MEMORY_LIMIT="12GB"
# MAGICK_MAP_LIMIT="6GB"

# # Intel/AMD Mid-range (8-12 cores, 16GB RAM)
# TOTAL_CORES=8
# MAX_JOBS=6
# MAGICK_MEMORY_LIMIT="6GB"
# MAGICK_MAP_LIMIT="3GB"