import Foundation

protocol Token {
    var type: TokenType { get }
    var value: String { get }
}

struct Whitespace: Token {
    let type: TokenType = .whitespace
    let value: String
}

struct Integer: Token {
    let type: TokenType = .integer
    let value: String
}

struct Keyword: Token {
    let type: TokenType
    var value: String { return type.rawValue }

    init?(string: String) {
        guard let type = TokenType(rawValue: string) else {
            return nil
        }

        self.type = type
    }
}

struct Variable: Token {
    let type: TokenType = .variable
    let value: String
}
