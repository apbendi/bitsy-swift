import Foundation

enum TokenType: String {
    case whitespace
    case variable
    case integer
    case leftParen  = "("
    case rightParen = ")"
    case plus       = "+"
    case minus      = "-"
    case multiply   = "*"
    case divide     = "/"
    case modulus    = "%"
    case assignment = "="
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

    static var operators: [TokenType] = [.plus, .minus, .multiply, .divide, .modulus, .assignment]
}