import Foundation

struct FuncPrototype {
    let name: String
    let args: [String]
}

struct FuncDefinition {
    let prototype: Prototype
    let expr: Expr
}

indirect enum Expr {
    case number(Double)
    case variable(String)
    case binary(Expr, BinaryOperator, Expr)
    case call(String, [Expr])
    case ifelse(Expr, Expr, Expr)
}
