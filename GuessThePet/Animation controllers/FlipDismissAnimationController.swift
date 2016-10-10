//
//  FlipDismissAnimationController.swift
//  GuessThePet
//
//  Created by 权仔 on 16/10/10.
//  Copyright © 2016年 Razeware LLC. All rights reserved.
//

import UIKit

class FlipDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    var destinationFrame = CGRect.zero
    let duration = 1.0
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) else {
            return
        }
        
        guard let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        // 1
        let initialFrame = transitionContext.initialFrame(for: fromVC)
        let finalFrame = destinationFrame
        let containerView = transitionContext.containerView
        
        // 2
        let image = FlipPresentAnimationController.imageWithView(view: fromVC.view)
        let snapshot = UIImageView(image: image)
        snapshot.layer.cornerRadius = 25
        snapshot.layer.masksToBounds = true
        
        // 3 
        AnimationHelper.perspectiveTransformForContainerView(containerView)
        toVC.view.layer.transform = AnimationHelper.yRotation(-M_PI_2)
        
        // 4
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        fromVC.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration,
                                delay: 0.0,
                                options: .calculationModeCubic,
                                animations: { 
                                    // 1 
                                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1 / 3, animations: { 
                                        snapshot.frame = finalFrame
                                    })
                                    
                                    // 2
                                    UIView.addKeyframe(withRelativeStartTime: 1 / 3, relativeDuration: 1 / 3, animations: { 
                                        snapshot.layer.transform = AnimationHelper.yRotation(M_PI_2)
                                    })
                                    
                                    // 3
                                    UIView.addKeyframe(withRelativeStartTime: 2 / 3, relativeDuration: 1 / 3, animations: { 
                                        toVC.view.layer.transform = AnimationHelper.yRotation(0.0)
                                    })
            }) { (true) in
                fromVC.view.isHidden = false
                snapshot.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
