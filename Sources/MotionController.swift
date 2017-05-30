/*
 * Copyright (C) 2015 - 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit

open class MotionController: NSObject, MotionSubscriber {
    /// An optional reference to the animation display link.
    fileprivate var displayLink: CADisplayLink? {
        willSet {
            guard let v = displayLink else {
                return
            }
            
            v.isPaused = true
            v.remove(from: RunLoop.main, forMode: RunLoopMode(rawValue: RunLoopMode.commonModes.rawValue))
        }
        
        didSet {
            guard let v = displayLink else {
                return
            }
            
            v.add(to: RunLoop.main, forMode: RunLoopMode(rawValue: RunLoopMode.commonModes.rawValue))
        }
    }
    
    /// A reference to the animation duration.
    fileprivate var transitionDuration: TimeInterval = 0
    
    /**
     A reference to the animation total duration,
     which is the total running animation time.
     */
    fileprivate var transitionTotalDuration: TimeInterval = 0
    
    /// A reference to the animation start time.
    fileprivate var transitionStartTime: TimeInterval? {
        didSet {
            guard nil != transitionStartTime else {
                displayLink = nil
                return
            }
            
            guard nil == displayLink else {
                return
            }
            
            displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLinkUpdate(displayLink:)))
        }
    }
    
    /// A reference to the animation elapsed time.
    open fileprivate(set) var transitionElapsedTime: TimeInterval = 0 {
        didSet {
            guard isTransitioning else {
                return
            }
            
            updateMotionObservers()
            updateMotionAnimators()
        }
    }
    
    /// A reference to an Array of MotionObservers.
    open fileprivate(set) var observers = [MotionObserver]()
    
    /// A reference to an Array of MotionAnimators.
    open fileprivate(set) var animators = [MotionAnimator]()
    
    /// A boolean indicating if a transition is in progress.
    open var isTransitioning: Bool {
        return nil == transitionContainer
    }
    
    /// A boolean indicating if the animation is finished.
    open fileprivate(set) var isFinished = false
    
    /// A boolean indicating if the animation is interactive.
    open var isInteractive: Bool {
        return nil == displayLink
    }
    
    /// Transition container.
    open fileprivate(set) var transitionContainer: UIView!
    
    /// An Array of from and to view paris to be animated.
    open fileprivate(set) var transitionParis = [(fromViews: [UIView], toViews: [UIView])]()
}

extension MotionController {
    /**
     Retrieves all the subviews of a given view.
     - Parameter of view: A UIView.
     - Returns: An Array of UIViews.
     */
    fileprivate func subviews(of view: UIView) -> [UIView] {
        var views: [UIView] = []
        subviews(of: view, views: &views)
        return views
    }
    
    /**
     Populates an Array of UIViews with the subviews of a given view.
     - Parameter of view: A UIView.
     - Returns: An Array of UIViews.
     */
    fileprivate func subviews(of view: UIView, views: inout [UIView]) {
        for v in view.subviews {
            if nil != v.motionIdentifier {
                views.append(v)
            }
            subviews(of: v, views: &views)
        }
    }
}

extension MotionController {
    /**
     Handles the animation update for the display link.
     - Parameter displayLink: A CADisplayLink.animation
     */
    @objc
    fileprivate func handleDisplayLinkUpdate(displayLink: CADisplayLink) {
        guard isTransitioning else {
            return
        }
        
        guard 0 < transitionDuration else {
            return
        }
        
        guard let v = transitionStartTime else {
            return
        }
        
        var elapsedTime = CACurrentMediaTime() - v
        
        if elapsedTime > transitionDuration {
            transitionElapsedTime = isFinished ? 1 : 0
            completeTransition()
            
        } else {
            elapsedTime = elapsedTime / transitionDuration
            
            if !isFinished {
                elapsedTime = 1 - elapsedTime
            }
            
            transitionElapsedTime = max(0, min(1, elapsedTime))
        }
    }
}

extension MotionController {
    fileprivate func updateMotionObservers() {
        for v in observers {
            v.update(elapsedTime: transitionElapsedTime)
        }
    }
    
    /// Updates the motion animators.
    fileprivate func updateMotionAnimators() {
        let elapsedTime = transitionElapsedTime * transitionTotalDuration
        
        for v in animators {
            v.seekTo(elapsedTime: elapsedTime)
        }
    }
}

extension MotionController {
    /// Completes the transition.
    fileprivate func completeTransition() {
        cleanMotionAnimators()
        cleanTransitionValues()
    }
    
    /// Cleans the motion animators Array.
    fileprivate func cleanMotionAnimators() {
        for v in animators {
            v.clean()
        }
    }
    
    /// Cleans the transition values.
    fileprivate func cleanTransitionValues() {
        transitionStartTime = nil
        transitionElapsedTime = 0
        transitionTotalDuration = 0
    }
}
