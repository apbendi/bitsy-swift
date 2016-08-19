import Foundation

/**
 *  Enumaration of all kinds of Tokens available
 *  For Parens, Operators, and Keywords, each case is backed
 *  by a rawValue of the String representing that symbol in Bitsy
 */
enum TokenType: String {
    // MARK: Seperators
    case whitespace
    case variable

    // MARK: Identifiers
    case integer
    case comment

    // MARK: Parens
    case leftParen  = "("
    case rightParen = ")"

    // MARK: Operators
    case plus       = "+"
    case minus      = "-"
    case multiply   = "*"
    case divide     = "/"
    case modulus    = "%"
    case assignment = "="

    // MARK: Keywords
    case begin      = "BEGIN"
    case end        = "END"
    case ifP        = "IFP"
    case ifZ        = "IFZ"
    case ifN        =  "IFN"
    case elseKey    = "ELSE"
    case loop       = "LOOP"
    case breakKey   = "BREAK"
    case print      = "PRINT"
    case read       = "READ"
}

extension TokenType {
    /**
     * All `TokenType`s which are considered Bitsy operators
     */
    static var operators: [TokenType] = [.plus, .minus, .multiply, .divide, .modulus, .assignment]
}