# KDE AppImage Helper Assistant Guidelines

## Commands
- Execute script: `./scripts/appimage-desktop-creator.sh [OPTIONS] [DIRECTORY]`
- Make script executable: `chmod +x scripts/appimage-desktop-creator.sh`
- Update KDE system cache: `kbuildsycoca5 --noincremental`

## Code Style
- **Indentation**: 4 spaces
- **Naming**:
  - Variables: `lowercase_with_underscores`
  - Constants: `UPPERCASE`
  - Functions: `lowercase_with_underscores`
- **Comments**: Precede code sections with descriptive comments
- **Error handling**: Use the `log()` function with appropriate level (ERROR, INFO, WARN)
- **Script Structure**:
  1. Version/metadata
  2. Color definitions
  3. Help function
  4. Utility functions
  5. Command-line argument parsing
  6. Main execution
- **Directory Layout**: Keep scripts in the `scripts/` directory
- **Documentation**: Update README.md when adding new features

## Testing
- Manual verification of desktop entries
- Test with `--verbose` flag for detailed execution information