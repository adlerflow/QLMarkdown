# Footnotes Test

## Basic Footnotes

This is a sentence with a footnote.[^1]

Another sentence with a different footnote.[^2]

[^1]: This is the first footnote.
[^2]: This is the second footnote.

## Named Footnotes

Here is a named footnote.[^note-name]

And another one.[^my-footnote]

[^note-name]: This is a named footnote.
[^my-footnote]: Another named footnote.

## Multiple References

This references footnote 1.[^ref]
This also references footnote 1.[^ref]
And this too.[^ref]

[^ref]: This footnote is referenced multiple times.

## Footnotes with Formatting

Footnote with formatting.[^fmt]

[^fmt]: This footnote has **bold**, *italic*, and `code`.

## Multi-line Footnotes

Here is a complex footnote.[^complex]

[^complex]: This footnote spans multiple paragraphs.

    It continues here with proper indentation.

    And even has a third paragraph!

## Footnotes with Links

Reference with link.[^link]

[^link]: See [this article](https://example.com) for more info.

## Footnotes in Different Contexts

**Bold text with footnote[^b]**

*Italic text with footnote[^i]*

> Blockquote with footnote[^q]

[^b]: Footnote from bold text.
[^i]: Footnote from italic text.
[^q]: Footnote from blockquote.

## Edge Cases

Undefined reference.[^undefined]

[^unused]: This footnote is defined but never referenced.

[^1]: Duplicate footnote definition (first one wins).
[^1]: This should be ignored.

## Mixed Numeric and Named

First numeric.[^1]
Then named.[^alpha]
Then numeric again.[^2]

[^1]: First footnote.
[^alpha]: Named footnote.
[^2]: Second footnote.
