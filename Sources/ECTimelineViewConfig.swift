import UIKit

public struct ECTimelineViewConfig {
    
    public typealias ScrollDirection = UICollectionView.ScrollDirection
    
    /// Number of screens to prefetch data for
    public let bufferScreens: Int
    
    /// Number of cells visible on the screen
    public let visibleCells: Int
    
    /// The direction dictates the axis fo scroll
    public let scrollDirection: ScrollDirection
    
    /// Whether or not to re-ask the data source for new data when loading a cell who's data had been previously fetched
    public let refetchData: Bool
    
    /// Spacing between each cell
    public var cellSpacing: CGFloat

    public init(bufferPages: Int = 3, visibleCells: Int = 5, scrollDirection: ScrollDirection = .vertical, refetchData: Bool = false, cellSpacing: CGFloat = 0) {
        self.bufferScreens = bufferPages
        self.visibleCells = visibleCells
        self.scrollDirection = scrollDirection
        self.refetchData = refetchData
        self.cellSpacing = cellSpacing
    }
}

extension ECTimelineViewConfig {
    
    var pages: Int { (bufferScreens * 2) + 1 }
    var bufferCells: Int { bufferScreens * visibleCells }
    var cellCount: Int { visibleCells + (bufferCells * 2) }
    var horizontal: Bool { scrollDirection == .horizontal }
    var vertical: Bool { scrollDirection == .vertical }
    
    var layout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        return layout
    }
}
