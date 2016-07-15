import Foundation

protocol CodeEmitter {
    func emit(code code: String);
    func finalize();
}

struct CmdLineEmitter: CodeEmitter {
    func emit(code code: String) {
        print(code, terminator: "")
    }

    func finalize() {}
}

class FileEmitter: CodeEmitter {
    private let finalPath: String
    private let intermediatePath: String
    private let retainIntermediate: Bool
    private var code: String = ""

    init(filePath path: String, retainIntermediate retain: Bool = false) {
        finalPath = path
        intermediatePath = finalPath + ".swift"
        retainIntermediate = retain
    }

    func emit(code newCode: String) {
        self.code += newCode
    }

    func finalize() {
        do {
            try code.writeToFile(intermediatePath, atomically: true, encoding: NSUTF8StringEncoding)
            let swiftcOutput = exec("swiftc \(intermediatePath) -o \(finalPath) -suppress-warnings")
            if swiftcOutput != "" {
                print(swiftcOutput)
            }
        } catch _ {
            print("Error writing to file: \(intermediatePath)")
            exit(EX_IOERR)
        }

        if retainIntermediate {
            return
        }

        do {
            try NSFileManager.defaultManager().removeItemAtPath(intermediatePath)
        } catch _ { }
    }
}
