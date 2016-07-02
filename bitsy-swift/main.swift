import Foundation

let reader: CodeReader = CmdLineReader()
let tokens = Tokenizer(code: reader.readCode())
let parser = Parser(tokens: tokens)

parser.parse()
