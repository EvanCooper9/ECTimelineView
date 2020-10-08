import UIKit

final public class ECTimelineView<T, U: UICollectionViewCell>: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Public properties
    
    /// Number of screens to prefetch data for
    public var bufferScreens = 3
    
    /// Number of cells visible on the screen
    public var visibleCellCount = 5
    
    /// The direction dictates the axis fo scroll
    public var scrollDirection = ScrollDirection.vertical
    
    /// Whether or not to re-ask the data source for new data when loading a cell who's data had been previously fetched
    public var refetchData = false
    
    /// Spacing between each cell
    public var cellSpacing: CGFloat = 0

    /// The data sources
    public weak var timelineDataSource: ECTimelineViewDataSource? {
        didSet {
            data.removeAll()
            dataOffset = 0
            onceOnly = true
            fetchData(for: dataOffset...(pages * visibleCellCount) + dataOffset - 1)
        }
    }
    
    // MARK: - Overrides
    
    public override var dataSource: UICollectionViewDataSource? {
        didSet {
            if !(dataSource is Self) { preconditionFailure("Please do not set the dataSource property. Use timelineDataSource instead") }
        }
    }
    
    public override var delegate: UICollectionViewDelegate? {
        didSet {
            if !(delegate is Self) { preconditionFailure("Please do not set the delegate property") }
        }
    }

    // MARK: - Private properties
    
    private var pages: Int { (bufferScreens * 2) + 1 }
    private var bufferCells: Int { bufferScreens * visibleCellCount }
    private var cellCount: Int { visibleCellCount + (bufferCells * 2) }
    private var horizontal: Bool { scrollDirection == .horizontal }
    private var vertical: Bool { scrollDirection == .vertical }
    
    private var layout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        return layout
    }

    private var onceOnly = true
    private var dataOffset = 0
    
    private let dataQueue = DispatchQueue(label: "com.evancooper.ectimelineview.data-queue")
    
    private var _data = [Int: T]()
    private var data: [Int: T] {
        get { dataQueue.sync { _data } }
        set { dataQueue.sync { _data = newValue } }
    }
    
    private var currentPosition: CGFloat {
        let offset = horizontal ? contentOffset.x : contentOffset.y
        return offset + (horizontal ? bounds.width : bounds.height) / 2
    }

    private var loadDirection: LoadDirection {
        let contentMiddle = (horizontal ? contentSize.width : contentSize.height) / 2
        return (currentPosition > contentMiddle) ? .positive : .negative
    }

    private var cellSize: CGSize {
        let width = horizontal ? frame.width / CGFloat(visibleCellCount) : frame.width
        let height = horizontal ? frame.height : frame.height / CGFloat(visibleCellCount)
        return CGSize(width: width, height: height)
    }

    private var visibleIndicies: [Int] {
        visibleCells
            .compactMap { indexPath(for: $0)?.row }
            .map { $0 + dataOffset }
    }

    // MARK: - Lifecycle

    public init(frame: CGRect = .zero) {
        super.init(frame: frame, collectionViewLayout: .init())
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        collectionViewLayout = layout
        showsVerticalScrollIndicator = vertical
        showsHorizontalScrollIndicator = horizontal
        delegate = self
        dataSource = self
        register(cellType: U.self)
        dataOffset = bufferScreens * visibleCellCount
    }
    
    // MARK: - Public Methods

    public func refresh(dataAt index: Int) {
        data[index] = timelineDataSource?
            .timelineCollectionView(self, dataFor: index) { asyncData in
                self.data[index] = asyncData
            }
    }

    // MARK: - Private Methods

    private func adjustContentOffset() {
        guard let lowestVisibleIndex = visibleIndicies.min() else { return }

        let oldDataOffset = dataOffset
        dataOffset = lowestVisibleIndex - bufferCells

        let size = horizontal ? cellSize.width : cellSize.height
        let scrollAmount = (CGFloat(dataOffset - oldDataOffset) * size)
        let startOfContentOffset = horizontal ? contentOffset.x : contentOffset.y
        let scrollTo = startOfContentOffset - scrollAmount
        
        let pointX = horizontal ? scrollTo : 0
        let pointY = horizontal ? 0 : scrollTo
        setContentOffset(.init(x: pointX, y: pointY), animated: false)
    }
    
    private func fetchData() {
        let pointToAddData = loadDirection.isPositive ? dataOffset + cellCount : dataOffset - bufferCells - 1
        let indexRange = pointToAddData...pointToAddData + (loadDirection.isPositive ? cellCount : bufferCells)
        self.fetchData(for: indexRange)
    }

    private func fetchData(for range: ClosedRange<Int>) {
        range
            .filter { refetchData || !data.keys.contains($0) }
            .forEach { index in
                self.dataQueue.sync {
                    self._data[index] = timelineDataSource?
                        .timelineCollectionView(self, dataFor: index) { [weak self] asyncData in
                            guard let self = self else { return }
                            self.dataQueue.sync { self._data[index] = asyncData }
                            DispatchQueue.main.async {
                                guard self.visibleIndicies.contains(index) else { return }
                                let indexPath = IndexPath(row: index - self.dataOffset, section: 0)
                                self.reloadItems(at: [indexPath])
                            }
                        }
                }
            }
    }

    // MARK: - UICollectionViewDataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCellCount * pages
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let adjustedIndex = indexPath.row + dataOffset
        let cell = dequeueReusableCell(withType: U.self, for: indexPath)
        timelineDataSource?.configure(cell, withData: data[adjustedIndex])
        return cell
    }

    // MARK: - UICollectionViewDelegate

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard onceOnly else { return }
        let middle: IndexPath = IndexPath(row: bufferCells, section: 0)
        scrollToItem(at: middle, at: .top, animated: false)
        onceOnly = false
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        cellSpacing
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        cellSize
    }

    // MARK: - UIScrollViewDelegate

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        fetchData()
        adjustContentOffset()
        reloadData()
    }
}
