import Foundation

class Parser {
    private let tokens: Tokenizer

    init(tokens: Tokenizer) {
        self.tokens = tokens

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

    func match(tokenType type: TokenType) -> String {
        guard currentToken.type == type else {
            print("[ERROR] Expecting \(type.rawValue) but received \(currentToken.value)")
            exit(-1)
        }

        print(currentToken.value)

        let value = currentToken.value
        advanceToken()
        return value
    }
}

private extension Parser {
    func program() {
        match(tokenType: .begin)
        block()
        match(tokenType: .end)
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
        switch currentToken.type {
        case .ifP:
            match(tokenType: .ifP)
        case .ifN:
            match(tokenType: .ifN)
        case .ifZ:
            match(tokenType: .ifZ)
        default:
            fatalError()
        }

        expression() // Conditional test

        block() // IF body

        if case .elseKey = currentToken.type {
            match(tokenType: .elseKey)
            block()
        }

        match(tokenType: .end)
    }

    func loop() {
        match(tokenType: .loop)
        block()
        match(tokenType: .end)
    }

    func doBreak() {
        match(tokenType: .breakKey)
    }

    func doPrint() {
        match(tokenType: .print)
        expression() // what to print
    }

    func read() {
        match(tokenType: .read)
        match(tokenType: .variable) // what variable to read
    }

    func assignment() {
        match(tokenType: .variable)
        match(tokenType: .assignment)
        expression()
    }

    func expression() {
        term()

        while currentToken.isAdditionOperator {
            match(tokenType: currentToken.type)
            term()
        }
    }

    func term() {
        signedFactor()

        while currentToken.isMultiplicationOperator {
            match(tokenType: currentToken.type)
            factor()
        }
    }

    func signedFactor() {
        if currentToken.isAdditionOperator {
            match(tokenType: currentToken.type)
        }

        factor()
    }

    func factor() {
        if case .integer = currentToken.type {
            match(tokenType: .integer)
        } else if case .variable = currentToken.type {
            match(tokenType: .variable)
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
