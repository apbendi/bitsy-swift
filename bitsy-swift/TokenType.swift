import Foundation

enum TokenType: String {
    case whitespace
    case variable
    case integer
    case begin   = "BEGIN"
    case end     = "END"
    case ifP     = "IFP"
    case ifZ     = "IFZ"
    case ifN     = "IFN"
    case elseKey = "ELSE"
    case loop    = "LOOP"
}