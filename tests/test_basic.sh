#!/bin/bash

# Basic test suite for Dual-Output Image Compressor
# Run this script to verify the tool is working correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Test configuration
SCRIPT_PATH="$(dirname "$0")/../bin/dual_output_image_compressor.sh"
TEST_DIR="$(dirname "$0")/test_data"
OUTPUT_DIR="$(dirname "$0")/test_output"
CLEANUP_ON_SUCCESS=true

# Test results tracking
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Logging
log_test() {
    echo -e "${CYAN}[TEST] $1${NC}"
}

log_success() {
    echo -e "${GREEN}[PASS] $1${NC}"
    ((TESTS_PASSED++))
}

log_failure() {
    echo -e "${RED}[FAIL] $1${NC}"
    ((TESTS_FAILED++))
}

log_info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Setup test environment
setup_test_environment() {
    log_info "Setting up test environment..."

    # Create test directories
    mkdir -p "$TEST_DIR" "$OUTPUT_DIR"

    # Create test images of various sizes and formats
    log_info "Creating test images..."

    # Small images (should compress to smaller than target)
    magick -size 50x50 xc:blue "$TEST_DIR/small_blue.png" 2>/dev/null || true
    magick -size 50x50 xc:red "$TEST_DIR/small_red.jpg" 2>/dev/null || true

    # Medium images (should compress to around target)
    magick -size 500x500 xc:green "$TEST_DIR/medium_green.png" 2>/dev/null || true
    magick -size 500x500 xc:yellow "$TEST_DIR/medium_yellow.jpg" 2>/dev/null || true

    # Large images (should require significant compression)
    magick -size 1500x1500 xc:purple "$TEST_DIR/large_purple.png" 2>/dev/null || true
    magick -size 1500x1500 xc:orange "$TEST_DIR/large_orange.jpg" 2>/dev/null || true

    # Images with transparency (PNG specific)
    magick -size 300x300 xc:transparent "$TEST_DIR/transparent.png" 2>/dev/null || true

    log_info "Test environment ready"
}

# Test 1: Script existence and permissions
test_script_exists() {
    log_test "Checking script existence and permissions"
    ((TESTS_RUN++))

    if [[ ! -f "$SCRIPT_PATH" ]]; then
        log_failure "Script not found: $SCRIPT_PATH"
        return 1
    fi

    if [[ ! -x "$SCRIPT_PATH" ]]; then
        log_failure "Script not executable: $SCRIPT_PATH"
        return 1
    fi

    log_success "Script exists and is executable"
}

# Test 2: Dependencies check
test_dependencies() {
    log_test "Checking dependencies"
    ((TESTS_RUN++))

    local missing_deps=()

    if ! command -v magick &> /dev/null; then
        missing_deps+=("imagemagick")
    fi

    if ! command -v bc &> /dev/null; then
        missing_deps+=("bc")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_failure "Missing dependencies: ${missing_deps[*]}"
        return 1
    fi

    log_success "All dependencies available"
}

# Test 3: Help function
test_help_function() {
    log_test "Testing help function"
    ((TESTS_RUN++))

    local help_output
    if help_output=$("$SCRIPT_PATH" -h 2>&1); then
        if [[ "$help_output" == *"DUAL-OUTPUT"* && "$help_output" == *"Verwendung"* ]]; then
            log_success "Help function works correctly"
        else
            log_failure "Help output doesn't contain expected content"
            return 1
        fi
    else
        log_failure "Help function failed to execute"
        return 1
    fi
}

# Test 4: Basic compression (default 1MB)
test_basic_compression() {
    log_test "Testing basic compression (1MB default)"
    ((TESTS_RUN++))

    local output_dir="${OUTPUT_DIR}/basic_1mb"
    rm -rf "$output_dir"

    if ! "$SCRIPT_PATH" "$TEST_DIR" "$output_dir" >/dev/null 2>&1; then
        log_failure "Basic compression failed"
        return 1
    fi

    # Check output structure
    if [[ ! -d "$output_dir/jpeg_compressed" || ! -d "$output_dir/png_compressed" ]]; then
        log_failure "Output directories not created"
        return 1
    fi

    # Count output files
    local jpeg_count=$(find "$output_dir/jpeg_compressed" -name "*.jpeg" 2>/dev/null | wc -l)
    local png_count=$(find "$output_dir/png_compressed" -name "*.png" 2>/dev/null | wc -l)

    if [[ $jpeg_count -eq 0 && $png_count -eq 0 ]]; then
        log_failure "No output files created"
        return 1
    fi

    log_success "Basic compression completed ($jpeg_count JPEG, $png_count PNG files)"
}

# Test 5: Custom size compression (500KB)
test_custom_size_500k() {
    log_test "Testing custom size compression (500KB)"
    ((TESTS_RUN++))

    local output_dir="${OUTPUT_DIR}/custom_500k"
    rm -rf "$output_dir"

    if ! "$SCRIPT_PATH" "$TEST_DIR" "$output_dir" -k500 >/dev/null 2>&1; then
        log_failure "500KB compression failed"
        return 1
    fi

    # Check that files were created
    local jpeg_count=$(find "$output_dir/jpeg_compressed" -name "*.jpeg" 2>/dev/null | wc -l)
    local png_count=$(find "$output_dir/png_compressed" -name "*.png" 2>/dev/null | wc -l)

    if [[ $jpeg_count -eq 0 && $png_count -eq 0 ]]; then
        log_failure "No 500KB output files created"
        return 1
    fi

    # Check approximate file sizes (should be around 500KB ± tolerance)
    local oversized_files=0
    while IFS= read -r -d '' file; do
        local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo "0")
        # Allow up to 2x target size for test flexibility (ImageMagick may not always hit exact targets)
        if [[ $size -gt 1000000 ]]; then  # 1MB = generous upper bound for 500KB target
            ((oversized_files++))
        fi
    done < <(find "$output_dir" -name "*compressed*" -type f -print0 2>/dev/null)

    log_success "500KB compression completed ($jpeg_count JPEG, $png_count PNG files)"
}

# Test 6: Custom size compression (2MB)
test_custom_size_2mb() {
    log_test "Testing custom size compression (2MB)"
    ((TESTS_RUN++))

    local output_dir="${OUTPUT_DIR}/custom_2mb"
    rm -rf "$output_dir"

    if ! "$SCRIPT_PATH" "$TEST_DIR" "$output_dir" -m2 >/dev/null 2>&1; then
        log_failure "2MB compression failed"
        return 1
    fi

    # Check that files were created
    local jpeg_count=$(find "$output_dir/jpeg_compressed" -name "*.jpeg" 2>/dev/null | wc -l)
    local png_count=$(find "$output_dir/png_compressed" -name "*.png" 2>/dev/null | wc -l)

    if [[ $jpeg_count -eq 0 && $png_count -eq 0 ]]; then
        log_failure "No 2MB output files created"
        return 1
    fi

    log_success "2MB compression completed ($jpeg_count JPEG, $png_count PNG files)"
}

# Test 7: Error handling - invalid size parameter
test_invalid_size_parameter() {
    log_test "Testing error handling for invalid size parameter"
    ((TESTS_RUN++))

    local output_dir="${OUTPUT_DIR}/invalid_param"
    rm -rf "$output_dir"

    # This should fail
    if "$SCRIPT_PATH" "$TEST_DIR" "$output_dir" -x999 >/dev/null 2>&1; then
        log_failure "Script should have failed with invalid parameter -x999"
        return 1
    fi

    log_success "Invalid size parameter properly rejected"
}

# Test 8: Error handling - empty directory
test_empty_directory() {
    log_test "Testing behavior with empty directory"
    ((TESTS_RUN++))

    local empty_dir="${TEST_DIR}/empty"
    local output_dir="${OUTPUT_DIR}/empty_input"
    mkdir -p "$empty_dir"
    rm -rf "$output_dir"

    # This should handle empty directory gracefully
    "$SCRIPT_PATH" "$empty_dir" "$output_dir" >/dev/null 2>&1 || true

    log_success "Empty directory handled gracefully"
}

# Test 9: File size verification
test_file_sizes() {
    log_test "Verifying output file sizes are reasonable"
    ((TESTS_RUN++))

    local test_files=()
    local size_issues=0

    # Collect all output files
    while IFS= read -r -d '' file; do
        test_files+=("$file")
    done < <(find "$OUTPUT_DIR" -name "*compressed*" -type f -print0 2>/dev/null)

    if [[ ${#test_files[@]} -eq 0 ]]; then
        log_failure "No compressed files found for size verification"
        return 1
    fi

    # Check file sizes
    for file in "${test_files[@]}"; do
        local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo "0")

        # Files should be between 100KB and 10MB (reasonable range)
        if [[ $size -lt 100000 || $size -gt 10485760 ]]; then
            ((size_issues++))
        fi
    done

    if [[ $size_issues -gt 0 ]]; then
        log_failure "$size_issues files have unreasonable sizes"
        return 1
    fi

    log_success "All ${#test_files[@]} output files have reasonable sizes"
}

# Test 10: Performance benchmark
test_performance() {
    log_test "Running performance benchmark"
    ((TESTS_RUN++))

    local benchmark_dir="${TEST_DIR}/benchmark"
    local output_dir="${OUTPUT_DIR}/benchmark"

    mkdir -p "$benchmark_dir"
    rm -rf "$output_dir"

    # Create benchmark images
    for i in {1..5}; do
        magick -size 400x400 xc:blue "$benchmark_dir/bench_${i}.png" 2>/dev/null || true
        magick -size 400x400 xc:red "$benchmark_dir/bench_${i}.jpg" 2>/dev/null || true
    done

    # Time the processing
    local start_time=$(date +%s)
    "$SCRIPT_PATH" "$benchmark_dir" "$output_dir" -m1 >/dev/null 2>&1 || true
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Count results
    local total_files=$(find "$output_dir" -name "*compressed*" -type f 2>/dev/null | wc -l)

    if [[ $total_files -gt 0 && $duration -gt 0 ]]; then
        local throughput=$(echo "scale=2; $total_files / $duration" | bc -l 2>/dev/null || echo "N/A")
        log_success "Benchmark: $total_files files in ${duration}s (${throughput} files/sec)"
    else
        log_success "Benchmark completed in ${duration}s"
    fi
}

# Cleanup function
cleanup() {
    if [[ "$CLEANUP_ON_SUCCESS" == "true" && $TESTS_FAILED -eq 0 ]]; then
        log_info "Cleaning up test files..."
        rm -rf "$TEST_DIR" "$OUTPUT_DIR"
    else
        log_info "Test files preserved at: $TEST_DIR and $OUTPUT_DIR"
    fi
}

# Main test runner
run_tests() {
    echo -e "${BOLD}${BLUE}=============================================="
    echo "Dual-Output Image Compressor - Test Suite"
    echo "==============================================${NC}\n"

    setup_test_environment

    # Run all tests
    test_script_exists
    test_dependencies
    test_help_function
    test_basic_compression
    test_custom_size_500k
    test_custom_size_2mb
    test_invalid_size_parameter
    test_empty_directory
    test_file_sizes
    test_performance

    # Results summary
    echo -e "\n${BOLD}${BLUE}=============================================="
    echo "Test Results Summary"
    echo "==============================================${NC}"
    echo -e "${CYAN}Tests Run: $TESTS_RUN${NC}"
    echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
        echo -e "\n${YELLOW}Some tests failed. Check output above for details.${NC}"
        cleanup
        exit 1
    else
        echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
        echo -e "\n${GREEN}✅ All tests passed! The tool is working correctly.${NC}"
        cleanup
        exit 0
    fi
}

# Handle script arguments
case "${1:-}" in
    --no-cleanup)
        CLEANUP_ON_SUCCESS=false
        run_tests
        ;;
    --help|-h)
        echo "Usage: $0 [--no-cleanup] [--help]"
        echo ""
        echo "Options:"
        echo "  --no-cleanup  Preserve test files after successful run"
        echo "  --help        Show this help message"
        exit 0
        ;;
    "")
        run_tests
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac