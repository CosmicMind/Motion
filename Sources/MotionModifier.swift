/*
 * The MIT License (MIT)
 *
 * Copyright (C) 2019, CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
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

public final class MotionModifier {
  /// A reference to the callback that applies the MotionModifier.
  internal let apply: (inout MotionTargetState) -> Void
  
  /**
   An initializer that accepts a given callback.
   - Parameter applyFunction: A given callback.
   */
  public init(applyFunction: @escaping (inout MotionTargetState) -> Void) {
    apply = applyFunction
  }
}

public extension MotionModifier {
  /**
   Animates the view with a matching motion identifier.
   - Parameter _ motionIdentifier: A String.
   - Returns: A MotionModifier.
   */
  static func source(_ motionIdentifier: String) -> MotionModifier {
    return MotionModifier {
      $0.motionIdentifier = motionIdentifier
    }
  }
  
  /**
   Animates the view's current masksToBounds to the
   given masksToBounds.
   - Parameter masksToBounds: A boolean value indicating the
   masksToBounds state.
   - Returns: A MotionModifier.
   */
  static func masksToBounds(_ masksToBounds: Bool) -> MotionModifier {
    return MotionModifier {
      $0.masksToBounds = masksToBounds
    }
  }
  
  /**
   Animates the view's current background color to the
   given color.
   - Parameter color: A UIColor.
   - Returns: A MotionModifier.
   */
  static func background(color: UIColor) -> MotionModifier {
    return MotionModifier {
      $0.backgroundColor = color.cgColor
    }
  }
  
  /**
   Animates the view's current border color to the
   given color.
   - Parameter color: A UIColor.
   - Returns: A MotionModifier.
   */
  static func border(color: UIColor) -> MotionModifier {
    return MotionModifier {
      $0.borderColor = color.cgColor
    }
  }
  
  /**
   Animates the view's current border width to the
   given width.
   - Parameter width: A CGFloat.
   - Returns: A MotionModifier.
   */
  static func border(width: CGFloat) -> MotionModifier {
    return MotionModifier {
      $0.borderWidth = width
    }
  }
  
  /**
   Animates the view's current corner radius to the
   given radius.
   - Parameter radius: A CGFloat.
   - Returns: A MotionModifier.
   */
  static func corner(radius: CGFloat) -> MotionModifier {
    return MotionModifier {
      $0.cornerRadius = radius
    }
  }
  
  /**
   Animates the view's current transform (perspective, scale, rotate)
   to the given one.
   - Parameter _ transform: A CATransform3D.
   - Returns: A MotionModifier.
   */
  static func transform(_ transform: CATransform3D) -> MotionModifier {
    return MotionModifier {
      $0.transform = transform
    }
  }
  
  /**
   Animates the view's current perspective to the given one through
   a CATransform3D object.
   - Parameter _ perspective: A CGFloat.
   - Returns: A MotionModifier.
   */
  static func perspective(_ perspective: CGFloat) -> MotionModifier {
    return MotionModifier {
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
   - Returns: A MotionModifier.
   */
  static func rotate(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> MotionModifier {
    return MotionModifier {
      $0.transform = CATransform3DRotate($0.transform ?? CATransform3DIdentity, x, 1, 0, 0)
      $0.transform = CATransform3DRotate($0.transform!, y, 0, 1, 0)
      $0.transform = CATransform3DRotate($0.transform!, z, 0, 0, 1)
    }
  }
  
  /**
   Animates the view's current rotate to the given point.
   - Parameter _ point: A CGPoint.
   - Parameter z: A CGFloat, default is 0.
   - Returns: A MotionModifier.
   */
  static func rotate(_ point: CGPoint, z: CGFloat = 0) -> MotionModifier {
    return .rotate(x: point.x, y: point.y, z: z)
  }
  
  /**
   Rotate 2d.
   - Parameter _ z: A CGFloat.
   - Returns: A MotionModifier.
   */
  static func rotate(_ z: CGFloat) -> MotionModifier {
    return .rotate(z: z)
  }
  
  /**
   Animates the view's current scale to the given x, y, z scale values.
   - Parameter x: A CGFloat.
   - Parameter y: A CGFloat.
   - Parameter z: A CGFloat.
   - Returns: A MotionModifier.
   */
  static func scale(x: CGFloat = 1, y: CGFloat = 1, z: CGFloat = 1) -> MotionModifier {
    return MotionModifier {
      $0.transform = CATransform3DScale($0.transform ?? CATransform3DIdentity, x, y, z)
    }
  }
  
  /**
   Animates the view's current x & y scale to the given scale value.
   - Parameter _ xy: A CGFloat.
   - Returns: A MotionModifier.
   */
  static func scale(_ xy: CGFloat) -> MotionModifier {
    return .scale(x: xy, y: xy)
  }
  
  /**
   Animates the view's current translation to the given
   x, y, and z values.
   - Parameter x: A CGFloat.
   - Parameter y: A CGFloat.
   - Parameter z: A CGFloat.
   - Returns: A MotionModifier.
   */
  static func translate(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> MotionModifier {
    return MotionModifier {
      $0.transform = CATransform3DTranslate($0.transform ?? CATransform3DIdentity, x, y, z)
    }
  }
  
  /**
   Animates the view's current translation to the given
   point value (x & y), and a z value.
   - Parameter _ point: A CGPoint.
   - Parameter z: A CGFloat, default is 0.
   - Returns: A MotionModifier.
   */
  static func translate(_ point: CGPoint, z: CGFloat = 0) -> MotionModifier {
    return .translate(x: point.x, y: point.y, z: z)
  }
  
  /**
   Animates the view's current position to the given point.
   - Parameter _ point: A CGPoint.
   - Returns: A MotionModifier.
   */
  static func position(_ point: CGPoint) -> MotionModifier {
    return MotionModifier {
      $0.position = point
    }
  }
  
  /**
   Animates a view's current position to the given x and y values.
   - Parameter x: A CGloat.
   - Parameter y: A CGloat.
   - Returns: A MotionModifier.
   */
  static func position(x: CGFloat, y: CGFloat) -> MotionModifier {
    return .position(CGPoint(x: x, y: y))
  }
  
  /// Forces the view to not fade during a transition.
  static var forceNonFade = MotionModifier {
    $0.nonFade = true
  }
  
  /// Fades the view in during a transition.
  static var fadeIn = MotionModifier.fade(1)
  
  /// Fades the view out during a transition.
  static var fadeOut = MotionModifier.fade(0)
  
  /**
   Animates the view's current opacity to the given one.
   - Parameter to opacity: A Double.
   - Returns: A MotionModifier.
   */
  static func fade(_ opacity: Double) -> MotionModifier {
    return MotionModifier {
      $0.opacity = opacity
    }
  }
  
  /**
   Animates the view's current opacity to the given one.
   - Parameter _ opacity: A Double.
   - Returns: A MotionModifier.
   */
  static func opacity(_ opacity: Double) -> MotionModifier {
    return MotionModifier {
      $0.opacity = opacity
    }
  }
  
  /**
   Animates the view's current zPosition to the given position.
   - Parameter _ position: An Int.
   - Returns: A MotionModifier.
   */
  static func zPosition(_ position: CGFloat) -> MotionModifier {
    return MotionModifier {
      $0.zPosition = position
    }
  }
  
  /**
   Animates the view's current size to the given one.
   - Parameter _ size: A CGSize.
   - Returns: A MotionModifier.
   */
  static func size(_ size: CGSize) -> MotionModifier {
    return MotionModifier {
      $0.size = size
    }
  }
  
  /**
   Animates the view's current size to the given width and height.
   - Parameter width: A CGFloat.
   - Parameter height: A CGFloat.
   - Returns: A MotionModifier.
   */
  static func size(width: CGFloat, height: CGFloat) -> MotionModifier {
    return .size(CGSize(width: width, height: height))
  }
  
  /**
   Animates the view's current shadow path to the given one.
   - Parameter path: A CGPath.
   - Returns: A MotionModifier.
   */
  static func shadow(path: CGPath) -> MotionModifier {
    return MotionModifier {
      $0.shadowPath = path
    }
  }
  
  /**
   Animates the view's current shadow color to the given one.
   - Parameter color: A UIColor.
   - Returns: A MotionModifier.
   */
  static func shadow(color: UIColor) -> MotionModifier {
    return MotionModifier {
      $0.shadowColor = color.cgColor
    }
  }
  
  /**
   Animates the view's current shadow offset to the given one.
   - Parameter offset: A CGSize.
   - Returns: A MotionModifier.
   */
  static func shadow(offset: CGSize) -> MotionModifier {
    return MotionModifier {
      $0.shadowOffset = offset
    }
  }
  
  /**
   Animates the view's current shadow opacity to the given one.
   - Parameter opacity: A Float.
   - Returns: A MotionModifier.
   */
  static func shadow(opacity: Float) -> MotionModifier {
    return MotionModifier {
      $0.shadowOpacity = opacity
    }
  }
  
  /**
   Animates the view's current shadow radius to the given one.
   - Parameter radius: A CGFloat.
   - Returns: A MotionModifier.
   */
  static func shadow(radius: CGFloat) -> MotionModifier {
    return MotionModifier {
      $0.shadowRadius = radius
    }
  }
  
  /**
   Animates the view's contents rect to the given one.
   - Parameter rect: A CGRect.
   - Returns: A MotionModifier.
   */
  static func contents(rect: CGRect) -> MotionModifier {
    return MotionModifier {
      $0.contentsRect = rect
    }
  }
  
  /**
   Animates the view's contents scale to the given one.
   - Parameter scale: A CGFloat.
   - Returns: A MotionModifier.
   */
  static func contents(scale: CGFloat) -> MotionModifier {
    return MotionModifier {
      $0.contentsScale = scale
    }
  }
  
  /**
   The duration of the view's animation.
   - Parameter _ duration: A TimeInterval.
   - Returns: A MotionModifier.
   */
  static func duration(_ duration: TimeInterval) -> MotionModifier {
    return MotionModifier {
      $0.duration = duration
    }
  }
  
  /**
   Sets the view's animation duration to the longest
   running animation within a transition.
   */
  static var durationMatchLongest = MotionModifier {
    $0.duration = .infinity
  }
  
  /**
   Delays the animation of a given view.
   - Parameter _ time: TimeInterval.
   - Returns: A MotionModifier.
   */
  static func delay(_ time: TimeInterval) -> MotionModifier {
    return MotionModifier {
      $0.delay = time
    }
  }
  
  /**
   Sets the view's timing function for the transition.
   - Parameter _ timingFunction: A CAMediaTimingFunction.
   - Returns: A MotionModifier.
   */
  static func timingFunction(_ timingFunction: CAMediaTimingFunction) -> MotionModifier {
    return MotionModifier {
      $0.timingFunction = timingFunction
    }
  }
  
  /**
   Available in iOS 9+, animates a view using the spring API,
   given a stiffness and damping.
   - Parameter stiffness: A CGFlloat.
   - Parameter damping: A CGFloat.
   - Returns: A MotionModifier.
   */
  @available(iOS 9, *)
  static func spring(stiffness: CGFloat, damping: CGFloat) -> MotionModifier {
    return MotionModifier {
      $0.spring = (stiffness, damping)
    }
  }
  
  /**
   Animates the natural curve of a view. A value of 1 represents
   a curve in a downward direction, and a value of -1
   represents a curve in an upward direction.
   - Parameter intensity: A CGFloat.
   - Returns: A MotionModifier.
   */
  static func arc(intensity: CGFloat = 1) -> MotionModifier {
    return MotionModifier {
      $0.arc = intensity
    }
  }
  
  /**
   Animates subviews with an increasing delay between each animation.
   - Parameter delta: A TimeInterval.
   - Parameter direction: A CascadeDirection.
   - Parameter animationDelayedUntilMatchedViews: A boolean indicating whether
   or not to delay the subview animation until all have started.
   - Returns: A MotionModifier.
   */
  static func cascade(delta: TimeInterval = 0.02, direction: CascadeDirection = .topToBottom, animationDelayedUntilMatchedViews: Bool = false) -> MotionModifier {
    return MotionModifier {
      $0.cascade = (delta, direction, animationDelayedUntilMatchedViews)
    }
  }
  
  /**
   Creates an overlay on the animating view with a given color and opacity.
   - Parameter color: A UIColor.
   - Parameter opacity: A CGFloat.
   - Returns: A MotionModifier.
   */
  static func overlay(color: UIColor, opacity: CGFloat) -> MotionModifier {
    return MotionModifier {
      $0.overlay = (color.cgColor, opacity)
    }
  }
}

// conditional modifiers
public extension MotionModifier {
  /**
   Apply modifiers when the condition is true.
   - Parameter _ condition: A MotionConditionalContext.
   - Returns: A Boolean.
   */
  static func when(_ condition: @escaping (MotionConditionalContext) -> Bool, _ modifiers: [MotionModifier]) -> MotionModifier {
    
    return MotionModifier {
      if nil == $0.conditionalModifiers {
        $0.conditionalModifiers = []
      }
      
      $0.conditionalModifiers!.append((condition, modifiers))
    }
  }
  
  static func when(_ condition: @escaping (MotionConditionalContext) -> Bool, _ modifiers: MotionModifier...) -> MotionModifier {
    return .when(condition, modifiers)
  }
  
  /**
   Apply modifiers when matched.
   - Parameter _ modifiers: A list of modifiers.
   - Returns: A MotionModifier.
   */
  static func whenMatched(_ modifiers: MotionModifier...) -> MotionModifier {
    return .when({ $0.isMatched }, modifiers)
  }
  
  /**
   Apply modifiers when presenting.
   - Parameter _ modifiers: A list of modifiers.
   - Returns: A MotionModifier.
   */
  static func whenPresenting(_ modifiers: MotionModifier...) -> MotionModifier {
    return .when({ $0.isPresenting }, modifiers)
  }
  
  /**
   Apply modifiers when dismissing.
   - Parameter _ modifiers: A list of modifiers.
   - Returns: A MotionModifier.
   */
  static func whenDismissing(_ modifiers: MotionModifier...) -> MotionModifier {
    return .when({ !$0.isPresenting }, modifiers)
  }
  
  /**
   Apply modifiers when appearingg.
   - Parameter _ modifiers: A list of modifiers.
   - Returns: A MotionModifier.
   */
  static func whenAppearing(_ modifiers: MotionModifier...) -> MotionModifier {
    return .when({ $0.isAppearing }, modifiers)
  }
  
  /**
   Apply modifiers when disappearing.
   - Parameter _ modifiers: A list of modifiers.
   - Returns: A MotionModifier.
   */
  static func whenDisappearing(_ modifiers: MotionModifier...) -> MotionModifier {
    return .when({ !$0.isAppearing }, modifiers)
  }
}

public extension MotionModifier {
  /**
   Apply transitions directly to the view at the start of the transition.
   The transitions supplied here won't be animated.
   For source views, transitions are set directly at the begining of the animation.
   For destination views, they replace the target state (final appearance).
   */
  static func beginWith(_ modifiers: [MotionModifier]) -> MotionModifier {
    return MotionModifier {
      if nil == $0.beginState {
        $0.beginState = []
      }
      
      $0.beginState?.append(contentsOf: modifiers)
    }
  }
  
  static func beginWith(modifiers: [MotionModifier]) -> MotionModifier {
    return .beginWith(modifiers)
  }
  
  static func beginWith(_ modifiers: MotionModifier...) -> MotionModifier {
    return .beginWith(modifiers)
  }
  
  /**
   Use global coordinate space.
   
   When using global coordinate space. The view becomes an independent view that is not 
   a subview of any view. It won't move when its parent view moves, and won't be affected 
   by parent view attributes.
   
   When a view is matched, this is automatically enabled.
   The `source` transition will also enable this.
   */
  static var useGlobalCoordinateSpace = MotionModifier {
    $0.coordinateSpace = .global
  }
  
  /// Ignore all motion transition attributes for a view's direct subviews.
  static var ignoreSubviewTransitions: MotionModifier = .ignoreSubviewTransitions()
  
  /**
   Ignore all motion transition attributes for a view's subviews.
   - Parameter recursive: If false, will only ignore direct subviews' transitions. 
   default false.
   */
  static func ignoreSubviewTransitions(recursive: Bool = false) -> MotionModifier {
    return MotionModifier {
      $0.ignoreSubviewTransitions = recursive
    }
  }
  
  /**
   This will create a snapshot optimized for different view types.
   For custom views or views with masking, useOptimizedSnapshot might create snapshots
   that appear differently than the actual view.
   In that case, use .useNormalSnapshot or .useSlowRenderSnapshot to disable the optimization.
   
   This transition actually does nothing by itself since .useOptimizedSnapshot is the default.
   */
  static var useOptimizedSnapshot = MotionModifier {
    $0.snapshotType = .optimized
  }
  
  /// Create a snapshot using snapshotView(afterScreenUpdates:).
  static var useNormalSnapshot = MotionModifier {
    $0.snapshotType = .normal
  }
  
  /**
   Create a snapshot using layer.render(in: currentContext).
   This is slower than .useNormalSnapshot but gives more accurate snapshots for some views 
   (eg. UIStackView).
   */
  static var useLayerRenderSnapshot = MotionModifier {
    $0.snapshotType = .layerRender
  }
  
  /**
   Force Motion to not create any snapshots when animating this view.
   This will mess up the view hierarchy, therefore, view controllers have to rebuild
   their view structure after the transition finishes.
   */
  static var useNoSnapshot = MotionModifier {
    $0.snapshotType = .noSnapshot
  }
  
  /**
   Force the view to animate (Motion will create animation contexts & snapshots for them, so 
   that they can be interactive).
   */
  static var forceAnimate = MotionModifier {
    $0.forceAnimate = true
  }
  
  /**
   Force Motion to use scale based size animation. This will convert all .size transitions into 
   a .scale transition. This is to help Motion animate layers that doesn't support bounds animations.
   This also gives better performance.
   */
  static var useScaleBasedSizeChange = MotionModifier {
    $0.useScaleBasedSizeChange = true
  }
}
