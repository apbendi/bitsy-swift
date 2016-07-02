import Foundation

struct CharStream {
    private let string: String
    private var index: String.CharacterView.Index

    init(string: String) {
        self.string = string
        self.index = self.string.startIndex
    }

    var current: Character {
        return string[index]
    }

    var hasMore: Bool {
        return index.successor() < string.endIndex
    }

    mutating func advance() {
        guard hasMore else { return }
        index = index.successor()
    }
}
