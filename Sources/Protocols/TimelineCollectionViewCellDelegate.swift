//
//  TimelineCollectionViewCellDelegate.swift
//  TimelineCollectionView
//
//  Created by Evan Cooper on 2018-12-24.
//  Copyright © 2018 Evan Cooper. All rights reserved.
//

import UIKit

public protocol TimelineCollectionViewCellDelegate: class {

    /**
     Asks the delegate to configure the cell with the designated data

     - parameters:
        - cell: the cell to configure
        - data: the data that should be used to configure the cell
     */
    func configure<T, U: UICollectionViewCell>(_ cell: U, withData data: T?)
}
