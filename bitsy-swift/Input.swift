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
