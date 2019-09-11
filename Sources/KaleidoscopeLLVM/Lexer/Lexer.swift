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

private extension Lexer {

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
        // Punctuation
        if char == Punctuation.leftParen.rawValue { goToNextChar(); return .punctuation(.leftParen) }
        if char == Punctuation.rightParen.rawValue { goToNextChar(); return .punctuation(.rightParen) }
        if char == Punctuation.comma.rawValue { goToNextChar(); return .punctuation(.comma) }
        if char == Punctuation.semicolon.rawValue { goToNextChar(); return .punctuation(.semicolon) }
        // BinaryOperator
        if char == BinaryOperator.plus.rawValue { goToNextChar(); return .operator(.plus) }
        if char == BinaryOperator.minus.rawValue { goToNextChar(); return .operator(.minus) }
        if char == BinaryOperator.multiply.rawValue { goToNextChar(); return .operator(.multiply) }
        if char == BinaryOperator.divide.rawValue { goToNextChar(); return .operator(.divide) }
        if char == BinaryOperator.mod.rawValue { goToNextChar(); return .operator(.mod) }

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
