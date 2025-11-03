# TextDown – SwiftUI-Migrationsdokument

## 1. Metadaten

**Storyboard-Datei:** `Main.storyboard`

**Zielplattform:** macOS (AppKit)

**Storyboard-Version:**
- `toolsVersion="24412"`
- `targetRuntime="MacOSX.Cocoa"`
- Mindestkompatibilität: Xcode 8 (`minToolsVersion="8.0"`)
- Plugins: `CocoaPlugin`, `WebKit2IBPlugin` (beide Version 24412)

**App-Kontext:** TextDown – Markdown-Editor mit Live-Preview

---

## 2. View- und Fenster-Hierarchie

### Scene 1: Application (`sceneID="JPo-4y-FX3"`)
**Rolle:** App-Hauptmenü und Delegate-Setup

- **Application** `id="hnw-xV-0zn"`
  - **Main Menu** `id="AYu-sK-qS6"` (systemMenu="main")
    - **TextDown Menu** `id="1Xt-HY-uBw"`
      - About TextDown → Segue zu `VZF-nt-1dI`
      - Check for Updates (Submenu mit 4 Intervallen)
      - Preferences… (`⌘,`)
      - Services, Hide/Show, Quit
    - **File Menu** `id="dMs-cI-mzQ"`
      - New (`⌘N`), Open (`⌘O`), Open Recent
      - Close (`⌘W`), Save (`⌘S`), Save As… (`⇧⌘S`)
      - Rename, Move To
      - Export as HTML… (`⌘E`)
    - **Edit Menu** `id="5QF-Oa-p0T"`
      - Undo/Redo, Cut/Copy/Paste
      - Find (Submenu), Spelling and Grammar, Substitutions, Transformations, Speech
    - **Format Menu** `id="jxT-CU-nIS"`
      - Font (Submenu mit Bold/Italic/Underline, Bigger/Smaller, Kern, Ligatures, Baseline, Colors, Copy/Paste Style)
      - Text (Align Left/Center/Right/Justify, Writing Direction, Ruler)
    - **View Menu** `id="H8h-7b-M4v"`
      - Preview auto refresh (toggleable, `state="on"`)
      - Refresh the preview (`⌘R`)
      - Show Toolbar, Customize Toolbar
      - Show Sidebar (`⌃⌘S`)
      - Enter Full Screen (`⌃⌘F`)
    - **Window Menu** `id="aUF-d1-5bR"` (systemMenu="window")
      - Minimize, Zoom, Bring All to Front
    - **Help Menu** `id="wpr-3q-Mcd"` (systemMenu="help")
      - TextDown Help (`⌘?`)

- **Custom Objects:**
  - `AppDelegate` `id="Voe-Tx-rLC"` (customModule="TextDown")
  - `NSFontManager` `id="YLy-65-1bz"`
  - `NSResponder` (First Responder) `id="Ady-hI-5gd"`

---

### Scene 2: Document Window Controller (`sceneID="R2V-B0-nI4"`)
**Rolle:** Hauptfenster für Dokument-Bearbeitung

- **Window Controller** `id="B8D-0N-5wS"` (`customClass="MarkdownWindowController"`)
  - **Window** `id="IQv-IB-iLA"` – `title="TextDown"`
    - Eigenschaften: `titlebarAppearsTransparent="YES"`, `toolbarStyle="unified"`
    - Größe: 1065×650 Pixel (contentRect)
    - **Toolbar** `id="QHW-KZ-sTw"` (unified, nicht-customizable)
      - Allowed Items: Space, FlexibleSpace
      - Default: FlexibleSpace
  - **Segue** → `XfG-lQ-9wD` (Main View Controller) als `window.shadowedContentViewController`

---

### Scene 3: Main Document View Controller (`sceneID="hIz-AP-VOD"`)
**Rolle:** Haupt-UI mit Split-View (Editor links, Preview rechts)

- **View Controller** `id="XfG-lQ-9wD"` (`customClass="DocumentViewController"`, title="Main")
  - **Root View** `id="m2S-Jp-Qdl"` (1065×650)
    - **Split View** `id="RbX-Sy-Yvt"` (`dividerStyle="paneSplitter"`, vertical)
      - **Left Pane** `id="GDJ-WJ-HAB"` (532px breit)
        - **Scroll View** `id="n1h-Pp-I4v"` (borderType="none", findBar enabled)
          - **Clip View** `id="Lcj-LF-Mgf"` (drawsBackground="NO")
            - **Text View** `id="Q3Q-a2-tMH"` (`customClass="DropableTextView"`)
              - Properties: `richText="NO"`, `verticallyResizable="YES"`, `findStyle="bar"`, `incrementalSearchingEnabled="YES"`, `allowsUndo="YES"`, `textCompletion="NO"`
              - Min size: 532×650, Max size: 679×10M
          - **Vertical Scroller** `id="wmM-BG-laq"` (visible)
          - **Horizontal Scroller** `id="Ovz-nv-9w3"` (hidden)
      - **Right Pane** `id="sp3-sm-w1y"` (523px breit)
        - **WKWebView** `id="bs7-Op-UnU"` (523×650, fixedFrame)
          - Media: audiovisual ohne User-Action
        - **Progress Indicator** `id="uLU-em-oOP"` (spinning, small, centered)
          - Position: Zentriert im Right Pane

- **Custom Objects:**
  - `SPUStandardUpdaterController` `id="uEM-91-19k"` (Sparkle Update Framework)
  - `NSUserDefaultsController` `id="JgT-L6-uQU"` (representsSharedInstance)
  - `NSResponder` (First Responder) `id="rPt-NT-nkU"`

---

### Scene 4: About Window Controller (`sceneID="WNd-O7-Vdp"`)
**Rolle:** About-Dialog

- **Window Controller** `id="VZF-nt-1dI"` (`customClass="AboutWindowController"`)
  - **Window** `id="07D-zf-Sfn"` – `title="Window"`
    - Eigenschaften: `titlebarAppearsTransparent="YES"`, `titleVisibility="hidden"`, `hidesOnDeactivate="YES"`
    - Größe: 291×176 Pixel
    - Style Mask: titled, closable (kein Resize)
  - **Segue** → `Z8Y-nM-9Xv` (About View Controller)

---

### Scene 5: About View Controller (`sceneID="Hw7-eQ-9gP"`)
**Rolle:** About-Dialog Inhalt

- **View Controller** `id="Z8Y-nM-9Xv"` (`customClass="AboutViewController"`)
  - **Root View** `id="n2F-vL-8Km"` (291×176)
    - **Image View** `id="aYc-Lb-9Qm"` (50×50, zentriert oben)
    - **Text Field** `id="bNc-Kf-9Hd"` (title, bold, centered) – "TextDown"
    - **Text Field** `id="cPd-Lf-9Ke"` (version, small, secondary color) – "Version 1.0 (1)"
    - **Text Field** `id="fQg-Nh-9Mg"` (copyright, small, secondary color) – "Copyright © 2025"
    - **Scroll View** `id="hSj-Ok-9Pj"` (borderless, 251×40)
      - **Clip View** `id="iRk-Pl-9Qk"`
        - **Text View** `id="jTl-Qm-9Rl"` (editable="NO", richText="NO")

---

## 3. Outlets & Actions (Verknüpfungen zu Code)

### Outlets

#### Application Scene
| Source | Outlet Name | Target | Target Class |
|--------|-------------|--------|--------------|
| `hnw-xV-0zn` (Application) | `delegate` | `Voe-Tx-rLC` | `AppDelegate` |
| `AYu-sK-qS6` (Main Menu) | `delegate` | `Voe-Tx-rLC` | `AppDelegate` |

#### Document Window Controller
| Source | Outlet Name | Target | Target Class |
|--------|-------------|--------|--------------|
| `IQv-IB-iLA` (Window) | `delegate` | `B8D-0N-5wS` | `MarkdownWindowController` |

#### Main View Controller
| Source | Outlet Name | Target | Target Class |
|--------|-------------|--------|--------------|
| `XfG-lQ-9wD` (DocumentViewController) | `textView` | `Q3Q-a2-tMH` | `DropableTextView` |
| `XfG-lQ-9wD` (DocumentViewController) | `webView` | `bs7-Op-UnU` | `WKWebView` |
| `Q3Q-a2-tMH` (DropableTextView) | `delegate` | `XfG-lQ-9wD` | `DocumentViewController` |
| `Q3Q-a2-tMH` (DropableTextView) | `container` | `XfG-lQ-9wD` | `DocumentViewController` |
| `bs7-Op-UnU` (WKWebView) | `navigationDelegate` | `XfG-lQ-9wD` | `DocumentViewController` |

#### About Window Controller
| Source | Outlet Name | Target | Target Class |
|--------|-------------|--------|--------------|
| `07D-zf-Sfn` (Window) | `delegate` | `VZF-nt-1dI` | `AboutWindowController` |

#### About View Controller
| Source | Outlet Name | Target | Target Class |
|--------|-------------|--------|--------------|
| `Z8Y-nM-9Xv` (AboutViewController) | `imageView` | `aYc-Lb-9Qm` | `NSImageView` |
| `Z8Y-nM-9Xv` (AboutViewController) | `titleField` | `bNc-Kf-9Hd` | `NSTextField` |
| `Z8Y-nM-9Xv` (AboutViewController) | `versionField` | `cPd-Lf-9Ke` | `NSTextField` |
| `Z8Y-nM-9Xv` (AboutViewController) | `copyrightField` | `fQg-Nh-9Mg` | `NSTextField` |
| `Z8Y-nM-9Xv` (AboutViewController) | `infoTextView` | `jTl-Qm-9Rl` | `NSTextView` |

---

### Actions

#### Update Menu Actions (Target: AppDelegate)
| Action Selector | Source | Control Type |
|-----------------|--------|--------------|
| `onUpdateRate:` | `Ugh-Dg-7oF`, `9hf-5c-VsA`, `PKe-RM-oGA`, `is3-eT-F7U` | Menu Items (Never/Hourly/Daily/Weekly) |
| `checkForUpdates:` | `YYv-je-P9H` | Menu Item (Check now…) |

#### Preferences & App Control (Target: AppDelegate)
| Action Selector | Source | Control Type |
|-----------------|--------|--------------|
| `showPreferences:` | `BOz-M7-B4X` | Menu Item (⌘,) |
| `hide:` | `Olw-nP-bQN` | Menu Item (Hide TextDown) |
| `hideOtherApplications:` | `Vdr-fp-XzO` | Menu Item |
| `unhideAllApplications:` | `Kd2-mp-pUS` | Menu Item |
| `terminate:` | `4sb-4s-VLi` | Menu Item (Quit) |

#### Document Actions (Target: First Responder `Ady-hI-5gd`)
| Action Selector | Source | Control Type |
|-----------------|--------|--------------|
| `newDocument:` | `Was-JA-tGl` | Menu Item (⌘N) |
| `openDocument:` | `V5k-Dq-0be` | Menu Item (⌘O) |
| `clearRecentDocuments:` | `vNY-rz-j42` | Menu Item |
| `performClose:` | `2wd-Ew-wQh` | Menu Item (⌘W) |
| `saveDocument:` | `pxx-59-PXV` | Menu Item (⌘S) |
| `saveDocumentAs:` | `Bw7-FT-i3A` | Menu Item (⇧⌘S) |
| `renameDocument:` | `uuM-SM-h1D` | Menu Item |
| `moveDocument:` | `1lO-Jt-CqP` | Menu Item |
| `exportPreview:` | `ZqH-Pa-y1s` | Menu Item (⌘E – Export as HTML) |

#### Edit Actions (Target: First Responder)
| Action Selector | Source | Control Type |
|-----------------|--------|--------------|
| `undo:` | `dRJ-4n-Yzg` | Menu Item (⌘Z) |
| `redo:` | `6dh-zS-Vam` | Menu Item (⇧⌘Z) |
| `cut:` | `uRl-iY-unG` | Menu Item (⌘X) |
| `copy:` | `x3v-GG-iWU` | Menu Item (⌘C) |
| `paste:` | `gVA-U4-sdL` | Menu Item (⌘V) |
| `pasteAsPlainText:` | `WeT-3V-zwk` | Menu Item (⌥⌘V) |
| `delete:` | `pa3-QI-u2k` | Menu Item |
| `selectAll:` | `Ruw-6m-B2m` | Menu Item (⌘A) |

#### Find Actions (Target: First Responder)
| Action Selector | Source | Control Type |
|-----------------|--------|--------------|
| `performFindPanelAction:` | `Xz5-n4-O0W` (tag=1) | Menu Item (Find… ⌘F) |
| `performFindPanelAction:` | `YEy-JH-Tfz` (tag=12) | Menu Item (Find and Replace… ⌥⌘F) |
| `performFindPanelAction:` | `q09-fT-Sye` (tag=2) | Menu Item (Find Next ⌘G) |
| `performFindPanelAction:` | `OwM-mh-QMV` (tag=3) | Menu Item (Find Previous ⇧⌘G) |
| `performFindPanelAction:` | `buJ-ug-pKt` (tag=7) | Menu Item (Use Selection for Find ⌘E) |
| `centerSelectionInVisibleArea:` | `S0p-oC-mLd` | Menu Item (Jump to Selection ⌘J) |

#### Spelling & Grammar Actions (Target: First Responder)
| Action Selector | Source | Control Type |
|-----------------|--------|--------------|
| `showGuessPanel:` | `HFo-cy-zxI` | Menu Item (⌘:) |
| `checkSpelling:` | `hz2-CU-CR7` | Menu Item (⌘;) |
| `toggleContinuousSpellChecking:` | `rbD-Rh-wIN` | Menu Item |
| `toggleGrammarChecking:` | `mK6-2p-4JG` | Menu Item |
| `toggleAutomaticSpellingCorrection:` | `78Y-hA-62v` | Menu Item |

#### Substitutions Actions (Target: First Responder)
| Action Selector | Source | Control Type |
|-----------------|--------|--------------|
| `orderFrontSubstitutionsPanel:` | `z6F-FW-3nz` | Menu Item |
| `toggleSmartInsertDelete:` | `9yt-4B-nSM` | Menu Item |
| `toggleAutomaticQuoteSubstitution:` | `hQb-2v-fYv` | Menu Item |
| `toggleAutomaticDashSubstitution:` | `rgM-f4-ycn` | Menu Item |
| `toggleAutomaticLinkDetection:` | `cwL-P1-jid` | Menu Item |
| `toggleAutomaticDataDetection:` | `tRr-pd-1PS` | Menu Item |
| `toggleAutomaticTextReplacement:` | `HFQ-gK-NFA` | Menu Item |

#### Transformations Actions (Target: First Responder)
| Action Selector | Source | Control Type |
|-----------------|--------|--------------|
| `uppercaseWord:` | `vmV-6d-7jI` | Menu Item |
| `lowercaseWord:` | `d9M-CD-aMd` | Menu Item |
| `capitalizeWord:` | `UEZ-Bs-lqG` | Menu Item |

#### Speech Actions (Target: First Responder)
| Action Selector | Source | Control Type |
|-----------------|--------|--------------|
| `startSpeaking:` | `Ynk-f8-cLZ` | Menu Item |
| `stopSpeaking:` | `Oyz-dy-DGm` | Menu Item |

#### Format Actions (Target: NSFontManager `YLy-65-1bz`)
| Action Selector | Source | Control Type |
|-----------------|--------|--------------|
| `orderFrontFontPanel:` | `Q5e-8K-NDq` | Menu Item (Show Fonts ⌘T) |
| `addFontTrait:` | `GB9-OM-e27` (tag=2) | Menu Item (Bold ⌘B) |
| `addFontTrait:` | `Vjx-xi-njq` (tag=1) | Menu Item (Italic ⌘I) |
| `modifyFont:` | `Ptp-SP-VEL` (tag=3) | Menu Item (Bigger ⌘+) |
| `modifyFont:` | `i1d-Er-qST` (tag=4) | Menu Item (Smaller ⌘-) |

#### Format Actions (Target: First Responder)
| Action Selector | Source | Control Type |
|-----------------|--------|--------------|
| `underline:` | `WRG-CD-K1S` | Menu Item (⌘U) |
| `useStandardKerning:` | `GUa-eO-cwY` | Menu Item |
| `turnOffKerning:` | `cDB-IK-hbR` | Menu Item |
| `tightenKerning:` | `46P-cB-AYj` | Menu Item |
| `loosenKerning:` | `ogc-rX-tC1` | Menu Item |
| `useStandardLigatures:` | `agt-UL-0e3` | Menu Item |
| `turnOffLigatures:` | `J7y-lM-qPV` | Menu Item |
| `useAllLigatures:` | `xQD-1f-W4t` | Menu Item |
| `unscript:` | `3Om-Ey-2VK` | Menu Item |
| `superscript:` | `Rqc-34-cIF` | Menu Item |
| `subscript:` | `I0S-gh-46l` | Menu Item |
| `raiseBaseline:` | `2h7-ER-AoG` | Menu Item |
| `lowerBaseline:` | `1tx-W0-xDw` | Menu Item |
| `orderFrontColorPanel:` | `bgn-CT-cEk` | Menu Item (Show Colors ⌘C) |
| `copyFont:` | `5Vv-lz-BsD` | Menu Item (Copy Style ⌥⌘C) |
| `pasteFont:` | `vKC-jM-MkH` | Menu Item (Paste Style ⌥⌘V) |

#### Text Alignment Actions (Target: First Responder)
| Action Selector | Source | Control Type |
|-----------------|--------|--------------|
| `alignLeft:` | `ZM1-6Q-yy1` | Menu Item (⌘{) |
| `alignCenter:` | `VIY-Ag-zcb` | Menu Item (⌘\|) |
| `alignJustified:` | `ljL-7U-jND` | Menu Item |
| `alignRight:` | `wb2-vD-lq4` | Menu Item (⌘}) |

#### Writing Direction Actions (Target: First Responder)
| Action Selector | Source | Control Type |
|-----------------|--------|--------------|
| `makeBaseWritingDirectionNatural:` | `YGs-j5-SAR` | Menu Item |
| `makeBaseWritingDirectionLeftToRight:` | `Lbh-J2-qVU` | Menu Item |
| `makeBaseWritingDirectionRightToLeft:` | `jFq-tB-4Kx` | Menu Item |
| `makeTextWritingDirectionNatural:` | `Nop-cj-93Q` | Menu Item |
| `makeTextWritingDirectionLeftToRight:` | `BgM-ve-c93` | Menu Item |
| `makeTextWritingDirectionRightToLeft:` | `RB4-Sm-HuC` | Menu Item |

#### Ruler Actions (Target: First Responder)
| Action Selector | Source | Control Type |
|-----------------|--------|--------------|
| `toggleRuler:` | `vLm-3I-IUL` | Menu Item |
| `copyRuler:` | `MkV-Pr-PK5` | Menu Item (⌃⌘C) |
| `pasteRuler:` | `LVM-kO-fVI` | Menu Item (⌃⌘V) |

#### View Actions (Target: First Responder)
| Action Selector | Source | Control Type |
|-----------------|--------|--------------|
| `doAutoRefresh:` | `7xD-aa-BRT` | Menu Item (Preview auto refresh, toggleable) |
| `doRefresh:` | `UQd-Ow-K5y` | Menu Item (Refresh preview ⌘R) |
| `toggleToolbarShown:` | `snW-S8-Cw5` | Menu Item (⌥⌘T) |
| `runToolbarCustomizationPalette:` | `1UK-8n-QPP` | Menu Item |
| `toggleSidebar:` | `kIP-vf-haE` | Menu Item (⌃⌘S) |
| `toggleFullScreen:` | `4J7-dP-txa` | Menu Item (⌃⌘F) |

#### Window Actions (Target: First Responder)
| Action Selector | Source | Control Type |
|-----------------|--------|--------------|
| `performMiniaturize:` | `OY7-WF-poV` | Menu Item (⌘M) |
| `performZoom:` | `R4o-n2-Eq4` | Menu Item |
| `arrangeInFront:` | `LE2-aR-0XJ` | Menu Item |

#### Help Action (Target: First Responder)
| Action Selector | Source | Control Type |
|-----------------|--------|--------------|
| `showHelp:` | `FKE-Sm-Kum` | Menu Item (⌘?) |

---

### ⚠️ Migrations-Hinweis: Actions
**Diese Methoden müssen in SwiftUI neu gedacht/abgebildet werden:**

1. **Menu-Actions** werden in SwiftUI durch `CommandGroup`, `CommandMenu`, und Button-Actions innerhalb von `.commands()`-Modifiern ersetzt.
2. **Responder Chain** (`First Responder`) gibt es in SwiftUI nicht – Logik muss direkt in ViewModels/Views implementiert werden.
3. **NSFontManager**-Aktionen müssen durch SwiftUI-Font-Picker oder eigene UI ersetzt werden.
4. **Update-Checker** (Sparkle) benötigt weiterhin AppKit-Integration oder SwiftUI-Wrapper.
5. **Document-basierte Actions** (`newDocument:`, `saveDocument:`) können durch `DocumentGroup` und `FileDocument`-Protokoll ersetzt werden.

---

## 4. Storyboard-spezifisches Verhalten

### Segues/Transitions

| Source | Destination | Kind | Identifier | Trigger |
|--------|-------------|------|------------|---------|
| `5kV-Vb-QxS` (Menu Item "About TextDown") | `VZF-nt-1dI` (About Window Controller) | `show` | `YtI-lA-Vf2` | Menu-Klick |
| `B8D-0N-5wS` (Document Window Controller) | `XfG-lQ-9wD` (Document View Controller) | `relationship` | `cq2-FE-JQM` | `window.shadowedContentViewController` |
| `VZF-nt-1dI` (About Window Controller) | `Z8Y-nM-9Xv` (About View Controller) | `relationship` | `kWz-Ab-Cd3` | `window.shadowedContentViewController` |

**Migrations-Hinweis:**
- `window.shadowedContentViewController`-Relationships sind AppKit-spezifisch und werden in SwiftUI durch direkte View-Hierarchie ersetzt.
- `show`-Segues für About-Dialog sollten in SwiftUI durch `.sheet()` oder `.popover()` ersetzt werden.

---

### Menüs

**Hauptmenü** (`id="AYu-sK-qS6"`, systemMenu="main"):
- Vollständiges macOS-Menüsystem mit 8 Top-Level-Items
- System-Menüs: apple, recentDocuments, services, font, window, help
- Custom-Menüs: File, Edit, Format, View

**Update-Checker-Submenu** (`id="9t9-UX-FUG"`):
- 4 Intervall-Optionen (Never, Hourly, Daily, Weekly)
- State: "Daily" ist vorausgewählt (`state="on"`)
- Tags: 0 (Never), 3600 (Hourly), 86400 (Daily), 604800 (Weekly)

**Migrations-Hinweis:**
- SwiftUI: Menüs über `.commands { }` und `CommandGroup`/`CommandMenu`
- System-Menüs teilweise automatisch, teilweise manuell über `.commands(replacing:)` oder `.commands(adding:)`
- State-Management für toggleable Items über `@AppStorage` oder ViewModel

---

### Toolbars

**Document Window Toolbar** (`id="QHW-KZ-sTw"`):
- Style: `unified` (macOS Big Sur+)
- User-Customization: **disabled** (`allowsUserCustomization="NO"`)
- Shows Baseline Separator: **disabled**
- Display Mode: `iconAndLabel`
- Default Items: nur FlexibleSpace
- Allowed Items: Space, FlexibleSpace

**Migrations-Hinweis:**
- SwiftUI: `.toolbar { }` mit `ToolbarItem` und `ToolbarItemGroup`
- Unified-Style ist Standard in SwiftUI macOS 11+
- Custom Toolbar Items müssen manuell definiert werden (derzeit nur Spacer)

---

### Initial View Controller

**Nicht explizit gesetzt** im Storyboard. Das Document Window wird vermutlich programmatisch via `NSDocumentController` instanziiert (Standard für document-based Apps).

**Migrations-Hinweis:**
- SwiftUI document-based Apps nutzen `DocumentGroup` in der App-Struktur
- Keine explizite initialViewController-Definition nötig

---

## 5. AppKit-spezifische Elemente (Migrations-Hotspots)

### 🔴 Kritische AppKit-Views

#### 1. **NSSplitView** `id="RbX-Sy-Yvt"`
**Verwendung:** Vertikaler Split zwischen Editor (links) und Preview (rechts)

**Eigenschaften:**
- `dividerStyle="paneSplitter"` (dicker Divider mit Gripper)
- `vertical="YES"` (nebeneinander, nicht übereinander)
- `arrangesAllSubviews="NO"` (manuelle Subview-Verwaltung)
- Holding Priorities: beide 250 (gleichwertig)

**In SwiftUI ersetzen durch:**
```swift
HSplitView {
    EditorView()
    PreviewView()
}
```
oder (macOS 13+):
```swift
NavigationSplitView {
    EditorView()
} detail: {
    PreviewView()
}
```

**⚠️ Beachte:**
- Divider-Style ist in SwiftUI eingeschränkt anpassbar
- Holding Priorities müssen über `.layoutPriority()` oder fixe Widths simuliert werden
- `NavigationSplitView` bietet bessere Sidebar-Kollaps-Funktionalität

---

#### 2. **NSScrollView** `id="n1h-Pp-I4v"` (Editor)
**Verwendung:** Scrollbarer Container für TextView

**Eigenschaften:**
- `borderType="none"`
- `findBarPosition="belowContent"` (System-Find-Bar)
- Horizontal Scroller: hidden
- Vertical Scroller: visible
- Clip View mit `drawsBackground="NO"`

**In SwiftUI ersetzen durch:**
```swift
ScrollView(.vertical) {
    TextEditor(text: $markdownText)
}
```

**⚠️ Beachte:**
- System-Find-Bar (`findBarPosition`) ist in SwiftUI nicht direkt verfügbar – muss über `.searchable()` oder eigene Lösung nachgebaut werden
- `TextEditor` hat eigenes Scrolling – möglicherweise `ScrollView` nicht nötig

---

#### 3. **NSTextView** `id="Q3Q-a2-tMH"` (`DropableTextView`)
**Verwendung:** Markdown-Editor mit Drag & Drop

**Eigenschaften:**
- `richText="NO"` (Plain-Text-Modus)
- `verticallyResizable="YES"`
- `findStyle="bar"` (System-Find-Interface)
- `incrementalSearchingEnabled="YES"`
- `allowsUndo="YES"`
- `textCompletion="NO"`
- Custom Class: `DropableTextView` (erweitert NSTextView für Drag & Drop)

**In SwiftUI ersetzen durch:**
```swift
TextEditor(text: $markdownText)
    .font(.system(.body, design: .monospaced))
    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
        // Drag & Drop Handling
    }
```

**⚠️ Beachte:**
- `TextEditor` ist begrenzter als NSTextView (keine Line Numbers, weniger Customization)
- Für professionelle Code-Editoren eventuell `NSViewRepresentable` mit NSTextView-Wrapper nötig
- Find-Interface muss über `.searchable()` nachgebaut werden
- Undo/Redo ist in SwiftUI automatisch vorhanden (via `@Binding`)

---

#### 4. **WKWebView** `id="bs7-Op-UnU"` (Preview)
**Verwendung:** HTML-Preview des Markdown-Outputs

**Eigenschaften:**
- `fixedFrame="YES"` (keine Auto-Layout-Constraints)
- Autoplay für Audio/Video: enabled (`mediaTypesRequiringUserActionForPlayback="none"`)
- Navigation Delegate: `DocumentViewController`

**In SwiftUI ersetzen durch:**
```swift
// Option 1: NSViewRepresentable (AppKit-Wrapper)
WebView(html: renderedHTML)

// Option 2: macOS 14+ native (Beta)
#if os(macOS) && swift(>=5.9)
import WebKit
WebView(url: previewURL)
#endif
```

**⚠️ Beachte:**
- WKWebView hat **kein** natives SwiftUI-Equivalent
- Muss über `NSViewRepresentable` gewrappt werden
- Navigation Delegate muss in Wrapper-Implementierung übernommen werden
- Alternativ: Quick Look API für Markdown-Preview (weniger Flexibilität)

---

#### 5. **NSProgressIndicator** `id="uLU-em-oOP"`
**Verwendung:** Spinning Wheel während Preview-Generierung

**Eigenschaften:**
- `style="spinning"` (Kreisanimation)
- `controlSize="small"`
- `indeterminate="YES"` (keine Progress-Prozent)
- `displayedWhenStopped="NO"` (auto-hide)

**In SwiftUI ersetzen durch:**
```swift
ProgressView()
    .controlSize(.small)
    .opacity(isLoading ? 1 : 0) // Statt displayedWhenStopped
```

**✅ Direkte 1:1 Migration möglich**

---

#### 6. **NSImageView** `id="aYc-Lb-9Qm"` (About Dialog)
**Verwendung:** App-Icon

**In SwiftUI ersetzen durch:**
```swift
Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
    .resizable()
    .frame(width: 50, height: 50)
```

**✅ Direkte Migration möglich**

---

#### 7. **NSTextField** (verschiedene im About Dialog)
**Verwendung:** Title, Version, Copyright

**Eigenschaften:**
- `focusRingType="none"` (kein Fokus-Ring)
- Alignment: center
- Farben: `labelColor`, `secondaryLabelColor` (System-Colors)

**In SwiftUI ersetzen durch:**
```swift
Text("TextDown")
    .font(.headline)
    .foregroundStyle(.primary)

Text("Version 1.0 (1)")
    .font(.caption)
    .foregroundStyle(.secondary)
```

**✅ Direkte Migration möglich**

---

### 🟡 Mittlere Komplexität

#### 8. **NSWindow** (2x: Document + About)
**Verwendung:** Fenster-Container

**Document Window** (`id="IQv-IB-iLA"`):
- `titlebarAppearsTransparent="YES"`
- `toolbarStyle="unified"`
- Größe: 1065×650
- RestorationClass: nicht gesetzt

**About Window** (`id="07D-zf-Sfn"`):
- `titlebarAppearsTransparent="YES"`
- `titleVisibility="hidden"`
- `hidesOnDeactivate="YES"`
- Größe: 291×176 (nicht resizable)

**In SwiftUI ersetzen durch:**
```swift
// Document Window (automatisch via DocumentGroup)
DocumentGroup(newDocument: TextDownDocument()) { file in
    ContentView(document: file.$document)
}

// About Window (Sheet/Popover)
.sheet(isPresented: $showAbout) {
    AboutView()
        .frame(width: 291, height: 176)
}
```

**⚠️ Beachte:**
- Transparent titlebar ist SwiftUI-Standard in macOS 11+
- `hidesOnDeactivate` muss über `.interactiveDismissDisabled()` simuliert werden
- Window-Sizing über `.frame()` weniger flexibel als in AppKit

---

### 🟢 Einfache Migration

#### 9. **Auto-Layout Constraints**
**Vorkommen:** Fast alle Views haben Constraints

**Beispiel:** Split View
```xml
<constraint firstAttribute="height" relation="greaterThanOrEqual" constant="300" id="kd0-WF-RAN"/>
```

**In SwiftUI ersetzen durch:**
```swift
.frame(minHeight: 300)
```

**✅ SwiftUI Layout-System ist deklarativ – viele Constraints werden implizit**

---

## 6. Datenfluss-Anmutung

### Identifizierte View-Intents

#### Intent 1: **Dokument laden/öffnen**
- **Trigger:** Menu Item "Open" (`⌘O`) → `openDocument:`
- **Ziel:** `DocumentViewController` lädt Markdown-Datei
- **Datenfluss:** File System → NSTextView (`textView` outlet)
- **SwiftUI-Äquivalent:** `DocumentGroup` mit `FileDocument` → automatisches File Handling

---

#### Intent 2: **Markdown eingeben & live rendern**
- **Trigger:** User tippt in `DropableTextView`
- **Datenfluss:** 
  1. NSTextView → `DocumentViewController` (via delegate)
  2. Controller rendert Markdown → HTML
  3. HTML → WKWebView (`webView` outlet)
- **SwiftUI-Äquivalent:** 
  ```swift
  @State var markdownText: String
  var renderedHTML: String { /* Markdown → HTML */ }
  
  TextEditor(text: $markdownText)
  WebView(html: renderedHTML) // via NSViewRepresentable
  ```

---

#### Intent 3: **Auto-Refresh Toggle**
- **Trigger:** Menu Item "Preview auto refresh" → `doAutoRefresh:`
- **Zustand:** Menu Item hat `state="on"` (checkmark)
- **Datenfluss:** 
  1. User klickt Menu Item
  2. `doAutoRefresh:` toggelt Bool-Flag in Controller
  3. Bei true: automatisches Rerendern bei jedem Textchange
  4. Bei false: nur manuelles Refresh via `⌘R`
- **SwiftUI-Äquivalent:**
  ```swift
  @AppStorage("autoRefresh") var autoRefresh = true
  
  var body: some View {
      Menu("View") {
          Toggle("Preview auto refresh", isOn: $autoRefresh)
          Button("Refresh preview") { refreshPreview() }
              .keyboardShortcut("r")
      }
  }
  ```

---

#### Intent 4: **Manueller Refresh**
- **Trigger:** Menu Item "Refresh the preview" (`⌘R`) → `doRefresh:`
- **Datenfluss:** Erzwingt Neurendering, auch wenn Auto-Refresh aus ist
- **SwiftUI-Äquivalent:** Button Action triggert `@Published var refreshTrigger: Bool`

---

#### Intent 5: **Dokument speichern**
- **Trigger:** Menu Items "Save" (`⌘S`), "Save As" (`⇧⌘S`) → `saveDocument:`, `saveDocumentAs:`
- **Datenfluss:** NSTextView-Content → File System
- **SwiftUI-Äquivalent:** `FileDocument`-Protocol mit `write(to:)` Methode – automatisch

---

#### Intent 6: **HTML-Export**
- **Trigger:** Menu Item "Export as HTML" (`⌘E`) → `exportPreview:`
- **Datenfluss:** WKWebView-Content → HTML-File (Save Panel)
- **SwiftUI-Äquivalent:** 
  ```swift
  .fileExporter(isPresented: $showExport, document: htmlDocument) { }
  ```

---

#### Intent 7: **Update-Check**
- **Trigger:** Menu Item "Check now…" → `checkForUpdates:`
- **Datenfluss:** Sparkle Framework (`SPUStandardUpdaterController`) prüft Server
- **SwiftUI-Äquivalent:** 
  - Sparkle bleibt AppKit-basiert
  - Integration über `@NSApplicationDelegateAdaptor` oder eigenständiges Update-System

---

#### Intent 8: **Preferences-Dialog öffnen**
- **Trigger:** Menu Item "Preferences…" (`⌘,`) → `showPreferences:`
- **Datenfluss:** AppDelegate öffnet Preferences Window (nicht im Storyboard sichtbar)
- **SwiftUI-Äquivalent:** 
  ```swift
  Settings {
      PreferencesView()
  }
  ```

---

#### Intent 9: **About-Dialog öffnen**
- **Trigger:** Menu Item "About TextDown" → Segue zu `VZF-nt-1dI`
- **Datenfluss:** Segue öffnet modales Fenster mit About-Infos
- **SwiftUI-Äquivalent:**
  ```swift
  .sheet(isPresented: $showAbout) {
      AboutView()
  }
  ```

---

#### Intent 10: **Drag & Drop in Editor**
- **Trigger:** User zieht Datei auf `DropableTextView`
- **Datenfluss:** 
  1. `DropableTextView` empfängt Drop-Event
  2. Custom-Class verarbeitet File → fügt Link/Bild-Syntax ein
- **SwiftUI-Äquivalent:**
  ```swift
  TextEditor(text: $markdownText)
      .onDrop(of: [.fileURL], isTargeted: nil) { providers in
          // File URL extrahieren & Markdown-Syntax generieren
      }
  ```

---

### Datenbindungs-Muster

| AppKit-Pattern | SwiftUI-Äquivalent |
|----------------|-------------------|
| `@IBOutlet weak var textView: NSTextView` | `@State var markdownText: String` |
| `@IBOutlet weak var webView: WKWebView` | `@State var renderedHTML: String` + WebView-Wrapper |
| `NSTextViewDelegate` → `textDidChange:` | `TextEditor(text: $markdownText)` → automatisch |
| `WKNavigationDelegate` | WebView-Wrapper mit `@Binding` für Navigation-Events |
| User Defaults für Auto-Refresh | `@AppStorage("autoRefresh") var autoRefresh = true` |
| NSDocument für File Handling | `FileDocument`-Protocol + `DocumentGroup` |

---

## 7. Erforderliche SwiftUI-Zielstruktur (Vorschlag)

### App-Struktur

```swift
@main
struct TextDownApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // 1. Haupt-Dokument-Interface
        DocumentGroup(newDocument: MarkdownDocument()) { file in
            ContentView(document: file.$document)
        }
        .commands {
            // 2. Custom Commands
            AppCommands()
        }
        
        // 3. Preferences
        Settings {
            PreferencesView()
        }
        
        // 4. About Window (alternativ als Sheet in ContentView)
        Window("About TextDown", id: "about") {
            AboutView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 291, height: 176)
    }
}
```

---

### View-Hierarchie

#### 1. **ContentView** (Haupt-UI)
**Rolle:** Ersetzt `DocumentViewController` + Window Controller

```swift
struct ContentView: View {
    @Binding var document: MarkdownDocument
    @StateObject var viewModel = EditorViewModel()
    
    var body: some View {
        HSplitView {
            EditorPane(text: $document.text, viewModel: viewModel)
            PreviewPane(html: viewModel.renderedHTML)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}
```

**Ersetzt:**
- `MarkdownWindowController` `id="B8D-0N-5wS"`
- `DocumentViewController` `id="XfG-lQ-9wD"`
- `NSSplitView` `id="RbX-Sy-Yvt"`

---

#### 2. **EditorPane** (Linke Split-Seite)
**Rolle:** Markdown-Editor mit Drag & Drop

```swift
struct EditorPane: View {
    @Binding var text: String
    @ObservedObject var viewModel: EditorViewModel
    
    var body: some View {
        TextEditor(text: $text)
            .font(.system(.body, design: .monospaced))
            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                viewModel.handleFileDrop(providers)
            }
    }
}
```

**Ersetzt:**
- `NSScrollView` `id="n1h-Pp-I4v"`
- `DropableTextView` `id="Q3Q-a2-tMH"`

**Hinweise:**
- Für erweiterte Editor-Features (Line Numbers, Syntax Highlighting) eventuell `NSViewRepresentable` mit `NSTextView` nötig

---

#### 3. **PreviewPane** (Rechte Split-Seite)
**Rolle:** Live-HTML-Preview

```swift
struct PreviewPane: View {
    let html: String
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            MarkdownWebView(html: html, isLoading: $isLoading)
            
            if isLoading {
                ProgressView()
                    .controlSize(.small)
            }
        }
    }
}

// NSViewRepresentable Wrapper
struct MarkdownWebView: NSViewRepresentable {
    let html: String
    @Binding var isLoading: Bool
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool
        
        init(isLoading: Binding<Bool>) {
            _isLoading = isLoading
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
        }
    }
}
```

**Ersetzt:**
- `WKWebView` `id="bs7-Op-UnU"`
- `NSProgressIndicator` `id="uLU-em-oOP"`

---

#### 4. **AboutView** (About-Dialog)
**Rolle:** App-Informationen

```swift
struct AboutView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 50, height: 50)
            
            Text("TextDown")
                .font(.headline)
            
            Text("Version \(Bundle.main.appVersion) (\(Bundle.main.buildNumber))")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text("Copyright © 2025")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ScrollView {
                Text(Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as? String ?? "")
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 40)
        }
        .padding()
        .frame(width: 291, height: 176)
    }
}
```

**Ersetzt:**
- `AboutWindowController` `id="VZF-nt-1dI"`
- `AboutViewController` `id="Z8Y-nM-9Xv"`
- Alle Subviews (ImageView, TextFields, ScrollView)

---

#### 5. **PreferencesView** (Einstellungen)
**Rolle:** App-Preferences (nicht im Storyboard, aber via `showPreferences:` Action referenziert)

```swift
struct PreferencesView: View {
    @AppStorage("autoRefresh") var autoRefresh = true
    @AppStorage("updateInterval") var updateInterval = 86400 // Daily
    
    var body: some View {
        Form {
            Section("Preview") {
                Toggle("Auto-refresh preview", isOn: $autoRefresh)
            }
            
            Section("Updates") {
                Picker("Check for updates", selection: $updateInterval) {
                    Text("Never").tag(0)
                    Text("Hourly").tag(3600)
                    Text("Daily").tag(86400)
                    Text("Weekly").tag(604800)
                }
            }
        }
        .frame(width: 400)
    }
}
```

**Neu:** Ersetzt vermutlich existierenden (nicht im Storyboard enthaltenen) Preferences Window Controller

---

### ViewModels

#### 1. **EditorViewModel**
**Rolle:** Zentrales Business Logic ViewModel

```swift
@MainActor
class EditorViewModel: ObservableObject {
    @Published var renderedHTML: String = ""
    @AppStorage("autoRefresh") var autoRefresh = true
    
    private let markdownParser = MarkdownParser()
    
    func updatePreview(from markdown: String) {
        guard autoRefresh else { return }
        renderedHTML = markdownParser.parse(markdown)
    }
    
    func forceRefresh(from markdown: String) {
        renderedHTML = markdownParser.parse(markdown)
    }
    
    func handleFileDrop(_ providers: [NSItemProvider]) -> Bool {
        // File URL extrahieren & Markdown-Syntax einfügen
        return true
    }
    
    func exportHTML() {
        // HTML-Export-Logik
    }
}
```

**Ersetzt Logik aus:**
- `DocumentViewController`
- `MarkdownWindowController`
- Teile von `AppDelegate`

---

#### 2. **MarkdownDocument** (FileDocument)
**Rolle:** Document-Model für File Handling

```swift
struct MarkdownDocument: FileDocument {
    static var readableContentTypes = [UTType.plainText]
    
    var text: String
    
    init(text: String = "") {
        self.text = text
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}
```

**Ersetzt:**
- NSDocument-basiertes File Handling
- Controller-Logik für `newDocument:`, `saveDocument:`, etc.

---

### Commands (Menu-System)

#### **AppCommands**
**Rolle:** Custom Menu Commands

```swift
struct AppCommands: Commands {
    @FocusedBinding(\.markdownText) var text
    @AppStorage("autoRefresh") var autoRefresh
    
    var body: some Commands {
        // 1. Replace "About" in App Menu
        CommandGroup(replacing: .appInfo) {
            Button("About TextDown") {
                NSApp.sendAction(#selector(AppDelegate.showAbout), to: nil, from: nil)
            }
        }
        
        // 2. Add Export to File Menu
        CommandGroup(after: .saveItem) {
            Divider()
            Button("Export as HTML…") {
                // Export Action
            }
            .keyboardShortcut("e")
        }
        
        // 3. Add View Commands
        CommandMenu("View") {
            Toggle("Preview auto refresh", isOn: $autoRefresh)
            
            Button("Refresh preview") {
                NotificationCenter.default.post(name: .refreshPreview, object: nil)
            }
            .keyboardShortcut("r")
        }
        
        // 4. Update Commands
        CommandMenu("Check for Updates") {
            Button("Check now…") {
                // Sparkle Integration
            }
            .keyboardShortcut("u")
            
            Divider()
            
            // Update Intervals...
        }
    }
}
```

**Ersetzt:**
- Komplettes Main Menu `id="AYu-sK-qS6"`
- Alle Menu Items mit Actions

---

### AppDelegate (Hybrid-Approach)

```swift
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Sparkle Setup
        setupSparkle()
    }
    
    @objc func showAbout() {
        // About Window öffnen (falls nicht via SwiftUI Window)
    }
    
    @objc func showPreferences() {
        // Preferences öffnen (automatisch via Settings {} in SwiftUI)
    }
    
    private func setupSparkle() {
        // SPUStandardUpdaterController Setup
    }
}
```

**Behält bei:**
- Sparkle Update Framework Integration
- Legacy AppKit-Integration wo nötig

---

### Migrations-Roadmap

#### Phase 1: Basis-Migration
1. ✅ `MarkdownDocument` (FileDocument) erstellen
2. ✅ `ContentView` mit `HSplitView` aufbauen
3. ✅ `EditorPane` mit `TextEditor` implementieren
4. ✅ `PreviewPane` mit WKWebView-Wrapper erstellen
5. ✅ `EditorViewModel` für Business Logic

#### Phase 2: Feature-Parity
6. ✅ `AboutView` migrieren
7. ✅ `PreferencesView` erstellen
8. ✅ Custom Commands (`AppCommands`) implementieren
9. ⚠️ Drag & Drop in `EditorPane`
10. ⚠️ Find & Replace (via `.searchable()` oder Custom UI)

#### Phase 3: AppKit-Brücken
11. ⚠️ Sparkle Integration über `@NSApplicationDelegateAdaptor`
12. ⚠️ Font-Picker (eventuell NSFontManager-Wrapper)
13. ⚠️ Erweiterte Editor-Features (falls `TextEditor` nicht ausreicht)

#### Phase 4: Polish & Testing
14. ✅ Layout-Anpassungen (min/max Sizes)
15. ✅ Keyboard Shortcuts verifizieren
16. ✅ Window-Restoration testen
17. ✅ Document-based App Lifecycle testen

---

### Offene Fragen / Risiken

1. **TextEditor-Limitierungen:**
   - Kein Line Number Support
   - Keine Syntax Highlighting (extern: Highlightr, CodeEditor-Packages)
   - Eventuell `NSViewRepresentable` mit `NSTextView` nötig

2. **Find & Replace:**
   - System-Find-Bar (`findBarPosition="belowContent"`) hat kein SwiftUI-Äquivalent
   - Muss über `.searchable()` oder Custom UI nachgebaut werden

3. **Sparkle Update Framework:**
   - Bleibt AppKit-basiert
   - Benötigt `@NSApplicationDelegateAdaptor` oder separates Update-System

4. **Toolbar Customization:**
   - Derzeit keine Custom Toolbar Items im Storyboard
   - Eventuell später nötig: SwiftUI Toolbar Items mit `.customizationID()`

5. **Window-Lifecycle:**
   - `hidesOnDeactivate` (About Window) schwer in SwiftUI abzubilden
   - Eventuell separates AppKit-Window nötig

---

### Dependencies

**Zu ersetzen:**
- `NSTextView` → `TextEditor` oder Package (z.B. `CodeEditor`, `Runestone`)
- `WKWebView` → `NSViewRepresentable`-Wrapper (obligatorisch)

**Beizubehalten:**
- Sparkle Framework (SPUStandardUpdaterController)
- Markdown Parser (vermutlich externe Library wie `Down`, `SwiftMark`, etc.)

**Neu hinzuzufügen (optional):**
- `Highlightr` – Syntax Highlighting für Markdown
- `SwiftUI-Introspect` – Zugriff auf underlying AppKit-Views falls nötig

---

## Zusammenfassung

### Migrations-Komplexität: **Mittel**

**Einfach (✅ direkt übertragbar):**
- About Dialog (100% SwiftUI-native)
- Preferences (komplett neu, aber trivial)
- Document-basiertes File Handling (`DocumentGroup`)
- Progress Indicator, Image Views, Text Fields

**Mittel (⚠️ benötigt Wrapper/Refactoring):**
- NSSplitView → `HSplitView` (funktional identisch)
- NSScrollView → SwiftUI `ScrollView` (meist implizit)
- Menu System → `.commands { }` (arbeitsintensiv, aber machbar)
- Auto-Layout → SwiftUI Layout (deklarativ, meist einfacher)

**Komplex (🔴 benötigt AppKit-Brücken):**
- NSTextView → `TextEditor` (Feature-Gap) oder `NSViewRepresentable`
- WKWebView → `NSViewRepresentable` (obligatorisch)
- Sparkle Updates → `@NSApplicationDelegateAdaptor` (Legacy-Integration)
- Find & Replace → Custom UI (kein System-Equivalent)

---

### Empfohlene Strategie

**Incremental Migration:**
1. Neue SwiftUI-Views parallel zu AppKit-Views entwickeln
2. Schrittweiser Übergang pro Feature (z.B. zuerst About, dann Preferences)
3. Document-Handling als Basis migrieren (`FileDocument` + `DocumentGroup`)
4. Editor + Preview als Kernfunktionalität mit `NSViewRepresentable`-Wrappern
5. Menu-System am Ende, da am arbeitsintensivsten

**Vorteile:**
- App bleibt funktionstüchtig während Migration
- Schrittweises Testing möglich
- Rückzugsmöglichkeit bei Blocker-Issues

**Zeitschätzung (grob):**
- Phase 1 (Basis): 3-5 Tage
- Phase 2 (Features): 5-7 Tage
- Phase 3 (Brücken): 2-3 Tage
- Phase 4 (Polish): 2-3 Tage
- **Gesamt: ~2-3 Wochen** (bei 1 Entwickler, Vollzeit)

---

**Ende des Migrationsdokuments**
