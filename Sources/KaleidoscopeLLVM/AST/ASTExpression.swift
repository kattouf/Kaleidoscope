import Foundation

// MARK: - AST Expressions
protocol ASTExpr {
}

struct NumberASTExpr: ASTExpr {
    let value: Number
}

struct VariableASTExpr: ASTExpr {
    let name: String
}

struct BinaryOperatorASTExpr: ASTExpr {
    let `operator`: BinaryOperator
    let lhs: ASTExpr
    let rhs: ASTExpr
}

struct FuncCallASTExpr: ASTExpr {
    let name: String
    let args: [ASTExpr]
}

// MARK: - Function AST
struct FuncPrototypeAST {
    let name: String
    let args: [String]
}

struct FuncAST {
    let proto: FuncPrototypeAST
    let body: ASTExpr
}
