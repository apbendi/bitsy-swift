import Foundation

let BitsyVersion = "0.1.0"
let config = ArgumentConfig(version: BitsyVersion)

let reader    = config.reader
let generator = config.generator

let tokens = Tokenizer(code: reader.readCode())
let parser = Parser(tokens: tokens, generator: generator)

parser.parse()
generator.finalize()
