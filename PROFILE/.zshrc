# ============================
#  Color Variables
# ============================

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

# ============================
#  First Run Welcome Message
# ============================

if [[ ! -f ~/.first_run_complete ]]; then
    echo -e "${MAGENTA}"
    echo "==============================================="
    echo -e "        ${BOLD}Welcome to Your New Zsh Setup!${RESET}${MAGENTA}"
    echo "==============================================="
    echo -e "${RESET}"

    echo -e "${GREEN}This message appears only once.${RESET}"
    echo -e "Your environment includes:"
    echo -e "  ${CYAN}• Zinit plugin manager${RESET}"
    echo -e "  ${CYAN}• Autosuggestions${RESET}"
    echo -e "  ${CYAN}• Syntax highlighting${RESET}"
    echo -e "  ${CYAN}• Dynamic Git-aware prompt${RESET}"
    echo -e "  ${CYAN}• System health summary${RESET}"
    echo -e "  ${CYAN}• Built-in help system (zhelp)${RESET}"
    echo ""
    echo -e "${YELLOW}Tip:${RESET} Type ${GREEN}zhelp${RESET} to explore your new environment."
    echo ""

    touch ~/.first_run_complete
fi

# ============================
#  Login Banner
# ============================

echo -e "${CYAN}"
echo "==============================================="
echo -e "   ${BOLD}Welcome to your Zsh Test Environment${RESET}${CYAN}"
echo "==============================================="
echo -e "${RESET}"

echo -e "${GREEN}User:${RESET}    $USER"
echo -e "${GREEN}Host:${RESET}    $(hostname)"
echo -e "${GREEN}Shell:${RESET}   $SHELL"
echo -e "${GREEN}Date:${RESET}    $(date)"
echo ""

echo -e "${YELLOW}Type 'zhelp' for available shortcuts and features.${RESET}"
echo ""

# ============================
#  System Health Summary
# ============================

system_health() {
    echo -e "${CYAN}System Health Summary:${RESET}"

    echo -e "  ${GREEN}CPU Load:${RESET}   $(uptime | awk -F'load average:' '{print $2}' | sed 's/^ //')"
    echo -e "  ${GREEN}Memory:${RESET}      $(free -h | awk '/Mem:/ {print $3 "/" $2}')"
    echo -e "  ${GREEN}Disk:${RESET}        $(df -h / | awk 'NR==2 {print $3 "/" $2 " used (" $5 ")"}')"

    if systemctl is-active --quiet docker; then
        RUNNING=$(docker ps -q | wc -l)
        echo -e "  ${GREEN}Docker:${RESET}      running (${RUNNING} containers)"
    else
        echo -e "  ${RED}Docker:${RESET}      not running"
    fi

    echo ""
}

system_health

# ============================
#  Zinit Plugin Manager (correct path)
# ============================

if [[ ! -f ~/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    mkdir -p ~/.local/share/zinit
    git clone https://github.com/zdharma-continuum/zinit.git ~/.local/share/zinit/zinit.git
fi

source ~/.local/share/zinit/zinit.git/zinit.zsh

# Plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting

# ============================
#  Basic Zsh Configuration
# ============================

autoload -Uz compinit
compinit

setopt prompt_subst
setopt append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt extended_glob
setopt autocd

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

# ============================
#  Dynamic Prompt (Git + Exit Code)
# ============================

git_branch() {
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    [[ -n "$branch" ]] && echo "($branch)"
}

exit_code() {
    [[ $? -ne 0 ]] && echo "%F{red}✖ $?%f"
}

PROMPT='%F{cyan}%n@%m%f:%F{yellow}%~%f $(git_branch) $(exit_code) %# '

# ============================
#  Aliases
# ============================

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"'
alias dlog='docker logs -f'
alias dstop='docker stop $(docker ps -q)'

# ============================
#  Built-in Help System
# ============================

zhelp() {
    case "$1" in
        docker)
            zhelp-docker
            return
            ;;
        git)
            zhelp-git
            return
            ;;
    esac

    echo -e ""
    echo -e "${MAGENTA}==============================================="
    echo -e "                 ${BOLD}ZSH HELP MENU${RESET}${MAGENTA}"
    echo -e "===============================================${RESET}"
    echo ""

    echo -e "${CYAN}${BOLD}Zsh Enhancements:${RESET}"
    echo -e "  ${GREEN}• Autosuggestions${RESET} – suggests commands as you type"
    echo -e "  ${GREEN}• Syntax highlighting${RESET} – colors commands based on validity"
    echo -e "  ${GREEN}• Autocd${RESET} – type a directory name to cd into it"
    echo -e "  ${GREEN}• Extended globbing${RESET} – powerful pattern matching"
    echo ""

    echo -e "${CYAN}${BOLD}Useful Keybindings:${RESET}"
    echo -e "  ${YELLOW}Ctrl+R${RESET}   Search command history"
    echo -e "  ${YELLOW}Ctrl+A${RESET}   Jump to start of line"
    echo -e "  ${YELLOW}Ctrl+E${RESET}   Jump to end of line"
    echo -e "  ${YELLOW}Alt+F${RESET}    Jump forward one word"
    echo -e "  ${YELLOW}Alt+B${RESET}    Jump backward one word"
    echo ""

    echo -e "${CYAN}${BOLD}Aliases:${RESET}"
    echo -e "  ${GREEN}ll${RESET}        Long listing"
    echo -e "  ${GREEN}la${RESET}        Show all files"
    echo -e "  ${GREEN}l${RESET}         Compact listing"
    echo -e "  ${GREEN}dps${RESET}       Pretty docker ps output"
    echo -e "  ${GREEN}dlog${RESET}      Follow logs of a container"
    echo -e "  ${GREEN}dstop${RESET}     Stop all running containers"
    echo ""

    echo -e "${CYAN}${BOLD}Submenus:${RESET}"
    echo -e "  ${GREEN}zhelp docker${RESET}   Docker commands"
    echo -e "  ${GREEN}zhelp git${RESET}      Git commands"
    echo ""

    echo -e "${MAGENTA}===============================================${RESET}"
    echo ""
}

# ============================
#  Submenu: Docker Help
# ============================

zhelp-docker() {
    echo -e "${MAGENTA}========== Docker Help ==========${RESET}"
    echo -e "${GREEN}dps${RESET}       List containers (clean format)"
    echo -e "${GREEN}dlog <name>${RESET}  Follow logs"
    echo -e "${GREEN}dstop${RESET}     Stop all containers"
    echo -e "${GREEN}docker exec -it <name> sh${RESET}  Shell into container"
    echo -e "${GREEN}docker stats${RESET}  Live resource usage"
    echo ""
}

# ============================
#  Submenu: Git Help
# ============================

zhelp-git() {
    echo -e "${MAGENTA}========== Git Help ==========${RESET}"
    echo -e "${GREEN}git status${RESET}     Show repo status"
    echo -e "${GREEN}git log --oneline${RESET}  Compact history"
    echo -e "${GREEN}git diff${RESET}       Show changes"
    echo -e "${GREEN}git branch${RESET}     List branches"
    echo -e "${GREEN}git switch <branch>${RESET}  Change branches"
    echo -e "${GREEN}git pull${RESET}       Update repo"
    echo ""
}
