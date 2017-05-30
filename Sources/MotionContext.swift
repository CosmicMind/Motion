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

open class MotionContext {
    /// A reference to the transition container.
    fileprivate var transitionContainer: UIView
    
    /// An index source of identifiers to their corresponding view.
    fileprivate var transitionSourceIdentifierToView = [String: UIView]()
    
    /// An index of destination identifiers to their corresponding view.
    fileprivate var transitionDestinationIdentifierToView = [String: UIView]()
    
    /// An index of views to their corresponding snapshot view.
    fileprivate var transitionSnapshotToView = [UIView: UIView]()
    
    /// A reference to the transition from views.
    fileprivate var fromViews: [UIView]!
    
    /// A reference to the transition to views.
    fileprivate var toViews: [UIView]!
    
    /**
     An initializer that accepts a given transition container view.
     - Parameter transitionContainer: A UIView.
     */
    init(transitionContainer: UIView) {
        self.transitionContainer = transitionContainer
    }
}

extension MotionContext {
    /**
     Prepares the source views to their identifiers.
     - Parameter views: An Array of UIViews.
     - Parameter identifierIndex: An Dictionary of identifiers to UIViews.
     */
    fileprivate func prepare(views: [UIView], identifierIndex: inout [String: UIView]) {
        for v in views {
            v.layer.removeAllAnimations()
            
            guard transitionContainer.convert(v.bounds, from: v).intersects(transitionContainer.bounds) else {
                return
            }
            
            if let i = v.motionIdentifier {
                identifierIndex[i] = v
            }
        }
    }
}

extension MotionContext {
    /**
     Sets the views that will transition from one state to another.
     - Parameter fromViews: An Array of UIViews.
     - Parameter toViews: An Array of UIViews.
     */
    fileprivate func set(fromViews: [UIView], toViews: [UIView]) {
        self.fromViews = fromViews
        self.toViews = toViews
        prepare(views: fromViews, identifierIndex: &transitionSourceIdentifierToView)
        prepare(views: toViews, identifierIndex: &transitionDestinationIdentifierToView)
    }
}
