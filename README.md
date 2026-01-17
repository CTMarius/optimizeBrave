# optimizeBrave

A comprehensive Bash script that disables all telemetry, tracking, and unnecessary features in Brave Browser on Linux, while applying performance optimizations to improve speed and responsiveness.

## What This Script Does

The `optimize_brave.sh` script performs a complete hardening of Brave Browser by:

- **Disabling all telemetry** and metric reporting that sends data to external servers
- **Removing crypto/AI features** (Wallet, Rewards, Leo Assistant, VPN promotions)
- **Hardening privacy settings** with privacy-sandbox disabling and fingerprinting protections
- **Optimizing performance** with GPU acceleration, memory optimizations, and caching improvements
- **Applying security enhancements** including HTTPS enforcement, WebRTC privacy, and site isolation
- **Creating automatic backups** before any changes so you can restore at any time
- **Generating launch flags** configuration for persistent optimization across browser restarts

All changes are applied to your Brave configuration files while maintaining a complete backup for easy restoration.

---

## Complete Checklist of Changes & Optimizations

### Privacy & Telemetry Disabling
- ✓ Disable all metrics and usage reporting
- ✓ Disable crash reporter and breakpad telemetry
- ✓ Disable field trial configuration
- ✓ Disable domain reliability reporting
- ✓ Disable background networking
- ✓ Disable component updates check
- ✓ Disable sync services
- ✓ Disable client-side phishing detection (use server-side instead)
- ✓ Disable search suggestions in address bar
- ✓ Disable alternate error page suggestions
- ✓ Disable DNS prefetching
- ✓ Disable automatic translation
- ✓ Disable referrer headers
- ✓ Disable hyperlink auditing (click tracking)
- ✓ Disable do-not-track (enable explicit DNT header instead)
- ✓ Disable default browser check prompts

### AI & Cryptocurrency Features Removal
- ✓ Disable Brave Leo AI Assistant
- ✓ Disable AI Chat history and autocomplete
- ✓ Disable Brave Wallet (crypto features)
- ✓ Disable Brave Rewards program
- ✓ Disable inline tip buttons
- ✓ Disable Brave VPN promotion
- ✓ Disable Brave News feed (Today tab)
- ✓ Remove stats reporting from Brave-specific features

### Network & Connection Privacy
- ✓ Disable WebRTC IP leaks (non-proxied UDP disabled)
- ✓ Enforce WebRTC IP permission checks
- ✓ Disable async DNS (use synchronous for better privacy)
- ✓ Disable network prediction
- ✓ Block third-party cookies
- ✓ Enable partitioned cookies (site-specific cookies)
- ✓ Disable media router service

### Data Collection & Permissions
- ✓ Disable geolocation services (block by default)
- ✓ Block payment handler requests
- ✓ Block notification permissions
- ✓ Block microphone access by default
- ✓ Block camera access by default
- ✓ Block MIDI/SYSEX access
- ✓ Block USB guard access
- ✓ Block Bluetooth access
- ✓ Block Bluetooth scanning

### Autofill & Form Security
- ✓ Disable autofill for forms
- ✓ Disable credit card autofill
- ✓ Disable address profile autofill
- ✓ Disable password manager service
- ✓ Disable credential storage

### Security Hardening
- ✓ Enable HTTPS-only mode
- ✓ Enable mixed content blocking with auto-upgrade
- ✓ Enable site isolation (process per site)
- ✓ Enable origin isolation
- ✓ Enable SafeBrowsing (basic, non-enhanced for privacy)
- ✓ Disable SafeBrowsing enhanced mode
- ✓ Disable SafeBrowsing reporting
- ✓ Enable certificate transparency checks

### Fingerprinting & Anti-Tracking
- ✓ Reduce user agent fingerprinting
- ✓ Reduce user agent minor version exposure
- ✓ Enable ephemeral storage (per-site cookie jars)
- ✓ Enable debouncing (URL tracking parameter removal)
- ✓ Enable CNAME uncloaking
- ✓ Enable dark mode fingerprinting protection
- ✓ Enable cosmetic filtering for ads
- ✓ Enable cosmetic filtering in child frames
- ✓ Enable cookie list default protection

### Performance Optimizations
- ✓ Enable GPU rasterization
- ✓ Enable zero-copy rendering
- ✓ Enable smooth scrolling
- ✓ Enable QUIC protocol
- ✓ Enable accelerated video decode
- ✓ Ignore GPU blocklist (use all available acceleration)
- ✓ Enable VAAPI video decoder
- ✓ Enable Canvas OOP rasterization
- ✓ Enable parallel downloading
- ✓ Enable Memory Savings Mode
- ✓ Enable Back-Forward Cache
- ✓ Enable lazy frame loading
- ✓ Enable lazy image loading
- ✓ Enable Prerender2 for faster navigation
- ✓ Enable iframe throttling
- ✓ Restrict WebSocket connection pooling
- ✓ Enable JXL image format support
- ✓ Enable fenced frames with Shadow DOM

### Brave-Specific Hardening
- ✓ Enable Brave Shields in aggressive mode
- ✓ Set Brave Shields as default protection level
- ✓ Enable extended ad/tracker blocking
- ✓ Enable Speedreader (disabled by default, can enable)
- ✓ Decentralized DNS disabled (optional, can enable)

### Cache & Storage Management
- ✓ Minimize disk cache size
- ✓ Clear session restore (no automatic session recovery)
- ✓ Disable WebRTC multiple routes
- ✓ Disable encrypted media extensions

### Additional Features
- ✓ Create launch flags configuration file for persistent settings
- ✓ Create optimized desktop launcher entry
- ✓ Remove crash report directories
- ✓ Disable system-level Brave background services
- ✓ Automatic backup before any changes are applied

---

## Execution Modes

### Basic Usage
```bash
# Make script executable
chmod +x optimize_brave.sh

# Run with default optimization
./optimize_brave.sh

# Or explicitly specify --optimize
./optimize_brave.sh --optimize
```

### Available Options

#### 1. **Apply Optimizations (Default)**
```bash
./optimize_brave.sh
# or
./optimize_brave.sh --optimize
```
Applies all telemetry disabling and performance optimizations. Creates an automatic backup before making any changes.

#### 2. **Create Backup Only**
```bash
./optimize_brave.sh --backup
```
Creates a backup of your current Brave configuration without applying any changes. Useful if you want to manually review what will be changed.

#### 3. **Restore from Backup**
```bash
./optimize_brave.sh --restore
```
Opens an interactive menu to restore from a previously created backup. Shows all available backup timestamps and lets you select which one to restore. **Note:** Brave must be closed before restoring.

#### 4. **List Available Backups**
```bash
./optimize_brave.sh --list-backups
```
Displays all available backup files with their timestamps and sizes. Helps you identify which backup to restore if needed.

#### 5. **Show Help**
```bash
./optimize_brave.sh --help
# or
./optimize_brave.sh -h
```
Displays the usage information and available options.

---

## How to Restore Settings

### Method 1: Using the Script (Recommended)
```bash
./optimize_brave.sh --restore
```
- Lists all available backups with timestamps
- Prompts you to select which backup to restore
- Automatically restores your previous configuration
- **Requires Brave to be closed**

### Method 2: Manual Restoration

If you know the exact backup timestamp, you can manually restore files:

```bash
# Find your backup timestamp (e.g., 20260116_143022)
TIMESTAMP="20260116_143022"
BACKUP_DIR="$HOME/.config/BraveSoftware/Brave-Browser/backups"

# Restore Preferences
cp "$BACKUP_DIR/Preferences_backup_$TIMESTAMP" "$HOME/.config/BraveSoftware/Brave-Browser/Default/Preferences"

# Restore Local State
cp "$BACKUP_DIR/LocalState_backup_$TIMESTAMP" "$HOME/.config/BraveSoftware/Brave-Browser/Local State"

# Restore Flags File
cp "$BACKUP_DIR/brave-flags.conf_backup_$TIMESTAMP" "$HOME/.config/BraveSoftware/Brave-Browser/brave-flags.conf"
```

### Method 3: View All Backups
```bash
./optimize_brave.sh --list-backups
```
Lists all available backups with dates and file sizes.

### Important Notes:
- ✓ **Always close Brave** before restoring to avoid conflicts
- ✓ **Backups are timestamped** so you can keep multiple versions
- ✓ **Default location:** `~/.config/BraveSoftware/Brave-Browser/backups/`
- ✓ **Full restore** includes: Preferences, Local State, and launch flags

---

## What Gets Modified

### 1. **Preferences File**
Location: `~/.config/BraveSoftware/Brave-Browser/Default/Preferences`
- JSON configuration file with 40+ privacy and performance settings
- Controls telemetry, autofill, notifications, search suggestions, and more
- Automatically backed up before modification

### 2. **Local State File**
Location: `~/.config/BraveSoftware/Brave-Browser/Local State`
- System-level browser settings
- Hardware acceleration mode
- User experience metrics disabling
- Automatically backed up before modification

### 3. **Launch Flags Configuration**
Location: `~/.config/BraveSoftware/Brave-Browser/brave-flags.conf`
- Command-line flags for browser startup
- Performance flags for GPU acceleration
- Privacy flags for tracking prevention
- Created with comprehensive feature enable/disable lists

### 4. **Desktop Launcher Entry**
Location: `~/.local/share/applications/brave-browser-optimized.desktop`
- Desktop shortcut for "Brave Browser (Optimized)"
- Includes embedded optimization flags
- Convenient launch from application menu

### 5. **Systemd Services**
- Disables Brave background update services
- Prevents automatic updates at system level

---

## Requirements

- **OS:** Linux (Ubuntu, Debian, Fedora, Arch, etc.)
- **Bash:** Version 4.0 or higher
- **Python 3:** Required for JSON preference updates
- **Brave Browser:** Installed and run at least once (creates config files)

## Installation

```bash
# Clone the repository
git clone https://github.com/CTMarius/optimizeBrave.git
cd optimizeBrave

# Make the script executable
chmod +x optimize_brave.sh

# Run it
./optimize_brave.sh
```

## Important Notes

- Script will **automatically close Brave** if it detects it running
- Creates **timestamped backups** before making any changes
- All changes are **non-destructive** and can be restored
- **No root/sudo access needed** for user-level optimizations
- Some system-wide optimizations may require sudo

## Related Configuration

The script creates or modifies:
- Brave configuration files in `~/.config/BraveSoftware/Brave-Browser/`
- Backup directory in the same location
- Desktop entry in `~/.local/share/applications/`
- Systemd user services in `~/.config/systemd/user/`

## License

Feel free to clone, copy, modify and distribute the script.

Use it at your own risk.

---

**Last Updated:** January 2026
**Compatible With:** Brave Browser (all recent versions)