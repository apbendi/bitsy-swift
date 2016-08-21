import Foundation

/**
 *
 *  The `Parser` consumes the stream of `Token`s created by the `Tokenizer`. Parsing
 *  is said to "succeed" if the `Parser` completes, in which case the Bitsy source
 *  code being parsed is considered valid. If the Bitsy source is invalid for any reason, 
 *  for example, if the developer didn't start their program with the `BEGIN` keyword, 
 *  the `Parser` will cease the compilation process and return an error to the user.
 *
 *  In this compiler, the `Parser` also performs code generation as it traverses the stream
 *  of `Tokens`. It does so by making calls to an abstract `CodeGenerator` class, which implements
 *  the details of emitting appropriate code in a given target language. Because parsing and
 *  code generation are done simultaneously, this compiler is referred to as a "single pass"
 *  compiler.
 *
 *  In more advanced, production compilers, the output of the Parsing routine is often not code
 *  in the target language, but rather an "Abstract Syntax Tree", or AST. An AST is a
 *  data structure representing the code that has been parsed and is manipulated by subsequent
 *  phases of the compilation process. These phases can include steps like optimization, type
 *  checking, and ultimately code generation. For learning and getting started, a single pass
 *  is sufficient!
 *
 *  This `Parser`implements an algorithm called "Recursive Descent." Recursive
 *  Descent parsers consist of a series of mutually recursive functions for each "production",
 *  or component of the source language. For example:
 *
 *    - A sequence of Bitsy statements can be defined as a <block>
 *    - A <block> can contain (among other thing) zero more <loop> statements
 *    - A <loop> statement contains a <block> between the "LOOP" and "END" keywords
 *
 *  Blocks and loops are mutually recursive, and in fact, our Parser implements two functions
 *  named `block()` and `loop()` which can call each other. The role of the `block()` function
 *  is to dispatch to other parsing functions. Other parsing functions consume the `Token`s which
 *  are expected in their productions, calling others where needed. For example, since the 
 *  `PRINT` statement must be follwed by an expression to output, the `doPrint()` function
 *  consumes a `.print` `Keyword` `Token` and calls `expression()`. Each function
 *  similiarly follows the "shape" of its expected input, or "grammar."
 */
class Parser {
    private let tokens: Tokenizer
    private let generator: CodeGenerator


    /**
     * Create a Parser
     *
     * - parameter tokens:    The unprocessesd stream of `Tokens` the Parser will inspect
     * - parameter generator: A code generator the `Parser` will use to output code in
     *                        its given target language
     */
    init(tokens: Tokenizer, generator: CodeGenerator) {
        self.tokens = tokens
        self.generator = generator

        if currentToken.isSkippable {
            advanceToken()
        }
    }

    /**
     *  Parses the program represented by the `Tokenizer` with which it was created.
     *  As it does so, the `Parser` produces code in the target language by making calls
     *  to the `CodeGenerator` with which it was initialized.
     *
     *  If this method completes, the input to the Parser was a valid program, and the
     *  code generation can be assumed to have completed successfully. This method will cease execution 
     *  and present an error to the user if the sequence of `Token`s does not represent a valid program.
     *
     *  @warning This method should be called once per instance. Subsequent calls would result in an error
     */
    func parse() {
        program()
    }
}

// MARK: Convenience Methods

private extension Parser {

    /**
     * Convenience accessor to the current token of the `Tokenizer`
     */
    var currentToken: Token { return tokens.current }

    /**
     * Advance the token stream to the next non-`Whitespace`, non-`Comment` `Token`
     */
    func advanceToken() {
        guard tokens.hasMore else {
            return
        }

        tokens.advance()

        while currentToken.isSkippable {
            tokens.advance()
        }
    }

    /**
     * Ensure the current `Token` matches an expected value, terminating with an error to
     * the user if it does not. Advances the `Token` stream unless told to terminate.
     * Returns the original String representation of this `Token` in the source code.
     *
     * - parameter tokenType: The expected value of the current `Token`s type property
     * - parameter andTerminate: If true, this method will *not* advance the token stream
     */
    func match(tokenType type: TokenType, andTerminate terminate: Bool = false) -> String {
        guard currentToken.type == type else {
            print("[ERROR] Expecting \(type.rawValue) but received \(currentToken.value)")
            exit(EX_DATAERR)
        }

        if terminate {
            return currentToken.value
        }

        let value = currentToken.value
        advanceToken()
        return value
    }
}

// MARK: Static Helpers

private extension Parser {

    /**
     *  The branch condition needed for code gen given a conditional `TokenType`
     *
     *  - warning: causes a fatal error if not passed a conditional `TokenType` case
     *
     *  - parameter forTokenType: A conditional `TokenType` case
     *  - returns: The corresponding `CodeGenCondition`
     */
    static func ifCond(forTokenType type: TokenType) -> CodeGenCondition {
        switch type {
        case .ifP:
            return .positive
        case .ifN:
            return .negative
        case .ifZ:
            return .zero
        default:
            fatalError("Unexpected non-IF code: \(type)")
        }
    }

    /**
     *  The code generation operation for given operator `TokenType`
     *
     *  - warning: causes a fatal error if not passed an operator `TokenType`
     *
     *  - parameter forTokenType: An operator `TokenType` case
     *  - returns: The corresponding `CodeGenCondition`
     */
    static func codeOp(forTokenType type: TokenType) -> CodeGenOperation {
        switch type {
        case .plus:
            return .add
        case .minus:
            return .subtract
        case .multiply:
            return .multiply
        case .divide:
            return .divide
        case .modulus:
            return .modulus
        default:
            fatalError("Unexpected non-Operator code: \(type)")
        }
    }
}

// MARK: Recursive Descent

private extension Parser {

    /**
     *  The top level entry point of our recursive descent parser
     */
    func program() {
        match(tokenType: .begin)
        generator.header()
        block()
        match(tokenType: .end, andTerminate: true)
        generator.footer()
    }

    /**
     *  A block is defined as any number of valid Bitsy statements. Blocks in Bitsy
     *  are always termintated by an `END`or `ELSE` keyword. Therefore, the block method in
     *  our parser simply dispatches to the parsing function appropriate for the current
     *  keyword until it encounters a block terminating keyword.
     */
    func block() {
        while !currentToken.isBlockEnd {
            switch currentToken.type {
            case isIf:
                ifStatement()
            case .loop:
                loop()
            case .breakKey:
                doBreak()
            case .print:
                doPrint()
            case .read:
                read()
            default:
                assignment()
            }
        }
    }

    /**
     *  Parses any of the Bitsy conditional statements, along with the
     *  optional else branch.
     */
    func ifStatement() {
        let condType = Parser.ifCond(forTokenType: currentToken.type)
        match(tokenType: currentToken.type)
        expression()
        generator.startCond(type: condType)
        block()

        if case .elseKey = currentToken.type {
            match(tokenType: .elseKey)
            generator.elseCond()
            block()
        }

        match(tokenType: .end)
        generator.endCond()
    }

    /**
     *  Parses a Bitsy LOOP...END statement
     */
    func loop() {
        match(tokenType: .loop)
        generator.loopOpen()

        block()

        match(tokenType: .end)
        generator.loopEnd()
    }

    /**
     *  Parses the Bitsy BREAK statement
     */
    func doBreak() {
        match(tokenType: .breakKey)
        generator.breakLoop()
    }

    /**
     *  Parses a Bitsy PRINT statement
     */
    func doPrint() {
        match(tokenType: .print)
        expression()
        generator.print()
    }

    /**
     *  Parses a Bitsy READ statement
     */
    func read() {
        match(tokenType: .read)
        let varName = match(tokenType: .variable)
        generator.read(variableName: varName)
    }

    /**
     *  Parses a Bitsy variable assignment
     */
    func assignment() {
        let varName = match(tokenType: .variable)
        match(tokenType: .assignment)
        expression()
        generator.set(variableName: varName)
    }

    /**
     *  Parses a Bitsy expression. An expression is one or more terms seperated
     *  by addition or subtraction operators.
     */
    func expression() {
        term()

        while currentToken.isAdditionOperator {
            generator.push()
            let op = Parser.codeOp(forTokenType: currentToken.type)
            match(tokenType: currentToken.type)
            term()
            generator.pop(andPerform: op)
        }
    }

    /**
     *  Parses a Bitsy term. A term is a factor, preceeded by an optional sign (+/-),
     *  followed by any number of addtional factors seperated by multiplication, subtraction,
     *  or modulus operators.
     */
    func term() {
        signedFactor()

        while currentToken.isMultiplicationOperator {
            generator.push()
            let op = Parser.codeOp(forTokenType: currentToken.type)
            match(tokenType: currentToken.type)
            factor()
            generator.pop(andPerform: op)
        }
    }

    /**
     *  Parses a Bitsy factor prepended by an optional addition or subtraction
     *  operator, indicating the signedness (positive or negative) of the factor
     */
    func signedFactor() {
        var op: CodeGenOperation = .add

        if currentToken.isAdditionOperator {
            op = Parser.codeOp(forTokenType: currentToken.type)
            match(tokenType: currentToken.type)
        }

        factor()

        if op == .subtract {
            generator.negate()
        }
    }

    /**
     *  Parses a Bitsy expression. An expression is an integer literal, a single
     *  variable, or an expression enclosed in parens.
     */
    func factor() {
        if case .integer = currentToken.type {
            let integer = match(tokenType: .integer)
            generator.load(integerValue: integer)
        } else if case .variable = currentToken.type {
            let varName = match(tokenType: .variable)
            generator.load(variableName: varName)
        } else {
            match(tokenType: .leftParen)
            expression()
            match(tokenType: .rightParen)
        }
    }
}

// MARK: Convenience Token Extensions

private extension Token {

    /** Is this `Token` one which has no effect on the execution of the program? */
    var isSkippable: Bool { return self.type == .whitespace || self.type == .comment }

    /** Is this `Token` one which denominates the end of block? */
    var isBlockEnd: Bool { return self.type == .end || self.type == .elseKey }

    /** Is this `Token` a mathematical operator with addition precedence */
    var isAdditionOperator: Bool { return self.type == .plus || self.type == .minus }

    /** Is this `Token` a mathematical operator with mutiplication precedence */
    var isMultiplicationOperator: Bool { return self.type == .multiply || self.type == .divide || self.type == .modulus }
}

// MARK: Custom Pattern Matching

/**
 *  Is this case one of the Bitsy conditionals?
 */
private func isIf(type type:TokenType) -> Bool {
    return type == .ifP || type == .ifZ || type == .ifN
}

/**
 *  Enable custom pattern matching on `TokenType` cases
 */
private func ~=(pattern: (TokenType) -> (Bool), value: TokenType) -> Bool {
    return pattern(value)
}
