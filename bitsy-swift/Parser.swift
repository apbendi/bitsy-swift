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
            case .variable:
                assignment()
            default:
                term()
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

        term() // Conditional test

        block() // IF body

        if case .elseKey = currentToken.type {
            match(tokenType: .elseKey)
            block()
        }

        match(tokenType: .end)
    }

    func assignment() {
        let _ = match(tokenType: .variable)
    }

    func term() {
        let _ = match(tokenType: .integer)
    }
}


private extension Token {
    var isSkippable: Bool { return self.type == .whitespace }
    var isBlockEnd: Bool { return self.type == .end || self.type == .elseKey }
}

private func isIf(type type:TokenType) -> Bool {
    return type == .ifP || type == .ifZ || type == .ifN
}

private func ~=(pattern: (TokenType) -> (Bool), value: TokenType) -> Bool {
    return pattern(value)
}
