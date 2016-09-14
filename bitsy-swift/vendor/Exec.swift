import Foundation

// https://gist.github.com/lmedinas/7963ac1985dba4dc60b5

func exec(_ cmdname: String) -> String {
    var outstr = ""
    let task = Process()
    task.launchPath = "/bin/sh"
    task.arguments = ["-c", cmdname]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
        outstr = output as String
    }

    task.waitUntilExit()
    let status = task.terminationStatus

    if status != 0 {
        print(status)
    }

    return outstr
}
