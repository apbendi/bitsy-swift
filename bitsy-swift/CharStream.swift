import Foundation

/**
 * Convenient interface for advancing one `Character` at a time
 * over a String
 */
struct CharStream {
    fileprivate let string: String
    fileprivate var index: String.Index

    /**
     * Initialize a character stream
     *
     * - parameter string: String to walk over
     */
    init(string: String) {
        self.string = string
        self.index = self.string.startIndex
    }

    /**
     *  Peek at the current character
     */
    var current: Character {
        return string[index]
    }

    /**
     *  Are there additional characters beyond `current`
     */
    var hasMore: Bool {
        return index != string.endIndex
    }

    /**
     *  Move to `current` to the next Character if `hasMore`
     */
    mutating func advance() {
        guard hasMore else { return }
        index = string.index(after: index)
    }
}
