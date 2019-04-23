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

@available(iOS 10, tvOS 10, *)
internal class MotionViewPropertyViewContext: MotionAnimatorViewContext {
  /// A reference to the UIViewPropertyAnimator.
  fileprivate var viewPropertyAnimator: UIViewPropertyAnimator!
  
  /// Ending effect.
  fileprivate var endEffect: UIVisualEffect?
  
  /// Starting effect.
  fileprivate var startEffect: UIVisualEffect?
  
  override class func canAnimate(view: UIView, state: MotionTargetState, isAppearing: Bool) -> Bool {
    return view is UIVisualEffectView && nil != state.opacity
  }
  
  override func resume(at progress: TimeInterval, isReversed: Bool) -> TimeInterval {
    guard let visualEffectView = snapshot as? UIVisualEffectView else {
      return 0
    }
    
    if isReversed {
      viewPropertyAnimator?.stopAnimation(false)
      viewPropertyAnimator?.finishAnimation(at: .current)
      viewPropertyAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) { [weak self] in
        guard let `self` = self else {
          return
        }
        
        visualEffectView.effect = isReversed ? self.startEffect : self.endEffect
      }
    }
    
    viewPropertyAnimator.startAnimation()
    
    return duration
  }
  
  override func seek(to progress: TimeInterval) {
    viewPropertyAnimator?.pauseAnimation()
    viewPropertyAnimator?.fractionComplete = CGFloat(progress / duration)
  }
  
  override func clean() {
    super.clean()
    viewPropertyAnimator?.stopAnimation(false)
    viewPropertyAnimator?.finishAnimation(at: .current)
    viewPropertyAnimator = nil
  }
  
  override func startAnimations() -> TimeInterval {
    guard let visualEffectView = snapshot as? UIVisualEffectView else {
      return 0
    }
    
    let appearedEffect = visualEffectView.effect
    let disappearedEffect = 0 == targetState.opacity ? nil : visualEffectView.effect
    
    startEffect = isAppearing ? disappearedEffect : appearedEffect
    endEffect = isAppearing ? appearedEffect : disappearedEffect
    
    visualEffectView.effect = startEffect
    
    viewPropertyAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) { [weak self] in
      guard let `self` = self else {
        return
      }
      
      visualEffectView.effect = self.endEffect
    }
    
    viewPropertyAnimator.startAnimation()
    
    return duration
  }
}
