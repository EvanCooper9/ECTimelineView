import UIKit

public struct ECTimelineViewConfig {
    public let bufferPages: Int
    public let bufferRegionPages: Int
    public let visibleCells: Int
    public let scrollDirection: UICollectionView.ScrollDirection
    public let refetchData: Bool
    public var cellSpacing: CGFloat

    public init(bufferPages: Int = 3,
                bufferRegionPages: Int = 1,
                visibleCells: Int = 5,
                scrollDirection: UICollectionView.ScrollDirection = .vertical,
                refetchData: Bool = false,
                cellSpacing: CGFloat = 0) {
        self.bufferPages = bufferPages
        self.bufferRegionPages = bufferRegionPages
        self.visibleCells = visibleCells
        self.scrollDirection = scrollDirection
        self.refetchData = refetchData
        self.cellSpacing = cellSpacing
    }
}

extension ECTimelineViewConfig {
    
    var pages: Int { (bufferPages * 2) + 1 }
    var bufferedCells: Int { bufferPages * visibleCells }
    var cellCount: Int { visibleCells + (bufferedCells * 2) }
    
    var horizontal: Bool { scrollDirection == .horizontal }
    var vertical: Bool { scrollDirection == .vertical }
    
    var layout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        return layout
    }
}
