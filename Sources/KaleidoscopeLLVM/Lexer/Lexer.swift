import Foundation

class Lexer {
    private let input: String

    private var iterator: String.Iterator
    private var currentChar: Character?

    init(input: String) {
        self.input = input

        self.iterator = input.makeIterator()
        goToNextChar()
    }

    func getTokens() -> [Token] {
        var tokens: [Token] = []

        while let token = nextToken() {
            tokens.append(token)
        }

        return tokens
    }
}

// MARK: - Private
private extension Lexer {

    static var oneCharacterTokenMap: [Character: Token] = [
        Punctuation.leftParen.rawValue: .punctuation(.leftParen),
        Punctuation.rightParen.rawValue: .punctuation(.rightParen),
        Punctuation.comma.rawValue: .punctuation(.comma),
        Punctuation.semicolon.rawValue: .punctuation(.semicolon),
        BinaryOperator.plus.rawValue: .operator(.plus),
        BinaryOperator.minus.rawValue: .operator(.minus),
        BinaryOperator.multiply.rawValue: .operator(.multiply),
        BinaryOperator.divide.rawValue: .operator(.divide),
        BinaryOperator.mod.rawValue: .operator(.mod)
    ]

    func nextToken() -> Token? {
        // skip whitespaces
        while let char = currentChar, char.isSpace {
            goToNextChar()
        }

        guard let char = currentChar else {
            return nil
        }

        // skip comment
        if char.isSharp {
            while let char = currentChar, !char.isNewline {
                goToNextChar()
            }
        }

        // check for one-character tokens
        if let oneCharacterToken = Lexer.oneCharacterTokenMap[char] {
            goToNextChar()
            return oneCharacterToken
        }

        // check for identifier or keyword
        if char.isAlpha {
            var identifier = String()

            while let char = currentChar, char.isAlphanumeric {
                identifier.append(char)
                goToNextChar()
            }

            // check for keywords
            if identifier == Keyword.def.rawValue { return .keyword(.def) }
            if identifier == Keyword.extern.rawValue { return .keyword(.extern) }
            if identifier == Keyword.if.rawValue { return .keyword(.if) }
            if identifier == Keyword.then.rawValue { return .keyword(.then) }
            if identifier == Keyword.else.rawValue { return .keyword(.else) }

            return .identifier(identifier)
        }

        // check for number
        if char.isDigit {
            var number = String()

            while let char = currentChar, char.isDigit || char.isDot  {
                number.append(char)
                goToNextChar()
            }

            if let numberDoubleValue = Double(number) {
                return .number(numberDoubleValue)
            } else {
                // TODO: invalid token?
            }
        }

        return nil
    }

    func goToNextChar() {
        currentChar = iterator.next()
    }
}

// MARK: - Character helper
private extension Character {

    var isSharp: Bool {
        return self == "#"
    }

    var isDot: Bool {
        return self == "."
    }

    var isSpace: Bool {
        return asciiValue
            .map(Int32.init)
            .map(isspace)
            .map { $0 != 0 } ?? false
    }

    var isAlpha: Bool {
        return asciiValue
            .map(Int32.init)
            .map(isalpha)
            .map { $0 != 0 } ?? false
    }

    var isAlphanumeric: Bool {
        return asciiValue
            .map(Int32.init)
            .map(isalnum)
            .map { $0 != 0 } ?? false
    }

    var isDigit: Bool {
        return asciiValue
            .map(Int32.init)
            .map(isnumber)
            .map { $0 != 0 } ?? false
    }
}
