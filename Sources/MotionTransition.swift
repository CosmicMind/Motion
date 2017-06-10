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
     Animates the view's current masksToBounds to the
     given masksToBounds.
     - Parameter masksToBounds: A boolean value indicating the
     masksToBounds state.
     - Returns: A MotionTransition.
     */
    public static func masksToBounds(_ masksToBounds: Bool) -> MotionTransition {
        return MotionTransition {
            $0.masksToBounds = masksToBounds
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
     Animates the view's current transform (perspective, scale, rotate)
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
     Animates the view's current rotate to the given x, y,
     and z values.
     - Parameter x: A CGFloat.
     - Parameter y: A CGFloat.
     - Parameter z: A CGFloat.
     - Returns: A MotionTransition.
     */
    public static func rotate(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> MotionTransition {
        return MotionTransition {
            var t = $0.transform ?? CATransform3DIdentity
            t = CATransform3DRotate(t, x, 1, 0, 0)
            t = CATransform3DRotate(t, y, 0, 1, 0)
            $0.transform = CATransform3DRotate(t, z, 0, 0, 1)
        }
    }
    
    /**
     Animates the view's current rotate to the given point.
     - Parameter _ point: A CGPoint.
     - Parameter z: A CGFloat, default is 0.
     - Returns: A MotionTransition.
     */
    public static func rotate(_ point: CGPoint, z: CGFloat = 0) -> MotionTransition {
        return .rotate(x: point.x, y: point.y, z: z)
    }
    
    /**
     Rotate 2d.
     - Parameter _ z: A CGFloat.
     - Returns: A MotionTransition.
     */
    public static func rotate(_ z: CGFloat) -> MotionTransition {
        return .rotate(z: z)
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
    
    /// Forces the view to not fade during a transition.
    public static var forceNonFade = MotionTransition { targetState in
        targetState.nonFade = true
    }
    
    /// Fades the view out during a transition.
    public static var fade = MotionTransition {
        $0.opacity = 0
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
     - Parameter _ timingFunction: A CAMediaTimingFunction.
     - Returns: A MotionTransition.
     */
    public static func timingFunction(_ timingFunction: CAMediaTimingFunction) -> MotionTransition {
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
     - Returns: A MotionTransition.
     */
    public static func arc(intensity: CGFloat = 1) -> MotionTransition {
        return MotionTransition {
            $0.arc = intensity
        }
    }
    
    /**
     Animates subviews with an increasing delay between each animation.
     - Parameter delta: A TimeInterval.
     - Parameter direction: A CascadeDirection.
     - Parameter animationDelayUntilMatchedViews: A boolean indicating whether
     or not to delay the subview animation until all have started.
     - Returns: A MotionTransition.
     */
    public static func cascade(delta: TimeInterval = 0.02, direction: CascadeDirection = .topToBottom, animationDelayUntilMatchedViews: Bool = false) -> MotionTransition {
        return MotionTransition {
            $0.cascade = (delta, direction, animationDelayUntilMatchedViews)
        }
    }
    
    /**
     Creates an overlay on the animating view with a given color and opacity.
     - Parameter color: A UIColor.
     - Parameter opacity: A CGFloat.
     - Returns: A MotionTransition.
     */
    public static func overlay(color: UIColor, opacity: CGFloat) -> MotionTransition {
        return MotionTransition {
            $0.overlay = (color.cgColor, opacity)
        }
    }
}

// advance transitions
extension MotionTransition {
    /**
     Apply transitions directly to the view at the start of the transition.
     The transitions supplied here won't be animated.
     For source views, transitions are set directly at the begining of the animation.
     For destination views, they replace the target state (final appearance).
     */
    public static func beginWith(transitions: [MotionTransition]) -> MotionTransition {
        return MotionTransition { targetState in
            if targetState.beginState == nil {
                targetState.beginState = MotionTransitionStateWrapper(state: [])
            }
            targetState.beginState!.state.append(contentsOf: transitions)
        }
    }
    
    /**
     Apply transitions directly to the view at the start of the transition if the view is matched with another view.
     The transitions supplied here won't be animated.
     For source views, transitions are set directly at the begining of the animation.
     For destination views, they replace the target state (final appearance).
     */
    public static func beginWithIfMatched(transitions: [MotionTransition]) -> MotionTransition {
        return MotionTransition { targetState in
            if targetState.beginStateIfMatched == nil {
                targetState.beginStateIfMatched = []
            }
            targetState.beginStateIfMatched!.append(contentsOf: transitions)
        }
    }
    
    /**
     Use global coordinate space.
     
     When using global coordinate space. The view become a independent view that is not a subview of any view.
     It won't move when its parent view moves, and won't be affected by parent view's attributes.
     
     When a view is matched, this is automatically enabled.
     The `source` modifier will also enable this.
     
     Global coordinate space is default for all views prior to version 0.1.3
     */
    public static var useGlobalCoordinateSpace: MotionTransition = MotionTransition { targetState in
        targetState.coordinateSpace = .global
    }
    
    /**
     Use same parent coordinate space.
     */
    public static var useSameParentCoordinateSpace: MotionTransition = MotionTransition { targetState in
        targetState.coordinateSpace = .sameParent
    }
    
    /**
     ignore all motionTransitions attributes for a view's direct subviews.
     */
    public static var ignoreSubviewTransitions: MotionTransition = .ignoreSubviewTransitions()
    
    /**
     ignore all motionTransitions attributes for a view's subviews.
     - Parameters:
     - recursive: if false, will only ignore direct subviews' transitions. default false.
     */
    public static func ignoreSubviewTransitions(recursive: Bool = false) -> MotionTransition {
        return MotionTransition { targetState in
            targetState.ignoreSubviewTransitions = recursive
        }
    }
    
    /**
     Will create snapshot optimized for different view type.
     For custom views or views with masking, useOptimizedSnapshot might create snapshots
     that appear differently than the actual view.
     In that case, use .useNormalSnapshot or .useSlowRenderSnapshot to disable the optimization.
     
     This modifier actually does nothing by itself since .useOptimizedSnapshot is the default.
     */
    public static var useOptimizedSnapshot: MotionTransition = MotionTransition { targetState in
        targetState.snapshotType = .optimized
    }
    
    /**
     Create snapshot using snapshotView(afterScreenUpdates:).
     */
    public static var useNormalSnapshot: MotionTransition = MotionTransition { targetState in
        targetState.snapshotType = .normal
    }
    
    /**
     Create snapshot using layer.render(in: currentContext).
     This is slower than .useNormalSnapshot but gives more accurate snapshot for some views (eg. UIStackView).
     */
    public static var useLayerRenderSnapshot: MotionTransition = MotionTransition { targetState in
        targetState.snapshotType = .layerRender
    }
    
    /**
     Force Motion to not create any snapshot when animating this view.
     This will mess up the view hierarchy, therefore, view controllers have to rebuild
     its view structure after the transition finishes.
     */
    public static var useNoSnapshot: MotionTransition = MotionTransition { targetState in
        targetState.snapshotType = .useOriginal
    }
    
    /**
     Force the view to animate (Motion will create animation context & snapshots for them, so that they can be interact)
     */
    public static var forceAnimate = MotionTransition { targetState in
        targetState.forceAnimate = true
    }
    
    /**
     Force Motion use scale based size animation. This will convert all .size modifier into .scale modifier.
     This is to help Motion animate layers that doesn't support bounds animation. Also gives better performance.
     */
    public static var useScaleBasedSizeChange: MotionTransition = MotionTransition { targetState in
        targetState.useScaleBasedSizeChange = true
    }
}
