import Foundation

internal enum LoadDirection {
    case positive, negative
}

extension LoadDirection {
    var isPositive: Bool { self == .positive }
    var isNegative: Bool { self == .negative }
}
