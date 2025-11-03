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
  - [Markdown processing](#markdown-processing)
  - [Difference with the GitHub Markdown engine](#difference-with-the-github-markdown-engine)
  - [Settings](#settings)
    - [Themes](#themes)
    - [Options](#options)
    - [Extensions](#extensions)
      - [Emoji](#emoji)
      - [Inline local images](#inline-local-images)
      - [Mathematical expressions](#mathematical-expressions)
      - [Syntax Highlighting](#syntax-highlighting)
      - [YAML header](#yaml-header)
  - [Build from source](#build-from-source)
    - [Dependency](#dependency)
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


### Extensions

|Extension|Description|
|:--|:--|
|Autolink|Automatically translate URL to link and parse email addresses.|
|Emoji|Enable the [Emoji extension](#emoji).|
|GitHub mentions|Translate mentions to link to the GitHub account.|
|<a name="heads-anchors"></a>Heads anchors|Create anchors for the heads to use as cross internal reference. Each anchor is named with the lowercased caption, stripped of any punctuation marks (except the dash) and spaces replaced with dash (`-`). UTF8 character encoding is supported.|
|Highlight|Highlight the text contained between the markers `==`.|
|Inline local images|Enable the [Inline local images extension](#inline-local-images).|
|Math|Enable the [formatting of math expressions](#mathematical-expressions).|
|Strikethrough|Strikethrough text inside tildes. You can choose to detect single or double tilde delimiters.|
|Sub/Superscript|Allow to subscript text inside `~` tag pairs, and superscript text inside `^` tag pairs. Please note that the Strikethrough extension must be disabled or set to recognize double `~`.|
|Syntax highlighting|Enable the [Syntax highlighting extension](#syntax-highlighting). |
|Table|Parse table as defined by the GitHub extension to the standard Markdown language.|
|Tag filter|Strip potentially dangerous HTML tags (`<title>`,   `<textarea>`, `<style>`,  `<xmp>`, `<iframe>`, `<noembed>`, `<noframes>`, `<script>`, `<plaintext>`). It only takes effect if the option to include HTML code is enabled.|
|Task list|Parse task list as defined by the GitHub extension to the standard Markdown language.|
|YAML header|Enable the [YAML header extension](#YAML-header).|

You can also choose whether to open external links in the preview pane or in the default browser.


#### Emoji

You can enable the Emoji extension to handle the shortcodes defined by [GitHub](https://api.github.com/emojis). You can render the emoji with an emoticon glyph or using the image provided by GitHub (internet connection required). 

Multibyte emoji are supported, so `:it:` equivalent to the code `\u1f1ee\u1f1f9` must be rendered as the Italian flag :it:. 

Some emoji do not have an equivalent glyph on the standard font and will be replaced always with the relative image.

A list of GitHub emoji shortcodes is available [here](https://github.com/ikatyang/emoji-cheat-sheet/blob/master/README.md#people--body).

 
#### Inline local images

You can enable the Inline image extension to embed local images directly into the rendered HTML by converting them to Base64 data URLs.

Supported image references:
- Relative paths: `./image.jpg`, `image.jpg`, `assets/image.jpg`
- Absolute paths with `file://` schema: `file:///Users/username/Documents/image.jpg`

For `file://` URLs, you must provide the full absolute path. For images in the same folder as the Markdown file, use relative paths (the `./` prefix is optional).

The extension processes both Markdown image syntax (`![alt](path)`) and HTML `<img>` tags (when raw HTML is enabled).


#### Mathematical expressions

This extension allow to format the mathematical expressions using the LaTeX syntax like [GitHub](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/writing-mathematical-expressions).
Math rendering capability uses [MathJax](https://www.mathjax.org/) display engine.

Inline math expressions are delimited with a dollar symbol `$`. Block expressions are delimited with a double dollar symbols `$$`.

Alternatively, you can use the ` ```math ` code block syntax to display a math expression as a block.

The [MathJax](https://www.mathjax.org/) library is loaded from cdn.jsdelivr.net. The library is loaded if the markdown code contains ` ```math ` code blocks or one or more dollar sign.



### YAML header

You can enable the extension to handle a `yaml` header at the beginning of a file. You can choose to enable the extensions to all `.md` files or only for `.rmd` and `.qmd` files.

The header is recognized only if the file start with `---`. The yaml block must be closed with `---` or with `...`.

When the `table` extension is enabled, the header is rendered as a table, otherwise as a block of code. Nested tables are supported. 


## Build from source

When you clone this repository, remember to fetch also the submodule with `git submodule update --init`.


## Note about the developer

I am not primarily an application developer. There may be possible bugs in the code, be patient.
Also, I am not a native English speaker :sweat_smile:. 

**This application was developed for pleasure :heart:.**
