//
//  SwipeInteractionController.swift
//  GuessThePet
//
//  Created by Openfield Mobility on 13/12/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

class SwipeInteractionController: UIPercentDrivenInteractiveTransition {
    var interactionInProgress = false
    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!
    
    func wireToViewController(viewController: UIViewController!) {
        self.viewController = viewController
        prepareGestureRecognizerInView(view: viewController.view)
    }
    
    private func prepareGestureRecognizerInView(view: UIView) {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(SwipeInteractionController.handleGesture(gestureRecognizer:)))
        gesture.edges = UIRectEdge.left
        view.addGestureRecognizer(gesture)
    }
    
    func handleGesture(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        // 1 - You start by declaring local variables to track the progress. You'll record the translation in the view and calculate the progress. A Swipe of 200 points will lead to 100% completion, so you use this number to measure the transition's progress.
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        var progress = (translation.x / 200)
        progress = CGFloat(fminf(fmaxf(Float(progress), 0), 1))
        
        switch gestureRecognizer.state {
            
        case .began:
            // 2 - When the gesture starts, you adjust interactionInProgress accordingly and trigger the dismissal of the view controller
            interactionInProgress = true
            viewController.dismiss(animated: true, completion: nil)
            
        case .changed:
            // 3 - While the gesture is moving, you continuously call updateInteractiveTransition with the progress amount. This is a method on UIPercentDrivenInteractiveTransition which moves the transition along by the percentage amount you pass in.
            shouldCompleteTransition = progress > 0.5
            update(progress)
            
        case .cancelled:
            // 4 - If the gesture is cancelled, you update interactionInProgress and roll back the transition
            interactionInProgress = false
            cancel()
            
        case .ended:
            // 5 - Once the gesture has ended, you use the current progress of the transition to decide whether to cancel it or finish it for the user.
            interactionInProgress = false
            
            if !shouldCompleteTransition {
                cancel()
            } else {
                finish()
            }
            
        default:
            print("Unsupported")
        }
    }
}
