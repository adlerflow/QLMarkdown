# Highlight/Mark Extension Test

## Basic Highlight

This is ==highlighted text== in a paragraph.

==This entire paragraph is highlighted.==

## Highlight with Other Formatting

==Highlighted text with **bold**==
==Highlighted text with *italic*==
==Highlighted text with `code`==

**Bold with ==highlight== inside**
*Italic with ==highlight== inside*

## Multiple Highlights

This has ==first== and ==second== highlights.

==First paragraph.==

==Second paragraph.==

## Highlight in Lists

- Item with ==highlight==
- ==Entire item highlighted==
- Normal item

1. Ordered with ==highlight==
2. ==Entire ordered item==
3. Normal

## Highlight in Blockquotes

> This quote has ==highlighted text==
>
> ==This entire line is highlighted==

## Edge Cases

===Triple equals=== (should it work?)

=Single equals is not highlight=

==Highlight across
multiple lines should work==

==Nested ==highlight== doesn't work==
