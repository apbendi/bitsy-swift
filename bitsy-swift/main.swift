import Foundation

let config = ArgumentConfig()

let reader    = config.reader
let generator = config.generator
let emitter   = generator.emitter

let tokens = Tokenizer(code: reader.readCode())
let parser = Parser(tokens: tokens, generator: generator)

parser.parse()
emitter.finalize(withIntermediate: generator)
