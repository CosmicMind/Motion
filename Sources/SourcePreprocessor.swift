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

public class SourcePreprocessor: TransitionPreprocessor {
    /// A reference to a MotionContext.
    public weak var context: MotionContext!
    
    /**
     Implementation for processor.
     - Parameter fromViews: An Array of UIViews.
     - Parameter toViews: An Array of UIViews.
     */
    public func process(fromViews: [UIView], toViews: [UIView]) {
        prepare(fromViews: fromViews)
        prepare(toViews: toViews)
    }
}

extension SourcePreprocessor {
    /**
     Prepares the from views.
     - Parameter fromViews: An Array of UIViews.
     */
    fileprivate func prepare(fromViews: [UIView]) {
        for fv in fromViews {
            guard let identifier = context.viewToMotionTransitionState[fv]?.motionIdentifier else {
                continue
            }
            
            guard let tv = context.destinationIdentifierToView[identifier] else {
                continue
            }
            
            prepare(view: fv, for: tv)
        }
    }
    
    /**
     Prepares the to views.
     - Parameter fromViews: An Array of UIViews.
     */
    fileprivate func prepare(toViews: [UIView]) {
        for tv in context.toViews {
            guard let identifier = context.viewToMotionTransitionState[tv]?.motionIdentifier else {
                continue
            }
            
            guard let fv = context.sourceIdentifierToView[identifier] else {
                continue
            }
            
            prepare(view: tv, for: fv)
        }
    }
    
    fileprivate func prepare(view: UIView, for targetView: UIView) {
        guard var state = context.viewToMotionTransitionState[view] else {
            return
        }
        
        state.coordinateSpace = .global
        state.position = context.container.convert(targetView.layer.position, from: targetView.superview!)
        state.transform = nil
        state.size = nil
        state.cornerRadius = nil
        
        if view.bounds.size != targetView.bounds.size {
            state.size = targetView.bounds.size
        }
        
        if view.layer.cornerRadius != targetView.layer.cornerRadius {
            state.cornerRadius = targetView.layer.cornerRadius
        }
        
        if view.layer.transform != targetView.layer.transform {
            state.transform = targetView.layer.transform
        }
        
        if view.layer.shadowColor != targetView.layer.shadowColor {
            state.shadowColor = targetView.layer.shadowColor
        }
        
        if view.layer.shadowOpacity != targetView.layer.shadowOpacity {
            state.shadowOpacity = targetView.layer.shadowOpacity
        }
        
        if view.layer.shadowOffset != targetView.layer.shadowOffset {
            state.shadowOffset = targetView.layer.shadowOffset
        }
        
        if view.layer.shadowRadius != targetView.layer.shadowRadius {
            state.shadowRadius = targetView.layer.shadowRadius
        }
        
        if view.layer.shadowPath != targetView.layer.shadowPath {
            state.shadowPath = targetView.layer.shadowPath
        }
        
        if view.layer.contentsRect != targetView.layer.contentsRect {
            state.contentsRect = targetView.layer.contentsRect
        }
        
        if view.layer.contentsScale != targetView.layer.contentsScale {
            state.contentsScale = targetView.layer.contentsScale
        }
        
        context.viewToMotionTransitionState[view] = state
    }
}
