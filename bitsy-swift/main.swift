import Foundation

let version = CounterOption(shortFlag: "v", longFlag: "version",
                              helpMessage: "Print the version of bitsy-swift")

let cli = CommandLine()
cli.addOptions(version)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

if version.value > 0 {
    print("0.0.1")
    exit(EX_OK)
}

let reader: CodeReader = CmdLineReader()
let tokens = Tokenizer(code: reader.readCode())
let parser = Parser(tokens: tokens, emitter: CmdLineEmitter())

parser.parse()
