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

public struct MotionConditionalContext {
    internal weak var motion: MotionTransition!
    public weak var view: UIView!
    
    public private(set) var isAppearing: Bool
    
    public var isPresenting: Bool {
        return motion.isPresenting
    }
    
    public var isTabBarController: Bool {
        return motion.isTabBarController
    }
    
    public var isNavigationController: Bool {
        return motion.isNavigationController
    }
    
    public var isMatched: Bool {
        return nil != matchedView
    }
    
    public var isAncestorViewMatched: Bool {
        return nil != matchedAncestorView
    }
    
    public var matchedView: UIView? {
        return motion.context.pairedView(for: view)
    }
    
    public var matchedAncestorView: (UIView, UIView)? {
        var current = view.superview
        
        while let ancestor = current, ancestor != motion.context.container {
            if let pairedView = motion.context.pairedView(for: ancestor) {
                return (ancestor, pairedView)
            }
            
            current = ancestor.superview
        }
        
        return nil
    }
    
    public var fromViewController: UIViewController {
        return motion.fromViewController!
    }
    
    public var toViewController: UIViewController {
        return motion.toViewController!
    }
    
    public var currentViewController: UIViewController {
        return isAppearing ? toViewController : fromViewController
    }
    
    public var otherViewController: UIViewController {
        return isAppearing ? fromViewController : toViewController
    }
}

class ConditionalPreprocessor: MotionCorePreprocessor {
    override func process(fromViews: [UIView], toViews: [UIView]) {
        process(views: fromViews, isAppearing: false)
        process(views: toViews, isAppearing: true)
    }
    
    func process(views: [UIView], isAppearing: Bool) {
        for v in views {
            guard let conditionalModifiers = context[v]?.conditionalModifiers else {
                continue
            }
            
            for (condition, modifiers) in conditionalModifiers {
                if condition(MotionConditionalContext(motion: motion, view: v, isAppearing: isAppearing)) {
                    context[v]!.append(contentsOf: modifiers)
                }
            }
        }
    }
}

