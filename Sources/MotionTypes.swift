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
  weak var context: MotionContext! { get set }
  func canAnimate(view: UIView, appearing: Bool) -> Bool
  func animate(fromViews: [UIView], toViews: [UIView]) -> TimeInterval
  func clean()

  func seekTo(timePassed: TimeInterval)
  func resume(timePassed: TimeInterval, reverse: Bool) -> TimeInterval
  func apply(state: MotionTargetState, to view: UIView)
}

public protocol MotionProgressUpdateObserver {
  func motionDidUpdateProgress(progress: Double)
}

@objc public protocol MotionViewControllerDelegate {
  @objc optional func motionWillStartAnimatingFrom(viewController: UIViewController)
  @objc optional func motionDidEndAnimatingFrom(viewController: UIViewController)
  @objc optional func motionDidCancelAnimatingFrom(viewController: UIViewController)

  @objc optional func motionWillStartTransition()
  @objc optional func motionDidEndTransition()
  @objc optional func motionDidCancelTransition()

  @objc optional func motionWillStartAnimatingTo(viewController: UIViewController)
  @objc optional func motionDidEndAnimatingTo(viewController: UIViewController)
  @objc optional func motionDidCancelAnimatingTo(viewController: UIViewController)
}
