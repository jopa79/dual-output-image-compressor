# Contributing to Dual-Output Image Compressor

Thank you for your interest in contributing to the Dual-Output Image Compressor! This guide will help you get started with contributing to this project.

## 🎯 Project Goals

- **Performance**: Maximize compression speed on Apple Silicon processors
- **Quality**: Maintain excellent image quality while achieving target file sizes
- **Usability**: Provide intuitive, reliable batch processing
- **Compatibility**: Ensure broad macOS and Unix compatibility

## 🚀 Getting Started

### Development Environment Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/your-username/dual-output-image-compressor.git
   cd dual-output-image-compressor
   ```

2. **Install Dependencies**
   ```bash
   ./scripts/install.sh
   ```

3. **Verify Installation**
   ```bash
   ./bin/dual_output_image_compressor.sh -h
   ```

### Development Tools

- **Shell**: Bash 4.0+ (macOS default or via Homebrew)
- **ImageMagick**: Version 7.x recommended
- **bc**: Basic calculator for mathematical operations
- **Editor**: Any editor with bash syntax highlighting

## 📋 Types of Contributions

### 🐛 Bug Reports

**Before Submitting:**
- Check existing issues to avoid duplicates
- Test with the latest version
- Gather relevant system information

**Include in Your Report:**
- **System Info**: macOS version, processor type, RAM
- **Software Versions**: ImageMagick version, bash version
- **Input Details**: Image types, sizes, directory structure
- **Expected vs Actual Behavior**: Clear description
- **Reproduction Steps**: Minimal example
- **Error Messages**: Complete error output
- **Performance Data**: Processing times, file counts

**Example Bug Report:**
```markdown
## Bug: JPEG optimization fails on images >10MB

**System:**
- macOS 14.0, M4 Ultra, 64GB RAM
- ImageMagick 7.1.1, bash 5.2

**Input:**
- 50 JPEG files, 10-15MB each
- Target size: -m2 (2MB)

**Expected:** All files compressed to ~2MB
**Actual:** Processing stops after 10 files with "magick: memory allocation failed"

**Reproduction:**
```bash
./bin/dual_output_image_compressor.sh ./test_large ./output -m2
```

**Error Output:**
```
magick: memory allocation failed `test_image_001.jpg' @ error/cache.c/OpenPixelCache/3927.
```
```

### 💡 Feature Requests

**Consider These Questions:**
- Does this fit the project's core mission?
- Would this benefit multiple users?
- Is this feasible with current architecture?
- Are there performance implications?

**Include in Your Request:**
- **Use Case**: Why is this needed?
- **Proposed Solution**: How should it work?
- **Alternatives**: Other approaches considered
- **Implementation Ideas**: Technical suggestions
- **Backwards Compatibility**: Impact on existing users

### 🔧 Code Contributions

#### Development Workflow

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**
   - Follow existing code style
   - Add appropriate comments
   - Update documentation if needed

3. **Test Thoroughly**
   ```bash
   # Test basic functionality
   ./bin/dual_output_image_compressor.sh ./test_images ./test_output

   # Test new features
   ./bin/dual_output_image_compressor.sh ./test_images ./test_output -k500

   # Test edge cases
   ./examples/batch-processing.sh
   ```

4. **Commit Changes**
   ```bash
   git add -A
   git commit -m "feat: add configurable worker thread limits

   - Add CUSTOM_MAX_JOBS environment variable
   - Update help documentation
   - Add validation for thread count limits

   Closes #123"
   ```

5. **Push and Create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

#### Code Standards

**Shell Script Best Practices:**
- Use `#!/bin/bash` shebang
- Enable strict mode: `set -euo pipefail` where appropriate
- Quote variables: `"$variable"` not `$variable`
- Use `[[ ]]` for conditionals, not `[ ]`
- Validate inputs and handle errors gracefully

**Performance Guidelines:**
- Minimize subprocess calls in loops
- Use efficient algorithms (binary search, etc.)
- Leverage parallel processing appropriately
- Profile changes with realistic data sets

**Documentation:**
- Comment complex algorithms
- Document function parameters and return values
- Update help text for new features
- Include usage examples

**Example Code Style:**
```bash
# Good: Proper quoting and error handling
process_image() {
    local input_file="$1"
    local output_dir="$2"
    local target_size="$3"

    # Validate parameters
    [[ -f "$input_file" ]] || {
        echo "Error: Input file not found: $input_file" >&2
        return 1
    }

    [[ -d "$output_dir" ]] || mkdir -p "$output_dir"

    # Process with error handling
    if ! magick "$input_file" -resize 50% "$output_dir/$(basename "$input_file")"; then
        echo "Error: Failed to process $input_file" >&2
        return 1
    fi
}

# Bad: No quoting, no error handling
process_image() {
    magick $1 -resize 50% $2/$(basename $1)
}
```

## 🧪 Testing

### Manual Testing

**Basic Functionality:**
```bash
# Test different sizes
./bin/dual_output_image_compressor.sh ./test_images ./output_1mb -m1
./bin/dual_output_image_compressor.sh ./test_images ./output_500k -k500

# Test edge cases
./bin/dual_output_image_compressor.sh ./empty_dir ./output        # Empty directory
./bin/dual_output_image_compressor.sh ./tiny_images ./output     # Very small images
./bin/dual_output_image_compressor.sh ./huge_images ./output     # Very large images
```

**Performance Testing:**
```bash
# Benchmark with different file counts
./examples/batch-processing.sh  # Option 7: Run performance benchmark

# Monitor system resources
top -pid $(pgrep -f dual_output_image_compressor)
```

### Test Environment

**Create Test Images:**
```bash
# Create test image directory
mkdir -p test_images

# Generate test images with different sizes
for size in 100x100 500x500 1000x1000 2000x2000; do
    magick -size $size xc:blue "test_images/blue_${size}.png"
    magick -size $size xc:red "test_images/red_${size}.jpg"
done
```

## 📖 Documentation

### README Updates
- Keep examples current and working
- Add new features to feature list
- Update installation instructions if needed
- Maintain performance benchmarks

### Code Documentation
- Document complex algorithms
- Explain non-obvious optimizations
- Include usage examples for new functions
- Update help text and error messages

### Changelog
- Follow [Keep a Changelog](https://keepachangelog.com/) format
- Include migration notes for breaking changes
- Document performance improvements with numbers

## 🔄 Pull Request Process

### Before Submitting

- [ ] Code follows project style guidelines
- [ ] All tests pass with new changes
- [ ] Documentation updated appropriately
- [ ] CHANGELOG.md updated
- [ ] Commits have descriptive messages
- [ ] Branch is up to date with main

### PR Description Template

```markdown
## Summary
Brief description of changes and motivation.

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that causes existing functionality to change)
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- [ ] Tested on M4 Ultra with 100+ images
- [ ] Tested different size parameters (-k500, -m1, -m5)
- [ ] Verified backwards compatibility
- [ ] Performance benchmarks show improvement/no regression

## Screenshots/Output
Include relevant command output or screenshots if applicable.

## Checklist
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] Any dependent changes have been merged and published
```

## 🎨 Optimization Opportunities

### Performance Improvements
- **Algorithm Optimization**: Improve binary search convergence
- **Memory Management**: Reduce peak memory usage
- **I/O Efficiency**: Minimize filesystem operations
- **Parallel Processing**: Better load balancing

### Feature Additions
- **Format Support**: WebP, AVIF output formats
- **Configuration**: Config file support
- **Monitoring**: Progress webhooks, logging
- **Integration**: CI/CD pipeline plugins

### Quality Improvements
- **Error Handling**: More graceful degradation
- **User Experience**: Better progress visualization
- **Compatibility**: Linux optimization
- **Testing**: Automated test suite

## 📞 Getting Help

- **Questions**: Open a GitHub Discussion
- **Issues**: Create a detailed GitHub Issue
- **Ideas**: Start with a GitHub Discussion
- **Security**: Email privately for security issues

## 🏆 Recognition

Contributors are recognized in:
- GitHub contributors graph
- CHANGELOG.md acknowledgments
- README.md contributor section (for significant contributions)

## 📜 License

By contributing, you agree that your contributions will be licensed under the project's MIT License.

---

**Thank you for helping make image compression faster and more efficient for everyone!** 🚀