//
//  FlipPresentAnimationController.swift
//  GuessThePet
//
//  Created by 权仔 on 16/10/10.
//  Copyright © 2016年 Razeware LLC. All rights reserved.
//

import UIKit
import QuartzCore

class FlipPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    var originFrame = CGRect.zero
    let duration = 1.0
    
    class func imageWithView(view:UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0);
        view.layer.render(in: UIGraphicsGetCurrentContext()!)

        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // 1
        guard let fromVC = transitionContext.viewController(forKey: .from) else {
            return
        }
    
        guard let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        // 2
        let initialFrame = originFrame
        let finalFrame = transitionContext.finalFrame(for: toVC)
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        
        // 3
        // 对toView拍个快照
        let image = FlipPresentAnimationController.imageWithView(view: toVC.view)
        let snapshot = UIImageView(image: image)
        
        snapshot.frame = initialFrame
        snapshot.layer.cornerRadius = 25
        snapshot.layer.masksToBounds = true
        containerView.addSubview(toVC.view)
        AnimationHelper.perspectiveTransformForContainerView(containerView)
        snapshot.layer.transform = AnimationHelper.yRotation(M_PI_2)
        containerView.addSubview(snapshot)

        toVC.view.isHidden = true
        
        let delayTime = DispatchTime.now()
        DispatchQueue.main.asyncAfter(deadline: delayTime) {

            // 关键帧动画
            UIView.animateKeyframes(
                withDuration: duration,
                delay: 0,
                options: .calculationModeCubic,
                animations: {
                    // from顺时针旋转180
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1 / 3, animations: {
                        fromVC.view.layer.transform = AnimationHelper.yRotation(-M_PI_2)
                    })
                    
                    // 快照顺时针旋转180
                    UIView.addKeyframe(withRelativeStartTime: 1 / 3, relativeDuration: 1 / 3, animations: {
                        snapshot.layer.transform = AnimationHelper.yRotation(0.0)
                    })
                    
                    // 快照旋转后放大满屏
                    UIView.addKeyframe(withRelativeStartTime: 2 / 3, relativeDuration: 1 / 3, animations: {
                        snapshot.frame = finalFrame
                    })
            }) { (true) in
                toVC.view.isHidden = false
                fromVC.view.layer.transform = AnimationHelper.yRotation(0.0)
                snapshot.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}
