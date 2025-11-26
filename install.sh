#!/bin/bash
# =============================================================================
# ZSH + Oh-My-Zsh Installer
# https://github.com/0FL01/fish-config
# =============================================================================
# Usage: curl -fsSL https://raw.githubusercontent.com/0FL01/shell-config/main/install.sh | bash
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

REPO_URL="https://raw.githubusercontent.com/0FL01/shell-config/main"

# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# -----------------------------------------------------------------------------
# Detect package manager
# -----------------------------------------------------------------------------

detect_package_manager() {
    if command -v apt &>/dev/null; then
        PKG_MANAGER="apt"
        PKG_UPDATE="sudo apt update"
        PKG_INSTALL="sudo apt install -y"
    elif command -v dnf &>/dev/null; then
        PKG_MANAGER="dnf"
        PKG_UPDATE="sudo dnf check-update || true"
        PKG_INSTALL="sudo dnf install -y"
    elif command -v pacman &>/dev/null; then
        PKG_MANAGER="pacman"
        PKG_UPDATE="sudo pacman -Sy"
        PKG_INSTALL="sudo pacman -S --noconfirm"
    elif command -v zypper &>/dev/null; then
        PKG_MANAGER="zypper"
        PKG_UPDATE="sudo zypper refresh"
        PKG_INSTALL="sudo zypper install -y"
    elif command -v apk &>/dev/null; then
        PKG_MANAGER="apk"
        PKG_UPDATE="sudo apk update"
        PKG_INSTALL="sudo apk add"
    else
        error "Пакетный менеджер не найден. Поддерживаются: apt, dnf, pacman, zypper, apk"
    fi
    
    success "Обнаружен пакетный менеджер: $PKG_MANAGER"
}

# -----------------------------------------------------------------------------
# Install dependencies
# -----------------------------------------------------------------------------

install_dependencies() {
    info "Установка зависимостей..."
    
    local packages_to_install=()
    
    # Check zsh
    if ! command -v zsh &>/dev/null; then
        packages_to_install+=("zsh")
    else
        success "zsh уже установлен"
    fi
    
    # Check git
    if ! command -v git &>/dev/null; then
        packages_to_install+=("git")
    else
        success "git уже установлен"
    fi
    
    # Check curl
    if ! command -v curl &>/dev/null; then
        packages_to_install+=("curl")
    else
        success "curl уже установлен"
    fi
    
    # Install bat (optional but recommended)
    if ! command -v bat &>/dev/null && ! command -v batcat &>/dev/null; then
        case "$PKG_MANAGER" in
            apt)
                packages_to_install+=("bat")
                ;;
            dnf)
                packages_to_install+=("bat")
                ;;
            pacman)
                packages_to_install+=("bat")
                ;;
            zypper)
                packages_to_install+=("bat")
                ;;
            apk)
                packages_to_install+=("bat")
                ;;
        esac
    else
        success "bat уже установлен"
    fi
    
    if [[ ${#packages_to_install[@]} -gt 0 ]]; then
        info "Обновление списка пакетов..."
        eval "$PKG_UPDATE"
        
        info "Установка: ${packages_to_install[*]}"
        eval "$PKG_INSTALL ${packages_to_install[*]}"
        success "Пакеты установлены"
    fi
}

# -----------------------------------------------------------------------------
# Install Oh-My-Zsh
# -----------------------------------------------------------------------------

install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        warn "Oh-My-Zsh уже установлен в $HOME/.oh-my-zsh"
        return 0
    fi
    
    info "Установка Oh-My-Zsh..."
    
    # Install oh-my-zsh without changing shell (we'll do it later)
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    
    success "Oh-My-Zsh установлен"
}

# -----------------------------------------------------------------------------
# Install plugins
# -----------------------------------------------------------------------------

install_plugins() {
    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    info "Установка плагинов..."
    
    # zsh-syntax-highlighting
    if [[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        warn "zsh-syntax-highlighting уже установлен"
    else
        info "Установка zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        success "zsh-syntax-highlighting установлен"
    fi
    
    # zsh-autosuggestions
    if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        warn "zsh-autosuggestions уже установлен"
    else
        info "Установка zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        success "zsh-autosuggestions установлен"
    fi
    
    # zsh-completions
    if [[ -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
        warn "zsh-completions уже установлен"
    else
        info "Установка zsh-completions..."
        git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
        success "zsh-completions установлен"
    fi
    
    success "Все плагины установлены"
}

# -----------------------------------------------------------------------------
# Setup configuration
# -----------------------------------------------------------------------------

setup_config() {
    info "Настройка конфигурации..."
    
    # Backup existing .zshrc if it exists and is not a symlink
    if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
        local backup_file="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        warn "Создаю резервную копию существующего .zshrc -> $backup_file"
        mv "$HOME/.zshrc" "$backup_file"
    fi
    
    # Download custom config
    info "Скачивание конфигурации..."
    curl -fsSL "$REPO_URL/.zshrc" -o "$HOME/.zshrc"
    
    success "Конфигурация установлена в $HOME/.zshrc"
}

# -----------------------------------------------------------------------------
# Change default shell
# -----------------------------------------------------------------------------

change_shell() {
    local zsh_path
    zsh_path=$(command -v zsh)
    
    if [[ "$SHELL" == *"zsh"* ]]; then
        success "zsh уже является оболочкой по умолчанию"
        return 0
    fi
    
    info "Смена оболочки по умолчанию на zsh..."
    
    # Check if zsh is in /etc/shells
    if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
        warn "Добавление $zsh_path в /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi
    
    # Change shell
    if chsh -s "$zsh_path"; then
        success "Оболочка по умолчанию изменена на zsh"
    else
        warn "Не удалось сменить оболочку автоматически."
        warn "Выполните вручную: chsh -s $zsh_path"
    fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          ZSH + Oh-My-Zsh Installer                            ║${NC}"
    echo -e "${CYAN}║          https://github.com/0FL01/shell-config                 ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    detect_package_manager
    install_dependencies
    install_oh_my_zsh
    install_plugins
    setup_config
    change_shell
    
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    Установка завершена!                       ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Для применения изменений:"
    echo -e "  ${CYAN}1.${NC} Перезайдите в систему"
    echo -e "  ${CYAN}2.${NC} Или выполните: ${YELLOW}exec zsh${NC}"
    echo ""
}

main "$@"

