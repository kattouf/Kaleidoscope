//
//  IRGenerator.swift
//  
//
//  Created by Vasiliy Yanguzin on 04.08.2020.
//

import LLVM

final class IRGenerator {

    enum Error: Swift.Error {
        case unknownFunction(String)
        case arityMismatch(String, expected: Int, got: Int)
        case unknownVariable(String)
    }

    let module: Module
    let builder: IRBuilder
    let ast: AST

    private var parameterValues = [String: IRValue]()

    init(ast: AST) {
        self.module = Module(name: "main")
        self.builder = IRBuilder(module: module)
        self.ast = ast
    }

    func generate() throws -> String {
        try emit()
        try module.verify()

        return module.description
    }
}

// MARK: - Private

private extension IRGenerator {

    func emit() throws {
        for extern in ast.externs {
            emitFunctionPrototype(extern)
        }
        for definition in ast.definitions {
            try emitFunctionDefinition(definition)
        }
        try emitMain()
    }

    func emitMain() throws {
        let mainType = FunctionType([], VoidType())
        let function = builder.addFunction("main", type: mainType)

        let entry = function.appendBasicBlock(named: "entry")
        builder.positionAtEnd(of: entry)

        let formatString = builder.buildGlobalStringPtr("%f\n")
        let printf = emitPrintf()

        for expr in ast.expressions {
            let val = try emitExpr(expr)
            _ = builder.buildCall(printf, args: [formatString, val])
        }

        builder.buildRetVoid()
    }

    func emitPrintf() -> Function {
        if let function = module.function(named: "printf") {
            return function
        }

        let printfType = FunctionType([PointerType(pointee: IntType.int8)],
                                      IntType.int32,
                                      variadic: true)

        return builder.addFunction("printf", type: printfType)
    }

    func emitExpr(_ expr: Expr) throws -> IRValue {
        switch expr {
            case .number(let value):
                return FloatType.double.constant(value)
            case .call(let name, let args):
                guard let prototype = ast.prototypeMap[name] else {
                    throw Error.unknownFunction(name)
                }

                guard prototype.args.count == args.count else {
                    throw Error.arityMismatch(name, expected: prototype.args.count, got: args.count)
                }

                let function = emitFunctionPrototype(prototype)
                let callArgs = try args.map(emitExpr(_:))

                return builder.buildCall(function, args: callArgs)
            case .variable(let name):
                guard let param = parameterValues[name] else {
                    throw Error.unknownVariable(name)
                }
                return param
            case .ifelse(let condition, let thenExpr, let elseExpr):
                let notZeroCondition = builder.buildFCmp(try emitExpr(condition),
                                                         FloatType.double.constant(0),
                                                         .orderedNotEqual)

                let thenBB = builder.currentFunction!.appendBasicBlock(named: "then")
                let elseBB = builder.currentFunction!.appendBasicBlock(named: "else")
                let mergeBB = builder.currentFunction!.appendBasicBlock(named: "merge")

                builder.buildCondBr(condition: notZeroCondition, then: thenBB, else: elseBB)

                builder.positionAtEnd(of: thenBB)
                let thenValue = try emitExpr(thenExpr)
                builder.buildBr(mergeBB)

                builder.positionAtEnd(of: elseBB)
                let elseValue = try emitExpr(elseExpr)
                builder.buildBr(mergeBB)

                builder.positionAtEnd(of: mergeBB)

                let phi = builder.buildPhi(FloatType.double)
                phi.addIncoming([(thenValue, thenBB), (elseValue, elseBB)])

                return phi
            case let .binary(lhs, op, rhs):
                let lhsVal = try emitExpr(lhs)
                let rhsVal = try emitExpr(rhs)
                switch op {
                    case .plus:
                        return builder.buildAdd(lhsVal, rhsVal)
                    case .minus:
                        return builder.buildSub(lhsVal, rhsVal)
                    case .divide:
                        return builder.buildDiv(lhsVal, rhsVal)
                    case .multiply:
                        return builder.buildMul(lhsVal, rhsVal)
                    case .mod:
                        return builder.buildRem(lhsVal, rhsVal)
            }
            //            case .equals:
            //                let comparison = builder.buildFCmp(lhsVal, rhsVal,
            //                                                   .orderedEqual)
            //                return builder.buildIntToFP(comparison,
            //                                            type: FloatType.double,
            //                                            signed: false)
        }
    }

    @discardableResult
    func emitFunctionPrototype(_ prototype: FuncPrototype) -> Function {
        if let function = module.function(named: prototype.name) {
            return function
        }

        let argTypes = [IRType](repeating: FloatType.double, count: prototype.args.count)
        let funcType = FunctionType(argTypes, FloatType.double)

        let function = builder.addFunction(prototype.name, type: funcType)

        for (var params, name) in zip(function.parameters, prototype.args) {
            params.name = name
        }

        return function
    }

    @discardableResult
    func emitFunctionDefinition(_ funcDefinition: FuncDefinition) throws -> Function {
        let function = emitFunctionPrototype(funcDefinition.prototype)

        for (idx, arg) in funcDefinition.prototype.args.enumerated() {
            let param = function.parameter(at: idx)!
            parameterValues[arg] = param
        }

        let entryBlock = function.appendBasicBlock(named: "entry")
        builder.positionAtEnd(of: entryBlock)

        let expr = try emitExpr(funcDefinition.expr)
        builder.buildRet(expr)

        parameterValues.removeAll()

        return function
    }
}
