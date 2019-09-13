import Foundation

typealias Number = Double

enum Token: Equatable {
    case punctuation(Punctuation)
    case keyword(Keyword)
    case `operator`(BinaryOperator)
    case identifier(String)
    case number(Number)
}

enum Punctuation: Character, Equatable {
    case leftParen = "("
    case rightParen = ")"
    case comma = ","
    case semicolon = ";"
}

enum Keyword: String, Equatable {
    case def
    case extern
    case `if`
    case then
    case `else`
}

enum BinaryOperator: Character, Equatable {
    case plus = "+"
    case minus = "-"
    case multiply = "*"
    case divide = "/"
    case mod = "%"
}
