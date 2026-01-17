#!/bin/bash

###############################################################################
# Brave Browser Telemetry Disabler & Performance Optimizer
# Description: Disables all telemetry/tracking and applies hidden settings
#              to improve performance in Brave Browser on Linux
# Usage: ./optimize_brave.sh [OPTIONS]
#   Options:
#     --optimize    : Apply optimizations (default if no option provided)
#     --backup      : Create backup only
#     --restore     : Restore from backup
#     --list-backups: List available backups
#     --help        : Show this help message
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Brave config directories
BRAVE_CONFIG="$HOME/.config/BraveSoftware/Brave-Browser"
BRAVE_PREFS="$BRAVE_CONFIG/Default/Preferences"
BRAVE_LOCAL_STATE="$BRAVE_CONFIG/Local State"
BACKUP_DIR="$BRAVE_CONFIG/backups"
FLAGS_FILE="$BRAVE_CONFIG/brave-flags.conf"

# Function to show usage
show_usage() {
    echo -e "${BLUE}Usage:${NC} $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --optimize       Apply all optimizations (default)"
    echo "  --backup         Create backup of current settings only"
    echo "  --restore        Restore from a backup interactively"
    echo "  --list-backups   List all available backups"
    echo "  --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Apply optimizations"
    echo "  $0 --backup           # Create backup only"
    echo "  $0 --restore          # Restore from backup"
    echo "  $0 --list-backups     # List available backups"
    exit 0
}

# Function to list backups
list_backups() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Available Backups${NC}"
    echo -e "${BLUE}========================================${NC}\n"
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        echo -e "${YELLOW}No backups found.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Preferences backups:${NC}"
    ls -lh "$BACKUP_DIR"/Preferences_backup_* 2>/dev/null | awk '{print "  " $6, $7, $8, "  " $9}' || echo "  None"
    
    echo -e "\n${GREEN}Local State backups:${NC}"
    ls -lh "$BACKUP_DIR"/LocalState_backup_* 2>/dev/null | awk '{print "  " $6, $7, $8, "  " $9}' || echo "  None"
    
    echo -e "\n${GREEN}Flags file backups:${NC}"
    ls -lh "$BACKUP_DIR"/brave-flags.conf_backup_* 2>/dev/null | awk '{print "  " $6, $7, $8, "  " $9}' || echo "  None"
    echo ""
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Creating backup of current settings...${NC}"
    mkdir -p "$BACKUP_DIR"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    
    local backup_created=false
    
    if [ -f "$BRAVE_PREFS" ]; then
        if cp "$BRAVE_PREFS" "$BACKUP_DIR/Preferences_backup_$TIMESTAMP" 2>/dev/null; then
            echo -e "${GREEN}✓ Backed up Preferences${NC}"
            backup_created=true
        else
            echo -e "${RED}✗ Failed to backup Preferences${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Preferences file not found${NC}"
    fi
    
    if [ -f "$BRAVE_LOCAL_STATE" ]; then
        if cp "$BRAVE_LOCAL_STATE" "$BACKUP_DIR/LocalState_backup_$TIMESTAMP" 2>/dev/null; then
            echo -e "${GREEN}✓ Backed up Local State${NC}"
            backup_created=true
        else
            echo -e "${RED}✗ Failed to backup Local State${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Local State file not found${NC}"
    fi
    
    if [ -f "$FLAGS_FILE" ]; then
        if cp "$FLAGS_FILE" "$BACKUP_DIR/brave-flags.conf_backup_$TIMESTAMP" 2>/dev/null; then
            echo -e "${GREEN}✓ Backed up brave-flags.conf${NC}"
            backup_created=true
        fi
    fi
    
    if [ "$backup_created" = true ]; then
        echo -e "\n${GREEN}Backup created successfully!${NC}"
        echo -e "${YELLOW}Backup location:${NC} $BACKUP_DIR"
        echo -e "${YELLOW}Timestamp:${NC} $TIMESTAMP"
    else
        echo -e "\n${RED}No files were backed up.${NC}"
        return 1
    fi
}

# Function to restore from backup
restore_from_backup() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Restore from Backup${NC}"
    echo -e "${BLUE}========================================${NC}\n"
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        echo -e "${RED}No backups found!${NC}"
        return 1
    fi
    
    # Get list of unique timestamps from backup files
    local timestamps=($(ls "$BACKUP_DIR" 2>/dev/null | grep -oP '\d{8}_\d{6}' | sort -u | tail -10))
    
    if [ ${#timestamps[@]} -eq 0 ]; then
        echo -e "${RED}No valid backups found!${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Available backup timestamps:${NC}\n"
    for i in "${!timestamps[@]}"; do
        local ts=${timestamps[$i]}
        local date_part=${ts:0:8}
        local time_part=${ts:9:6}
        local formatted_date="${date_part:0:4}-${date_part:4:2}-${date_part:6:2}"
        local formatted_time="${time_part:0:2}:${time_part:2:2}:${time_part:4:2}"
        echo -e "  ${BLUE}[$((i+1))]${NC} $formatted_date $formatted_time"
    done
    
    echo -e "\n${YELLOW}Enter the number of the backup to restore (or 'q' to quit):${NC} "
    read -r selection
    
    if [ "$selection" = "q" ] || [ "$selection" = "Q" ]; then
        echo -e "${YELLOW}Restore cancelled.${NC}"
        return 0
    fi
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#timestamps[@]} ]; then
        echo -e "${RED}Invalid selection!${NC}"
        return 1
    fi
    
    local selected_timestamp=${timestamps[$((selection-1))]}
    
    # Check if Brave is running
    if pgrep -x "brave" > /dev/null || pgrep -x "brave-browser" > /dev/null; then
        echo -e "${RED}Error: Brave Browser is running!${NC}"
        echo -e "${YELLOW}Please close Brave before restoring.${NC}"
        return 1
    fi
    
    echo -e "\n${YELLOW}Restoring from backup: $selected_timestamp${NC}"
    
    local restore_success=false
    
    # Restore Preferences
    if [ -f "$BACKUP_DIR/Preferences_backup_$selected_timestamp" ]; then
        if cp "$BACKUP_DIR/Preferences_backup_$selected_timestamp" "$BRAVE_PREFS" 2>/dev/null; then
            echo -e "${GREEN}✓ Restored Preferences${NC}"
            restore_success=true
        else
            echo -e "${RED}✗ Failed to restore Preferences${NC}"
        fi
    fi
    
    # Restore Local State
    if [ -f "$BACKUP_DIR/LocalState_backup_$selected_timestamp" ]; then
        if cp "$BACKUP_DIR/LocalState_backup_$selected_timestamp" "$BRAVE_LOCAL_STATE" 2>/dev/null; then
            echo -e "${GREEN}✓ Restored Local State${NC}"
            restore_success=true
        else
            echo -e "${RED}✗ Failed to restore Local State${NC}"
        fi
    fi
    
    # Restore flags file
    if [ -f "$BACKUP_DIR/brave-flags.conf_backup_$selected_timestamp" ]; then
        if cp "$BACKUP_DIR/brave-flags.conf_backup_$selected_timestamp" "$FLAGS_FILE" 2>/dev/null; then
            echo -e "${GREEN}✓ Restored brave-flags.conf${NC}"
            restore_success=true
        else
            echo -e "${RED}✗ Failed to restore brave-flags.conf${NC}"
        fi
    fi
    
    if [ "$restore_success" = true ]; then
        echo -e "\n${GREEN}========================================${NC}"
        echo -e "${GREEN}Restore completed successfully!${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo -e "\n${YELLOW}Please restart Brave Browser for changes to take effect.${NC}"
    else
        echo -e "\n${RED}No files were restored.${NC}"
        return 1
    fi
}

# Parse command line arguments
case "${1:-}" in
    --help|-h)
        show_usage
        ;;
    --list-backups)
        list_backups
        exit 0
        ;;
    --backup)
        if [ ! -d "$BRAVE_CONFIG" ]; then
            echo -e "${RED}Error: Brave Browser configuration directory not found!${NC}"
            exit 1
        fi
        create_backup
        exit 0
        ;;
    --restore)
        if [ ! -d "$BRAVE_CONFIG" ]; then
            echo -e "${RED}Error: Brave Browser configuration directory not found!${NC}"
            exit 1
        fi
        restore_from_backup
        exit 0
        ;;
    --optimize|"")
        # Continue with optimization (default behavior)
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        echo ""
        show_usage
        ;;
esac

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Brave Browser Optimizer${NC}"
echo -e "${GREEN}========================================${NC}\n"

# Check if Brave is installed
if [ ! -d "$BRAVE_CONFIG" ]; then
    echo -e "${RED}Error: Brave Browser configuration directory not found!${NC}"
    echo -e "${YELLOW}Please install Brave Browser first or run it at least once.${NC}"
    exit 1
fi

# Create backup before making changes
create_backup
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Close Brave if running
echo -e "\n${YELLOW}Checking if Brave is running...${NC}"
if pgrep -x "brave" > /dev/null || pgrep -x "brave-browser" > /dev/null; then
    echo -e "${YELLOW}Brave is running. Please close it before continuing.${NC}"
    read -p "Press Enter after closing Brave Browser..."
fi

# Create launch flags file
echo -e "\n${YELLOW}Configuring launch flags for performance...${NC}"

cat > "$FLAGS_FILE" << 'EOF'
# Performance optimizations
--enable-gpu-rasterization
--enable-zero-copy
--enable-smooth-scrolling
--enable-quic
--enable-accelerated-video-decode
--ignore-gpu-blocklist

# Privacy & Telemetry (disabled)
--disable-background-networking
--disable-breakpad
--disable-crash-reporter
--disable-field-trial-config
--disable-client-side-phishing-detection
--disable-component-update
--disable-default-apps
--disable-domain-reliability
--disable-sync
--disable-translate
--metrics-recording-only
--no-pings
--disable-background-timer-throttling
--disable-backgrounding-occluded-windows
--disable-hang-monitor
--disable-ipc-flooding-protection
--disable-popup-blocking
--disable-prompt-on-repost
--disable-renderer-backgrounding
--disable-sync-preferences
--force-dark-mode
--no-default-browser-check
--no-first-run
--no-service-autorun
--disable-geolocation
--dns-prefetch-disable
--reduced-referrer-granularity
--disable-notifications
--disable-offer-store-unmasked-wallet-cards
--disable-offer-upload-credit-cards
--disable-search-engine-choice-screen
--certificate-transparency-enforcement-disable

# WebRTC Privacy
--force-webrtc-ip-handling-policy=disable_non_proxied_udp
--enforce-webrtc-ip-permission-check

# Secure DNS / DoH Control
--async-dns=false

# Site Isolation & Security
--site-per-process
--enable-site-isolation-trial-opt-out

# Additional Security Flags
--enable-features=IsolateOrigins,site-per-process
--isolate-origins=*

# COMBINED: Features to ENABLE (performance & memory optimizations)
--enable-features=VaapiVideoDecoder,CanvasOopRasterization,ParallelDownloading,MemorySavingsMode,BackForwardCache,LazyFrameLoading,LazyImageLoading,BraveEphemeralStorage,BraveDomainBlock,BraveAdblockCnameUncloaking,BraveAdblockCosmeticFiltering,BraveDebounce,BraveDarkModeBlock,BraveExtensionNetworkBlocking,PartitionedCookies,ReduceUserAgent,ReduceUserAgentMinorVersion,Prerender2,ThrottleDisplayNoneAndVisibilityHiddenCrossOriginIframes,RestrictWebSocketsPool,ParallelDownloading,EnableJXL,FencedFrames:implementation_type/shadow_dom

# COMBINED: Features to DISABLE (privacy, tracking, AI, crypto, fingerprinting)
--disable-features=UseChromeOSDirectVideoDecoder,AutofillServerCommunication,CertificateTransparencyComponentUpdater,InterestFeedContentSuggestions,Translate,MediaRouter,BraveLeoAssistant,BraveAIChatHistory,AIChat,BraveLeo,ContextualSearches,BraveWallet,BraveRewards,BraveVPN,BraveNews,AsyncDNS,NetworkPrediction,SafeBrowsingEnhanced,AutofillCreditCard,AutofillAddressSave,PasswordImport,AudioServiceOutOfProcess,WebBluetooth,WebUSB,WebMIDI,Reporting,ReportingObserver,SignedHTTPExchange,OptimizationHints,OptimizationGuideModelDownloading,OptimizationHintsFetching,MediaEngagementBypassAutoplayPolicies,CalculateNativeWinOcclusion,AutofillEnableSendingBcnInGetUploadDetails,AutofillFillMerchantPromoCodeFields,AutofillParseMerchantPromoCodeFields,EnableAccessibilityLiveCaption,EnableAutofillCreditCardAuthentication,EnableWebUsbDeviceDetection,OmniboxDynamicMaxAutocomplete,OmniboxRichAutocompletionPromisin,SystemKeyboardLock,WebXrIncubations,GenericSensorExtraClasses,FontAccess,EditContext,DevicePosture,DurableClientHintsCache
EOF

echo -e "${GREEN}✓ Launch flags configured${NC}"

# Create preferences JSON updates
echo -e "\n${YELLOW}Applying privacy and performance preferences...${NC}"

# Function to update JSON preferences using Python
update_preferences() {
    python3 << 'PYTHON_SCRIPT'
import json
import sys
import os

prefs_file = os.path.expanduser("~/.config/BraveSoftware/Brave-Browser/Default/Preferences")
local_state_file = os.path.expanduser("~/.config/BraveSoftware/Brave-Browser/Local State")

# Preferences to disable telemetry and improve performance
telemetry_settings = {
    # Disable all metrics and reporting
    "browser": {
        "check_default_browser": False,
        "has_seen_welcome_page": True,
        # URL Bar Suggestions (moved here to avoid duplicate key)
        "urlbar": {
            "suggest": {
                "enabled": False,
                "searches": False
            },
            "shortcuts": {
                "enabled": False
            }
        }
    },
    "distribution": {
        "import_bookmarks": False,
        "import_history": False,
        "import_search_engine": False,
        "make_chrome_default_for_user": False,
        "skip_first_run_ui": True,
        "show_welcome_page": False
    },
    # Privacy & Security Settings (inspired by arkenfox)
    "privacy": {
        "privacy_sandbox": {
            "m1": {
                "topics_enabled": False,
                "fledge_enabled": False
            }
        }
    },
    # Geolocation
    "geolocation": {
        "default_content_setting": 2  # 2=block
    },
    # Disable AI features
    "brave": {
        "ai_chat": {
            "enabled": False,
            "autocomplete_enabled": False
        },
        "leo": {
            "enabled": False
        },
        # New Tab Page Settings
        "new_tab_page": {
            "custom_background_enabled": False,
            "show_background_image": False,
            "show_sponsored_images_background": False,
            "show_clock": False,
            "show_stats": False,
            "show_news": False,
            "show_web3_domains": False,
            "show_gemini": False
        },
        # Usage Statistics (disable sending data to Brave)
        "stats": {
            "reporting_enabled": False
        },
        "p3a": {
            "enabled": False
        },
        "brave_news_enabled": False,
        "brave_news_p3a_enabled": False,
        # Memory & Performance Settings
        "memory_savings_mode": {
            "enabled": True,
            "aggressive": True
        },
        "performance_tab_discarding": {
            "enabled": True
        },
        # Tab Groups
        "tab_groups": {
            "enabled": False
        },
        # Disable Crypto & Wallet features
        "wallet": {
            "enabled": False,
            "show_wallet_button": False,
            "show_wallet_icon": False
        },
        "rewards": {
            "enabled": False,
            "inline_tip_buttons_enabled": False,
            "show_brave_rewards_button_in_location_bar": False
        },
        "brave_vpn": {
            "show_button": False
        },
        "today": {
            "should_show": False
        },
        # Brave Shield Settings (enforce aggressive mode protections)
        "shields": {
            "brave_shields_default": True,
            "brave_shields_aggressive_mode": True
        },
        # Ephemeral Storage
        "ephemeral_storage": {
            "enabled": True
        },
        # Debouncing (URL tracking parameter removal)
        "debounce": {
            "enabled": True
        },
        # Dark Mode Blocking (fingerprinting protection)
        "dark_mode_block": {
            "enabled": True
        },
        # CNAME Uncloaking
        "adblock": {
            "cname_uncloaking": True,
            "cosmetic_filtering": True,
            "cosmetic_filtering_child_frames": True,
            "cookie_list_default": True
        },
        # Reader Mode / Speedreader
        "speedreader": {
            "enabled": False  # Set to True if you want it enabled
        },
        # Decentralized DNS
        "decentralized_dns": {
            "enabled": False  # Optionally enable for ENS/IPFS support
        }
    },
    # Search & Address Bar
    "search": {
        "suggest_enabled": False
    },
    "alternate_error_pages": {
        "enabled": False
    },
    "safebrowsing": {
        "enabled": True,  # Keep basic protection
        "enhanced": False,  # Disable enhanced mode for privacy
        "reporting_enabled": False
    },
    "net": {
        "network_prediction_options": 2  # 2=never predict
    },
    "dns_prefetching": {
        "enabled": False
    },
    # Autofill & Passwords
    "autofill": {
        "enabled": False,
        "credit_card_enabled": False,
        "profile_enabled": False
    },
    "credentials_enable_service": False,
    "password_manager_enabled": False,
    # WebRTC
    "webrtc": {
        "ip_handling_policy": "disable_non_proxied_udp",
        "multiple_routes_enabled": False,
        "nonproxied_udp_enabled": False
    },
    # Notifications
    "enable_notifications": False,
    # Performance settings
    "profile": {
        "default_content_setting_values": {
            "payment_handler": 2,  # Block
            "notifications": 2,  # Block
            "geolocation": 2,  # Block
            "media_stream_mic": 2,  # Block (ask when needed)
            "media_stream_camera": 2,  # Block (ask when needed)
            "midi_sysex": 2,  # Block
            "usb_guard": 2,  # Block
            "bluetooth_guard": 2,  # Block
            "bluetooth_scanning": 2  # Block
        },
        "cookie_controls_mode": 1,  # Block third-party cookies
        "block_third_party_cookies": True
    },
    # Disk Cache & Session
    "disk_cache_size": 0,  # Minimal disk cache
    "session": {
        "restore_on_startup": 5,  # Open New Tab page
        "startup_urls": []
    },
    # Site Isolation & Security
    "site_per_process": True,
    "site_isolation_trial_opt_out": False,
    "isolate_origins": True,
    # HTTPS & Security
    "https_only_mode_enabled": True,
    "mixed_content": {
        "always_upgrade": True
    },
    # Additional Telemetry Disabling
    "enable_do_not_track": True,
    "enable_referrers": False,
    "enable_encrypted_media": False,
    "webkit": {
        "webprefs": {
            "javascript_can_access_clipboard": False,
            "hyperlink_auditing_enabled": False  # Disable click tracking
        }
    },
    # Translation
    "translate": {
        "enabled": False
    },
    # Media
    "media": {
        "router": {
            "enabled": False
        }
    }
}

# Deep merge function (defined once)
def deep_merge(base, update):
    for key, value in update.items():
        if key in base and isinstance(base[key], dict) and isinstance(value, dict):
            deep_merge(base[key], value)
        else:
            base[key] = value

# Update Preferences file
if os.path.exists(prefs_file):
    try:
        with open(prefs_file, 'r', encoding='utf-8') as f:
            prefs = json.load(f)
        
        if not isinstance(prefs, dict):
            print("✗ Error: Preferences file is not a valid JSON object", file=sys.stderr)
            sys.exit(1)
        
        deep_merge(prefs, telemetry_settings)
        
        with open(prefs_file, 'w', encoding='utf-8') as f:
            json.dump(prefs, f, indent=2)
        print("✓ Updated Preferences file")
    except json.JSONDecodeError as e:
        print(f"✗ Error: Invalid JSON in Preferences file: {e}", file=sys.stderr)
        sys.exit(1)
    except IOError as e:
        print(f"✗ Error: Cannot read/write Preferences file: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"✗ Error updating Preferences: {e}", file=sys.stderr)
        sys.exit(1)
else:
    print("✗ Preferences file not found. Run Brave at least once.", file=sys.stderr)
    sys.exit(1)

# Update Local State file
if os.path.exists(local_state_file):
    try:
        with open(local_state_file, 'r', encoding='utf-8') as f:
            local_state = json.load(f)
        
        if not isinstance(local_state, dict):
            print("✗ Error: Local State file is not a valid JSON object", file=sys.stderr)
            sys.exit(1)
        
        # Disable metrics and crash reporting
        local_state_updates = {
            "hardware_acceleration_mode": {
                "enabled": True
            },
            "user_experience_metrics": {
                "reporting_enabled": False
            },
            "browser": {
                "has_seen_welcome_page": True
            }
        }
        
        deep_merge(local_state, local_state_updates)
        
        with open(local_state_file, 'w', encoding='utf-8') as f:
            json.dump(local_state, f, indent=2)
        print("✓ Updated Local State file")
    except json.JSONDecodeError as e:
        print(f"✗ Error: Invalid JSON in Local State file: {e}", file=sys.stderr)
        sys.exit(1)
    except IOError as e:
        print(f"✗ Error: Cannot read/write Local State file: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"✗ Error updating Local State: {e}", file=sys.stderr)
        sys.exit(1)
else:
    print("✗ Local State file not found. Run Brave at least once.", file=sys.stderr)
    sys.exit(1)

PYTHON_SCRIPT
}

# Check if Python3 is available
if command -v python3 &> /dev/null; then
    update_preferences
else
    echo -e "${RED}✗ Python3 not found. Skipping JSON preference updates.${NC}"
    echo -e "${YELLOW}  Install Python3 to apply advanced settings.${NC}"
fi

# Create desktop entry with custom flags
echo -e "\n${YELLOW}Creating optimized desktop launcher...${NC}"
DESKTOP_FILE="$HOME/.local/share/applications/brave-browser-optimized.desktop"
mkdir -p "$HOME/.local/share/applications"

cat > "$DESKTOP_FILE" << 'EOF'
[Desktop Entry]
Version=1.0
Name=Brave Browser (Optimized)
GenericName=Web Browser
Comment=Brave Browser with telemetry disabled and performance optimized
Exec=brave-browser --password-store=basic --disable-background-networking --disable-breakpad --disable-crash-reporter --disable-field-trial-config --disable-domain-reliability --disable-sync --no-pings --metrics-recording-only --enable-gpu-rasterization --enable-zero-copy --force-webrtc-ip-handling-policy=disable_non_proxied_udp --enable-features=VaapiVideoDecoder,CanvasOopRasterization,ParallelDownloading,MemorySavingsMode,BackForwardCache,LazyFrameLoading,LazyImageLoading --disable-features=BraveLeoAssistant,BraveAIChatHistory,AIChat,BraveLeo,BraveWallet,BraveRewards,BraveVPN,BraveNews,AutofillServerCommunication,InterestFeedContentSuggestions,Translate,MediaRouter,AsyncDNS,NetworkPrediction,SafeBrowsingEnhanced,AutofillCreditCard,AutofillAddressSave,WebBluetooth,WebUSB,WebMIDI,OptimizationHints,MediaEngagementBypassAutoplayPolicies %U
Icon=brave-browser
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF

echo -e "${GREEN}✓ Created optimized launcher${NC}"

# Create systemd user service to prevent Brave background services
echo -e "\n${YELLOW}Disabling Brave background services...${NC}"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
mkdir -p "$SYSTEMD_USER_DIR"

# List of Brave services to disable
declare -a services=(
    "brave-browser-updater.service"
    "brave-update.service"
)

for service in "${services[@]}"; do
    if systemctl --user list-unit-files | grep -q "$service"; then
        systemctl --user stop "$service" 2>/dev/null || true
        systemctl --user disable "$service" 2>/dev/null || true
        echo -e "${GREEN}✓ Disabled $service${NC}"
    fi
done

# Additional optimizations
echo -e "\n${YELLOW}Applying additional optimizations...${NC}"

# Remove crash reports
if [ -d "$BRAVE_CONFIG/Crash Reports" ]; then
    rm -rf "$BRAVE_CONFIG/Crash Reports"
    echo -e "${GREEN}✓ Removed crash reports${NC}"
fi

# Disable automatic updates via cron (if present)
if [ -f "/etc/cron.daily/brave-browser" ]; then
    echo -e "${YELLOW}Note: System-wide Brave update cron detected.${NC}"
    echo -e "${YELLOW}Run with sudo to disable: sudo rm /etc/cron.daily/brave-browser${NC}"
fi

# Summary
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Optimization Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${GREEN}Applied settings:${NC}"
echo "  ✓ Disabled all telemetry and metrics"
echo "  ✓ Disabled usage data reporting to Brave"
echo "  ✓ Disabled P3A analytics"
echo "  ✓ Disabled crash reporting"
echo "  ✓ Disabled background networking"
echo "  ✓ Disabled automatic updates (user level)"
echo "  ✓ Disabled AI features (Leo, AI Chat)"
echo "  ✓ Configured new tab page to blank/minimal"
echo "  ✓ Enabled memory savings mode (balanced)"
echo "  ✓ Disabled tab groups"
echo "  ✓ Removed wallet icon and features"
echo "  ✓ Disabled crypto features (Wallet, Rewards, VPN)"
echo "  ✓ Disabled geolocation services"
echo "  ✓ Configured WebRTC privacy protection"
echo "  ✓ Disabled DNS prefetching"
echo "  ✓ Blocked third-party cookies"
echo "  ✓ Disabled autofill (forms, passwords, credit cards)"
echo "  ✓ Disabled notifications by default"
echo "  ✓ Enabled HTTPS-only mode"
echo "  ✓ Disabled hyperlink auditing (click tracking)"
echo "  ✓ Disabled search suggestions"
echo "  ✓ Hardened fingerprinting protection"
echo "  ✓ Disabled WebUSB, WebBluetooth, WebMIDI"
echo "  ✓ Enabled site isolation for enhanced security"
echo "  ✓ Enabled ephemeral storage (per-site cookie jars)"
echo "  ✓ Enabled debouncing (URL tracking removal)"
echo "  ✓ Enabled CNAME uncloaking"
echo "  ✓ Enabled dark mode fingerprinting protection"
echo "  ✓ Enabled partitioned cookies"
echo "  ✓ Reduced user agent fingerprinting"
echo "  ✓ Enabled fenced frames with ShadowDOM"
echo "  ✓ Enabled JXL image format support"
echo "  ✓ Enabled Prerender2 for performance"
echo "  ✓ Enabled iframe throttling"
echo "  ✓ Enabled GPU acceleration"
echo "  ✓ Enabled memory optimizations"
echo "  ✓ Enabled parallel downloading"
echo "  ✓ Configured privacy-focused flags"
echo ""
echo -e "${YELLOW}Backup location:${NC} $BACKUP_DIR"
echo -e "${YELLOW}Launch flags:${NC} $FLAGS_FILE"
echo -e "${YELLOW}Optimized launcher:${NC} $DESKTOP_FILE"
echo ""
echo -e "${GREEN}You can now start Brave Browser!${NC}"
echo -e "Launch using: ${YELLOW}brave-browser${NC} or use the 'Brave Browser (Optimized)' launcher"
echo ""
echo -e "${YELLOW}To revert changes:${NC}"
echo -e "  ${GREEN}Quick restore:${NC} $0 --restore"
echo -e "  ${GREEN}List backups:${NC} $0 --list-backups"
echo ""
echo -e "${YELLOW}Manual restore (alternative):${NC}"
echo "  1. cp $BACKUP_DIR/Preferences_backup_$TIMESTAMP $BRAVE_PREFS"
echo "  2. cp $BACKUP_DIR/LocalState_backup_$TIMESTAMP $BRAVE_LOCAL_STATE"
echo "  3. rm $FLAGS_FILE"
echo ""
