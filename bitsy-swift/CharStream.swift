import Foundation

/**
 * Convenient interface for advancing one `Character` at a time
 * over a String
 */
struct CharStream {
    private let string: String
    private var index: String.CharacterView.Index

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
        return index.successor() < string.endIndex
    }

    /**
     *  Move to `current` to the next Character if `hasMore`
     */
    mutating func advance() {
        guard hasMore else { return }
        index = index.successor()
    }
}
