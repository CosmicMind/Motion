/*
 * The MIT License (MIT)
 *
 * Copyright (C) 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Original Inspiration & Author
 * Copyright (c) 2016 Luke Zhao <me@lkzhao.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

extension Motion {
    /**
     Complete the transition.
     - Parameter after: A TimeInterval.
     - Parameter isFinished: A Boolean indicating if the transition
     has completed.
     */
    func complete(after: TimeInterval, isFinished: Bool) {
        guard isTransitioning else {
            return
        }
        
        if after <= 0.001 {
            complete(isFinished: isFinished)
            return
        }
        
        let v = (isFinished ? elapsedTime : 1 - elapsedTime) * totalDuration
        
        self.isFinished = isFinished
        
        currentAnimationDuration = after + v
        beginTime = CACurrentMediaTime() - v
    }
    
    /**
     Complete the transition.
     - Parameter isFinished: A Boolean indicating if the transition
     has completed.
     */
    @objc
    func complete(isFinished: Bool) {
        if state == .notified {
            forceFinishing = isFinished
        }
        
        guard .animating == state || .starting == state else {
            return
        }
        
        defer {
            transitionContext = nil
            fromViewController = nil
            toViewController = nil
            isNavigationController = false
            isTabBarController = false
            forceNonInteractive = false
            transitionPairs.removeAll()
            transitionObservers = nil
            transitionContainer = nil
            completionCallback = nil
            forceFinishing = nil
            container = nil
            startingProgress = nil
            preprocessors.removeAll()
            animators.removeAll()
            plugins.removeAll()
            context = nil
            elapsedTime = 0
            totalDuration = 0
            state = .possible
        }
        
        state = .completing
        
        progressRunner.stop()
        context.clean()
        
        if let tv = toView, let fv = fromView {
            if isFinished && isPresenting && toOverFullScreen {
                // finished presenting a overFullScreen view controller.
                context.unhide(rootView: tv)
                context.removeSnapshots(rootView: tv)
                context.storeViewAlpha(rootView: fv)
                
                fromViewController!.motionStoredSnapshot = container
                fv.removeFromSuperview()
                fv.addSubview(container)
                
            } else if !isFinished && !isPresenting && fromOverFullScreen {
                // Cancelled dismissing a overFullScreen view controller.
                context.unhide(rootView: fv)
                context.removeSnapshots(rootView: fv)
                context.storeViewAlpha(rootView: tv)
                
                toViewController!.motionStoredSnapshot = container
                container.superview?.addSubview(tv)
                tv.addSubview(container)
                
            } else {
                context.unhideAll()
                context.removeAllSnapshots()
            }
            
            // Move fromView & toView back from our container back to the one supplied by UIKit.
            if (toOverFullScreen && isFinished) || (fromOverFullScreen && !isFinished) {
                transitionContainer?.addSubview(isFinished ? fv : tv)
            }
            
            transitionContainer?.addSubview(isFinished ? tv : fv)
            
            if isPresenting != isFinished, !isContainerController {
                // Only happens when present a .overFullScreen view controller.
                // bug: http://openradar.appspot.com/radar?id=5320103646199808
                UIApplication.shared.keyWindow?.addSubview(isPresenting ? fv : tv)
            }
        }
        
        if container.superview == transitionContainer {
            container.removeFromSuperview()
        }
        
        for a in animators {
            a.clean()
        }
        
        transitionContainer?.isUserInteractionEnabled = true
        
        completionCallback?(isFinished)
        
        let tContext = transitionContext
        let fvc = fromViewController
        let tvc = toViewController
        
        if isFinished {
            processEndTransitionDelegation(transitionContext: tContext, fromViewController: fvc, toViewController: tvc)
        } else {
            processCancelTransitionDelegation(transitionContext: tContext, fromViewController: fvc, toViewController: tvc)
            tContext?.cancelInteractiveTransition()
        }
        
        tContext?.completeTransition(isFinished)
    }
}
