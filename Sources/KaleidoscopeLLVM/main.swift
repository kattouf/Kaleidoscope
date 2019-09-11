import LLVM

let input = """
def foo(n) (n * 100.35);
# hui
extern double(x) (x * x)
"""
print(Lexer(input: input).getTokens())
