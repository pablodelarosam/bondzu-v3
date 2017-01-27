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
    
    func wireToViewController( _ vc : UIViewController ){
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(InteractiveDismissalHelper.handleGesture(_:)))
        vc.view.addGestureRecognizer(gesture)
        controller = vc
    }
    
    func handleGesture(_ gestureRecognizer : UIPanGestureRecognizer){
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view?.superview)
        
        print(gestureRecognizer.state)
        
        switch gestureRecognizer.state{
        case .began:
            
            interactionInProgress = true
            controller.dismiss(animated: true, completion: nil)
            
        case .changed:
            var fraction : CGFloat = (translation.y / 200.0)
            fraction = min( max( fraction, 0.0 ) , 1.0 )
            shouldCompleteTransition = ( fraction > 0.5 )
            print(fraction)
            update(fraction)
        case .ended, .cancelled:
            self.interactionInProgress = false
            if !shouldCompleteTransition || gestureRecognizer.state == .cancelled{
                self.cancel()
            }
            else{
                self.finish()
            }
        default:
            break
        }
        
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!.snapshotView(afterScreenUpdates: false)
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        toView.frame = container.frame
        
        container.addSubview(toView)
        container.addSubview(fromView!)
        
        toView.frame.origin = CGPoint(x: (container.frame.size.width), y: 0)
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.0, options: UIViewAnimationOptions(), animations: {
            
            fromView?.frame.origin =  CGPoint(x: -(container.frame.size.width), y: 0)
            toView.frame.origin = CGPoint.zero
            
            }, completion: { finished in
                toView.removeFromSuperview()
                fromView?.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.75
    }

}
