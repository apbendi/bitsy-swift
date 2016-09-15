import Foundation

/**
 *  Emits target code to a given location
 */
protocol CodeEmitter {

    /**
     * Append code to the output buffer for the compilation target
     *
     * - parameter code: The code to append to the buffer
     */
    func emit(code: String)

    /**
     * Finalize the code in the output buffer and perform any further transformations
     * to the compilation target to produce a binary
     *
     * - parameter withIntermediate: Concrete builder for performing any external build step
     *   required by a given compilation target language
     */
    func finalize(withIntermediate builder: IntermediateBuilder)
}

/**
 *  Concrete CodeEmitter for writing compilation target code to console on STDOUT
 *
 *  - warning: does not perform any finalization/build. useful for understanding
 *       or debugging intermediate target
 */
struct CmdLineEmitter: CodeEmitter {
    func emit(code: String) {
        print(code, terminator: "")
    }

    func finalize(withIntermediate builder: IntermediateBuilder) {}
}

/**
 *  Concrete CodeEmitter for writing compilation target to a file on disk and
 *  subsequently performing any required build step on that output to produce an
 *  an executable binary. Cleans up the
 *  intermediate target unless instructed otherwise. Exits process with message to
 *  user if cannot write to file.
 *
 *  - warning: does not write buffer to disk until `finalize(withIntermediate:)` is called
 */
class FileEmitter: CodeEmitter {
    fileprivate let retainIntermediate: Bool
    fileprivate let runDeleteBinary: Bool
    fileprivate let finalPath: String
    fileprivate var code: String = ""

    /**
     * Initialize a configured FileEmitter
     *
     * - parameter filePath: Path to write the final executable to
     * - parameter retainIntermediate: Leave any intermediate compilation target on disk?
     * - parameter runDeleteBinary: Immediately execute, and subsequently delete, the resulting executable?
     */
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
            try code.write(toFile: intermediatePath, atomically: true, encoding: String.Encoding.utf8)
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

    fileprivate func delete(filePath:String) {
        let _ = try? FileManager.default.removeItem(atPath: filePath)
    }
}
