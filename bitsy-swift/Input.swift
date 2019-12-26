import Foundation

/**
 * Reads characters representing code from some location
 */
protocol CodeReader {

    /**
     *  Read code from a given source and return stream of Characters
     */
    func readCode() -> CharStream
}

/**
 *  Concrete CodeReader that takes arbitrary user input from STDIN
 *  until receiving a terminating '.' line
 */
struct CmdLineReader: CodeReader {
    func readCode() -> CharStream {
        var input = ""
        var line = ""

        while line.first != "." {
            input += "\(line)\n"

            guard let nextLine = readLine() else {
                fatalError()
            }

            line = nextLine
        }

        return CharStream(string: input)
    }
}

/**
 *  Concrete CodeReader which loads characters from a given file on
 *  disk, or Exits with an error to the user if the contents of the file
 *  fail to read
 */
struct FileReader: CodeReader {
    fileprivate let filePath: String

    init(filePath path: String) {
        self.filePath =  path
    }

    func readCode() -> CharStream {
        guard let code = try? NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String else {
            print("Path to bitsy code was not valid (\(filePath))")
            exit(EX_NOINPUT)
        }

        return CharStream(string: code)
    }
}
