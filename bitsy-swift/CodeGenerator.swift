import Foundation

// MARK: Intermediate Target Details

/**
 *  An entity which handles implementation details of a given intermediate representation, 
 *  i.e. the compilation target language
 */
protocol IntermediateBuilder {

    /**
     * Returns the external shell command for producing a binary executable from the
     * intermediate/target code
     *
     * - parameter forFinalPath: The final path of the binary executable to generate
     */
    func buildCommand(forFinalPath path: String) -> String

    /**
     *  The appropriate extension for the compilation target (including the '.').
     *  For example, ".c" if targeting C, ".js" if targeting JavaScript
     */
    var intermediateExtension: String { get }
}

extension IntermediateBuilder {

    /**
     *  Full path of the file where the intermediate compilation target will be
     *  written, derived from the final path of the executable and the appropriate
     *  extension
     *
     *  - parameter forFinalPath: The final path of the binary executable to be generated
     */
    func intermediatePath(forFinalPath path: String) -> String {
        return path + intermediateExtension
    }
}

// MARK: Operations

/**
 * The mathematical operations that will need to be performed when generating
 * target code
 */
enum CodeGenOperation {
    case add, subtract, multiply, divide, modulus
}

// MARK: Branch Conditions

/**
 * The cases- mapping to IFP, IFN, and IFZ in Bitsy-
 * for which a branch conditional will need to be generated in the compilation target
 */
enum CodeGenCondition {
    case positive, negative, zero
}

// MARK: Code Generation

/**
 *  Emits code in the compilation target language for a predefined
 *  series of operations.
 *
 *  CodeGenerator can be thought of as an interface to a very simple,
 *  abstract instruction set with:
 *
 *   - A single register
 *   - A stack
 *   - Arbitrary storage addressable by a String key
 *   - Conditional branching on the signed-ness of the register
 *   - Unconditional loop-open/close/exit instructions (admittedly atypical)
 *
 *  A concrete CodeGenerator must emit code (via `emitLine(code:)`) that
 *  executes equivalent instructions in the compilation target language. It
 *  must also handle details of building the target language by implementing
 *  `IntermediateBuilder`
 *
 *  The generator itself may be stateful,
 *  depending on the sematics available to the target language. For example,
 *  a generator may need to maintain a stack of labels to properly implement 
 *  `loopOpen()`, `loopClose()`, and `breakLoop()`
 */
protocol CodeGenerator: IntermediateBuilder {

    /**
     *  The CodeEmitter to write isntructions to
     */
    var emitter: CodeEmitter { get }

    /**
     * Emits any header code which must precede all subsequent code in the
     * the target language
     */
    func header()

    /**
     * Emits any footer code which must go after all other code generated in
     * the target language
     */
    func footer()

    /**
     * Emits code defining a branch condition based on the state of the register.
     * Subsequent code *should* execute if the register matches the condition type.
     * 
     * - parameter type: Execute subsequent code if the state of the register
     *                   matches this condition
     */
    func startCond(type: CodeGenCondition)

    /**
     * Emits code defining alternate branch associated with a conditional
     */
    func elseCond()

    /**
     * Emits code defining the end of a conditional branch
     */
    func endCond()

    /**
     * Emits code defining the beginning of a repeating set of instructions
     */
    func loopOpen()

    /**
     * Emits code defining the end of a repeating set of instructions
     */
    func loopEnd()

    /**
     * Emits code which exits a repeating set of instructions
     */
    func breakLoop()

    /**
     * Emits code which outputs the register value to STDOUT with a trailing newline
     */
    func print()

    /**
     * Emits code which pauses to take input from STDIN and loads the integer value
     * into memory addressable by a name
     *
     * - Note: input other than a stream of digits, optionally prepended with +/-,
     *         should load a value of 0
     *
     *  - parameter variableName: The 'address' to load the input
     */
    func read(variableName name: String)

    /**
     * Loads the addressed value into the register. A given address is always
     * initialized with 0.
     *
     * - parameter variableName: The name of the 'address' from which to load input
     */
    func load(variableName name: String)

    /**
     * Loads an integer literal into the register
     *
     *  - parameter integerValue: digit characters of the integer to load
     */
    func load(integerValue value: String)

    /**
     * Stores the current value of the register into the 'address' identified
     *
     * - parameter variableName: The identifying name of the 'address' to write
     */
    func set(variableName name: String)

    /**
     * Push the current register value onto the stack
     */
    func push()

    /**
     * Pop a value off the top of the stack, perform an operation with that value
     * and the register (in that order), and place the result back in the register
     *
     * - parameter andPerform: The mathematical operation to perform
     */
    func pop(andPerform operation: CodeGenOperation)

    /**
     * Reverse the sign of the value in the register
     */
    func negate()
}

extension CodeGenerator {
    /**
     *  Emit a given line of target language code
     */
    func emitLine(_ code: String = "") {
        emitter.emit(code: "\(code)\n")
    }

    /**
     *  Finalize the intermediate code in the target language
     *  to produce an executable binary
     */
    func finalize() {
        emitter.finalize(withIntermediate: self)
    }
}
