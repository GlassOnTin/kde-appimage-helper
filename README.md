# KDE AppImage Helper

A tool to automatically create desktop entries for AppImage files in KDE Plasma, with proper icon extraction and menu integration. Solves common issues with AppImage integration in KDE Plasma desktop environments, particularly after the deprecation of AppImageLauncher.

## Features
- Automatic icon extraction from AppImages
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
```bash
git clone https://github.com/glassontin/kde-appimage-helper.git
cd kde-appimage-helper
chmod +x scripts/appimage-desktop-creator.sh
```

## Usage
```bash
./scripts/appimage-desktop-creator.sh [OPTIONS] [DIRECTORY]

Options:
-h, --help              Show help message
-v, --verbose           Enable verbose output
-f, --force            Force overwrite existing entries
-c, --cleanup          Remove old/broken entries
-n, --name-only        Use simple names (remove version numbers)
--verify               Test entries after creation
```

## Example
Process all AppImages in your Applications directory:
```bash
./scripts/appimage-desktop-creator.sh --verbose --cleanup ~/Applications
```

## Common Issues
- If icons don't appear immediately in menus, run:
```bash
kbuildsycoca5 --noincremental
```
- For panel integration issues, ensure the Icons-Only Task Manager widget is being used

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is licensed under the GPL-3.0 License - see the LICENSE file for details
