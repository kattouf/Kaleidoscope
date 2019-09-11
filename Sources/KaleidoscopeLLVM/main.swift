import LLVM

print(Lexer(input: "def foo(n) (n * 100.35);").getTokens())
