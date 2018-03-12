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

extension MotionTransition {
  /// Starts the transition animation.
  func animate() {
    guard .starting == state else {
      return
    }
    
    state = .animating
    
    if let tv = toView {
      context.unhide(view: tv)
    }
    
    for v in animatingFromViews {
      context.hide(view: v)
    }
    
    for v in animatingToViews {
      context.hide(view: v)
    }
    
    var t: TimeInterval = 0
    var animatorWantsInteractive = false
    
    if context.insertToViewFirst {
      for v in animatingToViews {
        context.snapshotView(for: v)
      }
      
      for v in animatingFromViews {
        context.snapshotView(for: v)
      }
      
    } else {
      for v in animatingFromViews {
        context.snapshotView(for: v)
      }
      
      for v in animatingToViews {
        context.snapshotView(for: v)
      }
    }
    
    // UIKit appears to set fromView setNeedLayout to be true.
    // We don't want fromView to layout after our animation starts.
    // Therefore we kick off the layout beforehand
    fromView?.layoutIfNeeded()
    for animator in animators {
      let duration = animator.animate(fromViews: animatingFromViews.filter {
        return animator.canAnimate(view: $0, isAppearing: false)
        }, toViews: animatingToViews.filter {
          return animator.canAnimate(view: $0, isAppearing: true)
      })
      
      if .infinity == duration {
        animatorWantsInteractive = true
      } else {
        t = max(t, duration)
      }
    }
    
    totalDuration = t
    
    if let forceFinishing = forceFinishing {
      complete(isFinishing: forceFinishing)
    } else if let startingProgress = startingProgress {
      update(startingProgress)
    } else if animatorWantsInteractive {
      update(0)
    } else {
      complete(after: totalDuration, isFinishing: true)
    }
    
    fullScreenSnapshot?.removeFromSuperview()
  }
}

