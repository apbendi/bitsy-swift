import Foundation

// MARK: CodeGenerator

/**
 *  A concrete CodeGenerator which emits Swift
 *
 *  Swift is, perhaps, an odd choice as a compilation target for "real" compiler.
 *  For the sake of learning its a good choice for a couple of reasons:
 *
 *     1. It removes the barrier of having to learn some other, lower level language
 *        like assembly or LLVM-IR in order to understand what's going on
 *     2. It shares certain semantics with the source language directly, making the
 *        generated code itself more straightforward to digest
 */
struct SwiftGenerator: CodeGenerator {

    let emitter: CodeEmitter

    init(emitter: CodeEmitter) {
        self.emitter = emitter
    }

    func header() {
        emitLine("// Compiler Output\n")
        emitLine("struct Variables {")
        emitLine("private var values: [String: Int] = [:]")
        emitLine("subscript(index: String) -> Int {")
        emitLine("get { guard let v = values[index] else { return 0 }; return v }")
        emitLine("set (newValue) { values[index] = newValue } } }")
        emitLine("var register: Int = 0")
        emitLine("var variables = Variables()")
        emitLine("var stack: [Int] = []")
        emitLine("func readIn() -> Int {")
        emitLine("if let input = readLine(), let intInput = Int(input) { return intInput")
        emitLine("} else { return 0 } }")
        emitLine()
    }

    func footer() {
        emitLine("\n// End Compiler Output")
    }

    func startCond(type: CodeGenCondition) {
        func ifCode(_ type: CodeGenCondition) -> String {
            switch type {
            case .positive:
                return ">"
            case .negative:
                return "<"
            case .zero:
                return "=="
            }
        }

        emitLine("if register \(ifCode(type)) 0 {")
    }

    func elseCond() {
        emitLine("} else { ")
    }

    func endCond() {
        emitLine("}")
    }

    func loopOpen() {
        emitLine("while true {")
    }

    func loopEnd() {
        emitLine("}")
    }

    func breakLoop() {
        emitLine("break")
    }

    func print() {
        emitLine("print(register)")
    }

    func read(variableName name: String) {
        emitLine("variables[\"\(name)\"] = readIn()")
    }

    func load(variableName name: String) {
        emitLine("register = variables[\"\(name)\"]")
    }

    func load(integerValue value: String) {
        emitLine("register = \(value)")
    }

    func set(variableName name: String) {
        emitLine("variables[\"\(name)\"] = register")
    }

    func push() {
        emitLine("stack.append(register)")
    }

    func pop(andPerform operation: CodeGenOperation) {
        func operationChar(forType type:CodeGenOperation) -> String {
            switch type {
            case .add:
                return "+"
            case .subtract:
                return "-"
            case .multiply:
                return "*"
            case .divide:
                return "/"
            case .modulus:
                return "%"
            }
        }

        emitLine("register = stack.removeLast() \(operationChar(forType: operation)) register")
    }

    func negate() {
        emitLine("register = -register")
    }
}


// MARK: IntermediateBuilder

extension SwiftGenerator {

    var intermediateExtension: String { return ".swift" }

    func buildCommand(forFinalPath path: String) -> String {
        return "swiftc \(intermediatePath(forFinalPath: path)) -o \(path) -suppress-warnings"
    }
}
