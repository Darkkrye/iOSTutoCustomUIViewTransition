//
//  FlipDismissAnimationController.swift
//  GuessThePet
//
//  Created by Openfield Mobility on 13/12/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

class FlipDismissAnimationController: NSObject {
    var destinationFrame = CGRect.zero
}

extension FlipDismissAnimationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from), let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        // 1 - Since this animation shrinks the view, you'll need to flip the initial and final frames.
        // let initialFrame = transitionContext.initialFrame(for: fromVC)
        let finalFrame = destinationFrame
        
        // 2 - This time you're manipulating the "from" view so you take a snapshot of that.
        let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false)
        snapshot?.layer.cornerRadius = 25
        snapshot?.layer.masksToBounds = true
        
        // 3 - Just as before, you add the "to" view and the snapshot to the container view, then hide the "from" view, so that it doesn't conflict with the snapshot.
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot!)
        fromVC.view.isHidden = true
        
        AnimationHelper.perspectiveTransformForContainerView(containerView)
        
        // 4 - Finally, you hide the "to" view via the same rotation technique.
        toVC.view.layer.transform = AnimationHelper.yRotation(-M_PI_2)
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            // 1 - You scale the view first, then hide the snapshot with the rotation. NEwt you reveal the "to" view by rotating it halfway around the y axis but in the opposite direction
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/3, animations: {
                snapshot?.frame = finalFrame
            })
            
            UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
                snapshot?.layer.transform = AnimationHelper.yRotation(M_PI_2)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
                toVC.view.layer.transform = AnimationHelper.yRotation(0)
            })
            
        }, completion: { _ in
            // 2 - Finally, you remove the snapshot and inform the context that the transition is complete. This allows UIKit to update the view controller hierarchy and tidy up the views it created to run the transition
            fromVC.view.isHidden = false
            snapshot?.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
