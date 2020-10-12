import UIKit

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(withType type: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as! T
    }

    func register<T: UICollectionViewCell>(cellType type: T.Type) {
        register(T.self, forCellWithReuseIdentifier: String(describing: T.self))
    }
}
