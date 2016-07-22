import Foundation

class Parser {
    private let tokens: Tokenizer
    private let generator: CodeGenerator

    init(tokens: Tokenizer, generator: CodeGenerator) {
        self.tokens = tokens
        self.generator = generator

        if currentToken.isSkippable {
            advanceToken()
        }
    }

    func parse() {
        program()
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

private extension Parser {

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

private extension Parser {
    func program() {
        match(tokenType: .begin)
        generator.header()
        block()
        match(tokenType: .end, andTerminate: true)
        generator.footer()
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

    func loop() {
        match(tokenType: .loop)
        generator.loopOpen()

        block()

        match(tokenType: .end)
        generator.loopEnd()
    }

    func doBreak() {
        match(tokenType: .breakKey)
        generator.breakLoop()
    }

    func doPrint() {
        match(tokenType: .print)
        expression()
        generator.print()
    }

    func read() {
        match(tokenType: .read)
        let varName = match(tokenType: .variable)
        generator.read(variableName: varName)
    }

    func assignment() {
        let varName = match(tokenType: .variable)
        match(tokenType: .assignment)
        expression()
        generator.set(variableName: varName)
    }

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


private extension Token {
    var isSkippable: Bool { return self.type == .whitespace || self.type == .comment }
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
