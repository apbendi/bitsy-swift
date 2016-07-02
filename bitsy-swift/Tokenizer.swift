import Foundation

class Tokenizer {
    private var codeStream: CharStream
    private(set) internal var current: Token = Variable(value: "placeholder")

    var hasMore: Bool { return codeStream.hasMore }

    init(code: CharStream) {
        codeStream = code
        advance()
    }

    func advance() {
        current = takeNext()
    }
}

private extension Tokenizer {
    func takeNext() -> Token {
        switch codeStream.current {
        case isWhitespace:
            return Whitespace(value: take(matching: isWhitespace))
        case isNumber:
            return Integer(value: take(matching: isNumber))
        case isIdent:
            let ident = take(matching: isIdent)
            if let key = Keyword(string: ident) {
                return key
            } else {
                return Variable(value: ident)
            }
        default:
            fatalError("Illegal Character: \"\(codeStream.current)\"")
        }
    }

    func take(matching matches:(Character) -> Bool) -> String {
        var taken = ""

        while matches(codeStream.current) {
            taken += String(codeStream.current)
            codeStream.advance()
        }

        return taken
    }
}

private func isWhitespace(char: Character) -> Bool {
    switch char {
    case "\n":
        return true
    case "\t":
        return true
    case " ":
        return true
    default:
        return false
    }
}

private func isNumber(char: Character) -> Bool {
    switch char {
    case "0"..."9":
        return true
    default:
        return false
    }
}

private func isIdent(char: Character) -> Bool {
    switch char {
    case "a"..."z":
        return true
    case "A"..."Z":
        return true
    case "_":
        return true
    default:
        return false
    }
}

private func ~=(pattern: (Character) -> (Bool), value: Character) -> Bool {
    return pattern(value)
}
