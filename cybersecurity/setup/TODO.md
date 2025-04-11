## Core Features to Implement

### [ ] Orphaned Package Cleanup
- Detect unused/orphaned dependencies after install.
- Prompt user to remove them.
- Commands:
```bash
sudo pacman -Qtdq
$YAY_CMD -Yc
```

---

### [ ] System Health Summary Output
- After install finishes:
  - Print clean status table.
  - Example:
```
+--------------------+-------------+
| Section            | Status      |
+--------------------+-------------+
| Keyring Refreshed  | Yes         |
| Mirrors Refreshed  | Yes         |
| AUR Installed      | Complete    |
| Orphan Cleanup     | Done        |
| Errors Logged      | No Errors   |
+--------------------+-------------+
```

---

### [ ] Self-Update Check
- Auto-check latest version on GitHub/Gist.
- Passive warning if out-of-date:
```bash
echo "[ ! ] New version available: v2.2"
echo "      Run: cyberup --update"
```

---

### [ ] User Config File Support
- Support `~/.config/cyberup/config`
- User can override:
```bash
LOG_ERRORS=true
DEFAULT_COUNTRY=JP
SKIP_BLACKARCH=true
AUTO_REFRESH_MIRRORS=true
```

---

### [ ] Modular Install Profiles
Add `--profile` flag:

| Profile Name | Installs | Purpose |
|--------------|----------|---------|
| minimal      | Core + Dev Tools | Fastest, smallest footprint |
| full         | Everything | Current default behavior |
| forensics-only | Forensics + Reverse Tools only | IR/DFIR setups |

---

### [ ] Logging / Output Polish
- Standardize all output through helper functions:
```bash
info "[ :3 ] message"
warn "[ ! ] warning"
error "[ :( ] error"
```

- Colors:
  - Green = Info
  - Yellow = Warning
  - Red = Error
  - Cyan = Section Headers

---

### [ ] Lockfile Protection
Prevent double execution:

```bash
LOCKFILE="/tmp/.cyberup.lock"

if [ -e "$LOCKFILE" ]; then
    error "cyberup is already running. Exiting..."
    exit 1
fi

trap 'rm -f $LOCKFILE' EXIT
touch "$LOCKFILE"
```

---

## Packaging & Distribution

### [ ] Create Official PKGBUILD
- Allow install via AUR:
```
yay -S cyberup
```

Structure:
```
pkgname=cyberup
pkgver=2.1
pkgrel=1
source=("https://gist.githubusercontent.com/.../cyberup.sh")
install=cyberup.install
```

---

### [ ] Generate Manpage
Command:
```bash
man cyberup
```

Function:
```bash
manpage() { cat << EOF
<insert preformatted manpage here>
EOF
}
```

Install into:
```
/usr/share/man/man1/cyberup.1.gz
```

---

## Fun & Cute UX Ideas

| Idea | Detail |
|------|--------|
| Easter Egg | `cyberup --credits` prints hacker history / dev log |
| Terminal Quotes | Randomized quotes from hacker culture after install |
| ASCII Art Finish | Optional `ponysay` or `cowsay` finish |
| System Stats | Total installed packages, elapsed time |

---

## Low Priority / Future Ideas

| Idea | Benefit |
|------|---------|
| Mirrorlist Auto Backup Rotation | Keep N recent mirrorlist backups |
| Terminal Theme Detection | Dark vs Light output color optimization |
| Bash Tab-Completion | Custom completion for `cyberup` flags |
