import Foundation

struct ArgumentConfig {
    let bitsyFile: String
    let reader: CodeReader

    init() {
        let version = CounterOption(shortFlag: "v", longFlag: "version", helpMessage: "Print the version of bitsy-swift")
        let cliInput = CounterOption(shortFlag: "r", longFlag:"read-cli", helpMessage: "Read Bitsy code from the command line, terminated by a '.'")

        let cli = CommandLine()
        cli.addOptions(version, cliInput)

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

        if cliInput.value > 0 {
            self.bitsyFile = ""
            self.reader = CmdLineReader()
            return
        }

        guard let filePath = cli.unparsedArguments.first where filePath.hasSuffix("bitsy") else {
            print("Please provide a valide .bitsy file for compilation")
            exit(EX_NOINPUT)
        }

        self.bitsyFile = filePath
        self.reader = FileReader(filePath: filePath)
    }
}
