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

public class MatchPreprocessor: TransitionPreprocessor {
    /// A reference to a MotionContext.
    public weak var context: MotionContext!
    
    /**
     Implementation for processor.
     - Parameter fromViews: An Array of UIViews.
     - Parameter toViews: An Array of UIViews.
     */
    public func process(fromViews: [UIView], toViews: [UIView]) {
        for tv in toViews {
            guard let identifier = tv.motionIdentifier else {
                return
            }
            
            guard let fv = context.sourceIdentifierToView[identifier] else {
                continue
            }
            
            var tvState = context.viewToMotionTransitionState[tv] ?? MotionTransitionState()
            var fvState = context.viewToMotionTransitionState[fv] ?? MotionTransitionState()
            
            if let v = tvState.startStateIfMatched {
                tvState.append(.startWith(animations: v))
            }
            
            if let v = fvState.startStateIfMatched {
                fvState.append(.startWith(animations: v))
            }
            
            fvState.motionIdentifier = identifier
            fvState.arc = tvState.arc
            fvState.duration = tvState.duration
            fvState.timingFunction = tvState.timingFunction
            fvState.delay = tvState.delay
            fvState.spring = tvState.spring
            
            tvState.motionIdentifier = identifier
            tvState.opacity = 0
            
            if !fv.isOpaque || fv.alpha < 1 || !tv.isOpaque || tv.alpha < 1 {
                fvState.opacity = 0
            } else {
                fvState.opacity = nil
                
                if !fv.layer.masksToBounds && fvState.displayShadow {
                    tvState.displayShadow = false
                }
            }
            
            context.viewToMotionTransitionState[tv] = tvState
            context.viewToMotionTransitionState[fv] = fvState
        }
    }
}
