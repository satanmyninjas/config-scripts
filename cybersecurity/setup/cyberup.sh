#!/bin/bash

VERSION=2.2
YEAR=$(date +%Y)

LOG_ERRORS=false
LOG_FILE="$HOME/cyberup-error.log"

export PACMAN_FLAGS="--needed --color=auto --noconfirm"
export YAY_FLAGS="--needed --noconfirm --batchinstall --removemake --cleanafter --color=auto --pgpfetch"

## ----------------------------------------------------------------------------
## NAME
##     show_usage - display program usage instructions.
##
## SYNOPSIS
##     show_usage
##
## DESCRIPTION
##     Outputs the help page, usage syntax, options, features,
##     and program information for the cyberup script.
##
## AUTHOR
##     Written by SATANMYNINJAS.
## ----------------------------------------------------------------------------
show_usage() {
    cat << EOF

cyberup - Arch Linux Cybersecurity Workstation Installer v$VERSION
by SATANMYNINJAS [DEFCON201] [nyc2600]

Usage:
  cyberup [OPTION]

Options:
  --install[=PATH]    Install this script system-wide (default: /usr/local/bin).
  --update            Download and replace the current script with the latest version.
  --log-errors        Enable error/warning logging to \$HOME/cyberup-error.log.
  --help              Show this help message and exit.

Interactive Menu:
  [1] Install BlackArch keyring only
  [2] Install ethical hacking environment only
  [3] Install both BlackArch keyring and ethical hacking environment
  [4] Show this help page
  [5] Exit

Description:
  cyberup automates the installation of a complete Arch Linux cybersecurity
  workstation, suitable for ethical hacking, forensics, reverse engineering,
  and security research.

Features:
  - Installs categorized packages (core, dev, pentest, forensics, etc)
  - Fetches tools from official repos, BlackArch, and the AUR
  - Handles pacman keyring updates and AUR PGP fetching
  - Optionally refreshes Arch mirrors based on your detected country
  - Provides an optional error log for troubleshooting
  - Supports auto-updating the script from GitHub

Examples:
  ./cyberup.sh --help
  ./cyberup.sh --install
  ./cyberup.sh --log-errors
  ./cyberup.sh --update

License:
  MIT License — Shoutout DEFCON-201 + NYC-2600 :3c

Repository:
  https://gist.github.com/<your-username>/<gist-id>

EOF
}

## ----------------------------------------------------------------------------
## NAME
##     log_error - append warnings and error messages to logfile.
##
## SYNOPSIS
##     log_error "message"
##
## DESCRIPTION
##     If error logging is enabled, appends warnings to the log file
##     at \$HOME/cyberup-error.log with a timestamp. Always echoes
##     to stdout regardless.
##
## OPTIONS
##     "message"
##         Message string to log.
##
## AUTHOR
##     Written by SATANMYNINJAS.
## ----------------------------------------------------------------------------
log_error() {
    local msg="$1"
    echo -e "[WARN] $msg"
    if [[ "$LOG_ERRORS" == true ]]; then
        echo "$(date +'%Y-%m-%d %H:%M:%S') [WARN] $msg" >> "$LOG_FILE"
    fi
}

## ----------------------------------------------------------------------------
## NAME
##     update_cyberup - download and replace cyberup with the latest version.
##
## SYNOPSIS
##     update_cyberup
##
## DESCRIPTION
##     Downloads the latest cyberup script from the GitHub repository
##     and overwrites the local copy. Sets execute permissions.
##
## AUTHOR
##     Written by SATANMYNINJAS.
## ----------------------------------------------------------------------------
update_cyberup() {
    echo -e "\n[ BUSY ] Checking for cyberup script updates...\n"
    curl -s -o "$HOME/cyberup.sh" https://raw.githubusercontent.com/satanmyninjas/config-scripts/refs/heads/main/cybersecurity/setup/cyberup.sh
    chmod +x "$HOME/cyberup.sh"
    echo -e "\n[ :3 ] cyberup updated! Run it with:\n"
    echo "bash ~/cyberup.sh"
    exit 0
}

## ----------------------------------------------------------------------------
## Function: generate_manpage
## Description:
##     Outputs a formatted manpage for cyberup in roff/groff format.
## ----------------------------------------------------------------------------
generate_manpage() {
cat << 'EOF'
.TH CYBERUP 1 "$YEAR" "v$VERSION" "Cybersecurity Workstation Setup"

.SH NAME
cyberup \- Arch Linux Cybersecurity Workstation Installer

.SH SYNOPSIS
.B cyberup
[\fIOPTION\fR]

.SH DESCRIPTION
cyberup automates the installation of a fully equipped Arch Linux workstation for cybersecurity, forensics, and ethical hacking.

.SH OPTIONS
.TP
\fB--install[=PATH]\fR
Install this script system-wide (default: /usr/local/bin).

.TP
\fB--update\fR
Download and replace the current script with the latest version.

.TP
\fB--log-errors\fR
Enable error/warning logging to \$HOME/cyberup-error.log.

.TP
\fB--help\fR
Display usage help and exit.

.SH FEATURES
- Installs categorized tools (core, dev, pentest, forensics, etc)
- Installs AUR packages using yay
- Auto-refreshes pacman keys and mirrors
- Region-optimized mirror updates
- Error logging support

.SH AUTHOR
Written by SATANMYNINJAS.
GitHub Repo: https://github.com/satanmyninjas/config-scripts/blob/main/cybersecurity/setup/cyberup.sh
Gist: https://gist.github.com/satanmyninjas/0a9249ad6e13c857dcd25ffa5bbd0f09

.SH LICENSE
MIT License.

.SH SEE ALSO
pacman(8), yay(1), reflector(1)
EOF
}


if [ "$EUID" -eq 0 ]; then
    echo "[ :( ] Do not run this script as root. Please run as a regular user. Exiting shell script..."
    exit 1
fi

if [[ "$1" == "--install" || "$1" == --install=* ]]; then
    INSTALL_DIR="/usr/local/bin"
    MANPAGE_DIR="/usr/share/man/man1"
    SCRIPT_NAME="cyberup"

    if [[ "$1" == --install=* ]]; then
        INSTALL_DIR="${1#--install=}"
    fi

    echo "[ BUSY ] Installing to $INSTALL_DIR/$SCRIPT_NAME ..."
    sudo cp "$0" "$INSTALL_DIR/$SCRIPT_NAME"
    sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

    echo "[ BUSY ] Installing manpage to $MANPAGE_DIR ..."
    generate_manpage | sudo tee "$MANPAGE_DIR/cyberup.1" > /dev/null
    sudo gzip -f "$MANPAGE_DIR/cyberup.1"

    echo "[ BUSY ] Updating man database ..."
    sudo mandb

    echo "[ :3c ] Installed successfully. You can now run 'cyberup' or 'man cyberup'"
    echo "[ ! ] If you updated this script, be sure to run ./cyberup --install to have the latest version be available system wide."
    exit 0
fi

if [[ "$1" == "--update" ]]; then
    update_cyberup
fi

if [[ "$1" == "--help" ]] then
    show_usage
fi

if [[ "$1" == "--log-errors" ]]; then
    LOG_ERRORS=true
    echo "[ :3 ] Logging enabled! Errors and warnings will be saved to: $LOG_FILE"
    : > "$LOG_FILE"  # Wipe previous log
fi

## ----------------------------------------------------------------------------
## NAME
##     display_ASCII_header - print program banner.
##
## SYNOPSIS
##     display_ASCII_header
##
## DESCRIPTION
##     Outputs the cyberup banner, version number, license, and
##     project purpose to the terminal.
##
## AUTHOR
##     Written by SATANMYNINJAS.
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
## NAME
##     check_yay - verify yay is installed and usable.
##
## SYNOPSIS
##     check_yay
##
## DESCRIPTION
##     Checks for yay (AUR helper) availability in the system \$PATH.
##     Falls back to /tmp/yay if available. Logs errors and exits if not found.
##
## AUTHOR
##     Written by SATANMYNINJAS.
## ----------------------------------------------------------------------------
check_yay() {
    if command -v yay >/dev/null 2>&1; then
        echo "[ :3 ] yay is already installed on the system."
        YAY_CMD="yay"
    else
        log_error "[ :( ] yay is not installed."
        read -p "[ ? ] Do you want to run yay from /tmp (if available)? [y/N] " choice
        case "$choice" in
            y|Y )
                if [ -x "/tmp/yay" ]; then
                    echo -e "\n[ BUSY ] Using yay from /tmp.\n"
                    YAY_CMD="/tmp/yay"
                else
                    log_error "\n[ :( ] yay not found in /tmp either. Please install yay manually first.\n"
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
## NAME
##     install_blackarch_keyring - add BlackArch repository and keys.
##
## SYNOPSIS
##     install_blackarch_keyring
##
## DESCRIPTION
##     Downloads and runs BlackArch's strap.sh to configure the keyring
##     and repository. Enables multilib support. Refreshes pacman database.
##
## AUTHOR
##     Written by SATANMYNINJAS.
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
## NAME
##     install_ethical_hacking_environment - install full cyber workstation.
##
## SYNOPSIS
##     install_ethical_hacking_environment
##
## DESCRIPTION
##     Installs categorized tools for cybersecurity, reverse engineering,
##     and forensics from official Arch repositories, BlackArch, and AUR.
##     Refreshes mirrorlist based on detected country. Updates keys and
##     package databases. Optionally logs warnings/errors to file.
##
## AUTHOR
##     Written by SATANMYNINJAS.
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

# Main menu.
while true; do

    clear

    display_ASCII_header
    echo "           CYBERUP Arch Linux Workstation Setup Script, v$VERSION"
    echo "  ==========================================================================="
    echo "  [1] Install BlackArch keyring only"
    echo "  [2] Install ethical hacking environment only"
    echo "  [3] Install both BlackArch keyring and ethical hacking environment :3c"
    echo "  [4] Show help page and program usage."
    echo -e "  [5] Exit :("
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
            show_usage
            break
            ;;
        5)
            echo -e "\n[ :3c ] Exiting setup. Goodbye! (=^w^=)/\n"
            exit 0
            ;;
        *)
            echo -e "\n[ :( ] Invalid choice. Please select a valid option.\n"
            break
            ;;
    esac
done
