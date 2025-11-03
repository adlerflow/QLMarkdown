# highlight.js Themes

## Available Themes (12 total)

### Dark Themes (6)

| Theme | File | Size | Description |
|-------|------|------|-------------|
| **Monokai** | monokai.min.css | 814B | Classic Monokai color scheme |
| **Monokai Sublime** | monokai-sublime.min.css | 826B | Sublime Text variant of Monokai |
| **Atom One Dark** | atom-one-dark.min.css | 856B | GitHub Atom's One Dark theme |
| **GitHub Dark** | github-dark.min.css | 1.3K | GitHub's dark mode theme (default dark) |
| **Nord** | nord.min.css | 2.6K | Arctic, north-bluish color palette |
| **VS2015** | vs2015.min.css | 1.1K | Visual Studio 2015 dark theme |

### Light Themes (6)

| Theme | File | Size | Description |
|-------|------|------|-------------|
| **GitHub** | github.min.css | 1.3K | GitHub's light mode theme (default light) |
| **Base16 GitHub** | base16-github.min.css | 1.3K | Base16-styled GitHub theme |
| **Atom One Light** | atom-one-light.min.css | 856B | GitHub Atom's One Light theme |
| **Stack Overflow Light** | stackoverflow-light.min.css | 1.3K | Stack Overflow's light theme |
| **Xcode** | xcode.min.css | 945B | Apple Xcode's default light theme |
| **VS** | vs.min.css | 640B | Visual Studio light theme |

## Usage

Themes are selected via Settings:
- **Light Theme**: Used when macOS is in Light Mode
- **Dark Theme**: Used when macOS is in Dark Mode

Default selections:
- Light: `github`
- Dark: `github-dark`

## File Naming Convention

All theme files follow the pattern: `{theme-name}.min.css`

When setting theme in Settings, use the theme name **without** the `.min.css` extension:
- ✅ Correct: `syntaxThemeLightOption = "atom-one-light"`
- ❌ Wrong: `syntaxThemeLightOption = "atom-one-light.min.css"`

## Integration

Themes are loaded dynamically in `Settings+render.swift` based on current appearance:

```swift
let hlTheme = Self.isLightAppearance ? self.syntaxThemeLightOption : self.syntaxThemeDarkOption
let cssPath = self.resourceBundle.path(forResource: hlTheme + ".min", ofType: "css", inDirectory: "highlight.js/styles")
```

## Source

All themes from: https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/styles/

Version: **11.11.1**

## Theme Comparison

### Best for Readability
- **Light**: github, xcode
- **Dark**: github-dark, atom-one-dark

### Best for Low Contrast
- **Light**: stackoverflow-light, base16-github
- **Dark**: vs2015

### Best for High Contrast
- **Light**: vs
- **Dark**: monokai, monokai-sublime

### Best for Colorful Highlighting
- **Light**: atom-one-light
- **Dark**: nord
