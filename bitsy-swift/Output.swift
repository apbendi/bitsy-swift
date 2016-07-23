import Foundation

protocol CodeEmitter {
    func emit(code code: String)
    func finalize(withIntermediate builder: IntermediateBuilder)
}

struct CmdLineEmitter: CodeEmitter {
    func emit(code code: String) {
        print(code, terminator: "")
    }

    func finalize(withIntermediate builder: IntermediateBuilder) {}
}

class FileEmitter: CodeEmitter {
    private let retainIntermediate: Bool
    private let runDeleteBinary: Bool
    private let finalPath: String
    private var code: String = ""

    init(filePath path: String, retainIntermediate retain: Bool = false, runDeleteBinary runDelete: Bool = false) {
        finalPath = path
        retainIntermediate = retain
        runDeleteBinary = runDelete
    }

    func emit(code newCode: String) {
        self.code += newCode
    }

    func finalize(withIntermediate builder: IntermediateBuilder) {
        let intermediatePath = builder.intermediatePath(forFinalPath: finalPath)
        let buildCommand = builder.buildCommand(forFinalPath: finalPath)

        do {
            try code.writeToFile(intermediatePath, atomically: true, encoding: NSUTF8StringEncoding)
            let swiftcOutput = exec(buildCommand)
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
