import Foundation

/**
 * Character representing the start of a comment block in Bitsy source
 */
private let CommentOpen = Character("{")

/**
 * Character representing the end of a comment block in Bitsy source
 */
private let CommentClose = Character("}")

/**
 * The `Tokenizer` breaks the raw stream of characters loaded
 * from the Bitsy source code into discrete elements of the Bitsy language, called `Token`s.
 * This process is sometimes referred to as lexical analaysis, or lexing.
 *
 * The `Tokenizer` consumes the stream of characters and exposes a stream of `Token`s, allowing
 * later stages of the compiler, specifically the `Parser`, to operate at a level above
 * individual characters.
 *
 * Take, for example, the following simple Bitsy program:
 *
 *        BEGIN 
 *            PRINT 42 
 *        END
 *
 * The `Tokenizer`, having been initialized with this stream of input, should produce the
 * following stream of `Token`s:
 *
 *            --------------       ----------------      --------------
 *           |.begin/"BEGIN"| ->  |.whitespace/"\n"| -> |.print/"PRINT"|
 *            --------------       ----------------      --------------
 *
 *            ----------------      -------------      ---------------
 *        -> |.whitespace/"\t"| -> |.integer/"42"| -> |.whitespace/" "|
 *            ----------------      -------------      ---------------
 *
 *            ----------
 *        -> |.end/"END"|
 *            ----------
 *
 */
class Tokenizer {
    fileprivate var codeStream: CharStream
    fileprivate(set) internal var current: Token = Variable(value: "placeholder")

    /**
     * Are there additional `Token`s beyond `current`?
     */
    var hasMore: Bool { return codeStream.hasMore }

    /**
     * Create a `Tokenizer` instance
     *
     * - parameter code: The `CharStream` representing the Bitsy source to be Tokenized
     */
    init(code: CharStream) {
        codeStream = code
        advance()
    }

    /**
     * Move to the next `Token` in this stream
     */
    func advance() {
        current = takeNext()
    }
}

private extension Tokenizer {

    /**
     * This method is the meat of the tokenization process. The switch statement uses the
     * current character to predict the kind of `Token` that will be constructed. It takes all
     * subsequent characters which are legal in this class of `Token` and uses them to create
     * a the appropriate `Token`.
     *
     * In many instances the, the type of Token can be inferred directly from the current character.
     * In the case of identifiers, the failable `Keyword` initializer is used to distinguish between
     * a keyword and a variable.
     *
     * This method will also cease compilation if an unexpected or illegal character is encountered,
     * but it does nothing to analyze the 'correctness' or the intention of the source it Tokenizes.
     * (This is the job of the `Parser`). For example, the `Tokenizer` will happily process nonsensical
     * Bitsy sources, such as
     *
     *     END
     *         ELSE 100
     *         IFZ true
     *         LOOP LOOP LOOP {!}
     *     BEGIN
     *
     */
    func takeNext() -> Token {
        switch codeStream.current {
        case isWhitespace:
            return Whitespace(value: take(matching: isWhitespace))
        case isNumber:
            return Integer(value: take(matching: isNumber))
        case isParen:
            let parenChar = takeOne()
            guard let parenToken = Paren(string: parenChar) else {
                fatalError("Unexpected Paren String: \(parenChar)")
            }

            return parenToken
        case isIdentifier:
            let ident = take(matching: isIdentifier)
            if let key = Keyword(string: ident) {
                return key
            } else {
                return Variable(value: ident)
            }
        case isOperator:
            let opString = take(matching: isOperator)
            guard let opChar = opString.first, let opToken = Operator(char: opChar) , opString.count == 1 else {
                fatalError("Illegal Operator: \(opString)")
            }

            return opToken
        case CommentOpen:
            return takeComment()
        default:
            fatalError("Illegal Character: \"\(codeStream.current)\"")
        }
    }

    /**
     *  Advance the code stream by one character and return it as a String
     */
    func takeOne() -> String {
        let charString = String(codeStream.current)
        codeStream.advance()
        return charString
    }

    /**
     *  Advance the code stream past all characters which match a given definition,
     *  and return them concatenated as a String.
     *
     *  - parameter matching: A function which defines which characters "match"
     */
    func take(matching matches:(Character) -> Bool) -> String {
        var taken = ""

        while matches(codeStream.current) {
            taken += takeOne()
        }

        return taken
    }

    /**
     * Advance the code stream past the opening comment character and all subsequent characters
     * which are a part of the comment, including the closing comment character, returning a 
     * `Comment` `Token`
     */
    func takeComment() -> Token {
        let openChar = takeOne()
        guard openChar == String(CommentOpen) else {
            fatalError("Error processing comment, received: \(openChar) when expecting \(CommentOpen)")
        }

        var commentText = ""

        while codeStream.current != CommentClose {
            commentText += takeOne()
        }

        let _ = takeOne() // CommentClose

        return Comment(value: commentText)
    }
}

/**
 * Returns true if `char` represents a whitespace in Bitsy
 */
private func isWhitespace(_ char: Character) -> Bool {
    return char == "\n" || char == "\t" || char == " "
}

/**
 * Returns true if `char` is a digit, '0' through '9'
 */
private func isNumber(_ char: Character) -> Bool {
    switch char {
    case "0"..."9":
        return true
    default:
        return false
    }
}

/**
 * Returns true if `char` is an open or closed paren character in Bitsy
 */
private func isParen(_ char: Character) -> Bool {
    let stringChar = String(char)
    return stringChar == TokenType.leftParen.rawValue ||
            stringChar == TokenType.rightParen.rawValue
}

/**
 * Returns true if `char` is a valid operator character in Bitsy
 */
private func isOperator(_ char: Character) -> Bool {
    return TokenType.operators.map { op in
                return String(char) == op.rawValue
            }.reduce(false) { acc, doesMatch in
                return acc || doesMatch
            }
}

/**
 * Returns true if `char` is a valid identifier character in Bitsy,
 * that is, one used for keywords and variable names
 */
private func isIdentifier(_ char: Character) -> Bool {
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

/**
 * Allow pattern matching on `Character`s
 */
private func ~=(pattern: (Character) -> (Bool), value: Character) -> Bool {
    return pattern(value)
}
