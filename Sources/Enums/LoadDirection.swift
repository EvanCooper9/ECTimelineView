import Foundation

internal enum LoadDirection {
    case positive, negative
}

extension LoadDirection {
    var positive: Bool { self == .positive }
    var negative: Bool { self == .negative }
}
