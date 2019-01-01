//
//  TimelineCollectionView.swift
//  TimelineCollectionView
//
//  Created by Evan Cooper on 2018-12-22.
//  Copyright © 2018 Evan Cooper. All rights reserved.
//

import UIKit

final public class TimelineCollectionView<T, U>: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout where T: Any, U: UICollectionViewCell {

    // MARK: - Public properties

    public weak var timelineDataSource: TimelineCollectionViewDataSource? {
        didSet {
            fetchData(for: dataOffset...(config.pages * config.visibleCells) + dataOffset - 1)
        }
    }

    public weak var timelineCellDelegate: TimelineCollectionViewCellDelegate? {
        didSet {
            let indexPaths = visibleCells.compactMap { cell -> IndexPath? in
                return indexPath(for: cell)
            }
            reloadItems(at: indexPaths)
        }
    }

    // MARK: - Private properties

    private var config: TimelineCollectionViewConfig!
    private var data: [Int: T?] = [Int: T?]()
    private var onceOnly = true
    private var dataOffset: Int!

    private var loadDirection: LoadDirection {
        let contentMiddle = (config.scrollDirection == .horizontal) ? contentSize.width / 2 : contentSize.height / 2
        let middle = (config.scrollDirection == .horizontal) ? contentOffset.x : contentOffset.y
        return (middle > contentMiddle) ? .positive : .negative
    }

    private var cellSize: CGSize {
        let width = (config.scrollDirection == .horizontal) ? frame.width / CGFloat(config.visibleCells) : frame.width
        let height = (config.scrollDirection == .horizontal) ? frame.height : frame.height / CGFloat(config.visibleCells)
        return CGSize(width: width, height: height)
    }

    private var lowestVisibleIndex: Int? {
        guard visibleCells.count > 0 else { return nil }
        return visibleCells.map({ cell -> Int in
            return indexPath(for: cell)!.row
        }).sorted().first! + dataOffset
    }

    private var visibleIndicies: [Int]? {
        guard visibleCells.count > 0 else { return nil }
        return visibleCells.map({ cell -> Int in
            return indexPath(for: cell)!.row + dataOffset
        }).sorted()
    }

    private var fetchDataClosure: (TimelineCollectionView<T, U>, T?, Int) -> Void = { timelineCollectionView, data, index in
        DispatchQueue.main.async {
            timelineCollectionView.data[index] = data
            guard let visibleIndicies = timelineCollectionView.visibleIndicies else { return }
            if visibleIndicies.contains(index) {
                let indexPath = IndexPath(row: index - timelineCollectionView.dataOffset, section: 0)
                timelineCollectionView.reloadItems(at: [indexPath])
            }
        }
    }

    // MARK: - Public functions

    public init(frame: CGRect, config: TimelineCollectionViewConfig) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = config.scrollDirection
        super.init(frame: frame, collectionViewLayout: layout)
        self.config = config
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.config = TimelineCollectionViewConfig()
        commonInit()
    }

    public func refresh(dataAt index: Int) {
        data[index] = timelineDataSource?.timelineCollectionView(self, dataFor: index, asyncClosure: { asyncData in
            self.data[index] = asyncData
        })
    }

    // MARK: - Private functions

    private func commonInit() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        delegate = self
        dataSource = self
        register(cellType: U.self)
        dataOffset = config.bufferPages * config.visibleCells
    }

    private func verifyDelegates() {
        if timelineDataSource == nil { fatalError("timelineDataSource must not be nil") }
        if timelineCellDelegate == nil { fatalError("timelineCellDelegate must not be nil") }
    }

    private func adjustContentOffset() {
        guard lowestVisibleIndex != nil else { return }

        let oldDataOffset = dataOffset!
        dataOffset = lowestVisibleIndex! - config.bufferedCells

//        let spacingOffset = CGFloat(numberOfItems(inSection: 0) / 2) * config.cellSpacing * ((loadDirection == .positive) ? 1 : -1)
        let size = (config.scrollDirection == .horizontal) ? cellSize.width : cellSize.height
        let scrollAmount = (CGFloat(dataOffset - oldDataOffset) * size)
        let startOfContentOffset = (config.scrollDirection == .horizontal) ? contentOffset.x : contentOffset.y
        let scrollTo = (loadDirection == .negative) ? startOfContentOffset - scrollAmount : startOfContentOffset - scrollAmount
        let pointX = (config.scrollDirection == .horizontal) ? scrollTo : 0
        let pointY = (config.scrollDirection == .horizontal) ? 0 : scrollTo

        setContentOffset(CGPoint(x: pointX, y: pointY), animated: false)
    }

    private func fetchData(for range: ClosedRange<Int>) {
        range.compactMap({ index -> Int? in
            return (data.keys.contains(index)) ? nil : index
        }).forEach { index in
            data[index] = timelineDataSource?.timelineCollectionView(self, dataFor: index, asyncClosure: { data in
                self.fetchDataClosure(self, data, index)
            })
        }
    }

    private func fetchData() {
        guard timelineDataSource != nil else { return }
        let pointToAddData = (loadDirection == .positive) ? data.keys.max()! + 1 : data.keys.min()! - 1
        let indexRange = (loadDirection == .positive) ? pointToAddData...pointToAddData + config.bufferedCells : pointToAddData - config.bufferedCells...pointToAddData
        self.fetchData(for: indexRange)
    }

    private func requiresContentAdjustment() -> Bool {
        let size = (config.scrollDirection == .horizontal) ? frame.width : frame.height
        let cSize = (config.scrollDirection == .horizontal) ? contentSize.width : contentSize.height
        let start = (config.scrollDirection == .horizontal) ? contentOffset.x : contentOffset.y
        let end = start + size

        let bufferRegionTop = size * CGFloat(config.bufferRegionPages)
        let bufferRegionBottom = cSize - bufferRegionTop

        let scrolledToTop = start < bufferRegionTop
        let scrolledToBottom = end > bufferRegionBottom

        return scrolledToTop || scrolledToBottom
    }

    // MARK: - UICollectionViewDataSource

    private func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return config.visibleCells * config.pages
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let adjustedIndex = indexPath.row + dataOffset
        let cell = dequeueReusableCell(withType: U.self, for: indexPath)
        timelineCellDelegate?.configure(cell, withData: data[adjustedIndex])
        return cell
    }

    // MARK: - UICollectionViewDelegate

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if onceOnly {
            let middle: IndexPath = IndexPath(row: config.bufferedCells, section: 0)
            scrollToItem(at: middle, at: .top, animated: false)
            onceOnly = false
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return config.cellSpacing
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }

    // MARK: - UIScrollViewDelegate

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if config.energySaving && !requiresContentAdjustment() { return }
        fetchData()
        adjustContentOffset()
        reloadData()
    }
}
