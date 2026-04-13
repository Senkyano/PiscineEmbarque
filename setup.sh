#!/usr/bin/env bash
# ============================================================
#  setup.sh — Manager pour cross-compilation ATmega328P
#  Compatible Docker et Podman
#  Usage : ./setup.sh <commande> [exoN] [options]
# ============================================================

set -euo pipefail

# ── Config ───────────────────────────────────────────────────
IMAGE_NAME="avr-env"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_PORT="/dev/ttyUSB0"
DEFAULT_BAUD="115200"
DEFAULT_PROGRAMMER="arduino"
DEFAULT_MCU="atmega328p"
DEFAULT_F_CPU="16000000UL"

# ── Couleurs ─────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${RESET}  $*"; }
log_ok()      { echo -e "${GREEN}[OK]${RESET}    $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
log_error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
log_section() { echo -e "\n${BOLD}${CYAN}══  $*  ══${RESET}"; }

# ════════════════════════════════════════════════════════════
#  DÉTECTION DOCKER / PODMAN
# ════════════════════════════════════════════════════════════

detect_runtime() {
    # Priorité : variable d'env CONTAINER_RUNTIME > docker > podman
    if [[ -n "${CONTAINER_RUNTIME:-}" ]]; then
        echo "$CONTAINER_RUNTIME"
        return
    fi

    if command -v docker &>/dev/null; then
        # Vérifie si c'est un vrai Docker ou un alias podman
        if docker --version 2>/dev/null | grep -qi "podman"; then
            echo "podman"
        else
            echo "docker"
        fi
    elif command -v podman &>/dev/null; then
        echo "podman"
    else
        log_error "Ni Docker ni Podman trouvé. Installez l'un des deux."
        exit 1
    fi
}

RUNTIME="$(detect_runtime)"

# ════════════════════════════════════════════════════════════
#  HELPERS
# ════════════════════════════════════════════════════════════

check_image() {
    if ! $RUNTIME image inspect "$IMAGE_NAME" &>/dev/null; then
        log_warn "Image '${IMAGE_NAME}' introuvable."
        read -rp "  → Voulez-vous la builder maintenant ? [Y/n] " ans
        ans="${ans:-Y}"
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            cmd_build
        else
            log_error "Image requise. Lancez : ./setup.sh build"
            exit 1
        fi
    fi
}

# Valide qu'un projet exoN existe et contient un main.c
resolve_project() {
    local project="${1:-}"

    if [[ -z "$project" ]]; then
        log_error "Précisez un projet. Ex: ./setup.sh compile exo0"
        log_info  "Projets disponibles : $(list_projects)"
        exit 1
    fi

    local dir="${ROOT_DIR}/${project}"

    if [[ ! -d "$dir" ]]; then
        log_error "Projet introuvable : ${dir}"
        log_info  "Projets disponibles : $(list_projects)"
        exit 1
    fi

    if [[ ! -f "$dir/main.c" ]]; then
        log_error "Aucun main.c dans : ${dir}"
        exit 1
    fi

    echo "$project"
}

# Liste tous les projets détectés (dossiers avec un main.c)
list_projects() {
    find "$ROOT_DIR" -mindepth 2 -maxdepth 2 -name "main.c" \
        | sed "s|${ROOT_DIR}/||;s|/main.c||" \
        | sort \
        | tr '\n' ' '
}

# Lance un conteneur éphémère — monte la RACINE dans /project
container_run() {
    $RUNTIME run --rm \
        -v "${ROOT_DIR}:/project" \
        "$IMAGE_NAME" \
        "$@"
}

# Lance avec accès au port série
container_run_serial() {
    local port="$1"; shift

    if [[ ! -e "$port" ]]; then
        log_error "Port série introuvable : $port"
        log_info  "Ports disponibles :"
        ls /dev/ttyUSB* /dev/ttyACM* /dev/cu.* 2>/dev/null \
            || echo "  (aucun détecté)"
        exit 1
    fi

    $RUNTIME run --rm \
        -v "${ROOT_DIR}:/project" \
        --device "${port}" \
        "$IMAGE_NAME" \
        "$@"
}

# ════════════════════════════════════════════════════════════
#  COMMANDES
# ════════════════════════════════════════════════════════════

cmd_build() {
    log_section "Build de l'image Docker/Podman"
    log_info "Runtime    : ${RUNTIME}"
    log_info "Dockerfile : ${ROOT_DIR}/Dockerfile"
    $RUNTIME build -t "$IMAGE_NAME" "$ROOT_DIR"
    log_ok "Image '${IMAGE_NAME}' prête."
}

cmd_rebuild() {
    log_section "Rebuild complet (no-cache)"
    log_info "Runtime : ${RUNTIME}"
    $RUNTIME build --no-cache -t "$IMAGE_NAME" "$ROOT_DIR"
    log_ok "Image '${IMAGE_NAME}' reconstruite."
}

cmd_compile() {
    local project
    project="$(resolve_project "${1:-}")"

    local mcu="${MCU:-$DEFAULT_MCU}"
    local f_cpu="${F_CPU:-$DEFAULT_F_CPU}"

    log_section "Compilation — ${project}"
    log_info "Runtime   : ${RUNTIME}"
    log_info "MCU       : ${mcu}  |  F_CPU : ${f_cpu}"
    log_info "Source    : ${ROOT_DIR}/${project}/main.c"
    log_info "Sortie    : ${ROOT_DIR}/build/${project}/"

    # Crée le dossier de sortie sur l'hôte
    mkdir -p "${ROOT_DIR}/build/${project}"

    # Compile dans le conteneur (chemin /project = ROOT_DIR monté)
    container_run \
        sh -c "
            mkdir -p /project/build/${project} && \
            avr-gcc \
                -mmcu=${mcu} \
                -DF_CPU=${f_cpu} \
                -Os -Wall -Wextra -std=c99 \
                -ffunction-sections -fdata-sections \
                -Wl,--gc-sections \
                -Wl,-Map=/project/build/${project}/main.map \
                -o /project/build/${project}/main.elf \
                /project/${project}/main.c && \
            avr-objcopy -O ihex -R .eeprom \
                /project/build/${project}/main.elf \
                /project/build/${project}/main.hex
        "

    log_ok "Binaire : build/${project}/main.hex"
    cmd_size "$project"
}

cmd_compile_all() {
    log_section "Compilation de tous les projets"
    local projects
    projects="$(list_projects)"

    if [[ -z "$projects" ]]; then
        log_warn "Aucun projet (dossier avec main.c) trouvé."
        return
    fi

    for p in $projects; do
        cmd_compile "$p"
    done
    log_ok "Tous les projets compilés."
}

cmd_flash() {
    local project
    project="$(resolve_project "${1:-}")"

    local port="${PORT:-$DEFAULT_PORT}"
    local baud="${BAUD:-$DEFAULT_BAUD}"
    local programmer="${PROGRAMMER:-$DEFAULT_PROGRAMMER}"
    local mcu="${MCU:-$DEFAULT_MCU}"

    local hex="${ROOT_DIR}/build/${project}/main.hex"

    if [[ ! -f "$hex" ]]; then
        log_warn "Pas de .hex trouvé → compilation préalable..."
        cmd_compile "$project"
    fi

    log_section "Flash — ${project}"
    log_info "Runtime    : ${RUNTIME}"
    log_info "Port       : ${port}  |  Baud : ${baud}"
    log_info "Programmer : ${programmer}"

    container_run_serial "$port" \
        avrdude -c "$programmer" -p "$mcu" -P "$port" -b "$baud" \
                -U "flash:w:/project/build/${project}/main.hex:i"

    log_ok "Flash terminé."
}

cmd_clean() {
    local project="${1:-}"

    if [[ -z "$project" ]]; then
        log_section "Clean — tous les projets"
        rm -rf "${ROOT_DIR}/build"
        log_ok "Dossier build/ supprimé."
    else
        project="$(resolve_project "$project")"
        log_section "Clean — ${project}"
        rm -rf "${ROOT_DIR}/build/${project}"
        log_ok "build/${project} supprimé."
    fi
}

cmd_size() {
    local project
    project="$(resolve_project "${1:-}")"

    local elf="${ROOT_DIR}/build/${project}/main.elf"
    if [[ ! -f "$elf" ]]; then
        log_error "Pas d'ELF trouvé. Compilez d'abord : ./setup.sh compile ${project}"
        exit 1
    fi

    local mcu="${MCU:-$DEFAULT_MCU}"
    container_run \
        avr-size --mcu="$mcu" --format=avr "/project/build/${project}/main.elf"
}

cmd_disasm() {
    local project
    project="$(resolve_project "${1:-}")"

    local elf="${ROOT_DIR}/build/${project}/main.elf"
    if [[ ! -f "$elf" ]]; then
        log_error "Pas d'ELF trouvé. Compilez d'abord : ./setup.sh compile ${project}"
        exit 1
    fi

    log_section "Désassemblage — ${project}"
    container_run \
        avr-objdump -d -S "/project/build/${project}/main.elf"
}

cmd_shell() {
    log_section "Shell interactif"
    log_info "Runtime : ${RUNTIME}"
    log_info "Répertoire monté : ${ROOT_DIR} → /project"
    log_info "Tapez 'exit' pour quitter."
    $RUNTIME run --rm -it \
        -v "${ROOT_DIR}:/project" \
        "$IMAGE_NAME" \
        bash
}

cmd_list() {
    log_section "Runtime détecté"
    log_info "Utilisation de : ${BOLD}${RUNTIME}${RESET}"
    echo ""

    log_section "Image '${IMAGE_NAME}'"
    $RUNTIME images "$IMAGE_NAME" 2>/dev/null \
        || log_warn "Aucune image '${IMAGE_NAME}' trouvée."

    log_section "Projets disponibles"
    local projects
    projects="$(list_projects)"
    if [[ -n "$projects" ]]; then
        for p in $projects; do
            local hex="${ROOT_DIR}/build/${p}/main.hex"
            if [[ -f "$hex" ]]; then
                echo -e "  ${GREEN}✓${RESET}  ${p}  (compilé)"
            else
                echo -e "  ${YELLOW}○${RESET}  ${p}  (non compilé)"
            fi
        done
    else
        log_warn "Aucun projet trouvé."
    fi
}

cmd_runtime() {
    log_section "Sélection du runtime"
    echo -e "  Runtime actuel : ${BOLD}${RUNTIME}${RESET}"
    echo ""
    echo "  Pour forcer un runtime :"
    echo "    CONTAINER_RUNTIME=docker  ./setup.sh <commande>"
    echo "    CONTAINER_RUNTIME=podman  ./setup.sh <commande>"
    echo ""
    echo "  Runtimes disponibles :"
    command -v docker &>/dev/null && echo -e "    ${GREEN}✓${RESET} docker  ($(docker --version 2>/dev/null | head -1))"
    command -v podman &>/dev/null && echo -e "    ${GREEN}✓${RESET} podman  ($(podman --version 2>/dev/null | head -1))"
}

cmd_help() {
    echo -e "
${BOLD}setup.sh${RESET} — Manager Docker/Podman pour ATmega328P
${CYAN}────────────────────────────────────────────────────────${RESET}
  Runtime actuel : ${BOLD}${RUNTIME}${RESET}

${BOLD}USAGE${RESET}
  ./setup.sh <commande> [projet] [options]

${BOLD}IMAGE${RESET}
  ${GREEN}build${RESET}                  Build l'image (avr-gcc, avrdude…)
  ${GREEN}rebuild${RESET}                Rebuild sans cache
  ${GREEN}runtime${RESET}                Affiche/explique la sélection du runtime

${BOLD}COMPILATION${RESET}
  ${GREEN}compile${RESET}   <exoN>       Compile un projet
  ${GREEN}compile-all${RESET}            Compile tous les projets détectés
  ${GREEN}flash${RESET}     <exoN>       Compile si besoin + flashe
  ${GREEN}size${RESET}      <exoN>       Affiche Flash/RAM utilisés
  ${GREEN}disasm${RESET}    <exoN>       Désassemble l'ELF

${BOLD}UTILITAIRES${RESET}
  ${GREEN}clean${RESET}     [exoN]       Supprime build/exoN (ou tout build/)
  ${GREEN}shell${RESET}                  Shell bash dans le conteneur
  ${GREEN}list${RESET}                   Liste projets et état de compilation

${BOLD}FORCER LE RUNTIME${RESET}
  CONTAINER_RUNTIME=docker  ./setup.sh compile exo0
  CONTAINER_RUNTIME=podman  ./setup.sh compile exo0

${BOLD}OVERRIDE MCU / FRÉQUENCE${RESET}
  MCU=atmega328p F_CPU=8000000UL ./setup.sh compile exo0

${BOLD}EXEMPLES${RESET}
  ./setup.sh build
  ./setup.sh compile exo0
  ./setup.sh compile-all
  ./setup.sh flash exo0 PORT=/dev/ttyACM0
  ./setup.sh clean exo0
  ./setup.sh shell

${BOLD}ARBORESCENCE ATTENDUE${RESET}
  .
  ├── Dockerfile
  ├── setup.sh
  ├── build/
  │   └── exo0/
  │       ├── main.elf
  │       ├── main.hex
  │       └── main.map
  └── exo0/
      └── main.c

${CYAN}────────────────────────────────────────────────────────${RESET}
"
}

# ════════════════════════════════════════════════════════════
#  MAIN — dispatch
# ════════════════════════════════════════════════════════════

COMMAND="${1:-help}"
shift || true

case "$COMMAND" in
    build)        cmd_build ;;
    rebuild)      cmd_rebuild ;;
    compile)      check_image; cmd_compile     "${1:-}" ;;
    compile-all)  check_image; cmd_compile_all ;;
    flash)        check_image; cmd_flash       "${1:-}" ;;
    clean)        cmd_clean                    "${1:-}" ;;
    size)         check_image; cmd_size        "${1:-}" ;;
    disasm)       check_image; cmd_disasm      "${1:-}" ;;
    shell)        check_image; cmd_shell ;;
    list)         cmd_list ;;
    runtime)      cmd_runtime ;;
    help|--help|-h) cmd_help ;;
    *)
        log_error "Commande inconnue : '${COMMAND}'"
        cmd_help
        exit 1
        ;;
esac