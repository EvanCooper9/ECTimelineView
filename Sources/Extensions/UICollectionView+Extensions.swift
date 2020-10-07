import UIKit

internal extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(withType type: T.Type, for indexPath: IndexPath) -> T {
        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as! T
    }

    func register<T: UICollectionViewCell>(cellType type: T.Type) {
        register(T.self, forCellWithReuseIdentifier: String(describing: T.self))
    }
}
