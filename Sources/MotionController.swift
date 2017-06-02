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

public class MotionController: NSObject, MotionSubscriber {
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
    fileprivate var duration: TimeInterval = 0
    
    /**
     A reference to the animation total duration,
     which is the total running animation time.
     */
    fileprivate var totalDuration: TimeInterval = 0
    
    /// A reference to the animation start time.
    fileprivate var startTime: TimeInterval? {
        didSet {
            guard nil != startTime else {
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
    public internal(set) var elapsedTime: TimeInterval = 0 {
        didSet {
            guard isTransitioning else {
                return
            }
            
            updateMotionObservers()
            updateMotionAnimators()
        }
    }
    
    /// A reference to a MotionContext.
    public internal(set) var context: MotionContext!
    
    /// A reference to an Array of MotionObservers.
    public internal(set) var observers = [MotionObserver]()
    
    /// A reference to an Array of MotionTransitionAnimator.
    public internal(set) var animators = [MotionTransitionAnimator]()
    
    /// A reference to the preprocessors.
    public internal(set) var preprocessors = [MotionTransitionPreprocessor]()
    
    /// A boolean indicating if a transition is in progress.
    public var isTransitioning: Bool {
        return nil == transitionContainer
    }
    
    /// A boolean indicating if the animation is finished.
    public fileprivate(set) var isFinished = false
    
    /// A boolean indicating if the animation is interactive.
    public var isInteractive: Bool {
        return nil == displayLink
    }
    
    /// An Array of from and to view paris to be animated.
    public fileprivate(set) var transitionParis = [(fromViews: [UIView], toViews: [UIView])]()
    
    /**
     An animation container used within the transitionContainer
     during a transition.
     */
    public fileprivate(set) var container: UIView!
    
    /// Transition container.
    public internal(set) var transitionContainer: UIView! {
        didSet {
            container = UIView(frame: transitionContainer.bounds)
            transitionContainer.addSubview(container)
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
        
        guard 0 < duration else {
            return
        }
        
        guard let v = startTime else {
            return
        }
        
        var t = CACurrentMediaTime() - v
        
        if t > duration {
            elapsedTime = isFinished ? 1 : 0
            completeTransition()
            
        } else {
            t = t / duration
            
            if !isFinished {
                t = 1 - t
            }
            
            elapsedTime = max(0, min(1, t))
        }
    }
}

extension MotionController {
    fileprivate func updateMotionObservers() {
        for v in observers {
            v.update(elapsedTime: elapsedTime)
        }
    }
    
    /// Updates the motion animators.
    fileprivate func updateMotionAnimators() {
        let t = elapsedTime * totalDuration
        
        for v in animators {
            v.seekTo(elapsedTime: t)
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
        startTime = nil
        elapsedTime = 0
        totalDuration = 0
    }
}
