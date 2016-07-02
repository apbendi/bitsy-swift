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
            case .variable:
                assignment()
            default:
                term()
            }
        }
    }

    func assignment() {
        let variable = match(tokenType: .variable)
        print("VARIABLE \(variable)")
    }

    func term() {
        let integer = match(tokenType: .integer)
        print("INTEGER \(integer)")
    }
}


private extension Token {
    var isSkippable: Bool { return self.type == .whitespace }
    var isBlockEnd: Bool { return self.type == .end }
}