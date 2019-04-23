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

extension MotionTransition: UIViewControllerTransitioningDelegate {
  /// A reference to the interactive transitioning instance.
  var interactiveTransitioning: UIViewControllerInteractiveTransitioning? {
    return forceNonInteractive ? nil : self
  }
  
  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    guard !isTransitioning else {
      return nil
    }
    
    state = .notified
    isPresenting = true
    isModalTransition = true
    fromViewController = fromViewController ?? presenting
    toViewController = toViewController ?? presented
    
    return self
  }
  
  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    guard !isTransitioning else {
      return nil
    }
    
    state = .notified
    isPresenting = false
    isModalTransition = true
    fromViewController = fromViewController ?? dismissed
    return self
  }
  
  public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactiveTransitioning
  }
  
  public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactiveTransitioning
  }
}

extension MotionTransition: UIViewControllerAnimatedTransitioning {
  /**
   The animation method that is used to coordinate the transition.
   - Parameter using transitionContext: A UIViewControllerContextTransitioning.
   */
  public func animateTransition(using context: UIViewControllerContextTransitioning) {
    transitionContext = context
    fromViewController = fromViewController ?? context.viewController(forKey: .from)
    toViewController = toViewController ?? context.viewController(forKey: .to)
    transitionContainer = context.containerView
    
    start()
  }
  
  /**
   Returns the transition duration time interval.
   - Parameter using transitionContext: An optional UIViewControllerContextTransitioning.
   - Returns: A TimeInterval that is the total animation time including delays.
   */
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0 // Time will be updated dynamically.
  }
  
  public func animationEnded(_ transitionCompleted: Bool) {
    state = .possible
  }
}

extension MotionTransition: UIViewControllerInteractiveTransitioning {
  public var wantsInteractiveStart: Bool {
    return true
  }
  
  public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
    animateTransition(using: transitionContext)
  }
}
