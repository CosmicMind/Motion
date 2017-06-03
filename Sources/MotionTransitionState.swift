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

internal class MotionTransitionStateWrapper {
    /// A reference to a MotionTransitionState.
    internal var state: MotionTransitionState

    /**
     An initializer that accepts a given MotionTransitionState.
     - Parameter state: A MotionTransitionState.
     */
    internal init(state: MotionTransitionState) {
        self.state = state
    }
}

public struct MotionTransitionState {
    /// An optional reference to the start state of the view.
    internal var startState: MotionTransitionStateWrapper?

    /// A reference to the motion identifier.
    public var motionIdentifier: String?

    public var startStateIfMatched: [MotionTransition]?

    public var position: CGPoint?
    public var size: CGSize?
    public var transform: CATransform3D?
    public var opacity: Float?
    public var cornerRadius: CGFloat?
    public var backgroundColor: CGColor?
    public var zPosition: CGFloat?

    public var contentsRect: CGRect?
    public var contentsScale: CGFloat?

    public var borderWidth: CGFloat?
    public var borderColor: CGColor?

    public var shadowColor: CGColor?
    public var shadowOpacity: Float?
    public var shadowOffset: CGSize?
    public var shadowRadius: CGFloat?
    public var shadowPath: CGPath?
    public var masksToBounds: Bool?
    public var displayShadow: Bool = true

    public var overlay: (color: CGColor, opacity: CGFloat)?

    public var spring: (CGFloat, CGFloat)?
    public var delay: TimeInterval = 0
    public var duration: TimeInterval?

    public var timingFunction: MotionAnimationTimingFunction?

    public var arc: CGFloat?
    public var cascade: (TimeInterval, MotionCascadeDirection, Bool)?

    public var ignoreSubviewTransitionAnimations: Bool?
    public var coordinateSpace: MotionCoordinateSpace?
    public var useScaleBasedSizeChange: Bool?
    public var motionSnapshot: MotionSnapshot?

    public var forceAnimate: Bool = false
    public var custom: [String:Any]?

    init(transitionAnimations: [MotionTransition]) {
        append(contentsOf: transitionAnimations)
    }

    public mutating func append(_ transitionAnimations: MotionTransition) {
        transitionAnimations.apply(&self)
    }

    public mutating func append(contentsOf transitionAnimations: [MotionTransition]) {
        for v in transitionAnimations {
            v.apply(&self)
        }
    }
}

extension MotionTransitionState: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: MotionTransition...) {
        append(contentsOf: elements)
    }
}

