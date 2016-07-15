import Foundation

protocol CodeReader {
    func readCode() -> CharStream
}

struct CmdLineReader: CodeReader {
    func readCode() -> CharStream {
        var input = ""
        var line = ""

        while line.characters.first != "." {
            input += "\(line)\n"

            guard let nextLine = readLine() else {
                fatalError()
            }

            line = nextLine
        }

        return CharStream(string: input)
    }
}

struct FileReader: CodeReader {
    private let filePath: String

    init(filePath path: String) {
        self.filePath =  path
    }

    func readCode() -> CharStream {
        guard let code = try? NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding) as String else {
            print("Path to bitsy code was not valid (\(filePath))")
            exit(EX_NOINPUT)
        }

        return CharStream(string: code)
    }
}
