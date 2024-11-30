#!/bin/bash

# Script version
VERSION="1.0.0"

# Color definitions for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display help
show_help() {
    cat << EOF
AppImage Desktop Entry Creator v${VERSION}
Usage: $(basename "$0") [OPTIONS] [DIRECTORY]

Creates desktop entries for AppImage files, automatically extracting icons
and setting up system integration.

Options:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output
    -f, --force            Force overwrite existing entries
    -c, --cleanup          Remove old/broken desktop entries
    -n, --name-only        Use simple names (remove version numbers)
    --verify               Test desktop entries after creation
    --no-desktop           Don't create desktop shortcuts
    --no-menu              Don't create AppImages menu category

Arguments:
    DIRECTORY              Path to directory containing AppImages
                          (defaults to current directory)

Example:
    $(basename "$0") --verbose ~/Applications
EOF
}

# Function to log messages
log() {
    local level=$1
    shift
    case "$level" in
        "ERROR") echo -e "${RED}[ERROR]${NC} $*" >&2 ;;
        "INFO") echo -e "${GREEN}[INFO]${NC} $*" ;;
        "WARN") echo -e "${YELLOW}[WARN]${NC} $*" ;;
    esac
}

# Function to clean up application name
clean_app_name() {
    local name=$1
    # Remove version numbers and extra info
    name=$(echo "$name" | sed -E 's/-[0-9]+\.[0-9]+\.[0-9]+.*//g')
    # Convert remaining dashes to spaces and capitalize
    name=$(echo "$name" | sed -E 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
    echo "$name"
}

# Function to get window class
get_window_class() {
    local appimage="$1"
    local basename=$(basename "$appimage")
    local name="${basename%.AppImage}"

    # Try to extract the window class by running the AppImage briefly
    # This is experimental and might need adjustment
    timeout 2s "$appimage" >/dev/null 2>&1 &
    sleep 1
    local wm_class=$(xprop -root | grep "^_NET_CLIENT_LIST_STACKING" | xargs -I{} xprop -id {} WM_CLASS 2>/dev/null | grep -m1 "\"$name\"" | cut -d'"' -f4)
    killall -q "${basename}"

    echo "$wm_class"
}

# Function to extract icon from AppImage
extract_icon() {
    local appimage="$1"
    local icon_name="$2"
    local temp_dir=$(mktemp -d)

    if [ "$VERBOSE" = true ]; then
        log "INFO" "Extracting icon from $appimage"
    fi

    # Mount AppImage and look for icon
    "$appimage" --appimage-extract >/dev/null 2>&1

    local icon_path=""
    local squashfs_root="squashfs-root"

    # Enhanced icon search with priority for higher resolution icons
    for ext in "png" "svg" "xpm"; do
        for size in "256x256" "128x128" "64x64" "48x48" "32x32"; do
            if [ -f "$squashfs_root/usr/share/icons/hicolor/$size/apps/"*".$ext" ]; then
                icon_path=$(find "$squashfs_root/usr/share/icons/hicolor/$size/apps/" -name "*.$ext" | head -n 1)
                break 2
            fi
        done
    done

    # Fallback icon locations
    if [ -z "$icon_path" ]; then
        for file in "$squashfs_root/.DirIcon" "$squashfs_root/icon.png" "$squashfs_root/icon.svg"; do
            if [ -f "$file" ]; then
                icon_path="$file"
                break
            fi
        done
    fi

    # Copy icon if found
    if [ -n "$icon_path" ]; then
        mkdir -p ~/.local/share/icons/appimages
        cp "$icon_path" ~/.local/share/icons/appimages/"$icon_name"
        if [ "$VERBOSE" = true ]; then
            log "INFO" "Icon extracted to ~/.local/share/icons/appimages/$icon_name"
        fi
    else
        log "WARN" "No icon found for $appimage"
    fi

    # Cleanup
    rm -rf "$squashfs_root"
    rm -rf "$temp_dir"
}

# Function to set up AppImages menu category
setup_appimages_menu() {
    if [ "$NO_MENU" = true ]; then
        return
    fi

    # Create directory for menu entry
    mkdir -p ~/.local/share/desktop-directories

    # Create the AppImages directory entry if it doesn't exist
    if [ ! -f ~/.local/share/desktop-directories/appimages.directory ]; then
        cat > ~/.local/share/desktop-directories/appimages.directory << EOF
[Desktop Entry]
Type=Directory
Name=AppImages
Icon=application-x-appimage
EOF
    fi

    # Create the menu structure
    mkdir -p ~/.config/menus/applications-merged
    cat > ~/.config/menus/applications-merged/appimages.menu << EOF
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
"http://www.freedesktop.org/standards/menu-spec/menu-1.0.dtd">
<Menu>
    <Name>Applications</Name>
    <Menu>
        <Name>AppImages</Name>
        <Directory>appimages.directory</Directory>
        <Include>
            <Category>AppImage</Category>
        </Include>
    </Menu>
</Menu>
EOF

    if [ "$VERBOSE" = true ]; then
        log "INFO" "Created AppImages menu category"
    fi
}

# Function to create desktop entry
create_desktop_entry() {
    local appimage="$1"
    local basename=$(basename "$appimage")
    local name="${basename%.AppImage}"
    local clean_name="$name"

    if [ "$NAME_ONLY" = true ]; then
        clean_name=$(clean_app_name "$name")
    fi

    local icon_name="${name}.png"
    local window_class=""

    if [ "$VERBOSE" = true ]; then
        window_class=$(get_window_class "$appimage")
    fi

    # Extract icon
    extract_icon "$appimage" "$icon_name"

    # Create desktop entry
    local desktop_file=~/.local/share/applications/"${name}.desktop"

    if [ -f "$desktop_file" ] && [ "$FORCE" != true ]; then
        log "WARN" "Desktop entry already exists for $clean_name. Use --force to overwrite."
        return
    fi

    cat > "$desktop_file" << EOF
[Desktop Entry]
Name=$clean_name
GenericName=$clean_name
Exec=$appimage
Icon=$HOME/.local/share/icons/appimages/$icon_name
Type=Application
Categories=AppImage;
Terminal=false
EOF

    if [ -n "$window_class" ]; then
        echo "StartupWMClass=$window_class" >> "$desktop_file"
    fi

    chmod +x "$desktop_file"

    # Create desktop shortcut if enabled
    if [ "$NO_DESKTOP" != true ]; then
        cp "$desktop_file" ~/Desktop/
        if [ "$VERBOSE" = true ]; then
            log "INFO" "Created desktop shortcut for $clean_name"
        fi
    fi

    if [ "$VERBOSE" = true ]; then
        log "INFO" "Created desktop entry for $clean_name"
    fi
}

# Parse command line arguments
VERBOSE=false
FORCE=false
CLEANUP=false
NAME_ONLY=false
NO_DESKTOP=false
NO_MENU=false
DIRECTORY="."

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -c|--cleanup)
            CLEANUP=true
            shift
            ;;
        -n|--name-only)
            NAME_ONLY=true
            shift
            ;;
        --no-desktop)
            NO_DESKTOP=true
            shift
            ;;
        --no-menu)
            NO_MENU=true
            shift
            ;;
        *)
            DIRECTORY="$1"
            shift
            ;;
    esac
done

# Main execution
if [ "$CLEANUP" = true ]; then
    log "INFO" "Cleaning up old desktop entries..."
    rm -f ~/.local/share/applications/appimagekit*
    rm -rf ~/.config/appimagekit
fi

# Setup AppImages menu category
setup_appimages_menu

if [ ! -d "$DIRECTORY" ]; then
    log "ERROR" "Directory $DIRECTORY does not exist"
    exit 1
fi

log "INFO" "Processing AppImages in $DIRECTORY..."

# Process all AppImages in the specified directory
for appimage in "$DIRECTORY"/*.AppImage; do
    if [ -f "$appimage" ]; then
        create_desktop_entry "$appimage"
    fi
done

# Update KDE's system configuration cache
log "INFO" "Updating system configuration cache..."
kbuildsycoca5 --noincremental

log "INFO" "Done! Desktop entries have been created in ~/.local/share/applications/"
