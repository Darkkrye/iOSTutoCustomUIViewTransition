//
//  FlipPresentAnimationController.swift
//  GuessThePet
//
//  Created by Openfield Mobility on 13/12/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

class FlipPresentAnimationController: NSObject {
    // MARK: Variables
    var originFrame = CGRect.zero
}

// Extension for UIViewControllerAnimatedTransitioning 
extension FlipPresentAnimationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // 1 - The transitioning context will provide the view controllers and views participating in the transition. You use the appropriate keys to obtain them.
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                return
        }
        
        let containerView = transitionContext.containerView
        
        // 2 - You next specify the starting and final frames for the "to" view. In this case, the transition starts from the card's frame and scales to fill the whole screen.
        let initialFrame = self.originFrame
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        // 3 - UIView snapshotting captures the "to" view and renders it into a lightweight view. This lets you animate the view together with its hierarchy. The snapshot's frame starts off as the card's frame. You also modify the corner radius to match the card.
        let snapshot = toVC.view.snapshotView(afterScreenUpdates: true)
        snapshot?.frame = initialFrame
        snapshot?.layer.cornerRadius = 25
        snapshot?.layer.masksToBounds = true
        
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot!)
        toVC.view.isHidden = true
        
        AnimationHelper.perspectiveTransformForContainerView(containerView)
        snapshot?.layer.transform = AnimationHelper.yRotation(M_PI_2) // Try with M_PI_4
        
        // 1 - First, you specify the duration of the animation. Notice the use of the transitionDuration(_:) method, implemented at the top of this class. You need the duration of your animations to match up with the duration you've declared for the whole transition so UIKit can keep things in sync.
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            // 2 - You start by rotating the "from" view halfway around its y axis to hide it from view
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/3, animations: {
                fromVC.view.layer.transform = AnimationHelper.yRotation(-M_PI_2)
            })
            
            // 3 - Next, you reveal the snapshot using the same technique
            UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
                snapshot?.layer.transform = AnimationHelper.yRotation(0.0)
            })
            
            // 4 - Then you set the frame of the snapshot to fill the screen
            UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
                snapshot?.frame = finalFrame
            })
            
        }, completion: { _ in
            // 5 - Finally, it's safe to reveal the real "to" view. You remove the snapshot since it's no longer useful. Then you rotate the "from" view back in place; otherwise, it would hidden when transitioning back. Calling completeTransition informs the transitioning context that the animation is complete. UIKit will ensure the final state is consistent and remove the "from" view from the container.
            toVC.view.isHidden = false
            fromVC.view.layer.transform = AnimationHelper.yRotation(0.0)
            snapshot?.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

public extension UIView {
    public func snapshotImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
    }
    
    public func snapshotView() -> UIView? {
        if let snapshotImage = snapshotImage() {
            return UIImageView(image: snapshotImage)
        } else {
            return nil
        }
    }
}
