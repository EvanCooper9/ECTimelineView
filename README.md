# ECTimelineView

An horizontal or vertical infinitely scrolling `UICollectionView` implementation. Loads data synchrounously and asynchronously.

## Installation
### Swift Package Manager

```swift
.package(url: "https://github.com/EvanCooper9/ECTimelineView", from: "1.0.0")
```

### Dependencies
- [ECUICollectionViewMultiDelegate](https://github.com/EvanCooper9/ECUICollectionViewMultiDelegate)

## Usage
> Note: See inline documentation for more details

### Data Source
Implement `ECTimelineViewDataSource`, and set the `timelineDataSource` property.

```swift
// MARK: ECTimelineViewDataSource protocol

// Asks for cell data that corresponds to the specified index
func timelineView<T, U>(_ timelineView: ECTimelineView<T, U>, dataFor index: Int, asyncClosure: @escaping (_ data: T?) -> Void) -> T?
    
// Configures the cell with the designated data
func configure<T, U: UICollectionViewCell>(_ cell: U, withData data: T?)
```
