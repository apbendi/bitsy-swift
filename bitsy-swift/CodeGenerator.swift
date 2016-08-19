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
    func emitLine(code: String = "") {
        emitter.emit(code: "\(code)\n")
    }

    func finalize() {
        emitter.finalize(withIntermediate: self)
    }
}
