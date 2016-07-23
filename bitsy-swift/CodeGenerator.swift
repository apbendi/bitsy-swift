import Foundation

protocol IntermediateBuilder {
    func buildCommand(forFinalPath path: String) -> String
    var intermediateExtension: String { get }
}

extension IntermediateBuilder {
    func intermediatePath(forFinalPath path: String) -> String {
        return path + intermediateExtension
    }
}

enum CodeGenOperation {
    case add, subtract, multiply, divide, modulus
}

enum CodeGenCondition {
    case positive, negative, zero
}

protocol CodeGenerator: IntermediateBuilder {
    var emitter: CodeEmitter { get }
    func header()
    func footer()
    func startCond(type type: CodeGenCondition)
    func elseCond()
    func endCond()
    func loopOpen()
    func loopEnd()
    func breakLoop()
    func print()
    func read(variableName name: String)
    func load(variableName name: String)
    func load(integerValue value: String)
    func set(variableName name: String)
    func push()
    func pop(andPerform op: CodeGenOperation)
    func negate()
}

extension CodeGenerator {
    func emit(code: String) {
        emitter.emit(code: code)
    }

    func emitLine(code: String) {
        emit("\(code)\n")
    }
}

struct SwiftGenerator: CodeGenerator {
    let emitter: CodeEmitter
    let intermediateExtension = ".swift"

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
        emitLine("if let input = readLine(), intInput = Int(input) { return intInput")
        emitLine("} else { return 0 } }")
        emit("\n")
    }

    func footer() {
        emitLine("\n// End Compiler Output")
    }

    func startCond(type type: CodeGenCondition) {
        func ifCode(type: CodeGenCondition) -> String {
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

    func pop(andPerform op: CodeGenOperation) {
        func opCode(forType type:CodeGenOperation) -> String {
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

        emitLine("register = stack.removeLast() \(opCode(forType: op)) register")
    }

    func negate() {
        emitLine("register = -register")
    }

    func buildCommand(forFinalPath path: String) -> String {
        return "swiftc \(intermediatePath(forFinalPath: path)) -o \(path) -suppress-warnings"
    }
}
