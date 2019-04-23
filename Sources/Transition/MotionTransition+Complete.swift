/*
 * The MIT License (MIT)
 *
 * Copyright (C) 2019, CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
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

extension MotionTransition {
  /**
   Complete the transition.
   - Parameter isFinishing: A Boolean indicating if the transition
   has completed.
   */
  @objc
  func complete(isFinishing: Bool) {
    if state == .notified {
      forceFinishing = isFinishing
    }
    
    guard .animating == state || .starting == state else {
      return
    }
    
    defer {
      transitionContext = nil
      fromViewController = nil
      toViewController = nil
      transitioningViewController = nil
      forceNonInteractive = false
      animatingToViews.removeAll()
      animatingFromViews.removeAll()
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
      progress = 0
      totalDuration = 0
      state = .possible
      defaultAnimation = .auto
      containerBackgroundColor = .black
      isModalTransition = false
    }
    
    state = .completing
    
    progressRunner.stop()
    context.clean()
    
    if let tv = toView, let fv = fromView {
      if isFinishing && isPresenting && toOverFullScreen {
        // finished presenting a overFullScreen view controller.
        context.unhide(rootView: tv)
        context.removeSnapshots(rootView: tv)
        context.storeViewAlpha(rootView: fv)
        
        fromViewController!.motionStoredSnapshot = container
        fv.removeFromSuperview()
        fv.addSubview(container)
        
      } else if !isFinishing && !isPresenting && fromOverFullScreen {
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
      if (toOverFullScreen && isFinishing) || (fromOverFullScreen && !isFinishing) {
        transitionContainer?.addSubview(isFinishing ? fv : tv)
      }
      
      transitionContainer?.addSubview(isFinishing ? tv : fv)
      
      if isPresenting != isFinishing, !isContainerController {
        // Only happens when present a .overFullScreen view controller.
        // bug: http://openradar.appspot.com/radar?id=5320103646199808
        Application.shared.keyWindow?.addSubview(isPresenting ? fv : tv)
      }
    }
    
    if container.superview == transitionContainer {
      container.removeFromSuperview()
    }
    
    for a in animators {
      a.clean()
    }
    
    transitionContainer?.isUserInteractionEnabled = true
    transitioningViewController?.view.isUserInteractionEnabled = true
    
    completionCallback?(isFinishing)
    
    if isFinishing {
      toViewController?.tabBarController?.tabBar.layer.removeAllAnimations()
    } else {
      fromViewController?.tabBarController?.tabBar.layer.removeAllAnimations()
    }
    
    let tContext = transitionContext
    let fvc = fromViewController
    let tvc = toViewController
    
    if isFinishing {
      processEndTransitionDelegation(transitionContext: tContext, fromViewController: fvc, toViewController: tvc)
    } else {
      processCancelTransitionDelegation(transitionContext: tContext, fromViewController: fvc, toViewController: tvc)
    }
    
    tContext?.completeTransition(isFinishing)
    
    let isModalDismissal = isModalTransition && !isPresenting
    if isModalDismissal {
      Application.shared.fixRootViewY()
    }
  }
}


private extension UIApplication {
  /**
   When in-call, hotspot, or recording status bar is enabled, just after (custom) modal
   dismissal transition animation ends `UITransitionView` is removed from the hierarchy
   and that removal was moving `rootViewController.view` 20 points upwards. This function
   should be called after transitioningContext.completeTransition(_:) upon modal dismissal
   transition. It applies the work that `UITransitionView` should ideally have done after
   custom modal dismissal. `UIKit` modal dismissals do not suffer from this.
   
   Fixes issue-44. See issue-44 for more info.
   */
  func fixRootViewY() {
    guard statusBarFrame.height == 40, let window = keyWindow, let vc = window.rootViewController else {
      return
    }
    
    if vc.view.frame.maxY + 20 == window.frame.height {
      vc.view.frame.origin.y += 20
    }
  }
}
