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

public final class MotionTransitionAnimation {
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

extension MotionTransitionAnimation {
    /**
     Animates the view's current background color to the
     given color.
     - Parameter color: A UIColor.
     - Returns: A MotionTransitionAnimation.
     */
    public static func background(color: UIColor) -> MotionTransitionAnimation {
        return MotionTransitionAnimation {
            $0.backgroundColor = color.cgColor
        }
    }
    
    /**
     Animates the view's current border color to the
     given color.
     - Parameter color: A UIColor.
     - Returns: A MotionTransitionAnimation.
     */
    public static func border(color: UIColor) -> MotionTransitionAnimation {
        return MotionTransitionAnimation {
            $0.borderColor = color.cgColor
        }
    }
    
    /**
     Animates the view's current border width to the
     given width.
     - Parameter width: A CGFloat.
     - Returns: A MotionTransitionAnimation.
     */
    public static func border(width: CGFloat) -> MotionTransitionAnimation {
        return MotionTransitionAnimation {
            $0.borderWidth = width
        }
    }
    
    /**
     Animates the view's current corner radius to the
     given radius.
     - Parameter radius: A CGFloat.
     - Returns: A MotionTransitionAnimation.
     */
    public static func corner(radius: CGFloat) -> MotionTransitionAnimation {
        return MotionTransitionAnimation {
            $0.cornerRadius = radius
        }
    }
    
    /**
     Animates the view's current transform (perspective, scale, rotation)
     to the given one.
     - Parameter _ transform: A CATransform3D.
     - Returns: A MotionTransitionAnimation.
     */
    public static func transform(_ transform: CATransform3D) -> MotionTransitionAnimation {
        return MotionTransitionAnimation {
            $0.transform = transform
        }
    }
    
    /**
     Animates the view's current perspective to the gievn one through
     a CATransform3D object.
     - Parameter _ perspective: A CGFloat.
     - Returns: A MotionTransitionAnimation.
     */
    public static func perspective(_ perspective: CGFloat) -> MotionTransitionAnimation {
        return MotionTransitionAnimation {
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
     - Returns: A MotionTransitionAnimation.
     */
    public static func rotation(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> MotionTransitionAnimation {
        return MotionTransitionAnimation {
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
     - Returns: A MotionTransitionAnimation.
     */
    public static func rotation(_ point: CGPoint, z: CGFloat = 0) -> MotionTransitionAnimation {
        return .rotation(x: point.x, y: point.y, z: z)
    }
    
    /**
     Animates the view's current scale to the given x, y, z scale values.
     - Parameter x: A CGFloat.
     - Parameter y: A CGFloat.
     - Parameter z: A CGFloat.
     - Returns: A MotionTransitionAnimation.
     */
    public static func scale(x: CGFloat = 1, y: CGFloat = 1, z: CGFloat = 1) -> MotionTransitionAnimation {
        return MotionTransitionAnimation {
            $0.transform = CATransform3DScale($0.transform ?? CATransform3DIdentity, x, y, z)
        }
    }
    
    /**
     Animates the view's current x & y scale to the given scale value.
     - Parameter to scale: A CGFloat.
     - Returns: A MotionTransitionAnimation.
     */
    public static func scale(to scale: CGFloat) -> MotionTransitionAnimation {
        return .scale(x: scale, y: scale)
    }
    
    /**
     Animates the view's current translation to the given
     x, y, and z values.
     - Parameter x: A CGFloat.
     - Parameter y: A CGFloat.
     - Parameter z: A CGFloat.
     - Returns: A MotionTransitionAnimation.
     */
    public static func translate(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> MotionTransitionAnimation {
        return MotionTransitionAnimation {
            $0.transform = CATransform3DTranslate($0.transform ?? CATransform3DIdentity, x, y, z)
        }
    }
    
    /**
     Animates the view's current translation to the given
     point value (x & y), and a z value.
     - Parameter to point: A CGPoint.
     - Parameter z: A CGFloat, default is 0.
     - Returns: A MotionTransitionAnimation.
     */
    public static func translate(to point: CGPoint, z: CGFloat = 0) -> MotionTransitionAnimation {
        return .translate(x: point.x, y: point.y, z: z)
    }
    
    /**
     Animates the view's current position to the given point.
     - Parameter to point: A CGPoint.
     - Returns: A MotionTransitionAnimation.
     */
    public static func position(to point: CGPoint) -> MotionTransitionAnimation {
        return MotionTransitionAnimation {
            $0.position = point
        }
    }

    /// Fades the view out during a transition.
    public static var fadeOut = MotionTransitionAnimation {
        $0.opacity = 0
    }
    
    /// Fades the view in during a transition.
    public static var fadeIn = MotionTransitionAnimation {
        $0.opacity = 1
    }
    
    /**
     Animates the view's current opacity to the given one.
     - Parameter _ opacity: A Float value.
     - Returns: A MotionTransitionAnimation.
     */
    public static func opacity(_ opacity: Float) -> MotionTransitionAnimation {
        return MotionTransitionAnimation {
            $0.opacity = opacity
        }
    }
    
    /**
     Animates the view's current zPosition to the given position.
     - Parameter _ position: An Int.
     - Returns: A MotionTransitionAnimation.
     */
    public static func zPosition(_ position: CGFloat) -> MotionTransitionAnimation {
        return MotionTransitionAnimation {
            $0.zPosition = position
        }
    }

    /**
     Animates the view's current size to the given one.
     - Parameter _ size: A CGSize.
     - Returns: A MotionTransitionAnimation.
     */
    public static func size(_ size: CGSize) -> MotionTransitionAnimation {
        return MotionTransitionAnimation {
            $0.size = size
        }
    }
    
    /**
     Animates the view's current shadow path to the given one.
     - Parameter path: A CGPath.
     - Returns: A MotionTransitionAnimation.
     */
    public static func shadow(path: CGPath) -> MotionTransitionAnimation {
        return MotionTransitionAnimation {
            $0.shadowPath = path
        }
    }
    
    /**
     Animates the view's current shadow color to the given one.
     - Parameter color: A UIColor.
     - Returns: A MotionTransitionAnimation.
     */
    public static func shadow(color: UIColor) -> MotionTransitionAnimation {
        return MotionTransitionAnimation {
            $0.shadowColor = color.cgColor
        }
    }
    
    /**
     Animates the view's current shadow offset to the given one.
     - Parameter offset: A CGSize.
     - Returns: A MotionTransitionAnimation.
     */
    public static func shadow(offset: CGSize) -> MotionTransitionAnimation {
        return MotionTransitionAnimation {
            $0.shadowOffset = offset
        }
    }
    
    /**
     Animates the view's current shadow opacity to the given one.
     - Parameter opacity: A CGFloat.
     - Returns: A MotionTransitionAnimation.
     */
    public static func shadow(opacity: CGFloat) -> MotionTransitionAnimation {
        return MotionTransitionAnimation {
            $0.shadowOpacity = Float(opacity)
        }
    }
    
    /**
     Animates the view's current shadow radius to the given one.
     - Parameter radius: A CGFloat.
     - Returns: A MotionTransitionAnimation.
     */
    public static func shadow(radius: CGFloat) -> MotionTransitionAnimation {
        return MotionTransitionAnimation {
            $0.shadowRadius = radius
        }
    }
}
