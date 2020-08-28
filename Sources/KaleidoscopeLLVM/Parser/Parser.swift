import Foundation

/* Grammar be represented in Backus-Naur Form:
 <prototype>  ::= <identifier> "(" <params> ")"
 <params>     ::= <identifier>
                | <identifier>, <params>
 <definition> ::= "def" <prototype> <expr> ";"
 <extern>     ::= "extern" <prototype> ";"
 <operator>   ::= "+" | "-" | "*" | "/" | "%"
 <expr>       ::= <binary> | <call> | <identifier> | <number> | <ifelse>
                | "(" <expr> ")"
 <binary>     ::= <expr> <operator> <expr>
 <call>       ::= <identifier> "(" <arguments> ")"
 <ifelse>     ::= "if" <expr> "then" <expr> "else" <expr>
 <arguments>  ::= <expr>
                | <expr> "," <arguments>
 */

// MARK: - ParseError

enum ParseError: Error {
    case unexpectedToken(Token)
    case unexpectedEOF
}

// MARK: - Parser

final class Parser {

    private let tokens: [Token]

    private var iterator: IndexingIterator<[Token]>
    private var currentToken: Token?

    init(tokens: [Token]) {
        self.tokens = tokens
        self.iterator = tokens.makeIterator()

        takeFirstToken()
    }

    func parse() throws -> AST {
        var externs = [FuncPrototype]()
        var definitions = [FuncDefinition]()
        var expressions = [Expr]()
        var prototypeMap = [String: FuncPrototype]()

        while let token = currentToken {
            switch token {
                case .keyword(.extern):
                    let extern = try parseExtern()
                    prototypeMap[extern.name] = extern
                    externs.append(extern)
                case .keyword(.def):
                    let definition = try parseFuncDefinition()
                    prototypeMap[definition.prototype.name] = definition.prototype
                    definitions.append(definition)
                default:
                    let expression = try parseExpr()
                    try parse(.punctuation(.semicolon))
                    expressions.append(expression)
            }
        }

        return .init(externs: externs,
                     definitions: definitions,
                     expressions: expressions,
                     prototypeMap: prototypeMap)
    }
}

// MARK: - Private (Iteration helpers)

private extension Parser {

    func takeFirstToken() {
        goToNextToken()
    }

    func goToNextToken() {
        currentToken = iterator.next()
    }
}


// MARK: - Private (Terms parsers)

private extension Parser {

    func parseFuncDefinition() throws -> FuncDefinition {
        try parse(.keyword(.def))
        let prototype = try parseFuncPrototype()
        let expression = try parseExpr()
        try parse(.punctuation(.semicolon))
        return .init(prototype: prototype, expr: expression)
    }

    func parseExtern() throws -> FuncPrototype {
        try parse(.keyword(.extern))
        let proto = try parseFuncPrototype()
        try parse(.punctuation(.semicolon))
        return proto
    }

    func parseFuncPrototype() throws -> FuncPrototype {
        let name = try parseIdentifier()

        try parse(.punctuation(.leftParen))
        let params = try parseCommaSeparatedTermsSequence(parseFunction: parseIdentifier)
        try parse(.punctuation(.rightParen))

        return .init(name: name, args: params)
    }

    func parseExpr() throws -> Expr {
        guard let token = currentToken else {
            throw ParseError.unexpectedEOF
        }

        var expr: Expr
        switch token {
        case .punctuation(.leftParen):
            try parse(.punctuation(.leftParen))
            expr = try parseExpr()
            try parse(.punctuation(.rightParen))
        case .number(let value):
            try parse(.number(value))
            expr = .number(value)
        case .identifier(let value):
            goToNextToken()
            if case .punctuation(.leftParen)? = currentToken {
                try parse(.punctuation(.leftParen))
                let expressions = try parseCommaSeparatedTermsSequence(parseFunction: parseExpr)
                try parse(.punctuation(.rightParen))
                expr = .call(value, expressions)
            } else {
                expr = .variable(value)
            }
            case .keyword(.if):
                try parse(.keyword(.if))
                let predicate = try parseExpr()
                try parse(.keyword(.then))
                let firstExpression = try parseExpr()
                try parse(.keyword(.else))
                let secondExpression = try parseExpr()
                expr = .ifelse(predicate, firstExpression, secondExpression)
        default:
            throw ParseError.unexpectedToken(token)
        }

        if case .operator(let binaryOperator)? = currentToken {
            try parse(.operator(binaryOperator))
            let rightExpression = try parseExpr()
            expr = .binary(expr, binaryOperator, rightExpression)
        }

        return expr
    }

    func parseCommaSeparatedTermsSequence<Term>(parseFunction: () throws -> Term) throws -> [Term] {
        var terms = [Term]()
        while let token = currentToken, token != .punctuation(.rightParen) {
            let term = try parseFunction()
            terms.append(term)
            if case .punctuation(.comma)? = currentToken {
                try parse(.punctuation(.comma))
            }
        }
        return terms
    }

    func parse(_ token: Token) throws {
        guard let tok = currentToken else {
            throw ParseError.unexpectedEOF
        }
        guard token == tok else {
            throw ParseError.unexpectedToken(token)
        }
        goToNextToken()
    }

    func parseIdentifier() throws -> String {
        guard let token = currentToken else {
            throw ParseError.unexpectedEOF
        }
        guard case .identifier(let name) = token else {
            throw ParseError.unexpectedToken(token)
        }
        goToNextToken()
        return name
    }
}
