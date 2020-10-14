import UIKit

public protocol ECTimelineViewDataSource: AnyObject {
    
    /// The lower bound (inclusive). The view will not scroll past this index or request data from the data source
    var lowerBound: Int? { get }
    
    
    /// The upper bound (exclusive). The view will not scroll past this index or request data from the data source
    var upperBound: Int? { get }
    
    /// Asks for cell data that corresponds to the specified index
    /// - Parameters:
    ///   - timelineCollectionView: the opject requesting the data
    ///   - index: the index of the data being stored in relation to all the other data
    ///   - asyncClosure: a closure to return the requested data in an asynchronous fashion
    /// - Important: Data returned through asyncClosure will override any data previously returned
    func timelineView<T, U>(_ timelineView: ECTimelineView<T, U>, dataFor index: Int, asyncClosure: @escaping (_ data: T?) -> Void) -> T?
    
    /// Configures the cell with the designated data
    /// - Parameters:
    ///   - cell: the cell to configure
    ///   - data: the data that should be used to configure the cell
    func configure<T, U: UICollectionViewCell>(_ cell: U, withData data: T?)
}

public extension ECTimelineViewDataSource {
    var lowerBound: Int? { nil }
    var upperBound: Int? { nil }
}
