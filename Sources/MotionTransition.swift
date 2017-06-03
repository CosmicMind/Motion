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

public final class MotionTransition {
    /// A reference to the callback that applies the MotionTransitionState.
    internal let apply: (inout MotionTransitionState) -> Void
    
    /**
    An initializer that accepts a given callback. 
     - Parameter applyFunction: A given callback.
     */
    public init(applyFunction: @escaping (inout MotionTransitionState) -> Void) {
        apply = applyFunction
    }
}

extension MotionTransition {
    /**
     Animates the view with a matching motion identifier.
     - Parameter _ identifier: A String.
     - Returns: A MotionTransition.
     */
    public static func motionIdentifier(_ identifier: String) -> MotionTransition {
        return MotionTransition {
            $0.motionIdentifier = identifier
        }
    }
    
    /**
     Animates the view's current background color to the
     given color.
     - Parameter color: A UIColor.
     - Returns: A MotionTransition.
     */
    public static func background(color: UIColor) -> MotionTransition {
        return MotionTransition {
            $0.backgroundColor = color.cgColor
        }
    }
    
    /**
     Animates the view's current border color to the
     given color.
     - Parameter color: A UIColor.
     - Returns: A MotionTransition.
     */
    public static func border(color: UIColor) -> MotionTransition {
        return MotionTransition {
            $0.borderColor = color.cgColor
        }
    }
    
    /**
     Animates the view's current border width to the
     given width.
     - Parameter width: A CGFloat.
     - Returns: A MotionTransition.
     */
    public static func border(width: CGFloat) -> MotionTransition {
        return MotionTransition {
            $0.borderWidth = width
        }
    }
    
    /**
     Animates the view's current corner radius to the
     given radius.
     - Parameter radius: A CGFloat.
     - Returns: A MotionTransition.
     */
    public static func corner(radius: CGFloat) -> MotionTransition {
        return MotionTransition {
            $0.cornerRadius = radius
        }
    }
    
    /**
     Animates the view's current transform (perspective, scale, rotation)
     to the given one.
     - Parameter _ transform: A CATransform3D.
     - Returns: A MotionTransition.
     */
    public static func transform(_ transform: CATransform3D) -> MotionTransition {
        return MotionTransition {
            $0.transform = transform
        }
    }
    
    /**
     Animates the view's current perspective to the gievn one through
     a CATransform3D object.
     - Parameter _ perspective: A CGFloat.
     - Returns: A MotionTransition.
     */
    public static func perspective(_ perspective: CGFloat) -> MotionTransition {
        return MotionTransition {
            var t = $0.transform ?? CATransform3DIdentity
            t.m34 = 1 / -perspective
            $0.transform = t
        }
    }
    
    /**
     Animates the view's current rotation to the given x, y,
     and z values.
     - Parameter x: A CGFloat.
     - Parameter y: A CGFloat.
     - Parameter z: A CGFloat.
     - Returns: A MotionTransition.
     */
    public static func rotation(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> MotionTransition {
        return MotionTransition {
            var t = $0.transform ?? CATransform3DIdentity
            t = CATransform3DRotate(t, x, 1, 0, 0)
            t = CATransform3DRotate(t, y, 0, 1, 0)
            $0.transform = CATransform3DRotate(t, z, 0, 0, 1)
        }
    }
    
    /**
     Animates the view's current rotation to the given point.
     - Parameter _ point: A CGPoint.
     - Parameter z: A CGFloat, default is 0.
     - Returns: A MotionTransition.
     */
    public static func rotation(_ point: CGPoint, z: CGFloat = 0) -> MotionTransition {
        return .rotation(x: point.x, y: point.y, z: z)
    }
    
    /**
     Animates the view's current scale to the given x, y, z scale values.
     - Parameter x: A CGFloat.
     - Parameter y: A CGFloat.
     - Parameter z: A CGFloat.
     - Returns: A MotionTransition.
     */
    public static func scale(x: CGFloat = 1, y: CGFloat = 1, z: CGFloat = 1) -> MotionTransition {
        return MotionTransition {
            $0.transform = CATransform3DScale($0.transform ?? CATransform3DIdentity, x, y, z)
        }
    }
    
    /**
     Animates the view's current x & y scale to the given scale value.
     - Parameter to scale: A CGFloat.
     - Returns: A MotionTransition.
     */
    public static func scale(to scale: CGFloat) -> MotionTransition {
        return .scale(x: scale, y: scale)
    }
    
    /**
     Animates the view's current translation to the given
     x, y, and z values.
     - Parameter x: A CGFloat.
     - Parameter y: A CGFloat.
     - Parameter z: A CGFloat.
     - Returns: A MotionTransition.
     */
    public static func translate(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> MotionTransition {
        return MotionTransition {
            $0.transform = CATransform3DTranslate($0.transform ?? CATransform3DIdentity, x, y, z)
        }
    }
    
    /**
     Animates the view's current translation to the given
     point value (x & y), and a z value.
     - Parameter to point: A CGPoint.
     - Parameter z: A CGFloat, default is 0.
     - Returns: A MotionTransition.
     */
    public static func translate(to point: CGPoint, z: CGFloat = 0) -> MotionTransition {
        return .translate(x: point.x, y: point.y, z: z)
    }
    
    /**
     Animates the view's current position to the given point.
     - Parameter to point: A CGPoint.
     - Returns: A MotionTransition.
     */
    public static func position(to point: CGPoint) -> MotionTransition {
        return MotionTransition {
            $0.position = point
        }
    }

    /// Fades the view out during a transition.
    public static var fadeOut = MotionTransition {
        $0.opacity = 0
    }
    
    /// Fades the view in during a transition.
    public static var fadeIn = MotionTransition {
        $0.opacity = 1
    }
    
    /**
     Animates the view's current opacity to the given one.
     - Parameter to opacity: A Float value.
     - Returns: A MotionTransition.
     */
    public static func fade(to opacity: Float) -> MotionTransition {
        return MotionTransition {
            $0.opacity = opacity
        }
    }
    
    /**
     Animates the view's current zPosition to the given position.
     - Parameter _ position: An Int.
     - Returns: A MotionTransition.
     */
    public static func zPosition(_ position: CGFloat) -> MotionTransition {
        return MotionTransition {
            $0.zPosition = position
        }
    }

    /**
     Animates the view's current size to the given one.
     - Parameter _ size: A CGSize.
     - Returns: A MotionTransition.
     */
    public static func size(_ size: CGSize) -> MotionTransition {
        return MotionTransition {
            $0.size = size
        }
    }
    
    /**
     Animates the view's current shadow path to the given one.
     - Parameter path: A CGPath.
     - Returns: A MotionTransition.
     */
    public static func shadow(path: CGPath) -> MotionTransition {
        return MotionTransition {
            $0.shadowPath = path
        }
    }
    
    /**
     Animates the view's current shadow color to the given one.
     - Parameter color: A UIColor.
     - Returns: A MotionTransition.
     */
    public static func shadow(color: UIColor) -> MotionTransition {
        return MotionTransition {
            $0.shadowColor = color.cgColor
        }
    }
    
    /**
     Animates the view's current shadow offset to the given one.
     - Parameter offset: A CGSize.
     - Returns: A MotionTransition.
     */
    public static func shadow(offset: CGSize) -> MotionTransition {
        return MotionTransition {
            $0.shadowOffset = offset
        }
    }
    
    /**
     Animates the view's current shadow opacity to the given one.
     - Parameter opacity: A CGFloat.
     - Returns: A MotionTransition.
     */
    public static func shadow(opacity: CGFloat) -> MotionTransition {
        return MotionTransition {
            $0.shadowOpacity = Float(opacity)
        }
    }
    
    /**
     Animates the view's current shadow radius to the given one.
     - Parameter radius: A CGFloat.
     - Returns: A MotionTransition.
     */
    public static func shadow(radius: CGFloat) -> MotionTransition {
        return MotionTransition {
            $0.shadowRadius = radius
        }
    }

    /**
     Animates the view's contents rect to the given one.
     - Parameter rect: A CGRect.
     - Returns: A MotionTransition.
     */
    public static func contents(rect: CGRect) -> MotionTransition {
        return MotionTransition {
            $0.contentsRect = rect
        }
    }
    
    /**
     Animates the view's contents scale to the given one.
     - Parameter scale: A CGFloat.
     - Returns: A MotionTransition.
     */
    public static func contents(scale: CGFloat) -> MotionTransition {
        return MotionTransition {
            $0.contentsScale = scale
        }
    }

    /**
     The duration of the view's animation.
     - Parameter _ duration: A TimeInterval.
     - Returns: A MotionTransition.
     */
    public static func duration(_ duration: TimeInterval) -> MotionTransition {
        return MotionTransition {
            $0.duration = duration
        }
    }
    
    /**
     Sets the view's animation duration to the longest
     running animation within a transition.
     */
    public static var preferredDurationMatchesLongest = MotionTransition.duration(.infinity)
    
    /**
     Delays the animation of a given view.
     - Parameter _ time: TimeInterval.
     - Returns: A MotionTransition.
     */
    public static func delay(_ time: TimeInterval) -> MotionTransition {
        return MotionTransition {
            $0.delay = time
        }
    }
    
    /**
     Sets the view's timing function for the animation.
     - Parameter _ timingFunction: A MotionAnimationTimingFunction.
     - Returns: A MotionTransition.
     */
    public static func timingFunction(_ timingFunction: MotionAnimationTimingFunction) -> MotionTransition {
        return MotionTransition {
            $0.timingFunction = timingFunction
        }
    }
    
    /**
     Available in iOS 9+, animates a view using the spring API, 
     given a stiffness and damping.
     - Parameter stiffness: A CGFlloat.
     - Parameter damping: A CGFloat.
     - Returns: A MotionTransition.
     */
    @available(iOS 9, *)
    public static func spring(stiffness: CGFloat, damping: CGFloat) -> MotionTransition {
        return MotionTransition {
            $0.spring = (stiffness, damping)
        }
    }
    
    /**
     Animates the natural curve of a view. A value of 1 represents
     a curve in a downward direction, and a value of -1
     represents a curve in an upward direction.
     - Parameter intensity: A CGFloat.
     */
    public static func arc(intensity: CGFloat = 1) -> MotionTransition {
        return MotionTransition {
            $0.arc = intensity
        }
    }
    
    /**
     Animates subviews with an increasing delay between each animation.
     - Parameter delta: A TimeInterval.
     - Parameter direction: A MotionCascadeDirection.
     - Paramater animationDelayUntilMatchedViews: A boolean indicating whether
     or not to delay the subview animation until all have started.
     */
    public static func cascade(delta: TimeInterval = 0.02, direction: MotionCascadeDirection = .topToBottom, animationDelayUntilMatchedViews: Bool = false) -> MotionTransition {
        return MotionTransition {
            $0.cascade = (delta, direction, animationDelayUntilMatchedViews)
        }
    }
}

extension MotionTransition {
    /**
     Applies the transition state directly to the view before the animation
     begins. For source views, the state is applied immediately. For destination
     views, the state is applied at the end of the transition.
     */
    public static func startWith(animations: [MotionTransition]) -> MotionTransition {
        return MotionTransition {
            if nil == $0.startState {
                $0.startState = MotionTransitionStateWrapper(state: [])
            }
            
            $0.startState!.state.append(contentsOf: animations)
        }
    }
    
    /**
     Applies the transition state directly to the view before the animation
     begins. For source views, the state is applied immediately. For destination
     views, the state is applied at the end of the transition. This only takes 
     affect if the view is matched.
     */
    public static func startWithIfMatched(animations: [MotionTransition]) -> MotionTransition {
        return MotionTransition {
            if nil == $0.startStateIfMatched {
                $0.startStateIfMatched = []
            }
            
            $0.startStateIfMatched!.append(contentsOf: animations)
        }
    }
    
    
}
