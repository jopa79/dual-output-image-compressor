#!/bin/bash

# DUAL-OUTPUT MULTITHREADED IMAGE COMPRESSOR für Apple M4 Ultra
# Erstellt parallel JPEG UND PNG Versionen in separaten Ordnern

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# M4 Ultra spezifische Konfiguration
TOTAL_CORES=28
MAX_JOBS=20              # Erhöht für doppelte Verarbeitung
TARGET_SIZE=1048576      # 1MB (default, can be overridden by parameter)
TOLERANCE=51200          # 5% of target size (will be recalculated based on target)

# Output-Struktur
JPEG_SUBDIR="jpeg_compressed"
PNG_SUBDIR="png_compressed"

# Parse target size parameter
parse_target_size() {
    local size_param="$1"

    # Remove leading dash if present
    size_param="${size_param#-}"

    # Check if parameter matches size pattern
    if [[ "$size_param" =~ ^([mk])([0-9]+)$ ]]; then
        local unit="${BASH_REMATCH[1]}"
        local number="${BASH_REMATCH[2]}"

        case "$unit" in
            "k"|"K")
                TARGET_SIZE=$((number * 1024))
                ;;
            "m"|"M")
                TARGET_SIZE=$((number * 1024 * 1024))
                ;;
        esac

        # Recalculate tolerance as 5% of target size
        TOLERANCE=$((TARGET_SIZE / 20))

        return 0
    fi

    return 1
}

# Banner
show_banner() {
    echo -e "${BOLD}${BLUE}================================================================"
    echo "🚀 DUAL-OUTPUT MULTITHREADED IMAGE COMPRESSOR"
    echo "   Erstellt parallel JPEG UND PNG Versionen"
    echo "================================================================${NC}"
    echo -e "${CYAN}• Max Parallel Jobs: ${MAX_JOBS} (doppelte Verarbeitung)${NC}"
    local target_mb=$(echo "scale=2; $TARGET_SIZE / 1024 / 1024" | bc -l 2>/dev/null || echo "1.00")
    local tolerance_kb=$(echo "scale=0; $TOLERANCE / 1024" | bc -l 2>/dev/null || echo "50")
    echo -e "${CYAN}• Target Size: ${target_mb}MB ± ${tolerance_kb}KB${NC}"
    echo -e "${CYAN}• Output: Separate JPEG + PNG Ordner${NC}"
    echo -e "${BLUE}================================================================${NC}\n"
}

# System-Optimierung
optimize_system() {
    echo -e "${YELLOW}🔧 Optimiere System für Dual-Output Processing...${NC}"
    
    export MAGICK_MEMORY_LIMIT=10GB
    export MAGICK_MAP_LIMIT=5GB
    export MAGICK_DISK_LIMIT=20GB
    export MAGICK_THREAD_LIMIT=$TOTAL_CORES
    export OMP_NUM_THREADS=$TOTAL_CORES
    
    echo -e "${GREEN}✓ System für Dual-Output optimiert${NC}"
}

# Abhängigkeiten prüfen
check_dependencies() {
    echo -e "${YELLOW}🔍 Prüfe Abhängigkeiten...${NC}"
    
    if ! command -v magick &> /dev/null; then
        echo -e "${RED}❌ ImageMagick fehlt: brew install imagemagick${NC}"
        exit 1
    fi
    
    if ! command -v bc &> /dev/null; then
        echo -e "${RED}❌ bc fehlt: brew install bc${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Alle Abhängigkeiten OK${NC}"
}

# Sicherer Pfad-Handler
safe_basename() {
    basename "$1"
}

# Worker-Script für DUAL-OUTPUT erstellen
create_dual_worker_script() {
    local worker_script="/tmp/dual_image_worker_$$.sh"
    
    cat > "$worker_script" << DUAL_WORKER_EOF
#!/bin/bash

# DUAL-OUTPUT Worker für parallele JPEG + PNG Verarbeitung
TARGET_SIZE=$TARGET_SIZE
TOLERANCE=$TOLERANCE

# Farben
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# ImageMagick optimieren
export MAGICK_MEMORY_LIMIT=3GB
export MAGICK_MAP_LIMIT=1GB
export MAGICK_THREAD_LIMIT=4

# Sicherer Basename
safe_basename() {
    basename "$1"
}

# JPEG-Optimierung für Dual-Worker
optimize_jpeg_dual() {
    local input_file="$1"
    local output_file="$2"
    local temp_id="jpeg_dual_$(date +%s)_$$_$(safe_basename "$input_file" | tr '[:space:]' '_' | head -c 15)"
    local temp_dir="/tmp/${temp_id}"
    
    mkdir -p "$temp_dir" || return 1
    
    local min_quality=20
    local max_quality=95
    local best_quality=75
    local iteration=0
    local max_iterations=5
    
    while [[ $iteration -lt $max_iterations ]]; do
        ((iteration++))
        local current_quality=$(( (min_quality + max_quality) / 2 ))
        local temp_file="${temp_dir}/test_${current_quality}.jpg"
        
        magick "$input_file" \
            -strip \
            -interlace Plane \
            -gaussian-blur 0.05 \
            -quality $current_quality \
            -sampling-factor 4:2:0 \
            "$temp_file" 2>/dev/null
        
        if [[ -f "$temp_file" ]]; then
            local current_size=$(stat -f%z "$temp_file" 2>/dev/null || stat -c%s "$temp_file" 2>/dev/null || echo "0")
            
            if [[ $current_size -eq 0 ]]; then
                break
            fi
            
            local diff=$(( current_size - TARGET_SIZE ))
            local abs_diff=${diff#-}
            
            best_quality=$current_quality
            
            if [[ $abs_diff -le $TOLERANCE ]]; then
                break
            fi
            
            if [[ $current_size -gt $TARGET_SIZE ]]; then
                max_quality=$current_quality
            else
                min_quality=$current_quality
            fi
            
            if [[ $((max_quality - min_quality)) -le 2 ]]; then
                break
            fi
        fi
    done
    
    # Finale JPEG-Konvertierung
    magick "$input_file" \
        -strip \
        -interlace Plane \
        -gaussian-blur 0.05 \
        -quality $best_quality \
        -sampling-factor 4:2:0 \
        "$output_file" 2>/dev/null
    
    rm -rf "$temp_dir"
    return 0
}

# PNG-Optimierung für Dual-Worker
optimize_png_dual() {
    local input_file="$1"
    local output_file="$2"
    local temp_id="png_dual_$(date +%s)_$$_$(safe_basename "$input_file" | tr '[:space:]' '_' | head -c 15)"
    local temp_dir="/tmp/${temp_id}"
    
    mkdir -p "$temp_dir" || return 1
    
    local strategies=(1 2 3)
    local scale_factors=(100 90 80)
    local best_temp_file=""
    local best_diff=$TARGET_SIZE
    
    for strategy in "${strategies[@]}"; do
        for scale in "${scale_factors[@]}"; do
            local temp_file="${temp_dir}/test_s${strategy}_sc${scale}.png"
            
            case $strategy in
                1) # Basis
                    if [[ $scale -lt 100 ]]; then
                        magick "$input_file" -resize "${scale}%" -colors 256 -strip "$temp_file" 2>/dev/null
                    else
                        magick "$input_file" -colors 256 -strip "$temp_file" 2>/dev/null
                    fi
                    ;;
                2) # Moderat
                    if [[ $scale -lt 100 ]]; then
                        magick "$input_file" -resize "${scale}%" -colors 128 -posterize 8 -strip "$temp_file" 2>/dev/null
                    else
                        magick "$input_file" -colors 128 -posterize 8 -strip "$temp_file" 2>/dev/null
                    fi
                    ;;
                3) # Aggressiv
                    if [[ $scale -lt 100 ]]; then
                        magick "$input_file" -resize "${scale}%" -colors 64 -posterize 6 -strip "$temp_file" 2>/dev/null
                    else
                        magick "$input_file" -colors 64 -posterize 6 -strip "$temp_file" 2>/dev/null
                    fi
                    ;;
            esac
            
            if [[ -f "$temp_file" ]]; then
                local current_size=$(stat -f%z "$temp_file" 2>/dev/null || stat -c%s "$temp_file" 2>/dev/null || echo "0")
                
                if [[ $current_size -gt 0 ]]; then
                    local diff=$(( current_size - TARGET_SIZE ))
                    local abs_diff=${diff#-}
                    
                    if [[ $abs_diff -lt ${best_diff#-} ]]; then
                        best_diff=$diff
                        best_temp_file="$temp_file"
                    fi
                    
                    if [[ $abs_diff -le $TOLERANCE ]]; then
                        break 2
                    fi
                fi
            fi
        done
    done
    
    # Kopiere bestes Ergebnis oder Fallback
    if [[ -n "$best_temp_file" && -f "$best_temp_file" ]]; then
        cp "$best_temp_file" "$output_file" 2>/dev/null || {
            magick "$input_file" -colors 256 -strip "$output_file" 2>/dev/null
        }
    else
        magick "$input_file" -colors 256 -strip "$output_file" 2>/dev/null
    fi
    
    rm -rf "$temp_dir"
    return 0
}

# DUAL-Worker Hauptfunktion - erstellt BEIDE Formate
dual_worker_main() {
    local input_file="$1"
    local jpeg_output_dir="$2"
    local png_output_dir="$3"
    
    local input_filename
    input_filename=$(safe_basename "$input_file")
    local name_without_ext="${input_filename%.*}"
    
    # Output-Dateien definieren
    local jpeg_output="${jpeg_output_dir}/${name_without_ext}_compressed.jpeg"
    local png_output="${png_output_dir}/${name_without_ext}_compressed.png"
    
    # Status-Initialisierung
    local jpeg_success=false
    local png_success=false
    local jpeg_size_mb="0.00"
    local png_size_mb="0.00"
    
    # PARALLELE VERARBEITUNG: JPEG UND PNG gleichzeitig
    (
        # JPEG-Verarbeitung im Sub-Shell
        if optimize_jpeg_dual "$input_file" "$jpeg_output"; then
            if [[ -f "$jpeg_output" ]]; then
                local size=$(stat -f%z "$jpeg_output" 2>/dev/null || stat -c%s "$jpeg_output" 2>/dev/null || echo "0")
                if [[ $size -gt 0 ]]; then
                    jpeg_size_mb=$(echo "scale=2; $size / 1024 / 1024" | bc -l 2>/dev/null || echo "?.??")
                    echo "JPEG_SUCCESS:${jpeg_size_mb}" > "/tmp/jpeg_result_$$_$(echo "$input_filename" | head -c 10)"
                fi
            fi
        fi
    ) &
    local jpeg_pid=$!
    
    (
        # PNG-Verarbeitung im Sub-Shell
        if optimize_png_dual "$input_file" "$png_output"; then
            if [[ -f "$png_output" ]]; then
                local size=$(stat -f%z "$png_output" 2>/dev/null || stat -c%s "$png_output" 2>/dev/null || echo "0")
                if [[ $size -gt 0 ]]; then
                    png_size_mb=$(echo "scale=2; $size / 1024 / 1024" | bc -l 2>/dev/null || echo "?.??")
                    echo "PNG_SUCCESS:${png_size_mb}" > "/tmp/png_result_$$_$(echo "$input_filename" | head -c 10)"
                fi
            fi
        fi
    ) &
    local png_pid=$!
    
    # Warte auf beide Prozesse
    wait $jpeg_pid
    wait $png_pid
    
    # Ergebnisse sammeln
    local jpeg_result_file="/tmp/jpeg_result_$$_$(echo "$input_filename" | head -c 10)"
    local png_result_file="/tmp/png_result_$$_$(echo "$input_filename" | head -c 10)"
    
    if [[ -f "$jpeg_result_file" ]]; then
        local jpeg_result=$(cat "$jpeg_result_file" 2>/dev/null)
        if [[ "$jpeg_result" =~ ^JPEG_SUCCESS:(.*)$ ]]; then
            jpeg_success=true
            jpeg_size_mb="${BASH_REMATCH[1]}"
        fi
        rm -f "$jpeg_result_file"
    fi
    
    if [[ -f "$png_result_file" ]]; then
        local png_result=$(cat "$png_result_file" 2>/dev/null)
        if [[ "$png_result" =~ ^PNG_SUCCESS:(.*)$ ]]; then
            png_success=true
            png_size_mb="${BASH_REMATCH[1]}"
        fi
        rm -f "$png_result_file"
    fi
    
    # Ergebnis-Ausgabe
    local short_name=$(echo "$input_filename" | head -c 35)
    [[ ${#input_filename} -gt 35 ]] && short_name="${short_name}..."
    
    local jpeg_status="${RED}✗${NC}"
    local png_status="${RED}✗${NC}"
    
    [[ "$jpeg_success" == "true" ]] && jpeg_status="${GREEN}✓ ${jpeg_size_mb}MB${NC}"
    [[ "$png_success" == "true" ]] && png_status="${GREEN}✓ ${png_size_mb}MB${NC}"
    
    echo -e "${CYAN}$short_name${NC} → JPEG: $jpeg_status | PNG: $png_status"
}

# Worker entry point
dual_worker_main "$@"
DUAL_WORKER_EOF
    
    chmod +x "$worker_script"
    echo "$worker_script"
}

# Dual-Output Multithreaded Verarbeitung
run_dual_multithreaded() {
    local -a input_files=("$@")
    local base_output_dir="$1"; shift
    
    # Worker-Script erstellen
    local worker_script
    worker_script=$(create_dual_worker_script)
    
    echo -e "${CYAN}🚀 Starte DUAL-OUTPUT mit ${MAX_JOBS} parallelen Worker...${NC}"
    echo -e "${CYAN}📝 Dual-Worker-Script: $worker_script${NC}"
    echo -e "${PURPLE}📁 JPEG Output: ${base_output_dir}/${JPEG_SUBDIR}${NC}"
    echo -e "${PURPLE}📁 PNG Output: ${base_output_dir}/${PNG_SUBDIR}${NC}\n"
    
    # Erstelle Output-Verzeichnisse
    local jpeg_dir="${base_output_dir}/${JPEG_SUBDIR}"
    local png_dir="${base_output_dir}/${PNG_SUBDIR}"
    
    mkdir -p "$jpeg_dir" "$png_dir"
    
    # Temporäre Datei für Input-Liste
    local input_list="/tmp/dual_input_files_$$.txt"
    printf '%s\n' "${input_files[@]}" > "$input_list"
    
    # Starte parallele Dual-Verarbeitung
    cat "$input_list" | \
    xargs -n 1 -P "$MAX_JOBS" -I {} \
    "$worker_script" {} "$jpeg_dir" "$png_dir"
    
    # Cleanup
    rm -f "$worker_script" "$input_list"
    
    echo -e "\n${GREEN}✅ Alle Dual-Output Jobs abgeschlossen${NC}"
}

# Erweiterte Progress-Überwachung für Dual-Output
show_dual_progress() {
    local total_files="$1"
    local base_output_dir="$2"
    local jpeg_dir="${base_output_dir}/${JPEG_SUBDIR}"
    local png_dir="${base_output_dir}/${PNG_SUBDIR}"
    
    while true; do
        local jpeg_completed=$(find "$jpeg_dir" -name "*_compressed.jpeg" -type f 2>/dev/null | wc -l | tr -d ' ')
        local png_completed=$(find "$png_dir" -name "*_compressed.png" -type f 2>/dev/null | wc -l | tr -d ' ')
        
        local jpeg_progress=$((jpeg_completed * 100 / total_files))
        local png_progress=$((png_completed * 100 / total_files))
        
        printf "\r${CYAN}⚡ JPEG: [%-25s] %d%% (%d/%d) | PNG: [%-25s] %d%% (%d/%d)${NC}" \
               "$(printf '%*s' $((jpeg_progress/4)) | tr ' ' '=')" \
               "$jpeg_progress" "$jpeg_completed" "$total_files" \
               "$(printf '%*s' $((png_progress/4)) | tr ' ' '=')" \
               "$png_progress" "$png_completed" "$total_files"
        
        [[ $jpeg_completed -ge $total_files && $png_completed -ge $total_files ]] && break
        sleep 2
    done
    echo
}

# Haupt-Verarbeitungsfunktion
main() {
    local input_dir="${1:-.}"
    local output_dir="${2:-./dual_compressed}"
    local size_param="$3"
    
    # Parse target size if provided
    if [[ -n "$size_param" ]]; then
        if ! parse_target_size "$size_param"; then
            echo -e "${RED}❌ Ungültiger Größen-Parameter: $size_param${NC}"
            echo -e "${YELLOW}💡 Verwende Format: -m1 (1MB), -k500 (500KB), etc.${NC}"
            exit 1
        fi
    fi

    show_banner
    check_dependencies
    optimize_system
    
    echo -e "${BLUE}📂 Input: $input_dir${NC}"
    echo -e "${BLUE}📁 Base Output: $output_dir${NC}"
    echo -e "${BLUE}📁 JPEG Subdir: ${output_dir}/${JPEG_SUBDIR}${NC}"
    echo -e "${BLUE}📁 PNG Subdir: ${output_dir}/${PNG_SUBDIR}${NC}\n"
    
    # Erstelle Base-Output-Verzeichnis
    if ! mkdir -p "$output_dir"; then
        echo -e "${RED}❌ Kann Output-Verzeichnis nicht erstellen: $output_dir${NC}"
        exit 1
    fi
    
    # Sammle alle Bilddateien
    echo -e "${YELLOW}🔍 Sammle Bilddateien...${NC}"
    
    local -a image_files=()
    while IFS= read -r -d '' file; do
        if [[ -f "$file" ]]; then
            image_files+=("$file")
        fi
    done < <(find "$input_dir" -maxdepth 1 \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) -type f -print0 2>/dev/null)
    
    if [[ ${#image_files[@]} -eq 0 ]]; then
        echo -e "${YELLOW}❌ Keine Bilddateien gefunden in: $input_dir${NC}"
        exit 0
    fi
    
    echo -e "${GREEN}🔍 Gefunden: ${#image_files[@]} Bilddateien${NC}"
    echo -e "${PURPLE}🎯 Erstelle ${#image_files[@]} JPEG + ${#image_files[@]} PNG = $((${#image_files[@]} * 2)) Ausgabedateien${NC}\n"
    
    # Starte Dual-Progress Monitor im Hintergrund
    show_dual_progress "${#image_files[@]}" "$output_dir" &
    local progress_pid=$!
    
    local start_time=$(date +%s)
    
    # Starte Dual-Multithreading
    run_dual_multithreaded "$output_dir" "${image_files[@]}"
    
    # Stoppe Progress Monitor
    kill $progress_pid 2>/dev/null
    wait $progress_pid 2>/dev/null
    
    local end_time=$(date +%s)
    local total_time=$((end_time - start_time))
    
    # Finale Statistiken für Dual-Output
    local jpeg_completed=$(find "${output_dir}/${JPEG_SUBDIR}" -name "*_compressed.jpeg" -type f 2>/dev/null | wc -l | tr -d ' ')
    local png_completed=$(find "${output_dir}/${PNG_SUBDIR}" -name "*_compressed.png" -type f 2>/dev/null | wc -l | tr -d ' ')
    local total_output_files=$((jpeg_completed + png_completed))
    local expected_files=$((${#image_files[@]} * 2))
    
    local success_rate=0
    local speed=0
    
    if [[ $expected_files -gt 0 ]]; then
        success_rate=$(echo "scale=1; $total_output_files * 100 / $expected_files" | bc -l 2>/dev/null || echo "0")
    fi
    
    if [[ $total_time -gt 0 ]]; then
        speed=$(echo "scale=2; $total_output_files / $total_time" | bc -l 2>/dev/null || echo "0")
    fi
    
    echo -e "\n${BOLD}${BLUE}================================================================"
    echo "🎯 DUAL-OUTPUT M4 ULTRA COMPRESSION REPORT"
    echo "================================================================${NC}"
    echo -e "${GREEN}✓ Input Files: ${#image_files[@]}${NC}"
    echo -e "${CYAN}📊 JPEG Created: ${jpeg_completed}/${#image_files[@]}${NC}"
    echo -e "${PURPLE}📊 PNG Created: ${png_completed}/${#image_files[@]}${NC}"
    echo -e "${YELLOW}📊 Total Output: ${total_output_files}/${expected_files} (${success_rate}%)${NC}"
    echo -e "${CYAN}⏱️  Total Time: ${total_time}s${NC}"
    echo -e "${CYAN}⚡ Average Speed: ${speed} files/sec${NC}"
    
    if [[ $total_time -gt 0 ]]; then
        local throughput=$(echo "scale=0; $total_output_files * 60 / $total_time" | bc -l 2>/dev/null || echo "0")
        echo -e "${CYAN}🚀 Throughput: ${throughput} files/minute${NC}"
    fi
    
    # CPU-Effizienz für Dual-Output
    local cpu_efficiency=0
    if [[ $total_time -gt 0 && $TOTAL_CORES -gt 0 ]]; then
        cpu_efficiency=$(echo "scale=1; $total_output_files * 100 / ($total_time * $TOTAL_CORES)" | bc -l 2>/dev/null || echo "0")
        echo -e "${PURPLE}💪 CPU Efficiency: ${cpu_efficiency}% (${TOTAL_CORES} cores, dual processing)${NC}"
    fi
    
    echo -e "${BOLD}${BLUE}================================================================${NC}"
    echo -e "${GREEN}📁 Ergebnisse verfügbar in:${NC}"
    echo -e "${GREEN}   • JPEG: ${output_dir}/${JPEG_SUBDIR}${NC}"
    echo -e "${GREEN}   • PNG:  ${output_dir}/${PNG_SUBDIR}${NC}"
    echo -e "${BOLD}${BLUE}================================================================${NC}"
    
    # Cleanup temporäre Dateien
    rm -rf /tmp/jpeg_dual_*_$$* /tmp/png_dual_*_$$* /tmp/*result*$$* /tmp/dual_input_files_$$* 2>/dev/null
}

# Hilfefunktion
show_help() {
    cat << 'EOF'
🚀 DUAL-OUTPUT MULTITHREADED IMAGE COMPRESSOR für Apple M4 Ultra

Erstellt parallel JPEG UND PNG Versionen jedes Bildes in separaten Ordnern

Verwendung: $0 [INPUT_DIR] [OUTPUT_DIR] [SIZE_PARAMETER]

Parameter:
  INPUT_DIR      - Verzeichnis mit Bilddateien (Standard: .)
  OUTPUT_DIR     - Base-Ausgabeverzeichnis (Standard: ./dual_compressed)
  SIZE_PARAMETER - Zielgröße für komprimierte Bilder (Standard: 1MB)

Größen-Parameter:
  -m<number>     - Zielgröße in Megabytes (z.B. -m1 für 1MB, -m2 für 2MB)
  -k<number>     - Zielgröße in Kilobytes (z.B. -k500 für 500KB, -k750 für 750KB)

Output-Struktur:
  OUTPUT_DIR/
  ├── jpeg_compressed/     ← Alle JPEG-Dateien (optimiert)
  └── png_compressed/      ← Alle PNG-Dateien (optimiert)

Beispiele:
  $0                                           # Standard: 1MB pro Datei
  $0 ~/Pictures ~/Desktop/dual_output         # Spezifische Verzeichnisse
  $0 . ./results -k500                        # 500KB Zielgröße
  $0 ~/Photos ~/Output -m2                    # 2MB Zielgröße

Features:
  • Dual-Output: Jedes Bild wird zu JPEG UND PNG konvertiert
  • M4 Ultra optimiert: 20 parallele Jobs für doppelte Verarbeitung
  • Separate Ordner für jedes Format
  • Flexible Zielgröße: Anpassbare MB/KB Parameter
  • Iterative Größen-Optimierung für präzise Dateigröße
  • Real-time Progress für beide Formate
  • Maximale CPU-Ausnutzung mit paralleler Sub-Processing

Abhängigkeiten:
  brew install imagemagick bc

EOF
}

# Parameter-Verarbeitung
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Starte Hauptfunktion
main "$1" "$2" "$3"