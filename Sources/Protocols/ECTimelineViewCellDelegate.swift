import UIKit

public protocol ECTimelineViewCellDelegate: class {

    /**
     Asks the delegate to configure the cell with the designated data

     - parameters:
        - cell: the cell to configure
        - data: the data that should be used to configure the cell
     */
    func configure<T, U: UICollectionViewCell>(_ cell: U, withData data: T?)
}
