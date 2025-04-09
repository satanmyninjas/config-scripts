#!/bin/bash

VERSION=1.4.2
YEAR=$(date +%Y)

export YAY_FLAGS="--noconfirm --quiet"
export PACMAN_FLAGS="--noconfirm --quiet"

if [ "$EUID" -eq 0 ]; then
    echo "[ :( ] Do not run this script as root. Please run as a regular user. Exiting shell script..."
    exit 1
fi

if [[ "$1" == "--install" ]]; then
    INSTALL_DIR="/usr/local/bin"
    SCRIPT_NAME="cyberup"

    # Allow override with --install=/bin or other path
    if [[ "$1" == --install=* ]]; then
        INSTALL_DIR="${1#--install=}"
    fi

    # Copy the script to the target directory
    echo "Installing to $INSTALL_DIR/$SCRIPT_NAME ..."
    if [[ $EUID -ne 0 ]]; then
        sudo cp "$0" "$INSTALL_DIR/$SCRIPT_NAME" && sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    else
        cp "$0" "$INSTALL_DIR/$SCRIPT_NAME" && chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    fi

    echo "Installed successfully. You can now run 'cyberup' from anywhere."
    exit 0
fi

## ----------------------------------------------------------------------------
## Function: display_ASCII_header
## Description:
##     Displays a custom ASCII art banner, script version, and purpose.
##     Adds a brief overview of the script's goals and licensing info.
## ----------------------------------------------------------------------------
display_ASCII_header() {

    echo -e "\n\n"
    echo "  ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░░▒▓████████▓▒░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░  "
    echo " ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ "
    echo " ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ "
    echo " ░▒▓█▓▒░       ░▒▓██████▓▒░░▒▓███████▓▒░░▒▓██████▓▒░ ░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░  "
    echo " ░▒▓█▓▒░         ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        "
    echo " ░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        "
    echo "  ░▒▓██████▓▒░   ░▒▓█▓▒░   ░▒▓███████▓▒░░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓█▓▒░        "
    echo -e "\n"
    echo -e "                        CYBERUP, v$VERSION, by SATANMYNINJAS, $YEAR                    \n"
    echo -e "                   MIT LICENSE -- SHOUTOUT DEFCON-201 + NYC-2600 :3\n\n"
    echo -e " This script automates the installation of essential tools and utilities for a fully equipped"
    echo -e " cybersecurity, ethical hacking, reverse engineering, and forensics workstation on Arch Linux."
    echo -e " Designed with efficiency and comprehensiveness in mind, it ensures your system is ready for"
    echo -e " coding, penetration testing, and forensic investigations with a single execution.\n"
}

## ----------------------------------------------------------------------------
## Function: check_yay
## Description:
##     Checks if the AUR helper 'yay' is installed on the system.
##     If not, optionally uses a local /tmp/yay fallback, or aborts.
## Globals:
##     YAY_CMD - Path to yay binary (set if found)
## ----------------------------------------------------------------------------
check_yay() {
    if command -v yay >/dev/null 2>&1; then
        echo "[ :3 ] yay is already installed on the system."
        YAY_CMD="yay"
    else
        echo "[ :( ] yay is not installed."
        read -p "[?] Do you want to run yay from /tmp (if available)? [y/N] " choice
        case "$choice" in
            y|Y )
                if [ -x "/tmp/yay" ]; then
                    echo "[BUSY] Using yay from /tmp."
                    YAY_CMD="/tmp/yay"
                else
                    echo "[ :( ] yay not found in /tmp either. Please install yay manually first."
                    exit 1
                fi
                ;;
            * )
                echo "[ :( ] Aborting. Please install yay first."
                exit 1
                ;;
        esac
    fi
}

## ----------------------------------------------------------------------------
## Function: install_blackarch_keyring
## Description:
##     Installs the BlackArch Linux keyring and repository by downloading
##     the official strap.sh installer and executing it. Also enables
##     the multilib repository and updates pacman databases.
## ----------------------------------------------------------------------------
install_blackarch_keyring() {
    echo -e "\n[BUSY] Setting up BlackArch keyring and downloading bootstrap..."
    curl -O https://blackarch.org/strap.sh
    

    echo "[BUSY] Adding execute permissions to strap.sh file..."
    chmod +x strap.sh
    ./strap.sh

    echo "[BUSY] Enabling multilib repository..."
    sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

    echo "[BUSY] Updating package databases..."
    sudo pacman -Syu --noconfirm

    echo -e "\n[ :3 ] BlackArch keyring setup complete!"
    echo -e "[BUSY] Cleaning up and removing strap.sh...\n"
    rm strap.sh
}

## ----------------------------------------------------------------------------
## Function: install_ethical_hacking_environment
## Description:
##     Installs an extensive set of packages from both official Arch repos
##     and the AUR to create a full cybersecurity, reverse engineering,
##     and digital forensics lab environment.
##
##     Tasks:
##       - Updates Arch mirror list with fastest HTTPS mirrors (US)
##       - Installs categorized toolsets (core, dev, hacking, forensics, etc.)
##       - Installs fonts/themes and productivity tools
##       - Installs AUR packages using yay
##       - Performs a final system update
## ----------------------------------------------------------------------------
install_ethical_hacking_environment() {
    echo -e "\n[BUSY] Installing ethical hacking environment..."
    echo -e "[ (0_o\") ] You might wanna grab a coffee. This can take a bit...\n"

    ESSENTIAL_CORE=(
    	linux-lts linux-lts-headers grub-btrfs timeshift os-prober 
	archlinux-keyring networkmanager network-manager-applet
    	fail2ban lynis clamav clamtk smartmontools nvme-cli 
	ethtool iw rfkillusbutils pciutils inxi dmidecode
    	pacman-contrib downgrade pkgfile man-db man 
    )

    BASE_PACKAGES=(
        base-devel git wget curl unzip zip p7zip
        htop neofetch tmux fish fzf fd ripgrep btop
        binutils nasm testdisk iputils traceroute bind 
        reflector screen 
    )

    DEV_TOOLS=(
        vim gvim gcc clang gdb lldb cmake make valgrind strace 
	ltrace python python-pip ipython jupyter-notebook
        python-virtualenv jdk-openjdk maven gradle go rustup rust
        nodejs npm yarn shellcheck ruby neovim github-cli
    )

    CYBERSEC_TOOLS=(
        metasploit nmap wireshark-qt john hydra sqlmap nikto 
	aircrack-ng impacket whois gnu-netcat
    )

    REVERSE_TOOLS=(
        ghidra radare2 binwalk cutter gdb bless capstone lsof
        sysdig strace hexedit ltrace
    )

    FORENSICS_TOOLS=(
        sleuthkit testdisk foremost btrfs-progs
        exfat-utils volatility3 ddrescue tcpdump dsniff
    )

    ETHICAL_HACKING_TOOLS=(
        hashcat kismet wifite reaver cowpatty mitmproxy
        bettercap bully wifite aircrack-ng
    )

    NETWORKING_TOOLS=(
        traceroute iperf3 tcpdump openssh tmate bind openvpn
        wireguard-tools
    )

    VIRTUALIZATION_TOOLS=(
        qemu-full libvirt virt-manager docker docker-compose
        virtualbox virtualbox-host-modules-arch vagrant edk2-ovmf
    )

    SECURITY_PRIVACY=(
        ufw gufw veracrypt gnupg keepassxc tor torbrowser-launcher
	rkhunter macchanger
    )

    NOTETAKING_REPORT_TOOLS=(
        libreoffice-fresh okular zathura zathura-pdf-poppler obsidian
        cherrytree exploitdb
    )

    EXTRAS=(
        ranger nnn thunar imagemagick perl-image-exiftool poppler pdftk qpdf
	telegram-desktop
    )

    FONTS_THEMES=(
        ttf-jetbrains-mono ttf-fira-code ttf-roboto-mono arc-gtk-theme
        papirus-icon-theme noto-fonts noto-fonts-emoji noto-fonts-cjk
    )

    AUR_PACKAGES=(
        gophish mullvad-vpn sddm-lain-wired-theme
        discord_arch_electron wordlists social-engineer-toolkit
        spiderfoot burpsuite recon-ng dnsprobe chkrootkit
        autopsy gobuster zenmap responder retdec extundelete guymager
        crunch sherlock-git phoneinfoga-bin osintgram dcfldd
        simplescreenrecorder binaryninja-free zoom otf-monocraft
	mkinitcpio-firmware powershell
    )

    # Modifying Arch Linux mirrors to be set to the US, checking
    # only HTTPS mirrors, and sorting the servers by speed.
    echo -e "\n[BUSY] Sorting fresh Arch mirrors..."
    reflector -p https -c US --sort rate --verbose
    echo -e "[ :3 ] Done sorting mirrors.\n"

    # Install necessary packages.
    echo -e "\n[BUSY] Installing a fuckload of packages..."
    sudo pacman -S $PACMAN_FLAGS "${ESSENTIAL_CORE[@]}"
    sudo pacman -S $PACMAN_FLAGS "${ETHICAL_HACKING_TOOLS[@]}"
    sudo pacman -S $PACMAN_FLAGS "${BASE_PACKAGES[@]}"
    sudo pacman -S $PACMAN_FLAGS "${DEV_TOOLS[@]}"
    sudo pacman -S $PACMAN_FLAGS "${CYBERSEC_TOOLS[@]}"
    sudo pacman -S $PACMAN_FLAGS "${REVERSE_TOOLS[@]}"
    sudo pacman -S $PACMAN_FLAGS "${FORENSICS_TOOLS[@]}"
    sudo pacman -S $PACMAN_FLAGS "${ETHICAL_HACKING_TOOLS[@]}"
    sudo pacman -S $PACMAN_FLAGS "${NETWORKING_TOOLS[@]}"
    sudo pacman -S $PACMAN_FLAGS "${VIRTUALIZATION_TOOLS[@]}"
    sudo pacman -S $PACMAN_FLAGS "${SECURITY_PRIVACY[@]}"
    sudo pacman -S $PACMAN_FLAGS "${NOTETAKING_REPORT_TOOLS[@]}"
    sudo pacman -S $PACMAN_FLAGS "${EXTRAS[@]}"
    sudo pacman -S $PACMAN_FLAGS "${FONTS_THEMES[@]}"
    echo -e "[ :3 ] Holy fuck it finished.\n"

    # Check yay availability.
    check_yay

    # Begin package installation and update logic using $YAY_CMD.
    echo -e "\n[BUSY] Updating AUR databases (output is set to quiet)..."
    $YAY_CMD -Syu --noconfirm
    echo -e "[ :3 ] Done updating AUR databases.\n"

    echo -e "\n[BUSY] Installing AUR packages..."
    $YAY_CMD $YAY_FLAGS -S "${AUR_PACKAGES[@]}"
    echo -e "[ :3 ] Done installing all AUR packages.\n"

    echo -e "\n[BUSY] Updating system..."
    sudo pacman -Syu --noconfirm
    echo -e "[ :3 ] Done updating system.\n"

    echo -e "\n[ :3c ] Ethical hacking environment setup complete!\n"
}

# Main menu.
while true; do

    clear

    display_ASCII_header
    echo "           CYBERUP Arch Linux Workstation Setup Script, v$VERSION"
    echo "  ========================================================================"
    echo "  [1] Install BlackArch keyring only"
    echo "  [2] Install ethical hacking environment only"
    echo "  [3] Install both BlackArch keyring and ethical hacking environment :3c"
    echo -e "  [4] Exit :("
    echo -e "  ========================================================================\n"
    read -rp " [?] Choose an option [1-4]: " choice

    case $choice in
        1)
            install_blackarch_keyring
            break
            ;;
        2)
            install_ethical_hacking_environment
            break
            ;;
        3)
            install_blackarch_keyring
            install_ethical_hacking_environment
            break
            ;;
        4)
            echo -e "\n[ :3c ] Exiting setup. Goodbye! (^_^)/\n"
            exit 0
            ;;
        *)
            echo -e "\n[ :( ] Invalid choice. Please select a valid option.\n"
            ;;
    esac
done
