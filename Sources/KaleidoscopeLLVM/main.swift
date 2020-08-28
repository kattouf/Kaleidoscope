import Foundation
import SwiftShell
import Files

guard CommandLine.arguments.count > 1 else {
    print("usage: Kaleidoscope <file>")
    exit(-1)
}

do {
    let file = try String(contentsOfFile: CommandLine.arguments[1])
    let lexer = Lexer(input: file)
    let parser = Parser(tokens: try lexer.getTokens())
    let ast = try parser.parse()
    let generator = IRGenerator(ast: ast)
    let llvmIR = try generator.generate()
    let llvmIRFile = try Folder.current.createFile(named: "ir.ll")
    try llvmIRFile.write(llvmIR)
    try runAndPrint("lli", llvmIRFile.path)
    try llvmIRFile.delete()

} catch {
    exit(error)
}
