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

class DurationPreprocessor: MotionPreprocessor {
    /// A reference to a MotionContext.
    weak var context: MotionContext!
    
    /**
     Implementation for processor.
     - Parameter fromViews: An Array of UIViews.
     - Parameter toViews: An Array of UIViews.
     */
    func process(fromViews: [UIView], toViews: [UIView]) {
        var maxDuration: TimeInterval = 0
        maxDuration = applyOptimizedDurationIfNoDuration(views:fromViews)
        maxDuration = max(maxDuration, applyOptimizedDurationIfNoDuration(views:toViews))
        setDurationForInfiniteDuration(views: fromViews, duration: maxDuration)
        setDurationForInfiniteDuration(views: toViews, duration: maxDuration)
    }

  func optimizedDurationFor(view: UIView) -> TimeInterval {
    let targetState = context[view]!
    return view.optimizedDuration(fromPosition: context.container.convert(view.layer.position, from: view.superview),
                                  toPosition: targetState.position,
                                  size: targetState.size,
                                  transform: targetState.transform)
  }

  func applyOptimizedDurationIfNoDuration(views: [UIView]) -> TimeInterval {
    var maxDuration: TimeInterval = 0
    for view in views where context[view] != nil {
      if context[view]?.duration == nil {
        context[view]!.duration = optimizedDurationFor(view: view)
      }
      if context[view]!.duration! == .infinity {
        maxDuration = max(maxDuration, optimizedDurationFor(view: view))
      } else {
        maxDuration = max(maxDuration, context[view]!.duration!)
      }
    }
    return maxDuration
  }

  func setDurationForInfiniteDuration(views: [UIView], duration: TimeInterval) {
    for view in views where context[view]?.duration == .infinity {
      context[view]!.duration = duration
    }
  }
}
