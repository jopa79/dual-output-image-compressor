#!/bin/bash

# Example batch processing script for multiple directories
# Demonstrates various usage patterns of the dual-output image compressor

# Configuration
COMPRESSOR="$(dirname "$0")/../bin/dual_output_image_compressor.sh"
BASE_OUTPUT_DIR="./batch_results"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Dual-Output Image Compressor - Batch Processing Example${NC}\n"

# Example 1: Process multiple directories with different sizes
process_photo_categories() {
    echo -e "${CYAN}📸 Processing photo categories with optimized sizes...${NC}"

    # Web thumbnails - 300KB
    if [[ -d "./photos/thumbnails" ]]; then
        echo -e "${YELLOW}Processing thumbnails (300KB target)...${NC}"
        "$COMPRESSOR" "./photos/thumbnails" "${BASE_OUTPUT_DIR}/web_thumbnails" -k300
    fi

    # Social media images - 800KB
    if [[ -d "./photos/social" ]]; then
        echo -e "${YELLOW}Processing social media images (800KB target)...${NC}"
        "$COMPRESSOR" "./photos/social" "${BASE_OUTPUT_DIR}/social_media" -k800
    fi

    # Print photos - 3MB
    if [[ -d "./photos/print" ]]; then
        echo -e "${YELLOW}Processing print photos (3MB target)...${NC}"
        "$COMPRESSOR" "./photos/print" "${BASE_OUTPUT_DIR}/print_ready" -m3
    fi
}

# Example 2: Process by date directories
process_by_date() {
    echo -e "${CYAN}📅 Processing photos by date (1MB standard)...${NC}"

    for year_dir in ./photos/20*/; do
        if [[ -d "$year_dir" ]]; then
            year_name=$(basename "$year_dir")
            echo -e "${YELLOW}Processing year: $year_name...${NC}"
            "$COMPRESSOR" "$year_dir" "${BASE_OUTPUT_DIR}/by_year/${year_name}" -m1
        fi
    done
}

# Example 3: Portfolio optimization
optimize_portfolio() {
    echo -e "${CYAN}🎨 Optimizing portfolio with different quality levels...${NC}"

    # High-res portfolio - 5MB
    if [[ -d "./portfolio/high_res" ]]; then
        echo -e "${YELLOW}Processing high-res portfolio (5MB)...${NC}"
        "$COMPRESSOR" "./portfolio/high_res" "${BASE_OUTPUT_DIR}/portfolio_hq" -m5
    fi

    # Web portfolio - 1.5MB
    if [[ -d "./portfolio/web" ]]; then
        echo -e "${YELLOW}Processing web portfolio (1.5MB)...${NC}"
        "$COMPRESSOR" "./portfolio/web" "${BASE_OUTPUT_DIR}/portfolio_web" -k1536
    fi

    # Mobile portfolio - 500KB
    if [[ -d "./portfolio/mobile" ]]; then
        echo -e "${YELLOW}Processing mobile portfolio (500KB)...${NC}"
        "$COMPRESSOR" "./portfolio/mobile" "${BASE_OUTPUT_DIR}/portfolio_mobile" -k500
    fi
}

# Example 4: E-commerce product images
process_ecommerce() {
    echo -e "${CYAN}🛒 Processing e-commerce product images...${NC}"

    # Product main images - 2MB
    if [[ -d "./products/main" ]]; then
        echo -e "${YELLOW}Processing main product images (2MB)...${NC}"
        "$COMPRESSOR" "./products/main" "${BASE_OUTPUT_DIR}/ecommerce_main" -m2
    fi

    # Product thumbnails - 200KB
    if [[ -d "./products/thumbs" ]]; then
        echo -e "${YELLOW}Processing product thumbnails (200KB)...${NC}"
        "$COMPRESSOR" "./products/thumbs" "${BASE_OUTPUT_DIR}/ecommerce_thumbs" -k200
    fi

    # Product galleries - 1MB
    if [[ -d "./products/gallery" ]]; then
        echo -e "${YELLOW}Processing gallery images (1MB)...${NC}"
        "$COMPRESSOR" "./products/gallery" "${BASE_OUTPUT_DIR}/ecommerce_gallery" -m1
    fi
}

# Example 5: Archive processing with logging
archive_with_logging() {
    echo -e "${CYAN}📦 Processing archive with detailed logging...${NC}"

    local log_file="${BASE_OUTPUT_DIR}/processing_log_$(date +%Y%m%d_%H%M%S).txt"
    mkdir -p "$(dirname "$log_file")"

    echo "Archive Processing Log - $(date)" > "$log_file"
    echo "=======================================" >> "$log_file"

    if [[ -d "./archive" ]]; then
        echo -e "${YELLOW}Processing archive (1MB standard) with logging...${NC}"

        # Process with output capture
        "$COMPRESSOR" "./archive" "${BASE_OUTPUT_DIR}/processed_archive" -m1 2>&1 | tee -a "$log_file"

        echo "Processing completed at $(date)" >> "$log_file"
        echo -e "${GREEN}✓ Log saved to: $log_file${NC}"
    fi
}

# Create example directory structure if it doesn't exist
setup_example_dirs() {
    echo -e "${CYAN}🏗️  Setting up example directories...${NC}"

    mkdir -p ./photos/{thumbnails,social,print}
    mkdir -p ./photos/{2022,2023,2024}
    mkdir -p ./portfolio/{high_res,web,mobile}
    mkdir -p ./products/{main,thumbs,gallery}
    mkdir -p ./archive

    echo -e "${GREEN}✓ Example directories created${NC}"
    echo -e "${YELLOW}💡 Add your images to these directories to test the examples${NC}\n"
}

# Performance benchmark example
run_benchmark() {
    echo -e "${CYAN}⚡ Running performance benchmark...${NC}"

    if [[ -d "./benchmark_images" ]]; then
        local start_time=$(date +%s)

        "$COMPRESSOR" "./benchmark_images" "${BASE_OUTPUT_DIR}/benchmark_results" -m1

        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        echo -e "${GREEN}✓ Benchmark completed in ${duration} seconds${NC}"

        # Count processed files
        local jpeg_count=$(find "${BASE_OUTPUT_DIR}/benchmark_results/jpeg_compressed" -name "*.jpeg" 2>/dev/null | wc -l)
        local png_count=$(find "${BASE_OUTPUT_DIR}/benchmark_results/png_compressed" -name "*.png" 2>/dev/null | wc -l)

        echo -e "${CYAN}📊 Results: ${jpeg_count} JPEG + ${png_count} PNG files processed${NC}"

        if [[ $duration -gt 0 ]]; then
            local throughput=$(( (jpeg_count + png_count) / duration ))
            echo -e "${CYAN}🚀 Throughput: ${throughput} files/second${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Create ./benchmark_images directory and add test images for benchmarking${NC}"
    fi
}

# Main menu
show_menu() {
    echo -e "${BLUE}Choose an example to run:${NC}"
    echo "1) Setup example directories"
    echo "2) Process photo categories (different sizes)"
    echo "3) Process by date directories"
    echo "4) Optimize portfolio"
    echo "5) Process e-commerce images"
    echo "6) Archive with logging"
    echo "7) Run performance benchmark"
    echo "8) Run all examples"
    echo "0) Exit"
    echo
}

# Main execution
main() {
    if [[ ! -f "$COMPRESSOR" ]]; then
        echo -e "${RED}❌ Compressor script not found at: $COMPRESSOR${NC}"
        exit 1
    fi

    while true; do
        show_menu
        read -p "Enter your choice (0-8): " choice

        case $choice in
            1) setup_example_dirs ;;
            2) process_photo_categories ;;
            3) process_by_date ;;
            4) optimize_portfolio ;;
            5) process_ecommerce ;;
            6) archive_with_logging ;;
            7) run_benchmark ;;
            8)
                setup_example_dirs
                process_photo_categories
                process_by_date
                optimize_portfolio
                process_ecommerce
                archive_with_logging
                run_benchmark
                ;;
            0) echo -e "${GREEN}✅ Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${YELLOW}❌ Invalid choice. Please try again.${NC}" ;;
        esac

        echo
        read -p "Press Enter to continue..."
        echo
    done
}

# Run the script
main "$@"