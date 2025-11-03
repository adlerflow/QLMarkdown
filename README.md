<p align="center">
  <img src="assets/img/icon.png" width="150" alt="logo" />
</p>

# TextDown

TextDown is a standalone Markdown editor and viewer for macOS with live preview.

**Features**:
- **Pure SwiftUI**: 100% native SwiftUI architecture (DocumentGroup, FileDocument)
- **Multi-window support**: Open multiple documents simultaneously
- **Auto-save**: Documents save automatically after changes
- **Native rendering**: Direct AST → SwiftUI views (no HTML, no JavaScript)
- **Rich Markdown support**: GitHub Flavored Markdown (tables, task lists, strikethrough)
- **Syntax highlighting**: 5 languages (Swift, Python, JavaScript, HTML, CSS)
- **Lightweight**: 10 MB bundle, 30-45 second build time

> **Please note that this software is provided "as is", without any warranty of any kind.**

Supported file types: Markdown (`.md`), R Markdown (`.rmd`), Quarto (`.qmd`), MDX (`.mdx`), Cursor Rulers (`.mdc`), Api Blueprint (`.apib`).


  - [Screenshots](#screenshots)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Settings](#settings)
    - [Appearance](#appearance)
    - [Parser Options](#parser-options)
    - [Markdown Extensions](#markdown-extensions)
  - [Build from source](#build-from-source)
  - [Note about the developer](#note-about-the-developer)


## Screenshots

![main interface](./assets/img/preview-screenshot.png)


## Installation

```shell
brew install --cask textdown
```

The precompiled app is not notarized or signed, so the first time you run the app the system may show a warning about the impossibility to check for malicious software.

To fix, you can launch the app with right click (or ctrl click) on the app icon and choose the open action.

You can also execute this command from the terminal:

```sh
$ xattr -r -d com.apple.quarantine /Applications/TextDown.app # Default path; change if necessary
```

Alternatively, after trying to launch the app for the first time, you can open the System Preferences > Security & Privacy > General (tab) and click the Open Anyway button.

This will resolve the error of an unsigned application when launching the app.


## Usage

**Opening Files**:
- File → Open (⌘O) to open existing Markdown files
- File → New (⌘N) to create a new document in a new window
- Drag & drop `.md` files onto the app icon

**Editing**:
- Left pane: SwiftUI TextEditor for raw Markdown
- Right pane: Native SwiftUI rendering (MarkdownASTView)
- Changes are saved automatically after 5 seconds of inactivity

**Multi-Window**:
- Each document opens in its own window
- Window → Merge All Windows to use native tabs

**Settings**:
- TextDown → Settings (⌘,) to configure rendering options
- Enable/disable Markdown extensions
- Settings persist automatically



## Settings

Open Settings (⌘,) to configure rendering options, enable extensions, and customize the appearance of your Markdown documents.

Settings are organized into sections:
- **Extensions**: Enable/disable Markdown extensions (tables, task lists, strikethrough, etc.)
- **Syntax**: Syntax highlighting for code blocks (5 languages supported)
- **Parser**: swift-markdown options and rendering behavior

Changes take effect immediately and persist automatically. 


### Appearance

TextDown uses native SwiftUI styling that automatically adapts to your system appearance (Light/Dark mode). The rendering uses SwiftUI's built-in text styles and colors, ensuring consistent appearance with macOS system preferences.

**Syntax Highlighting**: Code blocks use SwiftHighlighter (Pure Swift tokenizer) with color-coded syntax for 5 languages:
- Swift
- Python
- JavaScript
- HTML
- CSS

Unsupported languages display as plain text without syntax coloring.


### Parser Options

|Option|Description|
|:--|:--|
|Smart quotes|Convert straight quotes to curly, ```---``` to _em dashes_ and ```--``` to _en dashes_.|
|Footnotes|Parse footnotes in markdown.|
|Validate UTF-8|Validate UTF-8 in the input before parsing, replacing illegal sequences with the standard replacement character (U+FFFD &#xFFFD;).|

**Note**: TextDown uses swift-markdown parser with Pure SwiftUI rendering. Raw HTML tags in markdown source are ignored (not rendered).


### Markdown Extensions

**GitHub Flavored Markdown (Built-in)**:
- **Tables**: Basic table rendering (placeholder view for complex layouts)
- **Strikethrough**: `~~strikethrough~~` text
- **Task Lists**: `- [ ]` and `- [x]` checkboxes (placeholder view, not interactive)
- **Autolinks**: Automatic URL and email linking

**Syntax Highlighting**:
- Enable/disable syntax highlighting for code blocks
- Supported languages: Swift, Python, JavaScript, HTML, CSS
- Uses SwiftHighlighter (Pure Swift tokenizer)

**Known Limitations**:
- **Math expressions**: Not currently supported (no MathJax in Pure SwiftUI)
- **Emoji shortcodes**: Not currently supported
- **Complex tables**: Rendered as placeholder view
- **Interactive task lists**: Not currently supported (checkboxes are read-only)


 


## Build from source

**Requirements**:
- Xcode 16.0+ (for SwiftUI features)
- macOS 26.0+ deployment target

**Steps**:
```bash
git clone https://github.com/adlerflow/TextDown.git
cd TextDown
open TextDown.xcodeproj
```

Build with ⌘B. The project uses Swift Package Manager for dependencies (swift-markdown 0.7.3) which will be automatically fetched by Xcode.


## Note about the developer

I am not primarily an application developer. There may be possible bugs in the code, be patient.
Also, I am not a native English speaker :sweat_smile:. 

**This application was developed for pleasure :heart:.**
