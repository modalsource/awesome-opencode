#!/bin/bash

# Script AVANZATO per aggiornare .opencode preservando file locali
# Con report dettagliato delle modifiche

set -e

# Configurazione
REPO_URL="git@github.com:modalsource/awesome-opencode.git"
BRANCH="main-modalsource"
TARGET_FOLDER=".opencode"
TEMP_DIR=$(mktemp -d)
REPORT_FILE="opencode-update-report-$(date +%Y%m%d_%H%M%S).txt"

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Header
echo -e "${PURPLE}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║   📦 .opencode Update Script (Pro Version)      ║${NC}"
echo -e "${PURPLE}║   Mantiene i tuoi file locali                    ║${NC}"
echo -e "${PURPLE}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

# Funzione report
add_to_report() {
    echo "$1" >> "$REPORT_FILE"
}

# Inizializza report
add_to_report "=========================================="
add_to_report ".opencode Update Report"
add_to_report "Data: $(date)"
add_to_report "Utente: lucaforni"
add_to_report "=========================================="
add_to_report ""

# Cleanup
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Verifica prerequisiti
if [ ! -d .git ]; then
    echo -e "${RED}❌ Non sei in un repository git!${NC}"
    exit 1
fi

if [ ! command -v rsync &> /dev/null ]; then
    echo -e "${YELLOW}⚠️  rsync non trovato. Installalo per risultati migliori:${NC}"
    echo -e "${BLUE}   sudo apt-get install rsync  # Debian/Ubuntu${NC}"
    echo -e "${BLUE}   brew install rsync          # macOS${NC}"
fi

# Snapshot pre-aggiornamento
echo -e "${BLUE}📸 Snapshot stato attuale...${NC}"
if [ -d "$TARGET_FOLDER" ]; then
    find "$TARGET_FOLDER" -type f | sort > "$TEMP_DIR/snapshot_before.txt"
    FILE_COUNT_BEFORE=$(wc -l < "$TEMP_DIR/snapshot_before.txt")
    add_to_report "File presenti PRIMA: $FILE_COUNT_BEFORE"
    echo -e "${GREEN}   File attuali: $FILE_COUNT_BEFORE${NC}"
else
    FILE_COUNT_BEFORE=0
    add_to_report "Cartella .opencode non esistente prima dell'aggiornamento"
    echo -e "${YELLOW}   Cartella .opencode non esiste (sarà creata)${NC}"
fi

# Backup
if [ -d "$TARGET_FOLDER" ]; then
    BACKUP_DIR="${TARGET_FOLDER}.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}📦 Backup in ${BACKUP_DIR}...${NC}"
    cp -r "$TARGET_FOLDER" "$BACKUP_DIR"
    add_to_report "Backup creato: $BACKUP_DIR"
fi

# Clone repository
echo -e "${GREEN}📥 Download da awesome-opencode...${NC}"
git clone --depth 1 --branch "$BRANCH" --single-branch "$REPO_URL" "$TEMP_DIR/repo" 2>/dev/null

if [ ! -d "$TEMP_DIR/repo/$TARGET_FOLDER" ]; then
    echo -e "${RED}❌ Cartella ${TARGET_FOLDER} non trovata nel remoto!${NC}"
    exit 1
fi

# Snapshot repository remoto
find "$TEMP_DIR/repo/$TARGET_FOLDER" -type f | sed "s|$TEMP_DIR/repo/$TARGET_FOLDER/||" | sort > "$TEMP_DIR/remote_files.txt"
REMOTE_FILE_COUNT=$(wc -l < "$TEMP_DIR/remote_files.txt")
add_to_report "File nel repository remoto: $REMOTE_FILE_COUNT"
echo -e "${GREEN}   File nel remoto: $REMOTE_FILE_COUNT${NC}"

# Crea cartella se necessario
mkdir -p "$TARGET_FOLDER"

# Sync con rsync
echo -e "${GREEN}🔀 Sincronizzazione file...${NC}"
rsync -av \
    --update \
    --itemize-changes \
    "$TEMP_DIR/repo/$TARGET_FOLDER/" \
    "$TARGET_FOLDER/" \
    | tee "$TEMP_DIR/rsync_output.txt"

# Snapshot post-aggiornamento
find "$TARGET_FOLDER" -type f | sort > "$TEMP_DIR/snapshot_after.txt"
FILE_COUNT_AFTER=$(wc -l < "$TEMP_DIR/snapshot_after.txt")
add_to_report "File presenti DOPO: $FILE_COUNT_AFTER"

# Analisi dettagliata
echo ""
echo -e "${PURPLE}═══════════════════════════════════════${NC}"
echo -e "${PURPLE}   📊 REPORT DETTAGLIATO MODIFICHE${NC}"
echo -e "${PURPLE}═══════════════════════════════════════${NC}"

# Nuovi file dal remoto
echo ""
echo -e "${GREEN}📥 File NUOVI dal repository remoto:${NC}"
add_to_report ""
add_to_report "=== FILE NUOVI DAL REMOTO ==="
if [ -f "$TEMP_DIR/snapshot_before.txt" ]; then
    NEW_FILES=$(comm -13 \
        <(sed "s|$TARGET_FOLDER/||" "$TEMP_DIR/snapshot_before.txt") \
        <(sed "s|$TARGET_FOLDER/||" "$TEMP_DIR/snapshot_after.txt"))
    
    if [ -n "$NEW_FILES" ]; then
        echo "$NEW_FILES" | while read -r file; do
            # Verifica se il file viene dal remoto
            if grep -q "^$file$" "$TEMP_DIR/remote_files.txt"; then
                echo -e "${GREEN}   + $file${NC}"
                add_to_report "  + $file"
            fi
        done
        NEW_COUNT=$(echo "$NEW_FILES" | wc -l)
        echo -e "${GREEN}   Totale: $NEW_COUNT${NC}"
    else
        echo -e "${BLUE}   Nessun file nuovo${NC}"
        add_to_report "  Nessun file nuovo"
    fi
else
    add_to_report "  (Prima esecuzione - tutti i file sono nuovi)"
fi

# File modificati
echo ""
echo -e "${YELLOW}✏️  File MODIFICATI dal remoto:${NC}"
add_to_report ""
add_to_report "=== FILE MODIFICATI ==="
MODIFIED_FILES=$(grep '^>' "$TEMP_DIR/rsync_output.txt" | awk '{print $2}' || true)
if [ -n "$MODIFIED_FILES" ]; then
    echo "$MODIFIED_FILES" | head -20 | while read -r file; do
        echo -e "${YELLOW}   ⟳ $file${NC}"
        add_to_report "  ⟳ $file"
    done
    MOD_COUNT=$(echo "$MODIFIED_FILES" | wc -l)
    echo -e "${YELLOW}   Totale: $MOD_COUNT${NC}"
else
    echo -e "${BLUE}   Nessun file modificato${NC}"
    add_to_report "  Nessun file modificato"
fi

# File SOLO locali (preservati)
echo ""
echo -e "${PURPLE}💾 Tuoi file LOCALI (PRESERVATI):${NC}"
add_to_report ""
add_to_report "=== FILE LOCALI PRESERVATI ==="
LOCAL_ONLY=$(comm -23 \
    <(sed "s|$TARGET_FOLDER/||" "$TEMP_DIR/snapshot_after.txt") \
    <(cat "$TEMP_DIR/remote_files.txt"))

if [ -n "$LOCAL_ONLY" ]; then
    echo "$LOCAL_ONLY" | while read -r file; do
        echo -e "${PURPLE}   ★ $file${NC}"
        add_to_report "  ★ $file"
    done
    LOCAL_COUNT=$(echo "$LOCAL_ONLY" | wc -l)
    echo -e "${PURPLE}   Totale: $LOCAL_COUNT file (✅ PRESERVATI)${NC}"
    add_to_report ""
    add_to_report "Totale file locali preservati: $LOCAL_COUNT"
else
    echo -e "${BLUE}   Nessun file solo locale${NC}"
    add_to_report "  Nessun file solo locale"
fi

# Statistiche finali
echo ""
echo -e "${PURPLE}═══════════════════════════════════════${NC}"
echo -e "${PURPLE}   📈 STATISTICHE${NC}"
echo -e "${PURPLE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}   File prima:        $FILE_COUNT_BEFORE${NC}"
echo -e "${BLUE}   File dopo:         $FILE_COUNT_AFTER${NC}"
echo -e "${BLUE}   Differenza:        $((FILE_COUNT_AFTER - FILE_COUNT_BEFORE))${NC}"
echo -e "${PURPLE}═══════════════════════════════════════${NC}"

add_to_report ""
add_to_report "=== STATISTICHE FINALI ==="
add_to_report "File prima: $FILE_COUNT_BEFORE"
add_to_report "File dopo: $FILE_COUNT_AFTER"
add_to_report "Differenza: $((FILE_COUNT_AFTER - FILE_COUNT_BEFORE))"

# Salva report
echo ""
echo -e "${BLUE}💾 Report salvato in: ${REPORT_FILE}${NC}"

# Git status
echo ""
echo -e "${GREEN}📊 Stato Git:${NC}"
git status "$TARGET_FOLDER" --short

CHANGED_FILES=$(git status "$TARGET_FOLDER" --porcelain | wc -l)

if [ "$CHANGED_FILES" -eq 0 ]; then
    echo -e "${GREEN}✅ Nessuna modifica Git. Tutto aggiornato!${NC}"
    add_to_report ""
    add_to_report "Nessuna modifica da committare"
    exit 0
fi

# Commit
echo ""
read -p "$(echo -e ${YELLOW}Committare le modifiche? [y/N]:${NC} )" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git add "$TARGET_FOLDER"
    
    # Messaggio commit con statistiche
    if [ -n "$LOCAL_ONLY" ]; then
        LOCAL_COUNT=$(echo "$LOCAL_ONLY" | wc -l)
        COMMIT_MSG="chore: update .opencode from awesome-opencode

Updated: $(date +%Y-%m-%d)
- Files preserved: $LOCAL_COUNT local files
- Total files: $FILE_COUNT_AFTER

See detailed report: $REPORT_FILE"
    else
        COMMIT_MSG="chore: update .opencode from awesome-opencode ($(date +%Y-%m-%d))"
    fi
    
    git commit -m "$COMMIT_MSG"
    echo -e "${GREEN}✅ Commit creato!${NC}"
    add_to_report ""
    add_to_report "Modifiche committate con successo"
    
    read -p "$(echo -e ${YELLOW}Push? [y/N]:${NC} )" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push
        echo -e "${GREEN}✅ Push completato!${NC}"
        add_to_report "Push completato"
    fi
fi

echo ""
echo -e "${GREEN}✨ Aggiornamento completato!${NC}"
echo -e "${PURPLE}💡 I tuoi file locali sono stati preservati${NC}"
echo -e "${BLUE}📄 Vedi report dettagliato: ${REPORT_FILE}${NC}"
