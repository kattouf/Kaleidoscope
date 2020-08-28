import Foundation

struct FuncPrototype {
    let name: String
    let args: [String]
}

struct FuncDefinition {
    let prototype: FuncPrototype
    let expr: Expr
}

indirect enum Expr {
    case number(Number)
    case variable(String)
    case binary(Expr, BinaryOperator, Expr)
    case call(String, [Expr])
    case ifelse(Expr, Expr, Expr)
//    case equals
}
