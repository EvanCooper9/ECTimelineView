import UIKit

final public class ECTimelineView<T, U: UICollectionViewCell>: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Public properties

    public weak var timelineDataSource: ECTimelineViewDataSource? {
        didSet {
            data.removeAll()
            dataOffset = 0
            onceOnly = true
//            fetchData()
            fetchData(for: dataOffset...(config.pages * config.visibleCells) + dataOffset - 1)
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

    private let config: ECTimelineViewConfig
    private var onceOnly = true
    private var dataOffset = 0
    
    private let dataQueue = DispatchQueue(label: "com.evancooper.ectimelineview.data-queue")
    
    private var _data = [Int: T]()
    private var data: [Int: T] {
        get { dataQueue.sync { _data } }
        set { dataQueue.sync { _data = newValue } }
    }
    
    private var currentPosition: CGFloat {
        let offset = config.horizontal ? contentOffset.x : contentOffset.y
        return offset + (config.horizontal ? bounds.width : bounds.height) / 2
    }

    private var loadDirection: LoadDirection {
        let contentMiddle = (config.horizontal ? contentSize.width : contentSize.height) / 2
        return (currentPosition > contentMiddle) ? .positive : .negative
    }

    private var cellSize: CGSize {
        let width = config.horizontal ? frame.width / CGFloat(config.visibleCells) : frame.width
        let height = config.horizontal ? frame.height : frame.height / CGFloat(config.visibleCells)
        return CGSize(width: width, height: height)
    }

    private var visibleIndicies: [Int] {
        visibleCells
            .compactMap { indexPath(for: $0)?.row }
            .map { $0 + dataOffset }
    }

    // MARK: - Lifecycle

    public init(frame: CGRect, config: ECTimelineViewConfig) {
        self.config = config
        super.init(frame: frame, collectionViewLayout: config.layout)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        self.config = .init()
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        showsVerticalScrollIndicator = config.vertical
        showsHorizontalScrollIndicator = config.horizontal
        delegate = self
        dataSource = self
        register(cellType: U.self)
        dataOffset = config.bufferScreens * config.visibleCells
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
        dataOffset = lowestVisibleIndex - config.bufferCells

        let size = config.horizontal ? cellSize.width : cellSize.height
        let scrollAmount = (CGFloat(dataOffset - oldDataOffset) * size)
        let startOfContentOffset = config.horizontal ? contentOffset.x : contentOffset.y
        let scrollTo = startOfContentOffset - scrollAmount
        
        let pointX = config.horizontal ? scrollTo : 0
        let pointY = config.horizontal ? 0 : scrollTo
        setContentOffset(.init(x: pointX, y: pointY), animated: false)
    }
    
    private func fetchData() {
        let pointToAddData = loadDirection.isPositive ? dataOffset + config.cellCount : dataOffset - config.bufferCells - 1
        let indexRange = pointToAddData...pointToAddData + (loadDirection.isPositive ? config.cellCount : config.bufferCells)
        self.fetchData(for: indexRange)
    }

    private func fetchData(for range: ClosedRange<Int>) {
        range
            .filter { config.refetchData || !data.keys.contains($0) }
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
        config.visibleCells * config.pages
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
        let middle: IndexPath = IndexPath(row: config.bufferCells, section: 0)
        scrollToItem(at: middle, at: .top, animated: false)
        onceOnly = false
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        config.cellSpacing
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
