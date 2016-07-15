import Foundation

struct ArgumentConfig {
    let reader: CodeReader
    let emitter: CodeEmitter

    init() {
        let version = CounterOption(shortFlag: "v", longFlag: "version", helpMessage: "Print the version of bitsy-swift")
        let cliInput = CounterOption(shortFlag: "r", longFlag:"read-cli", helpMessage: "Read Bitsy code from the command line, terminated by a '.'")
        let outputPath = StringOption(shortFlag: "o", longFlag:"output", helpMessage: "Specify a name for the binary output")
        let cliOutput = CounterOption(shortFlag: "e", longFlag: "emit-cli", helpMessage: "Emit intermediate compilation to command line")

        let cli = CommandLine()
        cli.addOptions(version, cliInput, outputPath, cliOutput)

        do {
            try cli.parse()
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }

        ArgumentConfig.check(version: version)
        reader = ArgumentConfig.reader(freeArgs: cli.unparsedArguments, cliInput: cliInput)
        emitter = ArgumentConfig.emitter(outputPath: outputPath, cliOutput: cliOutput)
    }
}

private extension ArgumentConfig {
    static func check(version version:CounterOption) {
        if version.value > 0 {
            print("0.0.1")
            exit(EX_OK)
        }
    }

    static func reader(freeArgs freeArgs: [String], cliInput: CounterOption) -> CodeReader {
        if cliInput.value > 0 {
            return CmdLineReader()
        }

        guard let filePath = freeArgs.first where filePath.hasSuffix("bitsy") else {
            print("Please provide a valide .bitsy file for compilation; run -h for more info")
            exit(EX_NOINPUT)
        }

        return FileReader(filePath: filePath)
    }

    static func emitter(outputPath output:StringOption, cliOutput: CounterOption) -> CodeEmitter {
        if cliOutput.value > 0 {
            print("WTF")
            return CmdLineEmitter()
        }

        if let path = output.value {
            return FileEmitter(filePath: path)
        } else {
            return FileEmitter(filePath: "b.out")
        }
    }
}
