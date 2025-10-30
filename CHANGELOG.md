# Changelog


### 1.0.23 (49)
Bugfix:
- Unable to save the settings.


### 1.0.22 (47)
New Features:
- Support for MDX files (`.mdx`, _without_ JSX rendering).
- Support for Cursor Rulers files (`.mdc`).
- Highlight updated to 4.16.
- Lua updated to 5.4.7.
- File updated to 5.46.
- Enry updated to 2.9.2.
- Support for UTI `io.typora.markdown`.

Bugfix:
- Rewrite settings management to bypass warnings about accessing settings from other applications. **You will need to reset any preferences you have changed.**
- Unused code has been removed (including the ability to choose a theme for code formatting, now to change it you will need to edit the css file)


### 1.0.21 (46)
New Features:
- Warning about this is not a Markdown editor app.
- Alert when the app is closed and the current markdown file was changed.
- Experimental Shortcut Action (require macOS 15.2). 

Bugfix:
- Temporary fix for $ recognition without mathematical expression.


### 1.0.20 (45)
New Features:
- Support for some extended syntax:
  - highlight text with `==`
  - subscript (`~`) and superscript (`^`).


### 1.0.19 (44)
Bugfix:
- Fixed saving about flag settings.


### 1.0.18 (43)
New Features:
- Support for `com.nutstore.down` UTI.
- cmark-gfm updated to version 0.29.0.gfm.13.
- pcre2 updated to version 10.43.
- Enry updated to version 2.8.8.
- Settings to show about app info on the footer preview.
- Link to buy me a :coffee: (:heart:)

Bugfix:
- Exported html head title filled with the filename.


### 1.0.17 (42)
New Features:
- Improved Math (Latex) support (thanks to @mccann):
    - Prevent Markdown processing inside $'s
    - Allow multi-line Latex, like that supported by:
        - jupyter notebook
        - vscode
        - obsidian
        - probably many more - only tested the above.
    - Now prevents arbitrary html getting passed through.


### 1.0.16 (41)
New features:
- Support mathematical expressions with the MathJax engine.
- Update libraries:
    - cmark-gfm 0.29.0.gfm.11
    - highlight 4.5
    - lua 5.4.4
    - libmagic 5.44
    - go-enry v2.8.4
    - boost.
- Settings UI redesigned.
  
Bugfix:
- Alt attribute for emoji rendered as image.
 

### 1.0.15 (40)
New features:
- The markdown file is automatically reloaded when it is edited outside of the app.  
- Preliminary support for Quarto files (`.qmd`).


### 1.0.14 (39)
Bugfix:
- Allows you to use `...` to end the `yaml` header block. 


### 1.0.13 (38)
Bugfix:


### 1.0.12 (37)
Bugfix:
- Better procedure to install the command line tool.
- Fixed the bug that prevented the processing of html raw images when they are not inserted in a html block element. 


### 1.0.11 (36)
New features:
- Support for opening markdown files (by dragging the file onto the app icon)
- Support for exporting the markdown code.
- Sparkle updated to release 2.0.0. 

Bugfix:
- Fix for heads with dash.
- Implemented missing behavior for the color scheme editor.
- Fix for installation of the command line tool.


### 1.0.10 (35)
New features:
- Better performance for heads extension.
- Better performance for inline images on raw html fragments.
- Option for automatic saving of settings changes.
- GUI optimization.

Bugfix:
- Fixed settings save.


### 1.0.9 (34)
New features:
- Experimental support for defining the size of the Quick Look window.
- Magic `file` updated to release 5.41.

Bugfix:
- Fixed cross compile compilation of `file` library.


### 1.0.8 (33)
Bugfix:
- Fixed bug for undefined source code theme.
- Fixed bug on settings sync delay in the Quick Look preview on macOS Monterey.


### 1.0.7 (32)
New features:
- Support for render the markdown source code instead of the formatted output.


### 1.0.6 (31)
New features:
- Application menu item to install/reveal the CLI tool on `/usr/local/bin` folder.
- Support for UTI `public.markdown` defined by `Nova.app`.

Bugfix:
- Fixed possibile deallocation error with invalid highlight theme.


### 1.0.5 (30)
Bugfix:
- Tag Filter extension fixed.
- Improved performance for inline image handling in raw HTML fragment.
- Better recognition of javascript fenced block.
- Missing library credits on about dialog.


### 1.0.4 (29)
New features:
- On macOS 12 Monterey, the new lightweight data based preview will be used.
- Addeded more arguments to the CLI tool.
- CLI tool embed inline images handle also raw HTML fragments.

Bugfix:
- Handle markdown associated only to a dynamic UTI.
- Fixed issue with instantiated and never released `Markdown QL Extension Web Content` process for each file previewed.
- On macOS 12 Monterey now you can scroll the preview with the scrollbars.
- On macOS 12 Monterey the bug of trackpad scrolling in fullscreen preview has been fixed.


### 1.0.3 (28)
New features:
- Command line interface (CLI) tool.


### 1.0.2 (27)
Bugfix:
- Fenced code block highlighted even when rmd syntax is used (language name inside a curly brace).
  

### 1.0.1 (26)
New features:
- With `YAML` and `table` extensions enabled, the `yaml` file header is displayed as a table.  


### 1.0b25
New features:
- Extended the support for the `yaml` header of  `.rmd` to all `.md` files. The `rmd extension` was renamed to `YAML header`. 


### 1.0b24
New features:
- Support for `.rmd` file. The `.rmd` files are handled like normal `.md` files _without parsing the `r` code_. With the `rmd extension` enabled (default enabled, on advanced settings) the file header is rendered as a `yaml` block. 


### 1.0b23
New features:
- Support for UTI `com.unknown.md`.


### 1.0b22
Bugfix:
- Fixed a glitch when showing the preview (the webview is initially shown smaller than the QL window).


### 1.0b21
New features:
- Settings to handle autoupdate.


### 1.0b20
Bugfix:
- fix for anchors of head with emoji characters.


### 1.0b19
Bugfix:
- Responsive image height fix.
- Correct parsing of image filename with spaces inside a `<img>` tag. Please note that spaces are not supported within the filenames of images defined with markdown syntax. Spaces are unsafe to use inside an URL, must be replaced with `%20`.


### 1.0b18
Bugfix:
- Fixed base64 image encoding. 


### 1.0b17
Bugfix:
- Better mime recognition for inline images.


### 1.0b16
Bugfix:
- Fix on heads extension.
- Fix on emoji extension.
- Fix for exporting a source color scheme as a CSS style.


### 1.0b15
New features:
- Option to export the generated preview to an HTML file in the main application.

Bugfix:
- Fix emoji parser.


### 1.0b14
New features:
- Better emoji handler.
- UI improvement. Some less used commands on the theme dropdown popup are available pressing the alt key.


### 1.0b13
New features:
- QL preview handle TextBundle container.
- Inline image extension handle also image inserted with <image> tag on the markdown file.
- Better emoji handler.

Bugfix:
- Fix error on image mime detection.


### 1.0b12
1.0b12
New features:
- New icon (thanks to [setanarut](https://github.com/setanarut)). 
- Wrapper highlight library build inside the Xcode project.
- Wrapper highlight embed goutils with enry guess engine.
- Better about dialog.

Bugfix:
- Shared library and support files no more embedded twice reducing the total file size.
- Fix on exporting default style.
- Css theme fix.


### 1.0b11
Bugfix:
- Fixed open external link to the default browser on Big Sur (via an external XPC service).


### 1.0b10
New features:
- Implemented reset to factory settings.

Bugfix:
- Incomplete saving settings.
- UI fix.


### 1.0.b9
New features:
- Updated the default CSS style (thanks to [setanarut](https://github.com/setanarut)). 
- For Syntax highlighting, option to choose the document style or a specific language style.


### 1.0.b8
Bugfix:
- Fixed standard cmark tasklist extension not inserting class style in HTML output.


### 1.0.b7
New features:
- `Heads extension` to auto create anchor for the heads.
- Redesigned UI. 
- Auto refresh menu to automatically update the preview when an option is changed (the auto refresh do not apply when you change the example text). 
- The Quick Look extension detects the settings changed on the host application. Remember that macOS can store the Quick Look preview in a cache, so to see the new settings applied try to open the preview of a different file.
- On the host application you can open a .md file to view in the preview (you can also drag & drop the over the text editor).
- Import CSS inside the support folder.

Bugfix:
- Typo in application name.
- Null pointer bug on inlineimage extension.
- Fix on the image mime detection.


### 1.0.b6
New Features:
- better ui.
Bug fix:
- Fix for bug on colors scheme icon with underline style.
- Fix missing close menu item.
- Fix bug with "base16" syntax highlighting colors scheme.


### 1.0.b5
New features:
- Experimental option to choose to open links inside the Quick Look preview window or in the default browser (but on Big Sur do not works).

Bugfix:
- Fix missing sparkle framework.


### 1.0.b4
New features:
- Auto update with Sparkle framework. Auto updated works only when run the main application and not from the Quick Look extension. You must have launched the application at least twice for the update checks to begin, or you can use the appropriate item in the application menu.
- Save button enabled only when there are some changed settings. in case of error a warning panel will be shown.
- Debug options.

Bug fix:
- fix missing WKWebView class on Catalina


### 1.0.b3
Bugfix:
- Save menu item fixed.
- libmagic linked statically.


### 1.0.b2
New features:
- Reimplemented in C/C++ previous code developed on the external Go library (emoji, base64 encoding).
- Syntax Highlighting extension now use [Highlight](http://www.andre-simon.de/doku/highlight/en/highlight.php) linked as a library, and with more customizable options.
- GUI updated to use the changed extensions.
- Many others changes.


### 1.0.b1
First release.
