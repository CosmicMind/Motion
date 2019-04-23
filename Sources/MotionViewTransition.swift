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

private var MotionViewTransitionKey: UInt8 = 0

public extension UIView {
  /// The MotionViewTransition instance associated with the view.
  var motionViewTransition: MotionViewTransition {
    get {
      return AssociatedObject.get(base: self, key: &MotionViewTransitionKey) {
        MotionViewTransition(self)
      }
    }
  }
}

open class MotionViewTransition {
  /// A MotionViewTransitionAnimator used during a transition.
  private let animator = MotionViewTransitionAnimator()
  
  /// A UIView whose subviews and itself will be animating during a transition.
  private weak var container: UIView?
  
  /// Maximum duration of the animations.
  open private(set) var totalDuration: TimeInterval = 0
  
  /// Progress of the current transition.
  open private(set) var progress: CGFloat = 0
  
  /// A Boolean to control if the models should be updated when animations end.
  open var shouldUpdateModels: Bool = true
  
  /// Current duration of the animations based on totalDuration and progress.
  private var currentDuration: TimeInterval {
    return totalDuration * Double(progress)
  }
  
  /**
   An initializer that accepts a container transition view.
   - Parameter container: A UIView.
   */
  fileprivate init(_ container: UIView) {
    self.container = container
  }
  
  /// Prepares the transition animations.
  open func start() {
    guard let v = container else {
      return
    }
    
    totalDuration = animator.animate(fromViews: v.flattenedViewHierarchy, toViews: [])
    update(0)
  }
  
  /**
   Updates the elapsed time for the transition.
   - Parameter progress: the current progress.
   */
  open func update(_ progress: CGFloat) {
    self.progress = progress.clamp(0, 1)
    animator.seek(to: currentDuration)
  }
  
  /**
   Cancels the interactive transition by animatin from the current state
   to the **beginning** state.
   - Parameter isAnimated: A boolean indicating if the completion is animated.
   */
  open func cancel(isAnimated: Bool = true) {
    end(isAnimated: isAnimated, isReversed: true)
  }
  
  /**
   Finishes the interactive transition by animating from the current state
   to the **end** state.
   - Parameter isAnimated: A Boolean indicating if the completion is animated.
   */
  open func finish(isAnimated: Bool = true) {
    end(isAnimated: isAnimated, isReversed: false)
  }
  
  deinit {
    clean()
  }
}

private extension MotionViewTransition {
  /**
   Ends the interactive transition by animating from the current state
   to the **beginning** or **end** state based on the value of isReversed.
   - Parameter isAnimated: A Boolean indicating if the completion is animated.
   - Parameter isReversed: A Boolean indicating the direction of completion.
   */
  func end(isAnimated: Bool, isReversed: Bool) {
    let duration = isAnimated ? currentDuration : isReversed ? 0 : totalDuration
    
    /// 0.00001 is to make sure that animator adds the animations on resume.
    let after = animator.resume(at: abs(duration - 0.00001), isReversed: isReversed)
    updateModels()
    if isAnimated {
      Motion.delay(after, execute: complete)
    } else {
      complete()
    }
  }
  
  /// Finalizes the transition.
  func complete() {
    removeAnimations()
    clean()
  }
  
  /// Resets the transition.
  func clean() {
    animator.clean()
    totalDuration = 0
    progress = 0
  }
}

private extension MotionViewTransition {
  /// Updates the layers with final values of animations.
  func updateModels() {
    guard shouldUpdateModels else {
      return
    }
    
    walkingThroughAnimations { layer, _, anim in
      /// bounds.size somehow is directly set on the layer.
      let toValue = anim.keyPath == "bounds.size" ? layer.bounds.size : anim.toValue
      layer.setValue(toValue, forKeyPath: anim.keyPath!)
    }
  }
  
  /// Removes added animations from layers.
  func removeAnimations() {
    guard shouldUpdateModels else {
      return
    }
    
    walkingThroughAnimations { layer, key, _ in
      layer.removeAnimation(forKey: key)
    }
  }
  
  /**
   Walks through each layer's animation and executes give closure with
   CALayer, animation key String, and CABasicAnimation.
   - Parameter execute: A closure accepting CALayer, String, and CABasicAnimation
   which is called for each layer's animation.
   */
  func walkingThroughAnimations(execute: (CALayer, String, CABasicAnimation) -> Void) {
    animator.viewToContexts.keys.forEach { v in
      v.layer.animations.forEach { key, animation in
        if let anim = animation as? CABasicAnimation {
          execute(v.layer, key, anim)
        }
      }
    }
  }
}
