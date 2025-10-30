Build from source

When you clone this repository, remember to fetch also the submodule with git submodule update --init.

Some libraries (Sparkle, Yams and SwiftSoup) are handled by the Swift Package Manager. In case of problems it might be useful to reset the cache with the command from the menu File/Packages/Reset Package Caches.

Dependency

The app uses the following libraries built directly from Xcode:

highlight for syntax highlighting.
magic, used to guess the source code language when the guess mode is set to simple.
Enry, used to guess the source code language when the guess mode is set to accurate.
PCRE2 and JPCRE2 used by the heads extension.
libpcre require the autoconf utility to be build. You can install it with homebrew:

brew install autoconf
Because Enry is developed in go, to build the wrapper library you must have the go compiler installed (you can use brew install go).

The compilation of cmark-gfm require cmake (brew install cmake).

Note about security

To allow the Quick Look view of local images the application and the extension has an entitlement exception to allow only read access to the entire system.

On Big Sur there is a bug in the Quick Look engine and WebKit that cause the immediate crash of any WebView inside a Quick Look preview. To temporary fix this problem this Quick Look extension uses a com.apple.security.temporary-exception.mach-lookup.global-name entitlement.