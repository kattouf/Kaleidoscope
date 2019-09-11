import Foundation

typealias Number = Double

enum Token {
    case punctuation(Punctuation)
    case keyword(Keyword)
    case `operator`(BinaryOperator)
    case identifier(String)
    case number(Number)
}

enum Punctuation: Character {
    case leftParen = "("
    case rightParen = ")"
    case comma = ","
    case semicolon = ";"
}

enum Keyword: String {
    case def
    case extern
    case `if`
    case then
    case `else`
}

enum BinaryOperator: Character {
    case plus = "+"
    case minus = "-"
    case multiply = "*"
    case divide = "/"
    case mod = "%"
}
