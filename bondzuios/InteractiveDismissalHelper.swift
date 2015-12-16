//
//  InteractiveDismissalHelper.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 12/15/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit

class InteractiveDismissalHelper: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning{

    var interactionInProgress = true
    var shouldCompleteTransition = false
    
    var controller : UIViewController!
    
    override var completionSpeed : CGFloat{
        get{
            return 1 - percentComplete
        }
        set{}
    }
    
    func wireToViewController( vc : UIViewController ){
        let gesture = UIPanGestureRecognizer(target: self, action: "handleGesture:")
        vc.view.addGestureRecognizer(gesture)
        controller = vc
    }
    
    func handleGesture(gestureRecognizer : UIPanGestureRecognizer){
        let translation = gestureRecognizer.translationInView(gestureRecognizer.view?.superview)
        
        print(gestureRecognizer.state)
        
        switch gestureRecognizer.state{
        case .Began:
            
            interactionInProgress = true
            controller.dismissViewControllerAnimated(true, completion: nil)
            
        case .Changed:
            var fraction : CGFloat = (translation.y / 200.0)
            fraction = min( max( fraction, 0.0 ) , 1.0 )
            shouldCompleteTransition = ( fraction > 0.5 )
            print(fraction)
            updateInteractiveTransition(fraction)
        case .Ended, .Cancelled:
            self.interactionInProgress = false
            if !shouldCompleteTransition || gestureRecognizer.state == .Cancelled{
                self.cancelInteractiveTransition()
            }
            else{
                self.finishInteractiveTransition()
            }
        default:
            break
        }
        
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView()
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!.snapshotViewAfterScreenUpdates(false)
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        toView.frame = container!.frame
        
        container!.addSubview(toView)
        container!.addSubview(fromView)
        
        toView.frame.origin = CGPoint(x: (container?.frame.size.width)!, y: 0)
        let duration = transitionDuration(transitionContext)
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.0, options: UIViewAnimationOptions(), animations: {
            
            fromView.frame.origin =  CGPoint(x: -(container?.frame.size.width)!, y: 0)
            toView.frame.origin = CGPointZero
            
            }, completion: { finished in
                toView.removeFromSuperview()
                fromView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
        
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.75
    }

}
