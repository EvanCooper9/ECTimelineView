//
//  TimelineCollectionViewConfig.swift
//  TimelineCollectionView
//
//  Created by Evan Cooper on 2018-12-23.
//  Copyright © 2018 Evan Cooper. All rights reserved.
//

import UIKit

public struct ECTimelineViewConfig {
    public let bufferPages: Int
    public let bufferRegionPages: Int
    public let visibleCells: Int
    public let scrollDirection: UICollectionView.ScrollDirection
    public let energySaving: Bool
    public var cellSpacing: CGFloat
    public var pages: Int { return (bufferPages * 2) + 1 }
    public var bufferedCells: Int { return bufferPages * visibleCells }

    public init(bufferPages: Int = 3,
                bufferRegionPages: Int = 1,
                visibleCells: Int = 5,
                scrollDirection: UICollectionView.ScrollDirection = .vertical,
                energySaving: Bool = false,
                cellSpacing: CGFloat = 0) {
        self.bufferPages = bufferPages
        self.bufferRegionPages = bufferRegionPages
        self.visibleCells = visibleCells
        self.scrollDirection = scrollDirection
        self.energySaving = energySaving
        self.cellSpacing = cellSpacing
    }
}
