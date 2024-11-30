# KDE AppImage Helper

A tool to automatically create desktop entries for AppImage files in KDE Plasma, with proper icon extraction and menu integration. Solves common issues with AppImage integration in KDE Plasma desktop environments, particularly after the deprecation of AppImageLauncher.

## Features
- Automatic icon extraction from AppImages
- Dedicated AppImages menu category in KDE menu
- Optional desktop shortcuts creation
- Clean desktop entry creation with proper window class detection
- KDE Plasma menu and panel integration
- Batch processing of multiple AppImages
- Optional cleanup of legacy AppImageLauncher files
- Support for Icons-Only Task Manager integration

## Requirements
- KDE Plasma desktop environment
- bash shell
- xprop (usually installed by default)

## Installation
```
git clone https://github.com/glassontin/kde-appimage-helper.git
cd kde-appimage-helper
chmod +x scripts/appimage-desktop-creator.sh
```

## Usage
```
./scripts/appimage-desktop-creator.sh [OPTIONS] [DIRECTORY]

Options:
    -h, --help              Show help message
    -v, --verbose           Enable verbose output
    -f, --force            Force overwrite existing entries
    -c, --cleanup          Remove old/broken entries
    -n, --name-only        Use simple names (remove version numbers)
    --no-desktop           Don't create desktop shortcuts
    --no-menu              Don't create AppImages menu category
```

## Example
```
# Process all AppImages in your Applications directory with all features
./scripts/appimage-desktop-creator.sh --verbose --cleanup ~/Applications

# Process without creating desktop shortcuts
./scripts/appimage-desktop-creator.sh --verbose --no-desktop ~/Applications

# Process without creating dedicated menu category
./scripts/appimage-desktop-creator.sh --verbose --no-menu ~/Applications
```

## Common Issues
- If icons don't appear immediately in menus, run: `kbuildsycoca5 --noincremental`
- For panel integration issues, ensure the Icons-Only Task Manager widget is being used
- If the AppImages menu doesn't appear immediately, log out and back in to KDE Plasma

## Menu Integration
By default, the script creates a dedicated "AppImages" menu category in your KDE menu. All processed AppImages will appear in this menu for better organization. You can disable this feature using the --no-menu option.

## Desktop Integration
The script automatically creates desktop shortcuts for quick access to your AppImages. If you don't want desktop shortcuts, use the --no-desktop option.

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is licensed under the GPL-3.0 License - see the LICENSE file for details
