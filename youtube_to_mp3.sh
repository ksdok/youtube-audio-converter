#!/bin/bash

set -euo pipefail

# Script pour extraire le son de vidéos YouTube et les convertir en fichiers audio
# Usage: ./youtube_to_mp3.sh urls.txt
#        ./youtube_to_mp3.sh url1 url2 url3...

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher l'aide
show_help() {
    echo "Usage: $0 [OPTIONS] [URLS...|FILE]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Affiche cette aide"
    echo "  -o, --output   Dossier de sortie (par défaut: ./mp3)"
    echo "  -f, --format   Format audio de sortie (par défaut: mp3)"
    echo ""
    echo "Exemples:"
    echo "  $0 https://www.youtube.com/watch?v=example1 https://www.youtube.com/watch?v=example2"
    echo "  $0 urls.txt"
    echo "  $0 -o /chemin/vers/dossier urls.txt"
}

is_valid_url() {
    local url="$1"

    case "$url" in
        *://www.youtube.com/playlist*|*://youtube.com/playlist*|*://music.youtube.com/playlist*)
            return 1
            ;;
        http://www.youtube.com/watch\?*|https://www.youtube.com/watch\?*|http://youtube.com/watch\?*|https://youtube.com/watch\?*|http://music.youtube.com/watch\?*|https://music.youtube.com/watch\?*|http://youtu.be/*|https://youtu.be/*|http://www.youtube.com/shorts/*|https://www.youtube.com/shorts/*|http://youtube.com/shorts/*|https://youtube.com/shorts/*|http://www.youtube.com/live/*|https://www.youtube.com/live/*|http://youtube.com/live/*|https://youtube.com/live/*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Valeurs par défaut
OUTPUT_DIR="./mp3"
AUDIO_FORMAT="mp3"

# Traitement des arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -o|--output)
            if [ $# -lt 2 ]; then
                echo -e "${RED}Erreur: l'option $1 nécessite un dossier de sortie.${NC}" >&2
                exit 1
            fi
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -f|--format)
            if [ $# -lt 2 ]; then
                echo -e "${RED}Erreur: l'option $1 nécessite un format audio.${NC}" >&2
                exit 1
            fi
            AUDIO_FORMAT="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo -e "${RED}Option inconnue: $1${NC}" >&2
            show_help
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Vérification des dépendances
check_dependencies() {
    echo -e "${BLUE}Vérification des dépendances...${NC}"
    
    if ! command -v youtube-dl &> /dev/null && ! command -v yt-dlp &> /dev/null; then
        echo -e "${RED}Erreur: Ni youtube-dl ni yt-dlp n'est installé.${NC}" >&2
        echo "Installation de yt-dlp recommandée:"
        echo "  macOS: brew install yt-dlp"
        echo "  Ubuntu/Debian: sudo apt install yt-dlp"
        echo "  Fedora: sudo dnf install yt-dlp"
        echo "  Ou via pip: pip install yt-dlp"
        exit 1
    fi
    
    if ! command -v ffmpeg &> /dev/null; then
        echo -e "${RED}Erreur: ffmpeg n'est pas installé.${NC}" >&2
        echo "Installation requise:"
        echo "  macOS: brew install ffmpeg"
        echo "  Ubuntu/Debian: sudo apt install ffmpeg"
        echo "  Fedora: sudo dnf install ffmpeg"
        exit 1
    fi
    
    # Utiliser yt-dlp s'il est disponible, sinon youtube-dl
    if command -v yt-dlp &> /dev/null; then
        YOUTUBE_DL="yt-dlp"
    else
        YOUTUBE_DL="youtube-dl"
    fi
    
    echo -e "${GREEN}Dépendances vérifiées avec succès.${NC}"
    echo -e "${BLUE}Utilisation de: $YOUTUBE_DL${NC}"
}

# Création du dossier de sortie
create_output_dir() {
    if [ ! -d "$OUTPUT_DIR" ]; then
        echo -e "${BLUE}Création du dossier de sortie: $OUTPUT_DIR${NC}"
        mkdir -p -- "$OUTPUT_DIR"
    fi
}

# Extraction et conversion pour une URL
process_url() {
    local url="$1"
    local index="$2"
    
    printf '%bTraitement de la vidéo %s:%b %s\n' "$YELLOW" "$index" "$NC" "$url"

    if ! is_valid_url "$url"; then
        printf '%bURL YouTube invalide ou non supportée:%b %s\n' "$RED" "$NC" "$url" >&2
        return 1
    fi
    
    # Extraction du titre de la vidéo
    local title
    title=$($YOUTUBE_DL --no-playlist --get-title -- "$url" 2>/dev/null | head -n 1) || title=""
    
    if [ -z "$title" ]; then
        title="video_$index"
    fi
    
    printf '%bTitre:%b %s\n' "$BLUE" "$NC" "$title"
    
    # Téléchargement et conversion avec la meilleure qualité.
    # Le template laisse yt-dlp assainir le titre et ajoute l'id vidéo pour éviter les collisions.
    if $YOUTUBE_DL \
        --no-playlist \
        --extract-audio \
        --audio-format "$AUDIO_FORMAT" \
        --audio-quality 0 \
        --output "$OUTPUT_DIR/%(title).100s [%(id)s].%(ext)s" \
        -- "$url"; then
        echo -e "${GREEN}✓ Conversion terminée au format $AUDIO_FORMAT${NC}"
    else
        echo -e "${RED}✗ Échec de la conversion pour: $url${NC}" >&2
        return 1
    fi
}

# Traitement des URLs à partir d'un fichier
process_file() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}Erreur: Le fichier $file n'existe pas.${NC}" >&2
        exit 1
    fi
    
    echo -e "${BLUE}Lecture des URLs depuis: $file${NC}"
    
    local urls=()
    while IFS= read -r line || [ -n "$line" ]; do
        # Ignorer les lignes vides et les commentaires
        if [[ "$line" =~ ^[[:space:]]*$ || "$line" =~ ^[[:space:]]*# ]]; then
            continue
        else
            urls+=("$line")
        fi
    done < "$file"
    
    if [ "${#urls[@]}" -eq 0 ]; then
        echo -e "${RED}Aucune URL à traiter.${NC}" >&2
        exit 1
    fi
    
    process_urls "${urls[@]}"
}

# Traitement des URLs
process_urls() {
    local urls=("$@")
    local total=${#urls[@]}
    
    if [ "$total" -eq 0 ]; then
        echo -e "${RED}Aucune URL à traiter.${NC}" >&2
        exit 1
    fi
    
    echo -e "${BLUE}Traitement de $total vidéo(s)...${NC}"
    
    local success_count=0
    local fail_count=0
    
    for i in "${!urls[@]}"; do
        local url="${urls[$i]}"
        local index=$((i+1))
        
        if process_url "$url" "$index"; then
            ((success_count+=1))
        else
            ((fail_count+=1))
        fi
        
        echo ""  # Ligne vide pour séparer les traitements
    done
    
    # Résumé
    echo -e "${BLUE}=== Résumé ===${NC}"
    echo -e "${GREEN}Succès: $success_count${NC}"
    echo -e "${RED}Échecs: $fail_count${NC}"
    echo -e "${BLUE}Total: $total${NC}"
    
    if [ "$fail_count" -eq 0 ]; then
        echo -e "${GREEN}Toutes les conversions ont réussi !${NC}"
        echo -e "${BLUE}Fichiers audio disponibles dans: $OUTPUT_DIR${NC}"
    else
        echo -e "${YELLOW}Certaines conversions ont échoué. Vérifiez les messages d'erreur ci-dessus.${NC}"
        return 1
    fi
}

# Fonction principale
main() {
    # Affichage de l'en-tête
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  YouTube Audio Converter${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    # Traitement des arguments
    if [ $# -eq 0 ]; then
        echo -e "${RED}Erreur: Aucune URL ou fichier fourni.${NC}" >&2
        show_help
        exit 1
    fi

    # Vérification des dépendances après validation minimale des arguments,
    # afin de retourner les erreurs CLI les plus utiles en premier.
    check_dependencies
    
    # Création du dossier de sortie
    create_output_dir
    
    if [ $# -eq 1 ] && [ -f "$1" ]; then
        # Si un seul argument et que c'est un fichier, on le traite comme un fichier d'URLs
        process_file "$1"
    else
        # Sinon, on traite tous les arguments comme des URLs
        process_urls "$@"
    fi
}

# Exécution du script
main "$@"