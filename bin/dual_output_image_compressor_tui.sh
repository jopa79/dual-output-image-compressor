#!/bin/bash

# Dual-Output Image Compressor - Terminal UI (TUI)
# Interactive terminal-based user interface für den Image Compressor

set -e

# Colors für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Default-Werte
INPUT_DIR="."
OUTPUT_DIR="./dual_compressed"
SIZE_VALUE="1"
SIZE_UNIT="m"
PARALLEL_JOBS="20"

# Funktionen für UI-Elemente
clear_screen() {
    clear
}

show_header() {
    clear_screen
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}    🚀 DUAL-OUTPUT IMAGE COMPRESSOR - TERMINAL UI 🚀${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo
}

show_menu() {
    show_header
    echo -e "${BOLD}Aktuelle Konfiguration:${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${CYAN}📁 Eingabeverzeichnis:${NC}  ${INPUT_DIR}"
    echo -e "  ${CYAN}💾 Ausgabeverzeichnis:${NC} ${OUTPUT_DIR}"
    echo -e "  ${CYAN}📏 Zielgröße:${NC}          ${SIZE_VALUE}${SIZE_UNIT^^}B"
    echo -e "  ${CYAN}⚡ Parallel-Jobs:${NC}      ${PARALLEL_JOBS}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo -e "${BOLD}Menü-Optionen:${NC}"
    echo
    echo -e "  ${YELLOW}1)${NC} 📁 Eingabeverzeichnis ändern"
    echo -e "  ${YELLOW}2)${NC} 💾 Ausgabeverzeichnis ändern"
    echo -e "  ${YELLOW}3)${NC} 📏 Zielgröße ändern"
    echo -e "  ${YELLOW}4)${NC} ⚡ Parallel-Jobs ändern"
    echo
    echo -e "  ${BOLD}${GREEN}5)${NC} ${BOLD}🚀 Kompression starten${NC}"
    echo
    echo -e "  ${YELLOW}6)${NC} ⚡ Schnelleinstellung: Web (300KB)"
    echo -e "  ${YELLOW}7)${NC} ⚡ Schnelleinstellung: Social Media (800KB)"
    echo -e "  ${YELLOW}8)${NC} ⚡ Schnelleinstellung: Standard (1MB)"
    echo -e "  ${YELLOW}9)${NC} ⚡ Schnelleinstellung: Hohe Qualität (2MB)"
    echo -e "  ${YELLOW}10)${NC} ⚡ Schnelleinstellung: Druck (3MB)"
    echo
    echo -e "  ${RED}0)${NC} 🚪 Beenden"
    echo
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo
}

# Eingabefunktionen
change_input_dir() {
    show_header
    echo -e "${CYAN}📁 Eingabeverzeichnis ändern${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo -e "Aktuell: ${YELLOW}${INPUT_DIR}${NC}"
    echo
    read -p "Neues Eingabeverzeichnis (oder Enter für aktuell): " new_dir

    if [[ -n "$new_dir" ]]; then
        # Tilde expansion
        new_dir="${new_dir/#\~/$HOME}"

        if [[ -d "$new_dir" ]]; then
            INPUT_DIR="$new_dir"
            echo -e "${GREEN}✓ Eingabeverzeichnis aktualisiert!${NC}"
        else
            echo -e "${RED}✗ Verzeichnis existiert nicht!${NC}"
            read -p "Trotzdem verwenden? (j/N): " confirm
            if [[ "$confirm" =~ ^[jJ]$ ]]; then
                INPUT_DIR="$new_dir"
                echo -e "${YELLOW}⚠ Verzeichnis gesetzt (wird bei Start erstellt)${NC}"
            fi
        fi
    fi

    echo
    read -p "Drücken Sie Enter um fortzufahren..."
}

change_output_dir() {
    show_header
    echo -e "${CYAN}💾 Ausgabeverzeichnis ändern${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo -e "Aktuell: ${YELLOW}${OUTPUT_DIR}${NC}"
    echo
    read -p "Neues Ausgabeverzeichnis (oder Enter für aktuell): " new_dir

    if [[ -n "$new_dir" ]]; then
        # Tilde expansion
        new_dir="${new_dir/#\~/$HOME}"
        OUTPUT_DIR="$new_dir"
        echo -e "${GREEN}✓ Ausgabeverzeichnis aktualisiert!${NC}"
    fi

    echo
    read -p "Drücken Sie Enter um fortzufahren..."
}

change_target_size() {
    show_header
    echo -e "${CYAN}📏 Zielgröße ändern${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo -e "Aktuell: ${YELLOW}${SIZE_VALUE}${SIZE_UNIT^^}B${NC}"
    echo
    echo -e "Einheit wählen:"
    echo -e "  ${YELLOW}1)${NC} KB (Kilobytes)"
    echo -e "  ${YELLOW}2)${NC} MB (Megabytes)"
    echo
    read -p "Wählen Sie Einheit (1-2): " unit_choice

    case $unit_choice in
        1)
            SIZE_UNIT="k"
            ;;
        2)
            SIZE_UNIT="m"
            ;;
        *)
            echo -e "${RED}Ungültige Auswahl, Einheit bleibt unverändert${NC}"
            read -p "Drücken Sie Enter um fortzufahren..."
            return
            ;;
    esac

    echo
    read -p "Geben Sie die Größe ein (z.B. 500 für 500KB oder 2 für 2MB): " size_value

    if [[ "$size_value" =~ ^[0-9]+$ ]]; then
        SIZE_VALUE="$size_value"
        echo -e "${GREEN}✓ Zielgröße auf ${SIZE_VALUE}${SIZE_UNIT^^}B gesetzt!${NC}"
    else
        echo -e "${RED}✗ Ungültige Größe!${NC}"
    fi

    echo
    read -p "Drücken Sie Enter um fortzufahren..."
}

change_parallel_jobs() {
    show_header
    echo -e "${CYAN}⚡ Parallel-Jobs ändern${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo -e "Aktuell: ${YELLOW}${PARALLEL_JOBS}${NC} Jobs"
    echo
    echo -e "${CYAN}Empfohlene Werte:${NC}"
    echo -e "  • M4 Ultra (28 Kerne): 16-20 Jobs"
    echo -e "  • M3 Pro (12 Kerne): 8-12 Jobs"
    echo -e "  • M2 (8 Kerne): 6-8 Jobs"
    echo
    read -p "Geben Sie die Anzahl Jobs ein (1-32): " jobs

    if [[ "$jobs" =~ ^[0-9]+$ ]] && [ "$jobs" -ge 1 ] && [ "$jobs" -le 32 ]; then
        PARALLEL_JOBS="$jobs"
        echo -e "${GREEN}✓ Parallel-Jobs auf ${PARALLEL_JOBS} gesetzt!${NC}"
    else
        echo -e "${RED}✗ Ungültige Anzahl (1-32)!${NC}"
    fi

    echo
    read -p "Drücken Sie Enter um fortzufahren..."
}

# Schnelleinstellungen
set_preset() {
    local preset=$1
    case $preset in
        web)
            SIZE_VALUE="300"
            SIZE_UNIT="k"
            echo -e "${GREEN}✓ Web-Preset aktiviert (300KB)${NC}"
            ;;
        social)
            SIZE_VALUE="800"
            SIZE_UNIT="k"
            echo -e "${GREEN}✓ Social Media-Preset aktiviert (800KB)${NC}"
            ;;
        standard)
            SIZE_VALUE="1"
            SIZE_UNIT="m"
            echo -e "${GREEN}✓ Standard-Preset aktiviert (1MB)${NC}"
            ;;
        quality)
            SIZE_VALUE="2"
            SIZE_UNIT="m"
            echo -e "${GREEN}✓ Hohe Qualität-Preset aktiviert (2MB)${NC}"
            ;;
        print)
            SIZE_VALUE="3"
            SIZE_UNIT="m"
            echo -e "${GREEN}✓ Druck-Preset aktiviert (3MB)${NC}"
            ;;
    esac
    sleep 1
}

# Kompression starten
start_compression() {
    show_header
    echo -e "${BOLD}${GREEN}🚀 Kompression wird gestartet...${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo -e "${BOLD}Konfiguration:${NC}"
    echo -e "  ${CYAN}Eingabe:${NC}      ${INPUT_DIR}"
    echo -e "  ${CYAN}Ausgabe:${NC}      ${OUTPUT_DIR}"
    echo -e "  ${CYAN}Zielgröße:${NC}    ${SIZE_VALUE}${SIZE_UNIT^^}B"
    echo -e "  ${CYAN}Jobs:${NC}         ${PARALLEL_JOBS}"
    echo
    read -p "Fortfahren? (J/n): " confirm

    if [[ ! "$confirm" =~ ^[nN]$ ]]; then
        echo
        echo -e "${CYAN}Starte Kompression...${NC}"
        echo

        # Pfad zum Hauptskript
        SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
        MAIN_SCRIPT="$SCRIPT_DIR/dual_output_image_compressor.sh"

        if [[ ! -f "$MAIN_SCRIPT" ]]; then
            echo -e "${RED}✗ Hauptskript nicht gefunden: $MAIN_SCRIPT${NC}"
            read -p "Drücken Sie Enter um fortzufahren..."
            return
        fi

        # Temporäre Umgebungsvariablen für das Hauptskript setzen
        export DUAL_COMPRESSOR_JOBS="$PARALLEL_JOBS"

        # Hauptskript mit Parametern ausführen
        SIZE_PARAM="-${SIZE_UNIT}${SIZE_VALUE}"

        echo -e "${YELLOW}Befehl: $MAIN_SCRIPT \"$INPUT_DIR\" \"$OUTPUT_DIR\" \"$SIZE_PARAM\"${NC}"
        echo

        "$MAIN_SCRIPT" "$INPUT_DIR" "$OUTPUT_DIR" "$SIZE_PARAM"

        local exit_code=$?
        echo

        if [ $exit_code -eq 0 ]; then
            echo -e "${BOLD}${GREEN}✓ Kompression erfolgreich abgeschlossen!${NC}"
        else
            echo -e "${BOLD}${RED}✗ Kompression mit Fehler beendet (Exit Code: $exit_code)${NC}"
        fi

        echo
        read -p "Drücken Sie Enter um zum Menü zurückzukehren..."
    fi
}

# Hauptschleife
main() {
    while true; do
        show_menu

        read -p "Wählen Sie eine Option (0-10): " choice

        case $choice in
            1)
                change_input_dir
                ;;
            2)
                change_output_dir
                ;;
            3)
                change_target_size
                ;;
            4)
                change_parallel_jobs
                ;;
            5)
                start_compression
                ;;
            6)
                set_preset "web"
                ;;
            7)
                set_preset "social"
                ;;
            8)
                set_preset "standard"
                ;;
            9)
                set_preset "quality"
                ;;
            10)
                set_preset "print"
                ;;
            0)
                show_header
                echo -e "${CYAN}Auf Wiedersehen! 👋${NC}"
                echo
                exit 0
                ;;
            *)
                echo -e "${RED}Ungültige Option!${NC}"
                sleep 1
                ;;
        esac
    done
}

# Prüfe Abhängigkeiten
check_dependencies() {
    if ! command -v magick &> /dev/null && ! command -v convert &> /dev/null; then
        echo -e "${RED}✗ ImageMagick ist nicht installiert!${NC}"
        echo -e "${YELLOW}  Installieren Sie es mit: brew install imagemagick${NC}"
        exit 1
    fi

    if ! command -v bc &> /dev/null; then
        echo -e "${RED}✗ bc ist nicht installiert!${NC}"
        echo -e "${YELLOW}  Installieren Sie es mit: brew install bc${NC}"
        exit 1
    fi
}

# Script starten
check_dependencies
main "$@"
