import Foundation

final class Lexer {

    enum Error: Swift.Error {
        case invalidNumber(String)
    }

    private let input: String

    private var iterator: String.Iterator
    private var currentChar: Character?

    init(input: String) {
        self.input = input

        self.iterator = input.makeIterator()
    }

    func getTokens() throws -> [Token] {
        var tokens: [Token] = []

        takeFirstChar()
        while let token = try nextToken() {
            tokens.append(token)
        }

        return tokens
    }
}

// MARK: - Private

private extension Lexer {

    static var oneCharacterTokenRawValueMap: [Character: Token] = [
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

    static var keywordRawValueMap: [String: Token] = [
        Keyword.def.rawValue: .keyword(.def),
        Keyword.extern.rawValue: .keyword(.extern),
        Keyword.if.rawValue: .keyword(.if),
        Keyword.then.rawValue: .keyword(.then),
        Keyword.else.rawValue: .keyword(.else)
    ]

    func nextToken() throws -> Token? {
        // skip whitespaces
        while let char = currentChar, char.isSpace {
            goToNextChar()
        }

        // skip comment
        if currentChar?.isSharp == true {
            while let char = currentChar, !char.isNewline {
                goToNextChar()
            }
            goToNextChar()
        }

        guard let char = currentChar else {
            return nil
        }

        // check for one-character tokens
        if let oneCharacterToken = Lexer.oneCharacterTokenRawValueMap[char] {
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
            if let keyword = Lexer.keywordRawValueMap[identifier] {
                return keyword
            }

            return .identifier(identifier)
        }

        // check for number
        if char.isDigit {
            var number = String()

            while let char = currentChar, char.isDigit || char.isDot  {
                number.append(char)
                goToNextChar()
            }

            if let numberValue = Number(number) {
                return .number(numberValue)
            } else {
                throw Error.invalidNumber(number)
            }
        }

        return nil
    }

    func takeFirstChar() {
        goToNextChar()
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
