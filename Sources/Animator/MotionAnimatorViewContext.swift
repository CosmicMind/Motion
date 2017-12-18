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

internal class MotionAnimatorViewContext {
    /// An optional reference to a MotionAnimator.
    var animator: MotionAnimator?
    
    /// A reference to the snapshot UIView.
    var snapshot: UIView
    
    /// The animation target state.
    var targetState: MotionTargetState
    
    /// A boolean indicating if the view is appearing.
    var isAppearing: Bool

    /// Animation duration time.
    var duration: TimeInterval = 0
    
    /// The computed current time of the snapshot layer.
    var currentTime: TimeInterval {
        return snapshot.layer.convertTime(CACurrentMediaTime(), from: nil)
    }
    
    /// A container view for the transition.
    var container: UIView? {
        return animator?.motion.context.container
    }

    /**
     An initializer. 
     - Parameter animator: A MotionAnimator.
     - Parameter snapshot: A UIView.
     - Parameter targetState: A MotionModifier.
     - Parameter isAppearing: A Boolean.
     */
    required init(animator: MotionAnimator, snapshot: UIView, targetState: MotionTargetState, isAppearing: Bool) {
        self.animator = animator
        self.snapshot = snapshot
        self.targetState = targetState
        self.isAppearing = isAppearing
    }

    /// Cleans the context.
    func clean() {
        animator = nil
    }
    
    /**
     A class function that determines if a view can be animated
     to a given state.
     - Parameter view: A UIView.
     - Parameter state: A MotionModifier.
     - Parameter isAppearing: A boolean that determines whether the
     view is appearing.
     */
    class func canAnimate(view: UIView, state: MotionTargetState, isAppearing: Bool) -> Bool {
        return false
    }

    /**
     Resumes the animation with a given elapsed time and
     optional reversed boolean.
     - Parameter at progress: A TimeInterval.
     - Parameter isReversed: A boolean to reverse the animation 
     or not.
     - Returns: A TimeInterval.
     */
    @discardableResult
    func resume(at progress: TimeInterval, isReversed: Bool) -> TimeInterval {
        return 0
    }
    
    /**
     Moves the animation to the given elapsed time.
     - Parameter to progress: A TimeInterval.
     */
    func seek(to progress: TimeInterval) {}

    /**
     Applies the given state to the target state.
     - Parameter state: A MotionModifier.
     */
    func apply(state: MotionTargetState) {}
    
    /**
     Starts the animations with an appearing boolean flag.
     - Parameter isAppearing: A boolean value whether the view
     is appearing or not.
     */
    @discardableResult
    func startAnimations() -> TimeInterval {
        return 0
    }
}
