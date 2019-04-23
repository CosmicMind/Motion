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

internal class MotionCoreAnimator<T: MotionAnimatorViewContext>: MotionAnimator {
  /**
   Backing field for storing CACurrentMediaTime to ensure all
   animations begin at the exact same time.
   
   Should be invalidated using invalidateCurrentTime method
   after firing all animations.
   */
  private var storedCurrentTime: TimeInterval?
  
  /// Current time for the animator.
  var currentTime: TimeInterval {
    if nil == storedCurrentTime {
      storedCurrentTime = CACurrentMediaTime()
    }
    
    return storedCurrentTime!
  }
  
  /// Invalidates stored current time.
  func invalidateCurrentTime() {
    storedCurrentTime = nil
  }
  
  weak public var motion: MotionTransition!
  
  /// A reference to the MotionContext.
  public var context: MotionContext! {
    return motion.context
  }
  
  /// An index of views to their corresponding animator context.
  var viewToContexts = [UIView: T]()
  
  /// Cleans the contexts.
  func clean() {
    for v in viewToContexts.values {
      v.clean()
    }
    
    viewToContexts.removeAll()
    invalidateCurrentTime()
  }
  
  /**
   A function that determines if a view can be animated.
   - Parameter view: A UIView.
   - Parameter isAppearing: A boolean that determines whether the
   view is appearing.
   */
  func canAnimate(view: UIView, isAppearing: Bool) -> Bool {
    guard let state = targetState(for: view) else {
      return false
    }
    
    return T.canAnimate(view: view, state: state, isAppearing: isAppearing)
  }
  
  /**
   Animates the fromViews to the toViews.
   - Parameter fromViews: An Array of UIViews.
   - Parameter toViews: An Array of UIViews.
   - Returns: A TimeInterval.
   */
  func animate(fromViews: [UIView], toViews: [UIView]) -> TimeInterval {
    var d: TimeInterval = 0
    
    for v in fromViews {
      createViewContext(view: v, isAppearing: false)
    }
    
    for v in toViews {
      createViewContext(view: v, isAppearing: true)
    }
    
    for v in viewToContexts.values {
      if let duration = v.targetState.duration, .infinity != duration {
        v.duration = duration
        d = max(d, duration)
        
      } else {
        let duration = v.snapshot.optimizedDuration(targetState: v.targetState)
        
        if nil == v.targetState.duration {
          v.duration = duration
        }
        
        d = max(d, duration)
      }
    }
    
    for v in viewToContexts.values {
      if .infinity == v.targetState.duration {
        v.duration = d
      }
      
      d = max(d, v.startAnimations())
    }
    
    invalidateCurrentTime()
    
    return d
  }
  
  /**
   Moves the view's animation to the given elapsed time.
   - Parameter to progress: A TimeInterval.
   */
  func seek(to progress: TimeInterval) {
    for v in viewToContexts.values {
      v.seek(to: progress)
    }
    
    invalidateCurrentTime()
  }
  
  /**
   Resumes the animation with a given elapsed time and
   optional reversed boolean.
   - Parameter at progress: A TimeInterval.
   - Parameter isReversed: A boolean to reverse the animation
   or not.
   */
  func resume(at progress: TimeInterval, isReversed: Bool) -> TimeInterval {
    var duration: TimeInterval = 0
    
    for (_, v) in viewToContexts {
      duration = max(duration, v.resume(at: progress, isReversed: isReversed))
    }
    
    invalidateCurrentTime()
    return duration
  }
  
  /**
   Applies the given state to the given view.
   - Parameter state: A MotionModifier.
   - Parameter to view: A UIView.
   */
  func apply(state: MotionTargetState, to view: UIView) {
    guard let v = viewToContexts[view] else {
      return
    }
    
    v.apply(state: state)
    
    invalidateCurrentTime()
  }
  
  /**
   Returns MotionTargetState for the given view.
   - Parameter for view: A UIView.
   - Returns: A MotionTargetState.
   */
  func targetState(for view: UIView) -> MotionTargetState? {
    return context[view]
  }
  
  /**
   Returns snapshot view for the given view.
   - Parameter for view: A UIView.
   - Returns: A snapshot UIView.
   */
  func snapshotView(for view: UIView) -> UIView {
    return context.snapshotView(for: view)
  }
}

fileprivate extension MotionCoreAnimator {
  /**
   Creates a view context for a given view.
   - Parameter view: A UIView.
   - Parameter isAppearing: A boolean that determines whether the
   view is appearing.
   */
  func createViewContext(view: UIView, isAppearing: Bool) {
    viewToContexts[view] = T(animator: self, snapshot: snapshotView(for: view), targetState: targetState(for: view)!, isAppearing: isAppearing)
  }
}


