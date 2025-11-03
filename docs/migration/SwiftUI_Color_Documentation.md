# SwiftUI Color & Color Scheme Documentation

Complete reference documentation for SwiftUI's color and color scheme APIs, including view modifiers, properties, initializers, and related types.

---

## View Modifiers

### toolbarColorScheme(_:for:)

**Specifies the preferred color scheme of a bar managed by SwiftUI.**

```swift
nonisolated
func toolbarColorScheme(
    _ colorScheme: ColorScheme?,
    for bars: ToolbarPlacement...
) -> some View
```

**Parameters:**
- `colorScheme`: The preferred color scheme of the background of the bar.
- `bars`: The bars to update the color scheme of or automatic if empty.

**Discussion:**

The preferred color scheme flows up to the nearest container that renders a bar. This could be a `NavigationView` or `TabView` in iOS, or the root view of a `WindowGroup` in macOS. Pass in a value of `nil` to match the current system's color scheme.

This example shows a view that renders the navigation bar with a blue background and dark color scheme:

```swift
TabView {
    NavigationView {
        ContentView()
            .toolbarBackground(.blue)
            .toolbarColorScheme(.dark)
    }
    // other tabs...
}
```

You can provide multiple `ToolbarPlacement` instances to customize multiple bars at once:

```swift
TabView {
    NavigationView {
        ContentView()
            .toolbarBackground(
                .blue, for: .navigationBar, .tabBar)
            .toolbarColorScheme(
                .dark, for: .navigationBar, .tabBar)
    }
}
```

> **Note:** The provided color scheme is only respected while a background is visible in the requested bar. As the background becomes visible, the bar transitions from the color scheme of the app to the requested color scheme.

You can ensure that the color scheme is always respected by specifying that the background of the bar always be visible:

```swift
NavigationView {
    ContentView()
        .toolbarBackground(.visible)
        .toolbarColorScheme(.dark)
}
```

Depending on the specified bars, the requested color scheme may not be able to be fulfilled.

---

### tint(_:)

**Sets the tint color within this control template.**

```swift
@MainActor @preconcurrency
func tint(_ tint: Color?) -> some ControlWidgetTemplate
```

**Parameters:**
- `tint`: The tint Color to apply.

**Discussion:**

Controls don't respect the `tint(_:)` modifier when applied to control labels, nor do controls support arbitrary tint shape styles. Instead, define a tint color for your control by applying this modifier to its template:

```swift
struct GarageDoorOpener: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(...) {
            ControlWidgetToggle(...) {
                Label(
                    $0 ? "Open" : "Closed",
                    systemImage: $0 ? "door.open" : "door.closed"
                )
            }
            .tint(.orange)
        }
    }
}
```

---

## Instance Properties

### accessibilityDifferentiateWithoutColor

**Whether the system preference for Differentiate without Color is enabled.**

```swift
var accessibilityDifferentiateWithoutColor: Bool { get }
```

**Discussion:**

If this is `true`, UI should not convey information using color alone and instead should use shapes or glyphs to convey information.

---

### accessibilityInvertColors

**Whether the system preference for Invert Colors is enabled.**

```swift
var accessibilityInvertColors: Bool { get }
```

**Discussion:**

If this property's value is `true` then the display will be inverted. In these cases it may be needed for UI drawing to be adjusted in order to display optimally when inverted.

---

### colorScheme

**The color scheme of this environment.**

```swift
var colorScheme: ColorScheme { get set }
```

**Discussion:**

Read this environment value from within a view to find out if SwiftUI is currently displaying the view using the `ColorScheme.light` or `ColorScheme.dark` appearance. The value that you receive depends on whether the user has enabled Dark Mode, possibly superseded by the configuration of the current presentation's view hierarchy.

```swift
@Environment(\.colorScheme) private var colorScheme

var body: some View {
    Text(colorScheme == .dark ? "Dark" : "Light")
}
```

You can set the `colorScheme` environment value directly, but that usually isn't what you want. Doing so changes the color scheme of the given view and its child views but not the views above it in the view hierarchy. Instead, set a color scheme using the `preferredColorScheme(_:)` modifier, which also propagates the value up through the view hierarchy to the enclosing presentation, like a sheet or a window.

When adjusting your app's user interface to match the color scheme, consider also checking the `colorSchemeContrast` property, which reflects a system-wide contrast setting that the user controls. For information, see **Accessibility** in the Human Interface Guidelines.

> **Note:** If you only need to provide different colors or images for different color scheme and contrast settings, do that in your app's Asset Catalog. See **Asset management**.

---

### colorSchemeContrast

**The contrast associated with the color scheme of this environment.**

```swift
var colorSchemeContrast: ColorSchemeContrast { get }
```

**Discussion:**

Read this environment value from within a view to find out if SwiftUI is currently displaying the view using `ColorSchemeContrast.standard` or `ColorSchemeContrast.increased` contrast. The value that you read depends entirely on user settings, and you can't change it.

```swift
@Environment(\.colorSchemeContrast) private var colorSchemeContrast

var body: some View {
    Text(colorSchemeContrast == .standard ? "Standard" : "Increased")
}
```

When adjusting your app's user interface to match the contrast, consider also checking the `colorScheme` property to find out if SwiftUI is displaying the view with a light or dark appearance. For information, see **Accessibility** in the Human Interface Guidelines.

> **Note:** If you only need to provide different colors or images for different color scheme and contrast settings, do that in your app's Asset Catalog. See **Asset management**.

---

### symbolColorRenderingMode

**The property specifying how symbol images fill their layers, or nil to use the default fill style.**

```swift
var symbolColorRenderingMode: SymbolColorRenderingMode? { get set }
```

---

## View Modifiers - Accessibility

### accessibilityIgnoresInvertColors(_:)

**Sets whether this view should ignore the system Smart Invert setting.**

```swift
nonisolated
func accessibilityIgnoresInvertColors(_ active: Bool = true) -> some View
```

**Parameters:**
- `active`: A `true` value ignores the system Smart Invert setting. A `false` value follows the system setting.

**Discussion:**

Use this modifier to suppress Smart Invert in a view that shouldn't be inverted. Or pass an `active` argument of `false` to begin following the Smart Invert setting again when it was previously disabled.

---

## Styling Modifiers

### backgroundStyle(_:)

**Sets the specified style to render backgrounds within the view.**

```swift
nonisolated
func backgroundStyle<S>(_ style: S) -> some View where S : ShapeStyle
```

**Discussion:**

The following example uses this modifier to set the `backgroundStyle` environment value to a blue color that includes a subtle gradient. SwiftUI fills the `Circle` shape that acts as a background element with this style:

```swift
Image(systemName: "swift")
    .padding()
    .background(in: Circle())
    .backgroundStyle(.blue.gradient)
```

*An image of the Swift logo inside a circle that's blue with a slight gradient*

To restore the default background style, set the `backgroundStyle` environment value to `nil` using the `environment(_:_:)` modifier:

```swift
.environment(\.backgroundStyle, nil)
```

---

### foregroundStyle(_:)

**Sets a view's foreground elements to use a given style.**

```swift
nonisolated
func foregroundStyle<S>(_ style: S) -> some View where S : ShapeStyle
```

**Parameters:**
- `style`: The color or pattern to use when filling in the foreground elements. To indicate a specific value, use `Color` or `image(_:sourceRect:scale:)`, or one of the gradient types, like `linearGradient(colors:startPoint:endPoint:)`. To set a style that's relative to the containing view's style, use one of the semantic styles, like `primary`.

**Return Value:**
A view that uses the given foreground style.

**Discussion:**

Use this method to style foreground content like text, shapes, and template images (including symbols):

```swift
HStack {
    Image(systemName: "triangle.fill")
    Text("Hello, world!")
    RoundedRectangle(cornerRadius: 5)
        .frame(width: 40, height: 20)
}
.foregroundStyle(.teal)
```

*The example above creates a row of teal foreground elements*

You can use any style that conforms to the `ShapeStyle` protocol, like the teal color in the example above, or the `linearGradient(colors:startPoint:endPoint:)` gradient shown below:

```swift
Text("Gradient Text")
    .font(.largeTitle)
    .foregroundStyle(
        .linearGradient(
            colors: [.yellow, .blue],
            startPoint: .top,
            endPoint: .bottom
        )
    )
```

> **Tip:** If you want to fill a single `Shape` instance with a style, use the `fill(style:)` shape modifier instead because it's more efficient.

SwiftUI creates a context-dependent render for a given style. For example, a `Color` that you load from an asset catalog can have different light and dark appearances, while some styles also vary by platform.

**Hierarchical foreground styles** like `ShapeStyle/secondary` don't impose a style of their own, but instead modify other styles. In particular, they modify the primary level of the current foreground style to the degree given by the hierarchical style's name. To find the current foreground style to modify, SwiftUI looks for the innermost containing style that you apply with the `foregroundStyle(_:)` or the `foregroundColor(_:)` modifier. If you haven't specified a style, SwiftUI uses the default foreground style, as in the following example:

```swift
VStack(alignment: .leading) {
    Label("Primary", systemImage: "1.square.fill")
    Label("Secondary", systemImage: "2.square.fill")
        .foregroundStyle(.secondary)
}
```

If you add a foreground style on the enclosing `VStack`, the hierarchical styling responds accordingly:

```swift
VStack(alignment: .leading) {
    Label("Primary", systemImage: "1.square.fill")
    Label("Secondary", systemImage: "2.square.fill")
        .foregroundStyle(.secondary)
}
.foregroundStyle(.blue)
```

When you apply a custom style to a view, the view disables the vibrancy effect for foreground elements in that view, or in any of its child views, that it would otherwise gain from adding a background material — for example, using the `background(_:ignoresSafeAreaEdges:)` modifier. However, hierarchical styles applied to the default foreground don't disable vibrancy.

---

### foregroundStyle(_:_:)

**Sets the primary and secondary levels of the foreground style in the child view.**

```swift
nonisolated
func foregroundStyle<S1, S2>(
    _ primary: S1,
    _ secondary: S2
) -> some View where S1 : ShapeStyle, S2 : ShapeStyle
```

**Parameters:**
- `primary`: The primary color or pattern to use when filling in the foreground elements.
- `secondary`: The secondary color or pattern to use when filling in the foreground elements.

**Return Value:**
A view that uses the given foreground styles.

**Discussion:**

SwiftUI uses these styles when rendering child views that don't have an explicit rendering style, like images, text, shapes, and so on.

Symbol images within the view hierarchy use the palette rendering mode when you apply this modifier, if you don't explicitly specify another mode.

---

### foregroundStyle(_:_:_:)

**Sets the primary, secondary, and tertiary levels of the foreground style.**

```swift
nonisolated
func foregroundStyle<S1, S2, S3>(
    _ primary: S1,
    _ secondary: S2,
    _ tertiary: S3
) -> some View where S1 : ShapeStyle, S2 : ShapeStyle, S3 : ShapeStyle
```

**Parameters:**
- `primary`: The primary color or pattern to use when filling in the foreground elements.
- `secondary`: The secondary color or pattern to use when filling in the foreground elements.
- `tertiary`: The tertiary color or pattern to use when filling in the foreground elements.

**Return Value:**
A view that uses the given foreground styles.

**Discussion:**

SwiftUI uses these styles when rendering child views that don't have an explicit rendering style, like images, text, shapes, and so on.

Symbol images within the view hierarchy use the palette rendering mode when you apply this modifier, if you don't explicitly specify another mode.

---

### allowedDynamicRange(_:)

**Returns a new view configured with the specified allowed dynamic range.**

```swift
nonisolated
func allowedDynamicRange(_ range: Image.DynamicRange?) -> some View
```

**Parameters:**
- `range`: The requested dynamic range, or `nil` to restore the default allowed range.

**Return Value:**
A new view.

**Discussion:**

The following example enables HDR rendering within a view hierarchy:

```swift
MyView().allowedDynamicRange(.high)
```

---

## List Separators

### listRowSeparatorTint(_:edges:)

**Sets the tint color associated with a row.**

```swift
nonisolated
func listRowSeparatorTint(
    _ color: Color?,
    edges: VerticalEdge.Set = .all
) -> some View
```

**Parameters:**
- `color`: The color to use to tint the row separators, or `nil` to use the default color for the current list style.
- `edges`: The set of row edges for which the tint applies. The list style might decide to not display certain separators, typically the top edge. The default is `.all`.

**Discussion:**

Separators can be presented above and below a row. You can specify to which edge this preference should apply.

This modifier expresses a preference to the containing `List`. The list style is the final arbiter for the separator tint.

The following example shows a simple grouped list whose row separators are tinted based on row-specific data:

```swift
List {
    ForEach(garage.cars) { car in
        Text(car.model)
            .listRowSeparatorTint(car.brandColor)
    }
}
.listStyle(.grouped)
```

To hide row separators, use `listRowSeparator(_:edges:)`. To hide or change the tint color for a section separator, use `listSectionSeparator(_:edges:)` and `listSectionSeparatorTint(_:edges:)`.

---

### listSectionSeparatorTint(_:edges:)

**Sets the tint color associated with a section.**

```swift
nonisolated
func listSectionSeparatorTint(
    _ color: Color?,
    edges: VerticalEdge.Set = .all
) -> some View
```

**Parameters:**
- `color`: The color to use to tint the section separators, or `nil` to use the default color for the current list style.
- `edges`: The set of row edges for which the tint applies. The list style might decide to not display certain separators, typically the top edge. The default is `.all`.

**Discussion:**

Separators can be presented above and below a section. You can specify to which edge this preference should apply.

This modifier expresses a preference to the containing `List`. The list style is the final arbiter for the separator tint.

The following example shows a simple grouped list whose section separators are tinted based on section-specific data:

```swift
List {
    ForEach(garage) { garage in
        Section(header: Text(garage.location)) {
            ForEach(garage.cars) { car in
                Text(car.model)
                    .listRowSeparatorTint(car.brandColor)
            }
        }
        .listSectionSeparatorTint(
            garage.cars.last?.brandColor, edges: .bottom)
    }
}
.listStyle(.grouped)
```

To change the visibility and tint color for a row separator, use `listRowSeparator(_:edges:)` and `listRowSeparatorTint(_:edges:)`. To hide a section separator, use `listSectionSeparator(_:edges:)`.

---

## Color Scheme Preferences

### preferredColorScheme(_:)

**Sets the preferred color scheme for this presentation.**

```swift
nonisolated
func preferredColorScheme(_ colorScheme: ColorScheme?) -> some View
```

**Parameters:**
- `colorScheme`: The preferred color scheme for this view, or `nil` to indicate no preference.

**Return Value:**
A view that sets the color scheme.

**Discussion:**

Use one of the values in `ColorScheme` with this modifier to set a preferred color scheme for the nearest enclosing presentation, like a popover, a sheet, or a window. The value that you set overrides the user's Dark Mode selection for that presentation.

In the example below, the `Toggle` controls an `isDarkMode` state variable, which in turn controls the color scheme of the sheet that contains the toggle:

```swift
@State private var isPresented = false
@State private var isDarkMode = true

var body: some View {
    Button("Show Sheet") {
        isPresented = true
    }
    .sheet(isPresented: $isPresented) {
        List {
            Toggle("Dark Mode", isOn: $isDarkMode)
        }
        .preferredColorScheme(isDarkMode ? .dark : nil)
    }
}
```

If you apply the modifier to any of the views in the sheet — which in this case are a `List` and a `Toggle` — the value that you set propagates up through the view hierarchy to the enclosing presentation, or until another color scheme modifier higher in the hierarchy overrides it. The value you set also flows down to all child views of the enclosing presentation.

Pass `nil` to indicate that there is no preferred color scheme for this view. This is useful in cases where a preferred color scheme should only be applied conditionally. In the previous example, the sheet will prefer dark mode when `isDarkMode` is set to `true`, but otherwise defer to the color scheme as determined by the system.

Multiple views in the same view hierarchy can set a preferred color scheme. Applying this modifier overrides any existing preferred color scheme set for the view, such as by one of its subviews. If there are conflicting, non-nil color scheme preferences set by parallel branches of the view hierarchy, the system will prioritize the first non-nil preference based on the order of the views.

In the example below, the preferred color scheme for the entire view will resolve to `.dark`, from the second view:

```swift
VStack {
    Text("First")
        .preferredColorScheme(.light)
        .preferredColorScheme(nil) // overrides `.light`

    Text("Second")
        .preferredColorScheme(.dark)

    Text("Third")
        .preferredColorScheme(.light)
}
```

A common use for this modifier is to create side-by-side previews of the same view with light and dark appearances:

```swift
struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        MyView().preferredColorScheme(.light)
        MyView().preferredColorScheme(.dark)
    }
}
```

If you need to detect the color scheme that currently applies to a view, read the `colorScheme` environment value:

```swift
@Environment(\.colorScheme) private var colorScheme

var body: some View {
    Text(colorScheme == .dark ? "Dark" : "Light")
}
```

---

## Text Styling

### strikethrough(_:pattern:color:)

**Applies a strikethrough to the text in this view.**

```swift
nonisolated
func strikethrough(
    _ isActive: Bool = true,
    pattern: Text.LineStyle.Pattern = .solid,
    color: Color? = nil
) -> some View
```

**Parameters:**
- `isActive`: A Boolean value that indicates whether strikethrough is added. The default value is `true`.
- `pattern`: The pattern of the line. The default value is `.solid`.
- `color`: The color of the strikethrough. If `color` is `nil`, the strikethrough uses the default foreground color.

**Return Value:**
A view where text has a line through its center.

---

### underline(_:pattern:color:)

**Applies an underline to the text in this view.**

```swift
nonisolated
func underline(
    _ isActive: Bool = true,
    pattern: Text.LineStyle.Pattern = .solid,
    color: Color? = nil
) -> some View
```

**Parameters:**
- `isActive`: A Boolean value that indicates whether underline is added. The default value is `true`.
- `pattern`: The pattern of the line. The default value is `.solid`.
- `color`: The color of the underline. If `color` is `nil`, the underline uses the default foreground color.

**Return Value:**
A view where text has a line running along its baseline.

---

## Color Effects

### colorInvert()

**Inverts the colors in this view.**

```swift
nonisolated
func colorInvert() -> some View
```

**Return Value:**
A view that inverts its colors.

**Discussion:**

The `colorInvert()` modifier inverts all of the colors in a view so that each color displays as its complementary color. For example, blue converts to yellow, and white converts to black.

In the example below, two red squares each have an interior green circle. The inverted square shows the effect of the square's colors: complementary colors for red and green — teal and purple.

```swift
struct InnerCircleView: View {
    var body: some View {
        Circle()
            .fill(Color.green)
            .frame(width: 40, height: 40, alignment: .center)
    }
}

struct ColorInvert: View {
    var body: some View {
        HStack {
            Color.red.frame(width: 100, height: 100, alignment: .center)
                .overlay(InnerCircleView(), alignment: .center)
                .overlay(Text("Normal")
                             .font(.callout),
                         alignment: .bottom)
                .border(Color.gray)

            Spacer()

            Color.red.frame(width: 100, height: 100, alignment: .center)
                .overlay(InnerCircleView(), alignment: .center)
                .colorInvert()
                .overlay(Text("Inverted")
                             .font(.callout),
                         alignment: .bottom)
                .border(Color.gray)
        }
        .padding(50)
    }
}
```

*Two red squares with centered green circles with one showing the complementary colors*

---

### colorMultiply(_:)

**Adds a color multiplication effect to this view.**

```swift
nonisolated
func colorMultiply(_ color: Color) -> some View
```

**Parameters:**
- `color`: The color to bias this view toward.

**Return Value:**
A view with a color multiplication effect.

**Discussion:**

The following example shows two versions of the same image side by side; at left is the original, and at right is a duplicate with the `colorMultiply(_:)` modifier applied with purple.

```swift
struct InnerCircleView: View {
    var body: some View {
        Circle()
            .fill(Color.green)
            .frame(width: 40, height: 40, alignment: .center)
    }
}

struct ColorMultiply: View {
    var body: some View {
        HStack {
            Color.red.frame(width: 100, height: 100, alignment: .center)
                .overlay(InnerCircleView(), alignment: .center)
                .overlay(Text("Normal")
                             .font(.callout),
                         alignment: .bottom)
                .border(Color.gray)

            Spacer()

            Color.red.frame(width: 100, height: 100, alignment: .center)
                .overlay(InnerCircleView(), alignment: .center)
                .colorMultiply(Color.purple)
                .overlay(Text("Multiply")
                            .font(.callout),
                         alignment: .bottom)
                .border(Color.gray)
        }
        .padding(50)
    }
}
```

*A screenshot showing two images showing the effect of multiplying the colors*

---

### shadow(color:radius:x:y:)

**Adds a shadow to this view.**

```swift
nonisolated
func shadow(
    color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
    radius: CGFloat,
    x: CGFloat = 0,
    y: CGFloat = 0
) -> some View
```

**Parameters:**
- `color`: The shadow's color.
- `radius`: A measure of how much to blur the shadow. Larger values result in more blur.
- `x`: An amount to offset the shadow horizontally from the view.
- `y`: An amount to offset the shadow vertically from the view.

**Return Value:**
A view that adds a shadow to this view.

**Discussion:**

Use this modifier to add a shadow of a specified color behind a view. You can offset the shadow from its view independently in the horizontal and vertical dimensions using the `x` and `y` parameters. You can also blur the edges of the shadow using the `radius` parameter. Use a radius of zero to create a sharp shadow. Larger radius values produce softer shadows.

The example below creates a grid of boxes with varying offsets and blur. Each box displays its radius and offset values for reference.

```swift
struct Shadow: View {
    let steps = [0, 5, 10]

    var body: some View {
        VStack(spacing: 50) {
            ForEach(steps, id: \.self) { offset in
                HStack(spacing: 50) {
                    ForEach(steps, id: \.self) { radius in
                        Color.blue
                            .shadow(
                                color: .primary,
                                radius: CGFloat(radius),
                                x: CGFloat(offset), y: CGFloat(offset))
                            .overlay {
                                VStack {
                                    Text("\(radius)")
                                    Text("(\(offset), \(offset))")
                                }
                            }
                    }
                }
            }
        }
    }
}
```

*A three by three grid of blue boxes with shadows*

The example above uses `primary` as the color to make the shadow easy to see for the purpose of illustration. In practice, you might prefer something more subtle, like `gray`. If you don't specify a color, the method uses a semi-transparent black.

---

### colorEffect(_:isEnabled:)

**Returns a new view that applies shader to self as a filter effect on the color of each pixel.**

```swift
nonisolated
func colorEffect(
    _ shader: Shader,
    isEnabled: Bool = true
) -> some View
```

**Parameters:**
- `shader`: The shader to apply to self as a color filter.
- `isEnabled`: Whether the effect is enabled or not.

**Return Value:**
A new view that renders self with the shader applied as a color filter.

**Discussion:**

For a shader function to act as a color filter it must have a function signature matching:

```metal
[[ stitchable ]] half4 name(float2 position, half4 color, args...)
```

where `position` is the user-space coordinates of the pixel applied to the shader and `color` its source color, as a pre-multiplied color in the destination color space. `args...` should be compatible with the uniform arguments bound to `shader`. The function should return the modified color value.

> **Important:** Views backed by AppKit or UIKit views may not render into the filtered layer. Instead, they log a warning and display a placeholder image to highlight the error.

---

### drawingGroup(opaque:colorMode:)

**Composites this view's contents into an offscreen image before final display.**

```swift
nonisolated
func drawingGroup(
    opaque: Bool = false,
    colorMode: ColorRenderingMode = .nonLinear
) -> some View
```

**Parameters:**
- `opaque`: A Boolean value that indicates whether the image is opaque. The default is `false`; if set to `true`, the alpha channel of the image must be 1.
- `colorMode`: One of the working color space and storage formats defined in `ColorRenderingMode`. The default is `ColorRenderingMode.nonLinear`.

**Return Value:**
A view that composites this view's contents into an offscreen image before display.

**Discussion:**

The `drawingGroup(opaque:colorMode:)` modifier flattens a subtree of views into a single view before rendering it.

In the example below, the contents of the view are composited to a single bitmap; the bitmap is then displayed in place of the view:

```swift
VStack {
    ZStack {
        Text("DrawingGroup")
            .foregroundColor(.black)
            .padding(20)
            .background(Color.red)
        Text("DrawingGroup")
            .blur(radius: 2)
    }
    .font(.largeTitle)
    .compositingGroup()
    .opacity(1.0)
}
.background(Color.white)
.drawingGroup()
```

> **Note:** Views backed by native platform views may not render into the image. Instead, they log a warning and display a placeholder image to highlight the error.

---

## Live Activities

### activitySystemActionForegroundColor(_:)

**The text color for the auxiliary action button that the system shows next to a Live Activity on the Lock Screen.**

```swift
@MainActor @preconcurrency
func activitySystemActionForegroundColor(_ color: Color?) -> some View
```

**Parameters:**
- `color`: The text color to use. Pass `nil` to use the system's default color.

---

### activityBackgroundTint(_:)

**Sets the tint color for the background of a Live Activity that appears on the Lock Screen.**

```swift
@MainActor @preconcurrency
func activityBackgroundTint(_ color: Color?) -> some View
```

**Parameters:**
- `color`: The background tint color to apply. To use the system's default background material, pass `nil`.

**Discussion:**

When you set a custom background tint color, consider setting a custom text color for the auxiliary button people use to end a Live Activity on the Lock Screen. To set a custom text color, use the `activitySystemActionForegroundColor(_:)` view modifier.

---

### symbolColorRenderingMode(_:)

**Sets the color rendering mode for symbol images.**

```swift
nonisolated
func symbolColorRenderingMode(_ mode: SymbolColorRenderingMode?) -> some View
```

**Parameters:**
- `mode`: The color rendering mode, or `nil` to use the default mode.

**Return Value:**
A view that specifies the color rendering mode for symbol images.

---

## ColorScheme Enumeration

### ColorScheme

**The possible color schemes, corresponding to the light and dark appearances.**

```swift
enum ColorScheme
```

**Overview:**

You receive a color scheme value when you read the `colorScheme` environment value. The value tells you if a light or dark appearance currently applies to the view. SwiftUI updates the value whenever the appearance changes, and redraws views that depend on the value.

For example, the following `Text` view automatically updates when the user enables Dark Mode:

```swift
@Environment(\.colorScheme) private var colorScheme

var body: some View {
    Text(colorScheme == .dark ? "Dark" : "Light")
}
```

Set a preferred appearance for a particular view hierarchy to override the user's Dark Mode setting using the `preferredColorScheme(_:)` view modifier.

#### Cases

##### light

**The color scheme that corresponds to a light appearance.**

```swift
case light
```

##### dark

**The color scheme that corresponds to a dark appearance.**

```swift
case dark
```

#### Initializers

##### init(_:)

**Creates a color scheme from its user interface style equivalent.**

```swift
init?(_ uiUserInterfaceStyle: UIUserInterfaceStyle)
```

#### Supporting Types

##### PreferredColorSchemeKey

**A key for specifying the preferred color scheme.**

```swift
struct PreferredColorSchemeKey
```

**Overview:**

Don't use this key directly. Instead, set a preferred color scheme for a view using the `preferredColorScheme(_:)` view modifier. Get the current color scheme for a view by accessing the `colorScheme` value.

**Conforms To:** `PreferenceKey`

---

## ColorSchemeContrast

### init(_:)

**Creates a contrast from its accessibility contrast equivalent.**

```swift
init?(_ uiAccessibilityContrast: UIAccessibilityContrast)
```

---

## SurroundingsEffect

### colorMultiply(_:)

**An effect that applies a custom tint to the passthrough video by multiplying the passthrough with a Color.**

```swift
static func colorMultiply(_ color: Color) -> SurroundingsEffect
```

**Parameters:**
- `color`: The color to bias the passthrough toward. The opacity of the color is ignored. Use the extended color space to brighten the passthrough.

**Discussion:**

Use this with the `preferredSurroundingsEffect(_:)` view modifier when you want to tint the passthrough while displaying a particular view. The system may decide to limit how much each color in the passthrough can be brightened or darkened.

- `Color.black` will cause no passthrough to be visible
- `Color.white` will have no effect
- `Color(red: 1.15, green: 1.0, blue: 1.0)` would brighten the red in the passthrough by 15 percent

This effect will only be applied while an immersive space is opened.

---

## MatchedTransitionSourceConfiguration

### background(_:)

**Specifies a color that will be drawn behind the content within the matched transition source.**

```swift
func background(_ style: Color) -> some MatchedTransitionSourceConfiguration
```

**Discussion:**

During a zoom transition, the background color fills the interpolated shape as it grows from the matched transition source.

---

### shadow(color:radius:x:y:)

**Applies the specified shadow effect to the matched transition source.**

```swift
func shadow(
    color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
    radius: CGFloat,
    x: CGFloat = 0,
    y: CGFloat = 0
) -> some MatchedTransitionSourceConfiguration
```

**Parameters:**
- `color`: The shadow's color.
- `radius`: A measure of how much to blur the shadow. Larger values result in more blur.
- `x`: An amount to offset the shadow horizontally from the view.
- `y`: An amount to offset the shadow vertically from the view.

---

## Text Color Methods

### Text.strikethrough(_:color:)

**Applies a strikethrough to the text.**

```swift
nonisolated
func strikethrough(
    _ isActive: Bool = true,
    color: Color? = nil
) -> Text
```

**Parameters:**
- `isActive`: A Boolean value that indicates whether the text has a strikethrough applied.
- `color`: The color of the strikethrough. If `color` is `nil`, the strikethrough uses the default foreground color.

**Return Value:**
Text with a line through its center.

---

### Text.strikethrough(_:pattern:color:)

**Applies a strikethrough to the text.**

```swift
nonisolated
func strikethrough(
    _ isActive: Bool = true,
    pattern: Text.LineStyle.Pattern,
    color: Color? = nil
) -> Text
```

**Parameters:**
- `isActive`: A Boolean value that indicates whether strikethrough is added. The default value is `true`.
- `pattern`: The pattern of the line.
- `color`: The color of the strikethrough. If `color` is `nil`, the strikethrough uses the default foreground color.

**Return Value:**
Text with a line through its center.

---

### Text.underline(_:color:)

**Applies an underline to the text.**

```swift
nonisolated
func underline(
    _ isActive: Bool = true,
    color: Color? = nil
) -> Text
```

**Parameters:**
- `isActive`: A Boolean value that indicates whether the text has an underline.
- `color`: The color of the underline. If `color` is `nil`, the underline uses the default foreground color.

**Return Value:**
Text with a line running along its baseline.

---

### Text.underline(_:pattern:color:)

**Applies an underline to the text.**

```swift
nonisolated
func underline(
    _ isActive: Bool = true,
    pattern: Text.LineStyle.Pattern,
    color: Color? = nil
) -> Text
```

**Parameters:**
- `isActive`: A Boolean value that indicates whether underline styling is added. The default value is `true`.
- `pattern`: The pattern of the line.
- `color`: The color of the underline. If `color` is `nil`, the underline uses the default foreground color.

**Return Value:**
Text with a line running along its baseline.

---

## Text.LineStyle

### Text.LineStyle Structure

**Description of the style used to draw the line for StrikethroughStyleAttribute and UnderlineStyleAttribute.**

```swift
struct LineStyle
```

**Overview:**

Use this type to specify `underlineStyle` and `strikethroughStyle` SwiftUI attributes of an `AttributedString`.

#### Type Properties

##### single

**Draw a single solid line.**

```swift
static let single: Text.LineStyle
```

#### Initializers

##### init?(nsUnderlineStyle:)

**Creates a Text.LineStyle from NSUnderlineStyle.**

```swift
init?(nsUnderlineStyle: NSUnderlineStyle)
```

##### init(pattern:color:)

**Creates a line style.**

```swift
init(
    pattern: Text.LineStyle.Pattern = .solid,
    color: Color? = nil
)
```

**Parameters:**
- `pattern`: The pattern of the line.
- `color`: The color of the line. If not provided, the foreground color of text is used.

#### Supporting Types

##### Pattern

**The pattern that the line has.**

```swift
struct Pattern
```

---

## String Interpolation

### appendInterpolation(accessibilityName:)

**Appends a localized description of a color for accessibility to a string interpolation.**

```swift
mutating func appendInterpolation(accessibilityName color: Color)
```

**Parameters:**
- `color`: The color being described.

**Discussion:**

Don't call this method directly; it's used by the compiler when interpreting string interpolations.

---

## Image Initializers with Color

### Image.init(size:label:opaque:colorMode:renderer:)

**Initializes an image of the given size, with contents provided by a custom rendering closure.**

```swift
init(
    size: CGSize,
    label: Text? = nil,
    opaque: Bool = false,
    colorMode: ColorRenderingMode = .nonLinear,
    renderer: @escaping (inout GraphicsContext) -> Void
)
```

**Parameters:**
- `size`: The size of the newly-created image.
- `label`: The label associated with the image. SwiftUI uses the label for accessibility.
- `opaque`: A Boolean value that indicates whether the image is fully opaque. This may improve performance when `true`. Don't render non-opaque pixels to an image declared as opaque. Defaults to `false`.
- `colorMode`: The working color space and storage format of the image. Defaults to `ColorRenderingMode.nonLinear`.
- `renderer`: A closure to draw the contents of the image. The closure receives a `GraphicsContext` as its parameter.

**Discussion:**

Use this initializer to create an image by calling drawing commands on a `GraphicsContext` provided to the renderer closure.

The following example shows a custom image created by passing a `GraphicsContext` to draw an ellipse and fill it with a gradient:

```swift
let mySize = CGSize(width: 300, height: 200)
let image = Image(size: mySize) { context in
    context.fill(
        Path(
            ellipseIn: CGRect(origin: .zero, size: mySize)),
            with: .linearGradient(
                Gradient(colors: [.yellow, .orange]),
                startPoint: .zero,
                endPoint: CGPoint(x: mySize.width, y: mySize.height))
    )
}
```

*An ellipse with a gradient that blends from yellow at the upper-left to orange at the lower-right*

---

### Image.symbolColorRenderingMode(_:)

**Sets the color rendering mode of the image.**

```swift
func symbolColorRenderingMode(_ mode: SymbolColorRenderingMode?) -> Image
```

**Parameters:**
- `mode`: The color rendering mode, or `nil` to use the default mode.

**Return Value:**
A view that specifies how to fill symbol images.

---

## SymbolRenderingMode

### Type Property: multicolor

**A mode that renders symbols as multiple layers with their inherent styles.**

```swift
static let multicolor: SymbolRenderingMode
```

**Discussion:**

The layers may be filled with their own inherent styles, or the foreground style. For example, you can render a filled exclamation mark triangle in its inherent colors, with yellow for the triangle and white for the exclamation mark:

```swift
Image(systemName: "exclamationmark.triangle.fill")
    .symbolRenderingMode(.multicolor)
```

---

## SymbolColorRenderingMode

### Type Properties

#### flat

**The symbol image layer should be filled with a solid color.**

```swift
static let flat: SymbolColorRenderingMode
```

#### gradient

**The symbol image layer should be filled with an axial gradient.**

```swift
static let gradient: SymbolColorRenderingMode
```

---

## SymbolVariableValueMode

### Type Property: color

**The "color" variable value mode.**

```swift
static let color: SymbolVariableValueMode
```

**Discussion:**

Sets the opacity of each variable layer to either on or off depending on how its threshold compared to the current value.

---

## ColorPicker

### ColorPicker Initializers

**Creates a color picker with a text label generated from a title string key.**

```swift
nonisolated
init(
    _ titleKey: LocalizedStringKey,
    selection: Binding<CGColor>,
    supportsOpacity: Bool = true
)

nonisolated
init(
    _ titleKey: LocalizedStringKey,
    selection: Binding<Color>,
    supportsOpacity: Bool = true
)

nonisolated
init(
    _ titleResource: LocalizedStringResource,
    selection: Binding<CGColor>,
    supportsOpacity: Bool = true
)

nonisolated
init(
    _ titleResource: LocalizedStringResource,
    selection: Binding<Color>,
    supportsOpacity: Bool = true
)

nonisolated
init<S>(
    _ title: S,
    selection: Binding<CGColor>,
    supportsOpacity: Bool = true
) where S : StringProtocol

nonisolated
init<S>(
    _ title: S,
    selection: Binding<Color>,
    supportsOpacity: Bool = true
) where S : StringProtocol
```

**Available when Label is Text.**

**Parameters:**
- `titleKey`: The key for the localized title of the picker.
- `selection`: A Binding to the variable that displays the selected `CGColor` or `Color`.
- `supportsOpacity`: A Boolean value that indicates whether the color picker allows adjustments to the selected color's opacity; the default is `true`.

---

### ColorPicker.init(selection:supportsOpacity:label:)

**Creates an instance that selects a color.**

```swift
init(
    selection: Binding<CGColor>,
    supportsOpacity: Bool = true,
    @ViewBuilder label: () -> Label
)

init(
    selection: Binding<Color>,
    supportsOpacity: Bool = true,
    @ViewBuilder label: () -> Label
)
```

**Parameters:**
- `selection`: A Binding to the variable that displays the selected `CGColor` or `Color`.
- `supportsOpacity`: A Boolean value that indicates whether the color picker allows adjusting the selected color's opacity; the default is `true`.
- `label`: A view that describes the use of the selected color. The system color picker UI sets its title using the text from this view.

---

## Canvas

### Canvas.init(opaque:colorMode:rendersAsynchronously:renderer:)

**Creates and configures a canvas.**

```swift
init(
    opaque: Bool = false,
    colorMode: ColorRenderingMode = .nonLinear,
    rendersAsynchronously: Bool = false,
    renderer: @escaping (inout GraphicsContext, CGSize) -> Void
)
```

**Available when Symbols is EmptyView.**

**Parameters:**
- `opaque`: A Boolean that indicates whether the canvas is fully opaque. You might be able to improve performance by setting this value to `true`, but then drawing a non-opaque image into the context produces undefined results. The default is `false`.
- `colorMode`: A working color space and storage format of the canvas. The default is `ColorRenderingMode.nonLinear`.
- `rendersAsynchronously`: A Boolean that indicates whether the canvas can present its contents to its parent view asynchronously. The default is `false`.
- `renderer`: A closure in which you conduct immediate mode drawing. The closure takes two inputs: a context that you use to issue drawing commands and a size — representing the current size of the canvas — that you can use to customize the content. The canvas calls the renderer any time it needs to redraw the content.

**Discussion:**

Use this initializer to create a new canvas that you can draw into. For example, you can draw a path:

```swift
Canvas { context, size in
    context.stroke(
        Path(ellipseIn: CGRect(origin: .zero, size: size)),
        with: .color(.green),
        lineWidth: 4)
}
.frame(width: 300, height: 200)
.border(Color.blue)
```

*The example above draws the outline of an ellipse that exactly inscribes a canvas with a blue border*

For information about using a context to draw into a canvas, see `GraphicsContext`. If you want to provide SwiftUI views for the renderer to use as drawing elements, use `init(opaque:colorMode:rendersAsynchronously:renderer:symbols:)` instead.

---

### Canvas.init(opaque:colorMode:rendersAsynchronously:renderer:symbols:)

**Creates and configures a canvas that you supply with renderable child views.**

```swift
init(
    opaque: Bool = false,
    colorMode: ColorRenderingMode = .nonLinear,
    rendersAsynchronously: Bool = false,
    renderer: @escaping (inout GraphicsContext, CGSize) -> Void,
    @ViewBuilder symbols: () -> Symbols
)
```

**Parameters:**
- `opaque`: A Boolean that indicates whether the canvas is fully opaque.
- `colorMode`: A working color space and storage format of the canvas.
- `rendersAsynchronously`: A Boolean that indicates whether the canvas can present its contents asynchronously.
- `renderer`: A closure in which you conduct immediate mode drawing.
- `symbols`: A `ViewBuilder` that you use to supply SwiftUI views to the canvas for use during drawing. Uniquely tag each view using the `View/tag(_:)` modifier, so that you can find them from within your renderer using the `resolveSymbol(id:)` method.

**Discussion:**

This initializer behaves like the `init(opaque:colorMode:rendersAsynchronously:renderer:)` initializer, except that you also provide a collection of SwiftUI views for the renderer to use as drawing elements.

SwiftUI stores a rendered version of each child view that you specify in the symbols view builder and makes these available to the canvas. Tag each child view so that you can retrieve it from within the renderer using the `resolveSymbol(id:)` method.

For example, you can create a scatter plot using a passed-in child view as the mark for each data point:

```swift
struct ScatterPlotView<Mark: View>: View {
    let rects: [CGRect]
    let mark: Mark

    enum SymbolID: Int {
        case mark
    }

    var body: some View {
        Canvas { context, size in
            if let mark = context.resolveSymbol(id: SymbolID.mark) {
                for rect in rects {
                    context.draw(mark, in: rect)
                }
            }
        } symbols: {
            mark.tag(SymbolID.mark)
        }
        .frame(width: 300, height: 200)
        .border(Color.blue)
    }
}
```

You can use any SwiftUI view for the mark input:

```swift
ScatterPlotView(rects: rects, mark: Image(systemName: "circle"))
```

If the `rects` input contains 50 randomly arranged `CGRect` instances, SwiftUI draws a plot like this:

*A screenshot of a scatter plot inside a blue rectangle, containing 50 circle symbols*

The symbol inputs, like all other elements that you draw to the canvas, lack individual accessibility and interactivity, even if the original SwiftUI view has these attributes. However, you can add accessibility and interactivity modifiers to the canvas as a whole.

---

### Canvas.colorMode

**The working color space and storage format of the canvas.**

```swift
var colorMode: ColorRenderingMode { get set }
```

---

## GraphicsContext.Shading

### color(_:)

**Returns a shading instance that fills with a color.**

```swift
static func color(_ color: Color) -> GraphicsContext.Shading
```

**Parameters:**
- `color`: A `Color` instance that defines the color of the shading.

**Return Value:**
A shading instance filled with a color.

---

### color(_:red:green:blue:opacity:)

**Returns a shading instance that fills with a color in the given color space.**

```swift
static func color(
    _ colorSpace: Color.RGBColorSpace = .sRGB,
    red: Double,
    green: Double,
    blue: Double,
    opacity: Double = 1
) -> GraphicsContext.Shading
```

**Parameters:**
- `colorSpace`: The RGB color space used to define the color. The default is `Color.RGBColorSpace.sRGB`.
- `red`: The red component of the color.
- `green`: The green component of the color.
- `blue`: The blue component of the color.
- `opacity`: The opacity of the color. The default is 1, which means fully opaque.

**Return Value:**
A shading instance filled with a color.

---

### color(_:white:opacity:)

**Returns a shading instance that fills with a monochrome color in the given color space.**

```swift
static func color(
    _ colorSpace: Color.RGBColorSpace = .sRGB,
    white: Double,
    opacity: Double = 1
) -> GraphicsContext.Shading
```

**Parameters:**
- `colorSpace`: The RGB color space used to define the color. The default is `Color.RGBColorSpace.sRGB`.
- `white`: The value to use for each of the red, green, and blue components of the color.
- `opacity`: The opacity of the color. The default is 1, which means fully opaque.

**Return Value:**
A shading instance filled with a color.

---

## GraphicsContext Options and Modes

### GraphicsContext.GradientOptions.linearColor

**An option that interpolates between colors in a linear color space.**

```swift
static var linearColor: GraphicsContext.GradientOptions { get }
```

---

### GraphicsContext.BlendMode

#### colorBurn

**A mode that darkens background image samples to reflect the source image samples.**

```swift
static var colorBurn: GraphicsContext.BlendMode { get }
```

**Discussion:**

Source image sample values that specify white do not produce a change.

---

#### colorDodge

**A mode that brightens the background image samples to reflect the source image samples.**

```swift
static var colorDodge: GraphicsContext.BlendMode { get }
```

**Discussion:**

Source image sample values that specify black do not produce a change.

---

#### color

**A mode that uses the luminance values of the background with the hue and saturation values of the source image.**

```swift
static var color: GraphicsContext.BlendMode { get }
```

**Discussion:**

This mode preserves the gray levels in the image. You can use this mode to color monochrome images or to tint color images.

---

## GraphicsContext.Filter

### colorInvert(_:)

**Returns a filter that inverts the color of their results.**

```swift
static func colorInvert(_ amount: Double = 1) -> GraphicsContext.Filter
```

**Parameters:**
- `amount`: The inversion amount. A value of one results in total inversion, while a value of zero leaves the result unchanged. Other values apply a linear multiplier effect.

**Return Value:**
A filter that applies a color inversion.

**Discussion:**

This filter is equivalent to the invert filter primitive defined by the Scalable Vector Graphics (SVG) specification.

---

### colorMultiply(_:)

**Returns a filter that multiplies each color component by the matching component of a given color.**

```swift
static func colorMultiply(_ color: Color) -> GraphicsContext.Filter
```

**Parameters:**
- `color`: The color that the filter uses for the multiplication operation.

**Return Value:**
A filter that multiplies color components.

---

### colorMatrix(_:)

**Returns a filter that multiplies by a given color matrix.**

```swift
static func colorMatrix(_ matrix: ColorMatrix) -> GraphicsContext.Filter
```

**Parameters:**
- `matrix`: A `ColorMatrix` instance used by the filter.

**Return Value:**
A filter that transforms color using the given matrix.

**Discussion:**

This filter is equivalent to the `feColorMatrix` filter primitive defined by the Scalable Vector Graphics (SVG) specification.

The filter creates the output color `[R', G', B', A']` at each pixel from an input color `[R, G, B, A]` by multiplying the input color by the square matrix formed by the first four columns of the `ColorMatrix`, then adding the fifth column to the result:

```
R' = r1 ✕ R + r2 ✕ G + r3 ✕ B + r4 ✕ A + r5
G' = g1 ✕ R + g2 ✕ G + g3 ✕ B + g4 ✕ A + g5
B' = b1 ✕ R + b2 ✕ G + b3 ✕ B + b4 ✕ A + b5
A' = a1 ✕ R + a2 ✕ G + a3 ✕ B + a4 ✕ A + a5
```

---

### shadow(color:radius:x:y:blendMode:options:)

**Returns a filter that adds a shadow.**

```swift
static func shadow(
    color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
    radius: CGFloat,
    x: CGFloat = 0,
    y: CGFloat = 0,
    blendMode: GraphicsContext.BlendMode = .normal,
    options: GraphicsContext.ShadowOptions = ShadowOptions()
) -> GraphicsContext.Filter
```

**Parameters:**
- `color`: A `Color` that tints the shadow.
- `radius`: A measure of how far the shadow extends from the edges of the content receiving the shadow.
- `x`: An amount to translate the shadow horizontally.
- `y`: An amount to translate the shadow vertically.
- `blendMode`: The `GraphicsContext.BlendMode` to use when blending the shadow into the background layer.
- `options`: A set of options that you can use to customize the process of adding the shadow. Use one or more of the options in `GraphicsContext.ShadowOptions`.

**Return Value:**
A filter that adds a shadow style.

**Discussion:**

SwiftUI produces the shadow by blurring the alpha channel of the object receiving the shadow, multiplying the result by a color, optionally translating the shadow by an amount, and then blending the resulting shadow into a new layer below the source primitive. You can customize some of these steps by adding one or more shadow options.

---

### alphaThreshold(min:max:color:)

**Returns a filter that replaces each pixel with alpha components within a range by a constant color, or transparency otherwise.**

```swift
static func alphaThreshold(
    min: Double,
    max: Double = 1,
    color: Color = Color.black
) -> GraphicsContext.Filter
```

**Parameters:**
- `min`: The minimum alpha threshold. Pixels whose alpha component is less than this value will render as transparent. Results are undefined unless `min < max`.
- `max`: The maximum alpha threshold. Pixels whose alpha component is greater than this value will render as transparent. Results are undefined unless `min < max`.
- `color`: The color that is output for pixels with an alpha component between the two threshold values.

**Return Value:**
A filter that applies a threshold to alpha values.

---

### colorShader(_:)

**Returns a filter that applies shader to the color of each source pixel.**

```swift
static func colorShader(_ shader: Shader) -> GraphicsContext.Filter
```

**Parameters:**
- `shader`: The shader to apply to self as a color filter.

**Return Value:**
A filter that applies the shader as a color filter.

**Discussion:**

For a shader function to act as a color filter it must have a function signature matching:

```metal
[[ stitchable ]] half4 name(float2 position, half4 color, args...)
```

where `position` is the user-space coordinates of the pixel applied to the shader and `color` its source color, as a pre-multiplied color in the destination color space. `args...` should be compatible with the uniform arguments bound to `shader`. The function should return the modified color value.

---

### GraphicsContext.FilterOptions.linearColor

**An option that causes the filter to perform calculations in a linear color space.**

```swift
static var linearColor: GraphicsContext.FilterOptions { get }
```

---

## Color Structure

### Color.resolve(in:)

**Evaluates this color to a resolved color given the current context.**

```swift
func resolve(in environment: EnvironmentValues) -> Color.Resolved
```

---

### Color Initializers

#### init(_:white:opacity:)

**Creates a constant grayscale color.**

```swift
init(
    _ colorSpace: Color.RGBColorSpace = .sRGB,
    white: Double,
    opacity: Double = 1
)
```

**Parameters:**
- `colorSpace`: The profile that specifies how to interpret the color for display. The default is `Color.RGBColorSpace.sRGB`.
- `white`: A value that indicates how white the color is, with higher values closer to 100% white, and lower values closer to 100% black.
- `opacity`: An optional degree of opacity, given in the range 0 to 1. A value of 0 means 100% transparency, while a value of 1 means 100% opacity. The default is 1.

**Discussion:**

This initializer creates a constant color that doesn't change based on context. For example, it doesn't have distinct light and dark appearances, unlike various system-defined colors, or a color that you load from an Asset Catalog with `init(_:bundle:)`.

A standard sRGB color space clamps the white component to a range of 0 to 1, but SwiftUI colors use an extended sRGB color space, so you can use component values outside that range. This makes it possible to create colors using the `Color.RGBColorSpace.sRGB` or `Color.RGBColorSpace.sRGBLinear` color space that make full use of the wider gamut of a display that supports `Color.RGBColorSpace.displayP3`.

---

#### init(_:red:green:blue:opacity:)

**Creates a constant color from red, green, and blue component values.**

```swift
init(
    _ colorSpace: Color.RGBColorSpace = .sRGB,
    red: Double,
    green: Double,
    blue: Double,
    opacity: Double = 1
)
```

**Parameters:**
- `colorSpace`: The profile that specifies how to interpret the color for display. The default is `Color.RGBColorSpace.sRGB`.
- `red`: The amount of red in the color.
- `green`: The amount of green in the color.
- `blue`: The amount of blue in the color.
- `opacity`: An optional degree of opacity, given in the range 0 to 1. A value of 0 means 100% transparency, while a value of 1 means 100% opacity. The default is 1.

**Discussion:**

This initializer creates a constant color that doesn't change based on context. For example, it doesn't have distinct light and dark appearances, unlike various system-defined colors, or a color that you load from an Asset Catalog with `init(_:bundle:)`.

A standard sRGB color space clamps each color component — red, green, and blue — to a range of 0 to 1, but SwiftUI colors use an extended sRGB color space, so you can use component values outside that range. This makes it possible to create colors using the `Color.RGBColorSpace.sRGB` or `Color.RGBColorSpace.sRGBLinear` color space that make full use of the wider gamut of a display that supports `Color.RGBColorSpace.displayP3`.

---

## Color.RGBColorSpace

### Cases

#### sRGB

**The extended red, green, blue (sRGB) color space.**

```swift
case sRGB
```

**Discussion:**

For information about the sRGB colorimetry and nonlinear transform function, see the IEC 61966-2-1 specification.

Standard sRGB color spaces clamp the red, green, and blue components of a color to a range of 0 to 1, but SwiftUI colors use an extended sRGB color space, so you can use component values outside that range.

---

#### sRGBLinear

**The extended sRGB color space with a linear transfer function.**

```swift
case sRGBLinear
```

**Discussion:**

This color space has the same colorimetry as `Color.RGBColorSpace.sRGB`, but uses a linear transfer function.

Standard sRGB color spaces clamp the red, green, and blue components of a color to a range of 0 to 1, but SwiftUI colors use an extended sRGB color space, so you can use component values outside that range.

---

#### displayP3

**The Display P3 color space.**

```swift
case displayP3
```

**Discussion:**

This color space uses the Digital Cinema Initiatives - Protocol 3 (DCI-P3) primary colors, a D65 white point, and the `Color.RGBColorSpace.sRGB` transfer function.

---

## Platform-Specific Initializers

### init(uiColor:)

**Creates a color from a UIKit color.**

```swift
init(uiColor: UIColor)
```

**Discussion:**

Use this method to create a SwiftUI color from a `UIColor` instance. The new color preserves the adaptability of the original. For example, you can create a rectangle using `link` to see how the shade adjusts to match the user's system settings:

```swift
struct Box: View {
    var body: some View {
        Color(uiColor: .link)
            .frame(width: 200, height: 100)
    }
}
```

The `Box` view defined above automatically changes its appearance when the user turns on Dark Mode. With the light and dark appearances placed side by side, you can see the subtle difference in shades.

> **Note:** Use this initializer only if you need to convert an existing `UIColor` to a SwiftUI color. Otherwise, create a SwiftUI `Color` using an initializer like `init(_:red:green:blue:opacity:)`, or use a system color like `blue`.

---

### init(nsColor:)

**Creates a color from an AppKit color.**

```swift
nonisolated
init(nsColor: NSColor)
```

**Discussion:**

Use this method to create a SwiftUI color from an `NSColor` instance. The new color preserves the adaptability of the original. For example, you can create a rectangle using `linkColor` to see how the shade adjusts to match the user's system settings:

```swift
struct Box: View {
    var body: some View {
        Color(nsColor: .linkColor)
            .frame(width: 200, height: 100)
    }
}
```

The `Box` view defined above automatically changes its appearance when the user turns on Dark Mode. With the light and dark appearances placed side by side, you can see the subtle difference in shades.

> **Note:** Use this initializer only if you need to convert an existing `NSColor` to a SwiftUI color. Otherwise, create a SwiftUI `Color` using an initializer like `init(_:red:green:blue:opacity:)`, or use a system color like `blue`.

---

### init(cgColor:)

**Creates a color from a Core Graphics color.**

```swift
init(cgColor: CGColor)
```

---

## Standard Colors

### Type Properties

#### black

**A black color suitable for use in UI elements.**

```swift
static let black: Color
```

**See Also:**
- `blue`: A context-dependent blue color suitable for use in UI elements.
- `brown`: A context-dependent brown color suitable for use in UI elements.
- `clear`: A clear color suitable for use in UI elements.
- `cyan`: A context-dependent cyan color suitable for use in UI elements.
- `gray`: A context-dependent gray color suitable for use in UI elements.
- `green`: A context-dependent green color suitable for use in UI elements.
- `indigo`: A context-dependent indigo color suitable for use in UI elements.
- `mint`: A context-dependent mint color suitable for use in UI elements.
- `orange`: A context-dependent orange color suitable for use in UI elements.
- `pink`: A context-dependent pink color suitable for use in UI elements.
- `purple`: A context-dependent purple color suitable for use in UI elements.
- `red`: A context-dependent red color suitable for use in UI elements.
- `teal`: A context-dependent teal color suitable for use in UI elements.
- `white`: A white color suitable for use in UI elements.
- `yellow`: A context-dependent yellow color suitable for use in UI elements.

---

### Semantic Colors

#### accentColor

**A color that reflects the accent color of the system or app.**

```swift
static var accentColor: Color { get }
```

**Discussion:**

The accent color is a broad theme color applied to views and controls. You can set it at the application level by specifying an accent color in your app's asset catalog.

> **Note:** In macOS, SwiftUI applies customization of the accent color only if the user chooses Multicolor under General > Accent color in System Preferences.

The following code renders a `Text` view using the app's accent color:

```swift
Text("Accent Color")
    .foregroundStyle(Color.accentColor)
```

**See Also:**
- `primary`: The color to use for primary content.
- `secondary`: The color to use for secondary content.

---

## Color Methods

### opacity(_:)

**Multiplies the opacity of the color by the given amount.**

```swift
func opacity(_ opacity: Double) -> Color
```

**Parameters:**
- `opacity`: The amount by which to multiply the opacity of the color.

**Return Value:**
A view with modified opacity.

---

### mix(with:by:in:)

**Returns a version of self mixed with rhs by the amount specified by fraction.**

```swift
func mix(
    with rhs: Color,
    by fraction: Double,
    in colorSpace: Gradient.ColorSpace = .perceptual
) -> Color
```

**Parameters:**
- `rhs`: The color to mix self with.
- `fraction`: The amount of blending, 0.5 means self is mixed in equal parts with rhs.
- `colorSpace`: The color space used to mix the colors.

**Return Value:**
A new Color based on self and rhs.

---

### exposureAdjust(_:)

**Returns a new color with an exposure adjustment applied.**

```swift
func exposureAdjust(_ stops: Double) -> Color
```

**Parameters:**
- `stops`: The number of exposure levels to adjust by.

**Return Value:**
A new color with the exposure adjustment applied.

**Discussion:**

This function adjusts the exposure of a color by multiplying its linear-light representation by `pow(2, stops)` and adjusting its HDR content headroom.

For example, the system yellow color could have its brightness increased by two exposure levels:

```swift
Color.yellow.exposureAdjust(2)
```

---

### headroom(_:)

**Creates a new color with specified HDR content headroom.**

```swift
func headroom(_ headroom: Double?) -> Color
```

**Parameters:**
- `headroom`: The headroom value to associate with the new color.

**Return Value:**
A new color with the specified content headroom.

**Discussion:**

High Dynamic Range colors (those with RGB components outside the standard [0, 1] range) should be annotated with their headroom to ensure that they are displayed correctly. Knowing content headroom allows the rendering system to automatically increase display headroom when the color is displayed and to tone map the color when the available display headroom is insufficient to render the color as intended.

For example, a custom yellow color whose brightness has been increased by two exposure levels:

```swift
Color(.sRGB, red: 1.83, green: 1.47, blue: 0)
    .headroom(4)
```

> **Note:** Headroom is a linear quantity, and as such any color adjustments should typically be made in a linear color space.

---

### resolveHDR(in:)

**Evaluates this color to a resolved color with content headroom, given a set of environment values.**

```swift
func resolveHDR(in environment: EnvironmentValues) -> Color.ResolvedHDR
```

**Parameters:**
- `environment`: The environment of the view displaying the color.

**Return Value:**
The color's value in the sRGB color space.

---

## Color.ResolvedHDR

### init(_:headroom:)

**Initializes a new resolved color value.**

```swift
init(
    _ color: Color.Resolved,
    headroom: Float? = nil
)
```

**Parameters:**
- `color`: The resolved color to initialize from.
- `headroom`: The optional content headroom of the color.

---

### Properties

#### red

**The amount of red in the color in the extended sRGB color space.**

```swift
var red: Float { get set }
```

**See Also:**
- `green`: The amount of green in the color in the extended sRGB color space.
- `blue`: The amount of blue in the color in the extended sRGB color space.
- `linearRed`: The amount of red in the color in the extended sRGB color space variant with linear gamma.
- `linearGreen`: The amount of green in the color in the extended sRGB color space variant with linear gamma.
- `linearBlue`: The amount of blue in the color in the extended sRGB color space variant with linear gamma.
- `opacity`: The opacity of the color, in the range 0 to 1.
- `headroom`: The content headroom of the color.

---

### description

**A textual representation of the color.**

```swift
var description: String { get }
```

**Discussion:**

Use this method to get a string that represents the color. The `print(_:separator:terminator:)` function uses this property to get a string representing an instance:

```swift
print(Color.red)
// Prints "red"
```

---

## Equality

### ==(_:_:)

**Indicates whether two colors are equal.**

```swift
static func == (lhs: Color, rhs: Color) -> Bool
```

**Parameters:**
- `lhs`: The first color to compare.
- `rhs`: The second color to compare.

**Return Value:**
A Boolean that's set to `true` if the two colors are equal.

---

## Color.Resolved

### Color.Resolved Structure

**A concrete color value.**

```swift
@frozen
struct Resolved
```

**Overview:**

`Color.Resolved` is a set of RGBA values that represent a color that can be shown. The values are stored in the Linear sRGB color space, using extended range. This is a low-level type, most colors are represented by the `Color` type.

**See Also:** `Color.ResolvedHDR`, `Color`

#### Initializers

##### init(colorSpace:red:green:blue:opacity:)

**Creates a resolved color from red, green, and blue component values.**

```swift
init(
    colorSpace: Color.RGBColorSpace = .sRGB,
    red: Float,
    green: Float,
    blue: Float,
    opacity: Float = 1
)
```

**Parameters:**
- `colorSpace`: The profile that specifies how to interpret the color for display. The default is `Color.RGBColorSpace.sRGB`.
- `red`: The amount of red in the color.
- `green`: The amount of green in the color.
- `blue`: The amount of blue in the color.
- `opacity`: An optional degree of opacity, given in the range 0 to 1. A value of 0 means 100% transparency, while a value of 1 means 100% opacity. The default is 1.

**Discussion:**

A standard sRGB color space clamps each color component — red, green, and blue — to a range of 0 to 1, but SwiftUI colors use an extended sRGB color space, so you can use component values outside that range. This makes it possible to create colors using the `Color.RGBColorSpace.sRGB` or `Color.RGBColorSpace.sRGBLinear` color space that make full use of the wider gamut of a display that supports `Color.RGBColorSpace.displayP3`.

#### Instance Properties

- `blue`: The amount of blue in the color in the sRGB color space.
- `cgColor`: A Core Graphics representation of the color.
- `green`: The amount of green in the color in the sRGB color space.
- `linearBlue`: The amount of blue in the color in the sRGB linear color space.
- `linearGreen`: The amount of green in the color in the sRGB linear color space.
- `linearRed`: The amount of red in the color in the sRGB linear color space.
- `opacity`: The degree of opacity in the color, given in the range 0 to 1.
- `red`: The amount of red in the color in the sRGB color space.

---

### cgColor

**A Core Graphics representation of the color.**

```swift
var cgColor: CGColor { get }
```

**Discussion:**

You can get a `CGColor` instance from a resolved color.

---

## ShapeStyle Color Methods

### System Colors (Available when Self is Color)

**A black color suitable for use in UI elements.**

```swift
static var black: Color { get }
```

**See Also:**
- `blue`: A context-dependent blue color suitable for use in UI elements.
- `brown`: A context-dependent brown color suitable for use in UI elements.
- `clear`: A clear color suitable for use in UI elements.
- `cyan`: A context-dependent cyan color suitable for use in UI elements.
- `gray`: A context-dependent gray color suitable for use in UI elements.
- `green`: A context-dependent green color suitable for use in UI elements.
- `indigo`: A context-dependent indigo color suitable for use in UI elements.
- `mint`: A context-dependent mint color suitable for use in UI elements.
- `orange`: A context-dependent orange color suitable for use in UI elements.
- `pink`: A context-dependent pink color suitable for use in UI elements.
- `purple`: A context-dependent purple color suitable for use in UI elements.
- `red`: A context-dependent red color suitable for use in UI elements.
- `teal`: A context-dependent teal color suitable for use in UI elements.
- `white`: A white color suitable for use in UI elements.
- `yellow`: A context-dependent yellow color suitable for use in UI elements.

---

## Gradient Methods

### angularGradient(colors:center:startAngle:endAngle:)

**An angular gradient defined by a collection of colors.**

```swift
static func angularGradient(
    colors: [Color],
    center: UnitPoint,
    startAngle: Angle,
    endAngle: Angle
) -> AngularGradient
```

**Available when Self is AngularGradient.**

**Parameters:**
- `colors`: The colors of the gradient, evenly spaced along its full length.
- `center`: The relative center of the gradient, mapped from the unit space into the bounding rectangle of the filled shape.
- `startAngle`: The angle that marks the beginning of the gradient.
- `endAngle`: The angle that marks the end of the gradient.

**Discussion:**

For more information on how to use angular gradients, see `angularGradient(_:center:startAngle:endAngle:)`.

---

### conicGradient(colors:center:angle:)

**A conic gradient defined by a collection of colors that completes a full turn.**

```swift
static func conicGradient(
    colors: [Color],
    center: UnitPoint,
    angle: Angle = .zero
) -> AngularGradient
```

**Available when Self is AngularGradient.**

**Parameters:**
- `colors`: The colors of the gradient, evenly spaced along its full length.
- `center`: The relative center of the gradient, mapped from the unit space into the bounding rectangle of the filled shape.
- `angle`: The angle to offset the beginning of the gradient's full turn.

**Discussion:**

For more information on how to use conic gradients, see `conicGradient(_:center:angle:)`.

---

### ellipticalGradient(colors:center:startRadiusFraction:endRadiusFraction:)

**A radial gradient that draws an ellipse defined by a collection of colors.**

```swift
static func ellipticalGradient(
    colors: [Color],
    center: UnitPoint = .center,
    startRadiusFraction: CGFloat = 0,
    endRadiusFraction: CGFloat = 0.5
) -> EllipticalGradient
```

**Available when Self is EllipticalGradient.**

**Discussion:**

The gradient maps its coordinate space to the unit space square in which its center and radii are defined, then stretches that square to fill its bounding rect, possibly also stretching the circular gradient to have elliptical contours.

For example, an elliptical gradient used as a background:

```swift
.background(.elliptical(colors: [.red, .yellow]))
```

For information about how to use shape styles, see `ShapeStyle`.

---

### linearGradient(colors:startPoint:endPoint:)

**A linear gradient defined by a collection of colors.**

```swift
static func linearGradient(
    colors: [Color],
    startPoint: UnitPoint,
    endPoint: UnitPoint
) -> LinearGradient
```

**Available when Self is LinearGradient.**

**Discussion:**

The gradient applies the color function along an axis, as defined by its start and end points. The gradient maps the unit space points into the bounding rectangle of each shape filled with the gradient.

For information about how to use shape styles, see `ShapeStyle`.

---

### radialGradient(colors:center:startRadius:endRadius:)

**A radial gradient defined by a collection of colors.**

```swift
static func radialGradient(
    colors: [Color],
    center: UnitPoint,
    startRadius: CGFloat,
    endRadius: CGFloat
) -> RadialGradient
```

**Available when Self is RadialGradient.**

**Discussion:**

The gradient applies the color function as the distance from a center point, scaled to fit within the defined start and end radii. The gradient maps the unit space center point into the bounding rectangle of each shape filled with the gradient.

For information about how to use shape styles, see `ShapeStyle`.

---

## Gradient Initializers

### Angular Gradient

#### init(colors:center:angle:)

**Creates a conic gradient from a collection of colors that completes a full turn.**

```swift
init(
    colors: [Color],
    center: UnitPoint,
    angle: Angle = .zero
)
```

---

#### init(colors:center:startAngle:endAngle:)

**Creates an angular gradient from a collection of colors.**

```swift
init(
    colors: [Color],
    center: UnitPoint,
    startAngle: Angle,
    endAngle: Angle
)
```

---

## MeshGradient

### MeshGradient Initializers

#### init(width:height:bezierPoints:colors:background:smoothsColors:colorSpace:)

**Creates a new gradient mesh specified as a 2D grid of colored points, specifying the Bezier control points explicitly.**

```swift
init(
    width: Int,
    height: Int,
    bezierPoints: [MeshGradient.BezierPoint],
    colors: [Color],
    background: Color = .clear,
    smoothsColors: Bool = true,
    colorSpace: Gradient.ColorSpace = .device
)
```

**Parameters:**
- `width`: The width of the mesh, i.e. the number of vertices per row.
- `height`: The height of the mesh, i.e. the number of vertices per column.
- `bezierPoints`: The array of points and control points, containing width x height elements.
- `colors`: The array of colors, containing width x height elements.
- `background`: The background color, this fills any points outside the defined vertex mesh.
- `smoothsColors`: Whether cubic (smooth) interpolation should be used for the colors in the mesh (rather than only for the shape of the mesh).
- `colorSpace`: The color space in which to interpolate vertex colors.

---

#### init(width:height:bezierPoints:resolvedColors:background:smoothsColors:colorSpace:)

**Creates a new gradient mesh specified as a 2D grid of colored points, specifying the Bezier control points explicitly, with already-resolved sRGB colors.**

```swift
init(
    width: Int,
    height: Int,
    bezierPoints: [MeshGradient.BezierPoint],
    resolvedColors: [Color.Resolved],
    background: Color = .clear,
    smoothsColors: Bool = true,
    colorSpace: Gradient.ColorSpace = .device
)
```

**Parameters:**
- `width`: The width of the mesh, i.e. the number of vertices per row.
- `height`: The height of the mesh, i.e. the number of vertices per column.
- `bezierPoints`: The array of points and control points, containing width x height elements.
- `resolvedColors`: The array of colors, containing width x height elements.
- `background`: The background color, this fills any points outside the defined vertex mesh.
- `smoothsColors`: Whether cubic (smooth) interpolation should be used for the colors in the mesh (rather than only for the shape of the mesh).
- `colorSpace`: The color space in which to interpolate vertex colors.

---

#### init(width:height:locations:colors:background:smoothsColors:colorSpace:)

**Creates a new gradient mesh specified as a 2D grid of colored vertices.**

```swift
init(
    width: Int,
    height: Int,
    locations: MeshGradient.Locations,
    colors: MeshGradient.Colors,
    background: Color = .clear,
    smoothsColors: Bool = true,
    colorSpace: Gradient.ColorSpace = .device
)
```

**Parameters:**
- `width`: The width of the mesh, i.e. the number of vertices per row.
- `height`: The height of the mesh, i.e. the number of vertices per column.
- `locations`: The array of locations, containing width x height elements.
- `colors`: The array of colors, containing width x height elements.
- `background`: The background color, this fills any points outside the defined vertex mesh.
- `smoothsColors`: Whether cubic (smooth) interpolation should be used for the colors in the mesh (rather than only for the shape of the mesh).
- `colorSpace`: The color space in which to interpolate vertex colors.

---

### MeshGradient Properties

#### background

**The background color, this fills any points outside the defined vertex mesh.**

```swift
var background: Color
```

---

#### colorSpace

**The color space in which to interpolate vertex colors.**

```swift
var colorSpace: Gradient.ColorSpace
```

---

#### smoothsColors

**Whether cubic (smooth) interpolation should be used for the colors in the mesh (rather than only for the shape of the mesh).**

```swift
var smoothsColors: Bool
```

---

### MeshGradient.Colors

#### Cases

##### colors(_:)

```swift
case colors([Color])
```

##### resolvedColors(_:)

```swift
case resolvedColors([Color.Resolved])
```

---

## AnyGradient

### colorSpace(_:)

**Returns a version of the gradient that will use a specified color space for interpolating between its colors.**

```swift
func colorSpace(_ space: Gradient.ColorSpace) -> AnyGradient
```

**Parameters:**
- `space`: The color space the new gradient will use to interpolate its constituent colors.

**Return Value:**
A new gradient that interpolates its colors in the specified color space.

**Discussion:**

```swift
Rectangle().fill(.linearGradient(
    colors: [.white, .blue]).colorSpace(.perceptual))
```

---

## ShadowStyle

### drop(color:radius:x:y:)

**Creates a custom drop shadow style.**

```swift
static func drop(
    color: Color = .init(.sRGBLinear, white: 0, opacity: 0.33),
    radius: CGFloat,
    x: CGFloat = 0,
    y: CGFloat = 0
) -> ShadowStyle
```

**Parameters:**
- `color`: The shadow's color.
- `radius`: The shadow's size.
- `x`: A horizontal offset you use to position the shadow relative to this view.
- `y`: A vertical offset you use to position the shadow relative to this view.

**Return Value:**
A new shadow style.

**Discussion:**

Drop shadows draw behind the source content by blurring, tinting and offsetting its per-pixel alpha values.

---

### inner(color:radius:x:y:)

**Creates a custom inner shadow style.**

```swift
static func inner(
    color: Color = .init(.sRGBLinear, white: 0, opacity: 0.55),
    radius: CGFloat,
    x: CGFloat = 0,
    y: CGFloat = 0
) -> ShadowStyle
```

**Parameters:**
- `color`: The shadow's color.
- `radius`: The shadow's size.
- `x`: A horizontal offset you use to position the shadow relative to this view.
- `y`: A vertical offset you use to position the shadow relative to this view.

**Return Value:**
A new shadow style.

**Discussion:**

Inner shadows draw on top of the source content by blurring, tinting, inverting and offsetting its per-pixel alpha values.

---

## Glass Structure

### Glass

**A structure that defines the configuration of the Liquid Glass material.**

```swift
struct Glass
```

**Overview:**

You provide instances of a variant of Liquid Glass to the `glassEffect(_:in:)` view modifier:

```swift
Text("Hello, World!")
    .font(.title)
    .padding()
    .glassEffect()
```

You can combine Liquid Glass effects using a `GlassEffectContainer`, which supports morphing views with this effect into each other based on the geometry of their associated views.

#### Instance Methods

##### interactive(_:)

**Returns a copy of the structure configured to be interactive.**

```swift
func interactive(Bool) -> Glass
```

##### tint(_:)

**Returns a copy of the structure with a configured tint color.**

```swift
func tint(_ color: Color?) -> Glass
```

#### Type Properties

##### clear

**The clear variant of glass.**

```swift
static var clear: Glass
```

##### identity

**The identity variant of glass.**

```swift
static var identity: Glass
```

**Discussion:**

When applied, your content remains unaffected as if no glass effect was applied.

##### regular

**The regular variant of the Liquid Glass material.**

```swift
static var regular: Glass
```

**Conforms To:** `Equatable`, `Sendable`, `SendableMetatype`

---

## Visual Effects

### colorEffect(_:isEnabled:)

**Returns a new visual effect that applies shader to self as a filter effect on the color of each pixel.**

```swift
func colorEffect(
    _ shader: Shader,
    isEnabled: Bool = true
) -> some VisualEffect
```

**Parameters:**
- `shader`: The shader to apply to self as a color filter.
- `isEnabled`: Whether the effect is enabled or not.

**Return Value:**
A new view that renders self with the shader applied as a color filter.

**Discussion:**

For a shader function to act as a color filter it must have a function signature matching:

```metal
[[ stitchable ]] half4 name(float2 position, half4 color, args...)
```

where `position` is the user-space coordinates of the pixel applied to the shader and `color` its source color, as a pre-multiplied color in the destination color space. `args...` should be compatible with the uniform arguments bound to `shader`. The function should return the modified color value.

> **Important:** Views backed by AppKit or UIKit views may not render into the filtered layer. Instead, they log a warning and display a placeholder image to highlight the error.

---

## BlendMode

### BlendMode Cases

#### colorBurn

```swift
case colorBurn
```

#### colorDodge

```swift
case colorDodge
```

#### color

```swift
case color
```

---

## ColorRenderingMode

### ColorRenderingMode Enumeration

**The set of possible working color spaces for color-compositing operations.**

```swift
enum ColorRenderingMode
```

**Overview:**

Each color space guarantees the preservation of a particular range of color values.

#### Cases

##### extendedLinear

**The extended linear sRGB working color space.**

```swift
case extendedLinear
```

##### linear

**The linear sRGB working color space.**

```swift
case linear
```

##### nonLinear

**The non-linear sRGB working color space.**

```swift
case nonLinear
```

**Conforms To:** `Copyable`, `Equatable`, `Hashable`, `Sendable`, `SendableMetatype`

---

## Shader

### Shader.Argument Methods

#### color(_:)

**Returns an argument value representing color.**

```swift
static func color(_ color: Color) -> Shader.Argument
```

**Discussion:**

When passed to a MSL function it will convert to a `half4` value, as a premultiplied color in the target color space.

**See Also:**
- `boundingRect`: Returns an argument value representing the bounding rect of the shape or view.
- `colorArray([Color])`: Returns an argument value defined by the provided array of color values.
- `data(Data)`: Returns an argument value defined by the provided data value.
- `float<T>(T)`: Returns an argument value representing the MSL value `float(x)`.
- `float2(_:)`: Returns an argument value representing the MSL value `float2(point.x, point.y)`.
- `float2<T>(T, T)`: Returns an argument value representing the MSL value `float2(x, y)`.
- `float3<T>(T, T, T)`: Returns an argument value representing the MSL value `float3(x, y, z)`.
- `float4<T>(T, T, T, T)`: Returns an argument value representing the MSL value `float4(x, y, z, w)`.
- `floatArray([Float])`: Returns an argument value defined by the provided array of floating point numbers.
- `image(Image)`: Returns an argument value defined by the provided image.

---

#### colorArray(_:)

**Returns an argument value defined by the provided array of color values.**

```swift
static func colorArray(_ array: [Color]) -> Shader.Argument
```

**Discussion:**

When passed to an MSL function it will convert to a `device const half4 *ptr, int count` pair of parameters.

---

### Shader Properties

#### dithersColor

**For shader functions that return color values, whether the returned color has dither noise added to it, or is simply rounded to the output bit-depth.**

```swift
var dithersColor: Bool { get set }
```

**Discussion:**

For shaders generating smooth gradients, dithering is usually necessary to prevent visible banding in the result.

---

### Shader.UsageType

#### colorEffect

**The shader will be used as a color effect.**

```swift
static let colorEffect: Shader.UsageType
```

---

## ListItemTint

### fixed(_:)

**An explicit tint color.**

```swift
static func fixed(_ tint: Color) -> ListItemTint
```

**Parameters:**
- `tint`: The color to use to tint the content.

**Discussion:**

The system doesn't override this tint effect.

---

### preferred(_:)

**An explicit tint color that the system can override.**

```swift
static func preferred(_ tint: Color) -> ListItemTint
```

**Parameters:**
- `tint`: The color to use to tint the content.

**Discussion:**

The system can override this tint effect, like when the system has a custom user accent color on macOS.

---

## PencilPreferredAction

### showColorPalette

**An action that toggles the display of the color palette.**

```swift
static let showColorPalette: PencilPreferredAction
```

---

## Summary

This comprehensive documentation covers all SwiftUI color and color scheme APIs, including:

- **View modifiers** for color schemes, styling, and effects
- **Environment properties** for color scheme detection
- **Accessibility features** for differentiation and inversion
- **Color initializers** for various color spaces
- **Platform-specific** color conversions (UIKit, AppKit, Core Graphics)
- **Gradient types** and configurations
- **Shadow styles** for drop and inner shadows
- **Shader integration** for custom color effects
- **Live Activity** styling options
- **List customization** with separator tints
- **Text styling** with colors for underlines and strikethroughs

All APIs include detailed parameter descriptions, return values, usage examples, and important notes for proper implementation.
