import Foundation

/**
 *  Exposes concrete instances of components needed for compilation,
 *  based on the arguments passed by the user on the command line.
 *  Will exit process if user arguments are invalid.
 */
struct ArgumentConfig {
    /**
     * Concrete CodeReader per user command line configuration
     */
    let reader: CodeReader

    /**
     *  Concrete CodeGenerator per user command line configuration
     */
    let generator: CodeGenerator

    /**
     *  Parse the arguments passed by the user and return
     *  an exposing concrete instances of components needed for
     *  the compilation process. Exit process with message to user if
     *  arguments are invalid.
     *
     * - parameter version: The version string to report to the user if requested
     */
    init(version: String) {
        let versionArg = CounterOption(shortFlag: "v", longFlag: "version", helpMessage: "Print the version of bitsy-swift")
        let help = CounterOption(shortFlag: "h", longFlag: "help", helpMessage: "Display bitsy-swift usage")
        let cliInput = CounterOption(shortFlag: "c", longFlag:"read-cli", helpMessage: "Read Bitsy code from the command line, terminated by a '.'")
        let outputPath = StringOption(shortFlag: "o", longFlag:"output", helpMessage: "Specify a name for the binary output")
        let cliOutput = CounterOption(shortFlag: "e", longFlag: "emit-cli", helpMessage: "Emit intermediate compilation to command line")
        let runDelete = CounterOption(shortFlag: "r", longFlag: "run-delete", helpMessage: "Immediately run and delete the compiled binary")
        let retainIntermediate = CounterOption(shortFlag: "i", longFlag: "retain-intermediate", helpMessage: "Retain results of intermediate representation")

        let cli = CommandLine()
        cli.addOptions(versionArg, help, cliInput, outputPath, cliOutput, runDelete, retainIntermediate)

        do {
            try cli.parse()
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }

        if help.value > 0 {
            cli.printUsage()
            exit(EX_OK)
        }

        let shouldRunDelete = runDelete.value > 0
        let shouldRetain = retainIntermediate.value > 0

        ArgumentConfig.check(argument: versionArg, version: version)
        reader = ArgumentConfig.reader(freeArgs: cli.unparsedArguments, cliInput: cliInput)
        let emitter = ArgumentConfig.emitter(outputPath: outputPath, cliOutput: cliOutput, retain: shouldRetain, runDelete: shouldRunDelete)
        generator = SwiftGenerator(emitter: emitter)
    }
}

// MARK: Static Helpers

private extension ArgumentConfig {

    /**
     * Exit reporting the version if requested by user
     */
    static func check(argument arg:CounterOption, version: String) {
        if arg.value > 0 {
            print(version)
            exit(EX_OK)
        }
    }

    /**
     *  Instantiate a concrete CodeReader based on the CLI input by user.
     *  Exit with message to user if input is invalid or source cannot be read.
     */
    static func reader(freeArgs: [String], cliInput: CounterOption) -> CodeReader {
        if cliInput.value > 0 {
            return CmdLineReader()
        }

        guard let filePath = freeArgs.first , filePath.hasSuffix("bitsy") else {
            print("Please provide a valid .bitsy file for compilation; run -h for more info")
            exit(EX_NOINPUT)
        }

        return FileReader(filePath: filePath)
    }

    /**
     *  Return a configured concrete CodeEmitter base on the CLI input by user
     */
    static func emitter(outputPath output:StringOption, cliOutput: CounterOption, retain: Bool, runDelete: Bool) -> CodeEmitter {
        if cliOutput.value > 0 {
            return CmdLineEmitter()
        }

        if let path = output.value {
            return FileEmitter(filePath: path, retainIntermediate: retain, runDeleteBinary: runDelete)
        } else {
            return FileEmitter(filePath: "b.out", retainIntermediate: retain, runDeleteBinary: runDelete)
        }
    }
}
