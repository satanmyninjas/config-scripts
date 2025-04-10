#!/bin/bash

VERSION=2.1
YEAR=$(date +%Y)

update_cyberup() {
    echo -e "\n[ BUSY ] Checking for cyberup script updates...\n"
    curl -s -o "$HOME/cyberup.sh" https://raw.githubusercontent.com/satanmyninjas/config-scripts/refs/heads/main/cybersecurity/setup/cyberup.sh
    chmod +x "$HOME/cyberup.sh"
    echo -e "\n[ :3 ] cyberup updated! Run it with:\n"
    echo "bash ~/cyberup.sh"
    exit 0
}

export PACMAN_FLAGS="--needed --color=auto --noconfirm"
export YAY_FLAGS="--needed --noconfirm --batchinstall --removemake --cleanafter --color=auto --pgpfetch"


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
    echo "[ BUSY ] Installing to $INSTALL_DIR/$SCRIPT_NAME ..."
    if [[ $EUID -ne 0 ]]; then
        sudo cp "$0" "$INSTALL_DIR/$SCRIPT_NAME" && sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    else
        cp "$0" "$INSTALL_DIR/$SCRIPT_NAME" && chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    fi

    echo "[ :3c ] Installed successfully. You can now run 'cyberup' from anywhere."
    echo "[ ! ] If you updated this script, be sure to run ./cyberup --install to have the latest version be available system            wide."
    exit 0
fi

if [[ "$1" == "--update" ]]; then
    update_cyberup
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
    echo -e "                   MIT LICENSE -- SHOUTOUT DEFCON-201 + NYC-2600 :3c\n\n"
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
        read -p "[ ? ] Do you want to run yay from /tmp (if available)? [y/N] " choice
        case "$choice" in
            y|Y )
                if [ -x "/tmp/yay" ]; then
                    echo -e "\n[ BUSY ] Using yay from /tmp.\n"
                    YAY_CMD="/tmp/yay"
                else
                    echo -e "\n[ :( ] yay not found in /tmp either. Please install yay manually first.\n"
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
    echo -e "\n[ BUSY ] Setting up BlackArch keyring and downloading bootstrap...\n"
    curl -O https://blackarch.org/strap.sh

    echo -e "\n[ BUSY ] Adding execute permissions to strap.sh file...\n"
    chmod +x strap.sh
    sudo ./strap.sh

    echo "[ BUSY ] Enabling multilib repository..."
    sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

    echo "[ BUSY ] Updating package databases..."
    sudo pacman -Syu $PACMAN_FLAGS

    echo -e "\n[ :3 ] BlackArch keyring setup complete!"
    echo -e "[ BUSY ] Cleaning up and removing strap.sh...\n"
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
    echo -e "\n[ BUSY ] Installing ethical hacking environment..."
    echo -e "[ (0_o\") ] You might wanna grab a coffee. This can take a bit...\n"

    ESSENTIAL_CORE=(
    	linux-lts linux-lts-headers grub-btrfs timeshift os-prober
        archlinux-keyring networkmanager network-manager-applet
    	fail2ban lynis clamav clamtk smartmontools nvme-cli
        ethtool iw rfkill pciutils inxi dmidecode
    	pacman-contrib pkgfile man-db man
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
        bettercap bully wifite aircrack-ng chntpw
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
        ttf-jetbrains-mono ttf-fira-code ttf-roboto-mono
        papirus-icon-theme noto-fonts noto-fonts-emoji noto-fonts-cjk
    )

    AUR_PACKAGES=(
        downgrade gophish mullvad-vpn sddm-lain-wired-theme
        discord_arch_electron wordlists social-engineer-toolkit
        spiderfoot burpsuite recon-ng dnsprobe chkrootkit
        autopsy gobuster zenmap responder retdec extundelete guymager
        crunch sherlock-git phoneinfoga-bin osintgram dcfldd
        simplescreenrecorder binaryninja-free zoom otf-monocraft
	    mkinitcpio-firmware powershell
        beef-xss ccrypt chirp-next code-translucent cutecom
        dumpsterdiver-git exploitdb-bin-sploits-git exploitdb-papers-git
       	extundelete fatcat ferret-sidejack gr-osmosdr-git gss-ntlmssp gtkhash
        hamster-sidejack havoc hubble-bin hyperion.ng-git instaloader joplin
        libfreefare-git merlin miredo nmapsi4 ophcrack owl peass-ng
        pocsuite3 powershell powershell-empire python-ldapdomaindump
        readpe rephrase robotstxt sendemail sliver sparrow-wifi-git
        spire-bin swaks tightvnc tnscmd10g vboot-utils vopono waybackpy
       	whatmask wifipumpkin3-git wordlists xmount zerofree
    )

    KALI_TOOLS_EXTRACTED=(
        7zip arp-scan arpwatch atftp axel bettercap binwalk bluez
        bully cabextract cadaver capstone cherrytree chntpw cilium-cli
        clamav cosign cowpatty curlftpfs darkstat dbeaver ddrescue dos2unix
        dsniff eksctl ettercap expect exploitdb ext3grep fcrackzip findomain
        flashrom foremost fping freeradius ghidra git gitleaks gnu-netcat
        gnuradio gpart gparted gptfdisk gsocket hackrf hashcat hashcat-utils
        hcxtools hurl hydra impacket inspectrum libpst lynis masscan mc
        nasm nbtscan ncrack netscanner openvpn p0f pdfcrack pixiewps python-pipx
        python-virtualenv radare2 rarcrack routersploit ruby-rake seclists
        skipfish smbclient smtp-user-enum snmpcheck splint sqlite sqlmap
        ssldump sslscan steghide tcpdump testdisk thc-ipv6 tor traceroute
        unicornscan wafw00f wireshark-qt wpscan zaproxy zim zsh-autosuggestions
        zsh-syntax-highlighting lvm2 nfs-utils 0trace above aesfix aeskeyfind afflib
        airgeddon altdns amap amass apache-users arjun armitage asleap assetfinder autopsy autorecon
        bed bettercap-ui bing-ip2hosts bloodhound bloodyad blue-hydra bluelog
        blueranger bluesnarfer braa bruteforce-luks bruteforce-salted-openssl
        bruteforce-wallet brutespray btscanner bulk-extractor burpsuite
        bytecode-viewer certgraph certi cewl chainsaw chisel
        cisco-torch cookie-cadger crackmapexec crowbar cuckoo cutter
        darkdump dcfldd det dirb dirbuster dnsenum dnsmap dnsrecon
        dnstracer doona eapmd5pass edb-debugger enum4linux-ng enumiax
        fern-wifi-cracker fierce flawfinder
        fs-nyarl ghost-phisher goofile gospider gqrx hash-identifier
        haystack hexinject httprint intersect inurlbr
        johnny killerbee kismet legion
        linux-exploit-suggester mac-robber magicrescue maltego maryam maskprocessor
        massdns mdbtools memdump metagoofil mfcuk mimikatz missidentify mitm6 multimac
        myrescue naabu netdiscover netexec netmask netsed nextnet nishang nuclei o-saft
        ohrwurm ollydbg onesixtyone oscanner osrframework outguess pack pacu padbuster
        paros parsero pasco passdetective patator payloadsallthethings pdf-parser pdfid
        perl-cisco-copyconfig phishery photon pip3line pkt2flow plecost polenum
        powerfuzzer proxmark3 pwnat pyrit rainbowcrack rcracki_mt rsmangler
        rtpbreak sakis3g set shellnoob siparmyknife skiptracer sn0int sparta
        spooftooph sqlninja sqlsus sslcaudit sslsplit sublist3r termineter thc-pptp-bruter
        tlssled twofi u3-pwn unicornscan vega veil villain vinetto vlan voiphopper
        wafw00f wapiti wce webacoo webscarab webshells weevely wfuzz whatweb
        wifi-honey wifiphisher wig windows-binaries windows-privesc-check winregfs xplico
    )

    echo -e "\n[ BUSY ] Updating keyring first...\n"
    sudo pacman -Sy $PACMAN_FLAGS archlinux-keyring


    if ! command -v reflector >/dev/null 2>&1; then
        echo -e "\n[ :( ] Reflector not found. Installing...\n"
        sudo pacman -S $PACMAN_FLAGS reflector
    fi


    # Prompt to refresh Arch mirrors using reflector.
    read -rp "[ ? ] Do you want to refresh your Arch mirrors with the fastest mirrors for your region? [y/N] " refresh_mirrors

    if [[ "$refresh_mirrors" =~ ^[Yy]$ ]]; then
        echo -e "\n[ BUSY ] Determining your country for optimal mirrors...\n"

        # Auto-detect country code using ipinfo.io or fallback to US
        user_country=$(curl -s https://ipinfo.io/country || echo "US")
        user_country=${user_country//[$'\t\r\n']}  # Trim whitespace

        echo "[ :3 ] Detected country: $user_country"

        echo -e "\n[ BUSY ] Backing up current mirrorlist...\n"
        sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak.$(date +%Y%m%d)

        echo -e "\n[ BUSY ] Sorting fresh Arch mirrors...\n"
        sudo reflector -p https -c "$user_country" --sort rate --verbose --save /etc/pacman.d/mirrorlist

        echo -e "\n[ :3 ] Done sorting mirrors for region: $user_country\n"
    else
        echo -e "\n[ BUSY ] Skipping mirrorlist refresh...\n"
    fi

    echo -e "\n[ BUSY ] Refreshing pacman database...\n"
    sudo pacman -Sy $PACMAN_FLAGS

    echo -e "\n[ BUSY ] Refreshing Arch package keys...\n"
    sudo pacman-key --refresh-keys

    echo -e "\n[ BUSY ] Refreshing yay PGP keys (AUR)...\n"
    $YAY_CMD --devel --pgpfetch

    echo -e "\n[ BUSY ] Cleaning yay build cache...\n"
    $YAY_CMD -Sc --noconfirm

    # Install necessary packages.
    echo -e "\n[ BUSY ] Installing a fuckload of packages...\n"

    # Install all categorized packages (inline for clarity)
    sudo pacman -S $PACMAN_FLAGS \
        "${ESSENTIAL_CORE[@]}" \
        "${BASE_PACKAGES[@]}" \
        "${DEV_TOOLS[@]}" \
        "${CYBERSEC_TOOLS[@]}" \
        "${REVERSE_TOOLS[@]}" \
        "${FORENSICS_TOOLS[@]}" \
        "${ETHICAL_HACKING_TOOLS[@]}" \
        "${NETWORKING_TOOLS[@]}" \
        "${VIRTUALIZATION_TOOLS[@]}" \
        "${SECURITY_PRIVACY[@]}" \
        "${NOTETAKING_REPORT_TOOLS[@]}" \
        "${EXTRAS[@]}" \
        "${FONTS_THEMES[@]}" \
        "${KALI_TOOLS_EXTRACTED[@]}"
    echo -e "\n[ :3 ] Holy fuck it finished.\n"

    # Check yay availability.
    check_yay

    # Begin package installation and update logic using $YAY_CMD.
    echo -e "\n[ BUSY ] Installing AUR packages...\n"
    $YAY_CMD -Syu $YAY_FLAGS "${AUR_PACKAGES[@]}"
    echo -e "\n[ :3 ] Done installing all AUR packages.\n"

    echo -e "\n[ BUSY ] Updating system...\n"
    sudo pacman -Syu $PACMAN_FLAGS
    echo -e "\n[ :3 ] Done updating system.\n"

    echo -e "\n[ :3c ] Ethical hacking environment setup complete!\n"
}

## ----------------------------------------------------------------------------
## Function: show_usage
## Description:
##     Displays usage instructions and available flags for the cyberup script.
## ----------------------------------------------------------------------------
show_usage() {
    cat << EOF

cyberup - Arch Linux Cybersecurity Workstation Installer v$VERSION
by SATANMYNINJAS

Usage: cyberup [OPTION]

Options:
  --install[=PATH]    Install this script system-wide (default: /usr/local/bin).
  --help              Show this help message and exit.

Menu Options (Interactive):
  [1] Install BlackArch keyring only
  [2] Install ethical hacking environment only
  [3] Install both BlackArch keyring and ethical hacking environment
  [4] Exit

Description:
  cyberup automates the setup of a fully equipped cybersecurity,
  reverse engineering, and forensics workstation on Arch Linux.

  - Installs categorized tools (core, dev, hacking, forensics, etc)
  - Installs AUR tools via yay
  - Optional mirror refresh based on your region
  - Automatically handles pacman keyring updates
  - Optimized for clean, fast, reliable Arch systems

License:
  MIT License — Shoutout DEFCON-201 + NYC-2600 :3c

EOF
}

# Main menu.
while true; do

    clear

    display_ASCII_header
    echo "           CYBERUP Arch Linux Workstation Setup Script, v$VERSION"
    echo "  ==========================================================================="
    echo "  [1] Install BlackArch keyring only"
    echo "  [2] Install ethical hacking environment only"
    echo "  [3] Install both BlackArch keyring and ethical hacking environment :3c"
    echo -e "  [4] Exit :("
    echo -e "  ===========================================================================\n"
    read -rp "[ ? ] Choose an option [1-4]: " choice

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
            echo -e "\n[ :3c ] Exiting setup. Goodbye! (=^w^=)/\n"
            exit 0
            ;;
        *)
            echo -e "\n[ :( ] Invalid choice. Please select a valid option.\n"
            ;;
    esac
done
