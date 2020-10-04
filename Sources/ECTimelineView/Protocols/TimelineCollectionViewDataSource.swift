//
//  TimelineCollectionViewDataSource.swift
//  TimelineCollectionView
//
//  Created by Evan Cooper on 2018-12-24.
//  Copyright © 2018 Evan Cooper. All rights reserved.
//

import Foundation

public protocol TimelineCollectionViewDataSource: class {

    /**
     Asks for cell data that corresponds to the specified index

     - parameters:
        - timelineCollectionView: the opject requesting the data
        - index: the index of the data being stored in relation to all the other data
        - asyncClosure: a closure to return the requested data in an asynchronous fashion
        - data: the data that is being returned asynchronously

     - returns:
     Data for the cell that corresponds to the specified index

     - important:
     Data returned through asyncClosure will override any data previously returned
     */
    func timelineCollectionView<T, U>(_ timelineCollectionView: TimelineCollectionView<T, U>, dataFor index: Int, asyncClosure: @escaping (_ data: T?) -> Void) -> T?
}
