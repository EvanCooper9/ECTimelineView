# ECTimelineView

An horizontal or vertical infinitely scrolling `UICollectionView` implementation. Loads data synchrounously and asynchronously.

## Installation
### Swift Package Manager

```swift
.package(url: "https://github.com/EvanCooper9/ECTimelineView", from: "1.0.0")
```

## Usage
> Note: See inline documentation for more details

### Configuration
Use `ECTimelineViewConfig` at initialization time. You can configure things like:
- Scroll direction
- Cell count
- Cell spacing
- etc..

### Data Source
Implement `ECTimelineViewDataSource`, and set the `timelineDataSource` property.

```swift
// MARK: ECTimelineViewDataSource protocol

// Asks for cell data that corresponds to the specified index
func timelineCollectionView<T, U>(_ timelineCollectionView: ECTimelineView<T, U>, dataFor index: Int, asyncClosure: @escaping (_ data: T?) -> Void) -> T?
    
// Configures the cell with the designated data
func configure<T, U: UICollectionViewCell>(_ cell: U, withData data: T?)
```

### Important
Don't set the `dataSource` or `delegate` property. `ECTimelineView` is meant to be it's own data source and delegate.