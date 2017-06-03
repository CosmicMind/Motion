// The MIT License (MIT)
//
// Copyright (c) 2016 Luke Zhao <me@lkzhao.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

public class DurationPreprocessor: TransitionPreprocessor {
    /// A reference to a MotionContext.
    public weak var context: MotionContext!
    
    /**
     Implementation for processor.
     - Parameter fromViews: An Array of UIViews.
     - Parameter toViews: An Array of UIViews.
     */
    public func process(fromViews: [UIView], toViews: [UIView]) {
        var duration: TimeInterval = 0
        duration = applyOptimizedDuration(for: fromViews)
        duration = max(duration, applyOptimizedDuration(for: toViews))
        
        set(duration: duration, for: fromViews)
        set(duration: duration, for: toViews)
    }
}

extension DurationPreprocessor {
    fileprivate func set(duration: TimeInterval, for views: [UIView]) {
        for view in views where .infinity == context.viewToMotionTransitionState[view]?.duration {
            context.viewToMotionTransitionState[view]?.duration = duration
        }
    }
    
    fileprivate func applyOptimizedDuration(for views: [UIView]) -> TimeInterval {
        var duration: TimeInterval = 0
        
        for v in views {
            guard var state = context.viewToMotionTransitionState[v] else {
                continue
            }
            
            if state.duration == nil {
                state.duration = optimizedDuration(for: v)
            }
            
            if state.duration! == .infinity {
                duration = max(duration, optimizedDuration(for: v))
            } else {
                duration = max(duration, state.duration!)
            }
        }
        
        return duration
    }
    
    fileprivate func optimizedDuration(for view: UIView) -> TimeInterval {
        guard let state = context.viewToMotionTransitionState[view] else {
            return 0
        }
        
        return view.optimizedDuration(fromPosition: context.container.convert(view.layer.position, from: view.superview), toPosition: state.position, size: state.size, transform: state.transform)
    }
}
