import Foundation

// https://gist.github.com/lmedinas/7963ac1985dba4dc60b5

func exec(cmdname: String) -> String {
    var outstr = ""
    let task = NSTask()
    task.launchPath = "/bin/sh"
    task.arguments = ["-c", cmdname]

    let pipe = NSPipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = NSString(data: data, encoding: NSUTF8StringEncoding) {
        outstr = output as String
    }

    task.waitUntilExit()
    let status = task.terminationStatus

    if status != 0 {
        print(status)
    }

    return outstr
}
