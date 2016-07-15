import Foundation

let config = ArgumentConfig()

let tokens = Tokenizer(code: config.reader.readCode())
let parser = Parser(tokens: tokens, emitter: config.emitter)

parser.parse()
config.emitter.finalize()
