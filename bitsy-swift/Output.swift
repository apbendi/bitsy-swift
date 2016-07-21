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
    private let runDeleteBinary: Bool
    private var code: String = ""

    init(filePath path: String, retainIntermediate retain: Bool = false, runDeleteBinary runDelete: Bool = false) {
        finalPath = path
        intermediatePath = finalPath + ".swift"
        retainIntermediate = retain
        runDeleteBinary = runDelete
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

        if !retainIntermediate {
            delete(filePath: intermediatePath)
        }

        if runDeleteBinary {
            let bitsyOut = exec("./\(finalPath)")
            print(bitsyOut, terminator: "")

            delete(filePath: finalPath)
        }
    }

    private func delete(filePath filePath:String) {
        let _ = try? NSFileManager.defaultManager().removeItemAtPath(filePath)
    }
}
