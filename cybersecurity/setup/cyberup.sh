#!/bin/bash

VERSION=1.2.3

export YAY_FLAGS="--noconfirm --quiet --refresh --removemake --cleanafter"
export PACMAN_FLAGS="--needed --noconfirm --quiet"

if [ "$EUID" -eq 0 ]; then
    echo "[ :( ] Do not run this script as root. Please run as a regular user. Exiting shell script..."
    exit 1
fi

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
    echo -e "                        CYBERUP, v$VERSION, by SATANMYNINJAS, 2025                    \n"
    echo -e "                                      MIT LICENSE\n\n"
    echo -e " This script automates the installation of essential tools and utilities for a fully equipped"
    echo -e " cybersecurity, ethical hacking, reverse engineering, and forensics workstation on Arch Linux."
    echo -e " Designed with efficiency and comprehensiveness in mind, it ensures your system is ready for"
    echo -e " coding, penetration testing, and forensic investigations with a single execution.\n"
}

# Function to check if yay is installed -- will continue with user's installed yay setup if detected.
check_yay() {
    if command -v yay >/dev/null 2>&1; then
        echo "[+] yay is already installed on the system."
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

# Function to setup BlackArch keyring on system and enables multilib on system.
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

# Function defines and then installs a fuckton of packages from the AUR and official repos.
install_ethical_hacking_environment() {
    echo -e "\n[BUSY] Installing ethical hacking environment..."
    echo -e "[ (0_o\") ] You might wanna grab a coffee. This can take a bit...\n"

    BASE_PACKAGES=(
        base-devel git wget curl unzip zip p7zip
        htop neofetch tmux fish fzf fd ripgrep btop
        binutils nasm testdisk iputils traceroute bind 
        reflector screen
    )

    DEV_TOOLS=(
        vim gcc clang gdb lldb cmake make valgrind strace 
	ltrace python python-pip ipython jupyter-notebook
        python-virtualenv jdk-openjdk maven gradle go rustup rust
        nodejs npm yarn shellcheck ruby
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
        bettercap bully wifite
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
    )

    NOTETAKING_REPORT_TOOLS=(
        libreoffice-fresh okular zathura zathura-pdf-poppler obsidian
        cherrytree
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
    )

    # Modifying Arch Linux mirrors to be set to the US, checking
    # only HTTPS mirrors, and sorting the servers by speed.
    echo -e "\n[BUSY] Sorting fresh Arch mirrors..."
    reflector -p https -c US --sort rate --verbose
    echo -e "[ :3 ] Done sorting mirrors.\n"

    # Install necessary packages.
    echo -e "\n[BUSY] Installing a fuckload of packages..."
    sudo pacman -S --noconfirm --needed "${ETHICAL_HACKING_TOOLS[@]}"
    sudo pacman -S --noconfirm --needed "${BASE_PACKAGES[@]}"
    sudo pacman -S --noconfirm --needed "${DEV_TOOLS[@]}"
    sudo pacman -S --noconfirm --needed "${CYBERSEC_TOOLS[@]}"
    sudo pacman -S --noconfirm --needed "${REVERSE_TOOLS[@]}"
    sudo pacman -S --noconfirm --needed "${FORENSICS_TOOLS[@]}"
    sudo pacman -S --noconfirm --needed "${ETHICAL_HACKING_TOOLS[@]}"
    sudo pacman -S --noconfirm --needed "${NETWORKING_TOOLS[@]}"
    sudo pacman -S --noconfirm --needed "${VIRTUALIZATION_TOOLS[@]}"
    sudo pacman -S --noconfirm --needed "${SECURITY_PRIVACY[@]}"
    sudo pacman -S --noconfirm --needed "${NOTETAKING_REPORT_TOOLS[@]}"
    sudo pacman -S --noconfirm --needed "${EXTRAS[@]}"
    sudo pacman -S --noconfirm --needed "${FONTS_THEMES[@]}"
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
    echo "      CYBERUP Arch Linux Workstation Setup Script, v$VERSION"
    echo "  ==================================================================="
    echo "  [1] Install BlackArch keyring only"
    echo "  [2] Install ethical hacking environment only"
    echo "  [3] Install both BlackArch keyring and ethical hacking environment :3c"
    echo -e "  [4] Exit :("
    echo -e "  ===================================================================\n"
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
