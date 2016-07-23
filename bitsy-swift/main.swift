import Foundation

let config = ArgumentConfig()

let tokens = Tokenizer(code: config.reader.readCode())
let parser = Parser(tokens: tokens, generator: config.generator)

parser.parse()
config.emitter.finalize(withIntermediate: config.generator)
