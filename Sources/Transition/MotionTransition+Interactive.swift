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
    /**
     Updates the elapsed time for the interactive transition.
     - Parameter progress t: the current progress, must be between -1...1.
     */
    func update(_ percentageComplete: TimeInterval) {
        guard .animating == state else {
            startingProgress = percentageComplete
            return
        }
        
        progressRunner.stop()
        progress = Double(CGFloat(percentageComplete).clamp(0, 1))
    }
    
    /**
     Finish the interactive transition.
     Will stop the interactive transition and animate from the
     current state to the **end** state.
     - Parameter isAnimated: A Boolean.
     */
    func finish(isAnimated: Bool = true) {
        guard .animating == state || .notified == state || .starting == state else {
            return
        }
        
        guard isAnimated else {
            complete(isFinishing: true)
            return
        }
        
        var d: TimeInterval = 0
        
        for a in animators {
            d = max(d, a.resume(at: progress * totalDuration, isReversed: false))
        }
        
        complete(after: d, isFinishing: true)
    }
    
    /**
     Cancel the interactive transition.
     Will stop the interactive transition and animate from the
     current state to the **begining** state
     - Parameter isAnimated: A boolean indicating if the completion is animated.
     */
    func cancel(isAnimated: Bool = true) {
        guard .animating == state || .notified == state || .starting == state else {
            return
        }
        
        guard isAnimated else {
            complete(isFinishing: false)
            return
        }
        
        var d: TimeInterval = 0
        
        for a in animators {
            var t = progress
            if t < 0 {
                t = -t
            }
            
            d = max(d, a.resume(at: t * totalDuration, isReversed: true))
        }
        
        complete(after: d, isFinishing: false)
    }
    
    /**
     Override transition animations during an interactive animation.
     
     For example:
     
     Motion.shared.apply([.position(x:50, y:50)], to: view)
     
     will set the view's position to 50, 50
     - Parameter modifiers: An Array of MotionModifier.
     - Parameter to view: A UIView.
     */
    func apply(modifiers: [MotionModifier], to view: UIView) {
        guard .animating == state else {
            return
        }
        
        let targetState = MotionTargetState(modifiers: modifiers)
        if let otherView = context.pairedView(for: view) {
            for animator in animators {
                animator.apply(state: targetState, to: otherView)
            }
        }
        
        for animator in self.animators {
            animator.apply(state: targetState, to: view)
        }
    }
}
