public protocol LogStorageReader : Sequence, IteratorProtocol {
    mutating func rewind()
}
