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

public protocol MotionPreprocessor: class {
    weak var context: MotionContext! { get set }
    func process(fromViews: [UIView], toViews: [UIView])
}

public protocol MotionAnimator: class {
    /// A reference to a MotionContext.
    weak var context: MotionContext! { get set }

    /// Cleans the contexts.
    func clean()
    
    /**
     A function that determines if a view can be animated.
     - Parameter view: A UIView.
     - Parameter isAppearing: A boolean that determines whether the
     view is appearing.
     */
    func canAnimate(view: UIView, isAppearing: Bool) -> Bool
    
    /**
     Animates the from-views to the to-views.
     - Parameter fromViews: An Array of UIViews.
     - Parameter toViews: An Array of UIViews.
     - Returns: A TimeInterval.
     */
    func animate(fromViews: [UIView], toViews: [UIView]) -> TimeInterval
  
    /**
     Moves the view's animation to the given elapsed time.
     - Parameter to elapsedTime: A TimeInterval.
     */
    func seek(to elapsedTime: TimeInterval)
    
    /**
     Resumes the animation with a given elapsed time and
     optional reversed boolean.
     - Parameter at elapsedTime: A TimeInterval.
     - Parameter isReversed: A boolean to reverse the animation
     or not.
     */
    func resume(at elapsedTime: TimeInterval, isReversed: Bool) -> TimeInterval
    
    /**
     Applies the given state to the given view.
     - Parameter state: A MotionTargetState.
     - Parameter to view: A UIView.
     */
    func apply(state: MotionTargetState, to view: UIView)
}

public protocol MotionProgressUpdateObserver {
    func motionDidUpdateProgress(progress: Double)
}

@objc(MotionViewControllerDelegate)
public protocol MotionViewControllerDelegate {
    @objc
    optional func motionWillStartAnimatingFrom(viewController: UIViewController)
    
    @objc
    optional func motionDidEndAnimatingFrom(viewController: UIViewController)
    
    @objc
    optional func motionDidCancelAnimatingFrom(viewController: UIViewController)

    @objc
    optional func motionWillStartTransition()
    
    @objc
    optional func motionDidEndTransition()
    
    @objc
    optional func motionDidCancelTransition()

    @objc
    optional func motionWillStartAnimatingTo(viewController: UIViewController)
    
    @objc
    optional func motionDidEndAnimatingTo(viewController: UIViewController)
    
    @objc
    optional func motionDidCancelAnimatingTo(viewController: UIViewController)
}
