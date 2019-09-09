import UIKit

extension UIViewController {
    
    private static let blackoutViewTag = Int.max - 8
    
    func addBlackout(alpha: CGFloat = 0.7, duration: TimeInterval = UIView.Animation.Duration.normal, completion: (() -> Void)? = nil) {
        let blackoutView = UIView()
        blackoutView.frame.origin = .zero
        blackoutView.frame.size = view.bounds.size
        blackoutView.backgroundColor = .black
        blackoutView.tag = UIViewController.blackoutViewTag
        blackoutView.alpha = 0
        view.addSubview(blackoutView)
        UIView.animate(withDuration: duration, animations: {
            blackoutView.alpha = alpha
        }) { _ in
            completion?()
        }
    }
    
    func removeBlackout(duration: TimeInterval = UIView.Animation.Duration.normal, completion: (() -> Void)? = nil) {
        guard let blackoutView = view.viewWithTag(UIViewController.blackoutViewTag) else {
            return
        }
        UIView.animate(withDuration: duration, animations: {
            blackoutView.alpha = 0
        }) { _ in
            blackoutView.removeFromSuperview()
            completion?()
        }
    }
    
}
