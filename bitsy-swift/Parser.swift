import Foundation

class Parser {
    private let tokens: Tokenizer
    private let emitter: CodeEmitter

    init(tokens: Tokenizer, emitter: CodeEmitter) {
        self.tokens = tokens
        self.emitter = emitter

        if currentToken.isSkippable {
            advanceToken()
        }
    }

    func parse() {
        program()
    }
}

private extension Parser {
    func emit(code: String) {
        emitter.emit(code: code)
    }

    func emitLine(code: String) {
        emit("\(code)\n")
    }
}

private extension Parser {
    var currentToken: Token { return tokens.current }

    func advanceToken() {
        guard tokens.hasMore else {
            return
        }

        tokens.advance()

        while currentToken.isSkippable {
            tokens.advance()
        }
    }

    func match(tokenType type: TokenType) -> String {
        guard currentToken.type == type else {
            print("[ERROR] Expecting \(type.rawValue) but received \(currentToken.value)")
            exit(-1)
        }

        //print(currentToken.value)

        let value = currentToken.value
        advanceToken()
        return value
    }
}

private extension Parser {
    func program() {
        match(tokenType: .begin)

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

        block()

        match(tokenType: .end)

        emitLine("\n// End Compiler Output")
    }

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

    func ifStatement() {
        func ifCode(type type: TokenType) -> String {
            switch type {
            case .ifP:
                return ">"
            case .ifN:
                return "<"
            case .ifZ:
                return "=="
            default:
                fatalError("Unexpected non-IF code: \(type)")
            }
        }

        let codeOp = ifCode(type: currentToken.type)
        match(tokenType: currentToken.type)
        expression()
        emitLine("if register \(codeOp) 0 {")

        block()

        if case .elseKey = currentToken.type {
            match(tokenType: .elseKey)
            emitLine("} else { ")
            block()
        }

        match(tokenType: .end)
        emitLine("}")
    }

    func loop() {
        match(tokenType: .loop)
        emitLine("while true {")

        block()

        match(tokenType: .end)
        emitLine("}")
    }

    func doBreak() {
        match(tokenType: .breakKey)
        emitLine("break")
    }

    func doPrint() {
        match(tokenType: .print)
        expression()
        emitLine("print(register)")
    }

    func read() {
        match(tokenType: .read)
        let varName = match(tokenType: .variable)
        emitLine("variables[\"\(varName)\"] = readIn()")
    }

    func assignment() {
        let varName = match(tokenType: .variable)
        match(tokenType: .assignment)
        expression()
        emitLine("variables[\"\(varName)\"] = register")
    }

    func expression() {
        term()

        while currentToken.isAdditionOperator {
            emitLine("stack.append(register)")
            let op = match(tokenType: currentToken.type)
            term()
            emitLine("register = stack.removeLast() \(op) register")
        }
    }

    func term() {
        signedFactor()

        while currentToken.isMultiplicationOperator {
            emitLine("stack.append(register)")
            let op = match(tokenType: currentToken.type)
            factor()
            emitLine("register = stack.removeLast() \(op) register")
        }
    }

    func signedFactor() {
        var shouldNegate = false

        if currentToken.isAdditionOperator {
            shouldNegate = currentToken.type == .minus
            match(tokenType: currentToken.type)
        }

        factor()

        if shouldNegate {
            emitLine("register = -register")
        }
    }

    func factor() {
        if case .integer = currentToken.type {
            let integer = match(tokenType: .integer)
            emitLine("register = \(integer)")
        } else if case .variable = currentToken.type {
            let varName = match(tokenType: .variable)
            emitLine("register = variables[\"\(varName)\"]")
        } else {
            match(tokenType: .leftParen)
            expression()
            match(tokenType: .rightParen)
        }
    }
}


private extension Token {
    var isSkippable: Bool { return self.type == .whitespace }
    var isBlockEnd: Bool { return self.type == .end || self.type == .elseKey }
    var isAdditionOperator: Bool { return self.type == .plus || self.type == .minus }
    var isMultiplicationOperator: Bool { return self.type == .multiply || self.type == .divide || self.type == .modulus }
}

private func isIf(type type:TokenType) -> Bool {
    return type == .ifP || type == .ifZ || type == .ifN
}

private func ~=(pattern: (TokenType) -> (Bool), value: TokenType) -> Bool {
    return pattern(value)
}
