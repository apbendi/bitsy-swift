import Foundation

/**
 *  A `Token` represents a discrete element in the Bitsy language extracted
 *  from the source code by the `Tokenizer`
 */
protocol Token {

    /**
     * The kind of Bitsy language element represented by this Token
     */
    var type: TokenType { get }

    /**
     * The sequence of Characters from the Bitsy source code this Token
     * is representing
     */
    var value: String { get }
}


/**
 * A concrete `Token` representing a sequence of aribtrary whitespace characters
 */
struct Whitespace: Token {
    let type: TokenType = .whitespace
    let value: String
}

/**
 * A concrete `Token` representing a sequence of arbitrary characters in a comment block
 */
struct Comment: Token {
    let type: TokenType = .comment
    let value: String
}

/**
 * A concrete `Token` representing a sequence of digit characters
 */
struct Integer: Token {
    let type: TokenType = .integer
    let value: String
}

/**
 * A concrete `Token` representing a sequence of letters and underscores identifying a variable
 */
struct Variable: Token {
    let type: TokenType = .variable
    let value: String
}

/**
 * A concrete `Token` representing the start or close of an expression
 */
struct Paren: Token {
    let type: TokenType
    var value: String { return type.rawValue }

    init?(string: String) {
        guard let type = TokenType(rawValue: string) else {
            return nil
        }

        self.type = type
    }
}

/**
 * A concrete `Token` representing an assignment or mathematical operator
 */
struct Operator: Token {
    let type: TokenType
    var value: String { return type.rawValue }

    init?(char: Character) {
        guard let type = TokenType(rawValue: String(char)) else {
            return nil
        }

        self.type = type
    }
}

/**
 * A concrete `Token` representing a keyword identifier in the Bitsy language
 */
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
