import SwiftUI

/// Pure Swift Syntax Highlighter (ersetzt highlight.js)
enum SwiftHighlighter {
    /// Highlight code with syntax colors
    static func highlight(
        code: String,
        language: String,
        theme: String
    ) -> AttributedString {
        let tokens = tokenize(code: code, language: language)
        let colors = Theme.colors(for: theme)

        var result = AttributedString()
        for token in tokens {
            var attributed = AttributedString(token.text)
            attributed.foregroundColor = colors[token.type] ?? .primary
            result += attributed
        }

        return result
    }

    // MARK: - Tokenization

    private static func tokenize(code: String, language: String) -> [Token] {
        switch language.lowercased() {
        case "swift":
            return tokenizeSwift(code)
        case "python", "py":
            return tokenizePython(code)
        case "javascript", "js", "typescript", "ts":
            return tokenizeJavaScript(code)
        case "html", "xml":
            return tokenizeHTML(code)
        case "css":
            return tokenizeCSS(code)
        default:
            // Fallback: no highlighting
            return [Token(text: code, type: .plain)]
        }
    }

    // MARK: - Swift Tokenizer

    private static func tokenizeSwift(_ code: String) -> [Token] {
        var tokens: [Token] = []
        let keywords = Set([
            "func", "let", "var", "if", "else", "return", "import", "struct",
            "class", "enum", "protocol", "extension", "private", "public",
            "internal", "static", "mutating", "override", "init", "deinit",
            "guard", "switch", "case", "break", "continue", "for", "while",
            "in", "as", "is", "self", "Self", "true", "false", "nil"
        ])

        var currentWord = ""
        var inString = false
        var inComment = false

        for char in code {
            if inComment {
                currentWord.append(char)
                if char == "\n" {
                    tokens.append(Token(text: currentWord, type: .comment))
                    currentWord = ""
                    inComment = false
                }
            } else if inString {
                currentWord.append(char)
                if char == "\"" {
                    tokens.append(Token(text: currentWord, type: .string))
                    currentWord = ""
                    inString = false
                }
            } else if currentWord.starts(with: "//") {
                currentWord.append(char)
                inComment = true
            } else if char == "\"" {
                if !currentWord.isEmpty {
                    tokens.append(tokenForWord(currentWord, keywords: keywords))
                    currentWord = ""
                }
                currentWord.append(char)
                inString = true
            } else if char.isWhitespace || char.isPunctuation {
                if !currentWord.isEmpty {
                    tokens.append(tokenForWord(currentWord, keywords: keywords))
                    currentWord = ""
                }
                tokens.append(Token(text: String(char), type: .plain))
            } else {
                currentWord.append(char)
            }
        }

        if !currentWord.isEmpty {
            if inComment {
                tokens.append(Token(text: currentWord, type: .comment))
            } else if inString {
                tokens.append(Token(text: currentWord, type: .string))
            } else {
                tokens.append(tokenForWord(currentWord, keywords: keywords))
            }
        }

        return tokens
    }

    private static func tokenForWord(_ word: String, keywords: Set<String>) -> Token {
        if keywords.contains(word) {
            return Token(text: word, type: .keyword)
        } else if word.first?.isNumber ?? false {
            return Token(text: word, type: .number)
        } else if word.first?.isUppercase ?? false {
            return Token(text: word, type: .type)
        } else {
            return Token(text: word, type: .plain)
        }
    }

    // MARK: - Python Tokenizer

    private static func tokenizePython(_ code: String) -> [Token] {
        let keywords = Set([
            "def", "class", "if", "elif", "else", "for", "while", "return",
            "import", "from", "as", "try", "except", "finally", "with",
            "lambda", "pass", "break", "continue", "True", "False", "None"
        ])

        var tokens: [Token] = []
        var currentWord = ""
        var inString = false
        var inComment = false

        for char in code {
            if inComment {
                currentWord.append(char)
                if char == "\n" {
                    tokens.append(Token(text: currentWord, type: .comment))
                    currentWord = ""
                    inComment = false
                }
            } else if inString {
                currentWord.append(char)
                if char == "\"" || char == "'" {
                    tokens.append(Token(text: currentWord, type: .string))
                    currentWord = ""
                    inString = false
                }
            } else if char == "#" {
                if !currentWord.isEmpty {
                    tokens.append(tokenForWord(currentWord, keywords: keywords))
                    currentWord = ""
                }
                currentWord.append(char)
                inComment = true
            } else if char == "\"" || char == "'" {
                if !currentWord.isEmpty {
                    tokens.append(tokenForWord(currentWord, keywords: keywords))
                    currentWord = ""
                }
                currentWord.append(char)
                inString = true
            } else if char.isWhitespace || char.isPunctuation {
                if !currentWord.isEmpty {
                    tokens.append(tokenForWord(currentWord, keywords: keywords))
                    currentWord = ""
                }
                tokens.append(Token(text: String(char), type: .plain))
            } else {
                currentWord.append(char)
            }
        }

        if !currentWord.isEmpty {
            tokens.append(tokenForWord(currentWord, keywords: keywords))
        }

        return tokens
    }

    // MARK: - JavaScript Tokenizer

    private static func tokenizeJavaScript(_ code: String) -> [Token] {
        let keywords = Set([
            "function", "const", "let", "var", "if", "else", "return",
            "class", "extends", "import", "export", "from", "async", "await",
            "for", "while", "switch", "case", "break", "continue", "true",
            "false", "null", "undefined", "this", "new", "typeof"
        ])

        // Similar logic to Swift tokenizer
        var tokens: [Token] = []
        var currentWord = ""

        for char in code {
            if char.isWhitespace || char.isPunctuation {
                if !currentWord.isEmpty {
                    tokens.append(tokenForWord(currentWord, keywords: keywords))
                    currentWord = ""
                }
                tokens.append(Token(text: String(char), type: .plain))
            } else {
                currentWord.append(char)
            }
        }

        if !currentWord.isEmpty {
            tokens.append(tokenForWord(currentWord, keywords: keywords))
        }

        return tokens
    }

    // MARK: - HTML/XML Tokenizer (Basic)

    private static func tokenizeHTML(_ code: String) -> [Token] {
        // TODO: Implement proper HTML tag parsing
        return [Token(text: code, type: .plain)]
    }

    // MARK: - CSS Tokenizer (Basic)

    private static func tokenizeCSS(_ code: String) -> [Token] {
        // TODO: Implement CSS selector/property parsing
        return [Token(text: code, type: .plain)]
    }

    // MARK: - Token Model

    struct Token {
        let text: String
        let type: TokenType
    }

    enum TokenType {
        case plain
        case keyword
        case string
        case comment
        case number
        case type
        case function
        case operator
    }

    // MARK: - Theme Colors

    enum Theme {
        static func colors(for theme: String) -> [TokenType: Color] {
            switch theme {
            case "github-dark":
                return [
                    .keyword: Color(red: 1.0, green: 0.47, blue: 0.42),
                    .string: Color(red: 0.64, green: 0.86, blue: 0.64),
                    .comment: Color(red: 0.5, green: 0.5, blue: 0.5),
                    .number: Color(red: 0.7, green: 0.85, blue: 1.0),
                    .type: Color(red: 0.85, green: 0.85, blue: 0.5),
                    .function: Color(red: 0.68, green: 0.77, blue: 1.0),
                    .plain: Color.primary
                ]
            case "github-light":
                return [
                    .keyword: Color(red: 0.82, green: 0.1, blue: 0.25),
                    .string: Color(red: 0.03, green: 0.52, blue: 0.03),
                    .comment: Color(red: 0.4, green: 0.4, blue: 0.4),
                    .number: Color(red: 0.0, green: 0.4, blue: 0.8),
                    .type: Color(red: 0.4, green: 0.2, blue: 0.0),
                    .function: Color(red: 0.5, green: 0.0, blue: 0.8),
                    .plain: Color.primary
                ]
            default:
                return [.plain: .primary]
            }
        }
    }
}
