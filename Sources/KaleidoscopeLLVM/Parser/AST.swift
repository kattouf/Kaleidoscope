//
//  ParserResult.swift
//  KaleidoscopeLLVM
//
//  Created by Vasiliy Yanguzin on 03.08.2020.
//

import Foundation

struct AST {
    let externs: [FuncPrototype]
    let definitions: [FuncDefinition]
    let expressions: [Expr]
    let prototypeMap: [String: FuncPrototype]
}
