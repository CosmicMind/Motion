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

internal class MotionCoreAnimationViewContext: MotionAnimatorViewContext {
    /// The transition states.
    fileprivate var transitionStates = [String: (Any?, Any?)]()
    
    /// A reference to the animation timing function.
    fileprivate var timingFunction = CAMediaTimingFunction.from(mediaTimingFunctionType: .standard)

    /// Layer which holds the content.
    fileprivate var contentLayer: CALayer? {
        return snapshot.layer.sublayers?.get(0)
    }
    
    /// Layer which holds the overlay.
    fileprivate var overlayLayer: CALayer?

    /**
     Determines whether a view can be animated.
     - Parameter view: A UIView.
     - Parameter state: A MotionTargetState.
     - Parameter isAppearing: A boolean indicating whether or not the
     view is going to appear.
     */
    override class func canAnimate(view: UIView, state: MotionTargetState, isAppearing: Bool) -> Bool {
        return  nil != state.position           ||
                nil != state.size               ||
                nil != state.transform          ||
                nil != state.cornerRadius       ||
                nil != state.opacity            ||
                nil != state.overlay            ||
                nil != state.backgroundColor    ||
                nil != state.borderColor        ||
                nil != state.borderWidth        ||
                nil != state.shadowOpacity      ||
                nil != state.shadowRadius       ||
                nil != state.shadowOffset       ||
                nil != state.shadowColor        ||
                nil != state.shadowPath         ||
                nil != state.contentsRect       ||
                       state.forceAnimate
    }
    
    /**
     Lazy loads the overlay layer. 
     - Returns: A CALayer.
     */
    func getOverlayLayer() -> CALayer {
        if nil == overlayLayer {
            overlayLayer = CALayer()
            overlayLayer!.frame = snapshot.bounds
            overlayLayer!.opacity = 0
            snapshot.layer.addSublayer(overlayLayer!)
        }
        
        return overlayLayer!
    }
    
    /**
     Retrieves the overlay key for a given key.
     - Parameter for key: A String.
     - Returns: An optional String.
     */
    func overlayKey(for key: String) -> String? {
        guard key.hasPrefix("overlay.") else {
            return nil
        }
        
        var k = key
        k.removeSubrange(k.startIndex..<k.index(key.startIndex, offsetBy: 8))
        return k
    }
    
    /**
     Retrieves the current value for a given key. 
     - Parameter for key: A String.
     - Returns: An optional Any value.
     */
    func currentValue(for key: String) -> Any? {
        if let key = overlayKey(for: key) {
            return overlayLayer?.value(forKeyPath: key)
        }
        
        if false != snapshot.layer.animationKeys()?.isEmpty {
            return snapshot.layer.value(forKeyPath:key)
        }
        
        return (snapshot.layer.presentation() ?? snapshot.layer).value(forKeyPath: key)
    }
    
    /**
     Retrieves the animation for a given key. 
     - Parameter key: String.
     - Parameter beginTime: A TimeInterval.
     - Parameter fromValue: An optional Any value.
     - Parameter toValue: An optional Any value.
     - Parameter ignoreArc: A Boolean value to ignore an arc position.
     */
    func getAnimation(key: String, beginTime: TimeInterval, fromValue: Any?, toValue: Any?, ignoreArc: Bool = false) -> CAPropertyAnimation {
        let key = overlayKey(for: key) ?? key
        let anim: CAPropertyAnimation

        if !ignoreArc, "position" == key, let arcIntensity = targetState.arc,
            let fromPos = (fromValue as? NSValue)?.cgPointValue,
            let toPos = (toValue as? NSValue)?.cgPointValue,
            abs(fromPos.x - toPos.x) >= 1, abs(fromPos.y - toPos.y) >= 1 {

            let a = CAKeyframeAnimation(keyPath: key)
            let path = CGMutablePath()
            let maxControl = fromPos.y > toPos.y ? CGPoint(x: toPos.x, y: fromPos.y) : CGPoint(x: fromPos.x, y: toPos.y)
            let minControl = (toPos - fromPos) / 2 + fromPos

            path.move(to: fromPos)
            path.addQuadCurve(to: toPos, control: minControl + (maxControl - minControl) * arcIntensity)

            a.values = [fromValue!, toValue!]
            a.path = path
            a.duration = duration
            a.timingFunctions = [timingFunction]

            anim = a
        } else if #available(iOS 9.0, *), "cornerRadius" != key, let (stiffness, damping) = targetState.spring {
            let a = CASpringAnimation(keyPath: key)
            a.stiffness = stiffness
            a.damping = damping
            a.duration = a.settlingDuration * 0.9
            a.fromValue = fromValue
            a.toValue = toValue
            
            anim = a
        } else {
            let a = CABasicAnimation(keyPath: key)
            a.duration = duration
            a.fromValue = fromValue
            a.toValue = toValue
            a.timingFunction = timingFunction
            
            anim = a
        }

        anim.fillMode = kCAFillModeBoth
        anim.isRemovedOnCompletion = false
        anim.beginTime = beginTime

        return anim
    }

    /**
     Retrieves the duration of an animation, including the
     duration of the animation and the initial delay.
     - Parameter key: A String.
     - Parameter beginTime: A TimeInterval.
     - Parameter fromValue: A optional Any value.
     - Parameter toValue: A optional Any value.
     - Returns: A TimeInterval.
     */
    func animate(key: String, beginTime: TimeInterval, fromValue: Any?, toValue: Any?) -> TimeInterval {
        let anim = getAnimation(key: key, beginTime:beginTime, fromValue: fromValue, toValue: toValue)

        if let overlayKey = overlayKey(for: key) {
            getOverlayLayer().add(anim, forKey: overlayKey)
        } else {
            snapshot.layer.add(anim, forKey: key)
            switch key {
            case "cornerRadius", "contentsRect", "contentsScale":
                contentLayer?.add(anim, forKey: key)
                overlayLayer?.add(anim, forKey: key)
            case "bounds.size":
                let fromSize = (fromValue as? NSValue)!.cgSizeValue
                let toSize = (toValue as? NSValue)!.cgSizeValue

                // for the snapshotView(UIReplicantView): there is a
                // subview(UIReplicantContentView) that is hosting the real snapshot image.
                // because we are using CAAnimations and not UIView animations,
                // The snapshotView will not layout during animations.
                // we have to add two more animations to manually layout the content view.
                let fromPosn = NSValue(cgPoint:fromSize.center)
                let toPosn = NSValue(cgPoint:toSize.center)

                let positionAnim = getAnimation(key: "position", beginTime:0, fromValue: fromPosn, toValue: toPosn, ignoreArc: true)
                positionAnim.beginTime = anim.beginTime
                positionAnim.timingFunction = anim.timingFunction
                positionAnim.duration = anim.duration

                contentLayer?.add(positionAnim, forKey: "position")
                contentLayer?.add(anim, forKey: key)

                overlayLayer?.add(positionAnim, forKey: "position")
                overlayLayer?.add(anim, forKey: key)
            default: break
            }
        }

        return anim.duration + anim.beginTime - beginTime
    }

  func animate(delay: TimeInterval) {
    if let tf = targetState.timingFunction {
      timingFunction = tf
    }

    duration = targetState.duration!

    let beginTime = currentTime + delay
    var finalDuration: TimeInterval = duration
    for (key, (fromValue, toValue)) in transitionStates {
      let neededTime = animate(key: key, beginTime: beginTime, fromValue: fromValue, toValue: toValue)
      finalDuration = max(finalDuration, neededTime + delay)
    }

    duration = finalDuration
  }

  /**
   - Returns: a CALayer [keyPath:value] map for animation
   */
  func viewState(targetState: MotionTargetState) -> [String: Any?] {
    var targetState = targetState
    var rtn = [String: Any?]()

    if let size = targetState.size {
      if targetState.useScaleBasedSizeChange ?? self.targetState.useScaleBasedSizeChange ?? false {
        let currentSize = snapshot.bounds.size
        targetState.append(.scale(x:size.width / currentSize.width,
                                  y:size.height / currentSize.height))
      } else {
        rtn["bounds.size"] = NSValue(cgSize:size)
      }
    }
    if let position = targetState.position {
      rtn["position"] = NSValue(cgPoint:position)
    }
    if let opacity = targetState.opacity, !(snapshot is UIVisualEffectView) {
      rtn["opacity"] = NSNumber(value: opacity)
    }
    if let cornerRadius = targetState.cornerRadius {
      rtn["cornerRadius"] = NSNumber(value: cornerRadius.native)
    }
    if let backgroundColor = targetState.backgroundColor {
      rtn["backgroundColor"] = backgroundColor
    }
    if let zPosition = targetState.zPosition {
      rtn["zPosition"] = NSNumber(value: zPosition.native)
    }

    if let borderWidth = targetState.borderWidth {
      rtn["borderWidth"] = NSNumber(value: borderWidth.native)
    }
    if let borderColor = targetState.borderColor {
      rtn["borderColor"] = borderColor
    }
    if let masksToBounds = targetState.masksToBounds {
      rtn["masksToBounds"] = masksToBounds
    }

    if targetState.displayShadow {
      if let shadowColor = targetState.shadowColor {
        rtn["shadowColor"] = shadowColor
      }
      if let shadowRadius = targetState.shadowRadius {
        rtn["shadowRadius"] = NSNumber(value: shadowRadius.native)
      }
      if let shadowOpacity = targetState.shadowOpacity {
        rtn["shadowOpacity"] = NSNumber(value: shadowOpacity)
      }
      if let shadowPath = targetState.shadowPath {
        rtn["shadowPath"] = shadowPath
      }
      if let shadowOffset = targetState.shadowOffset {
        rtn["shadowOffset"] = NSValue(cgSize: shadowOffset)
      }
    }

    if let contentsRect = targetState.contentsRect {
      rtn["contentsRect"] = NSValue(cgRect: contentsRect)
    }

    if let contentsScale = targetState.contentsScale {
      rtn["contentsScale"] = NSNumber(value: contentsScale.native)
    }

    if let transform = targetState.transform {
      rtn["transform"] = NSValue(caTransform3D: transform)
    }

    if let (color, opacity) = targetState.overlay {
      rtn["overlay.backgroundColor"] = color
      rtn["overlay.opacity"] = NSNumber(value: opacity.native)
    }
    return rtn
  }

  override func apply(state: MotionTargetState) {
    let targetState = viewState(targetState: state)
    for (key, targetValue) in targetState {
      if self.transitionStates[key] == nil {
        let current = currentValue(for: key)
        self.transitionStates[key] = (current, current)
      }
      _ = animate(key: key, beginTime: 0, fromValue: targetValue, toValue: targetValue)
    }
  }

  override func resume(elapsedTime: TimeInterval, isReversed: Bool) {
    for (key, (fromValue, toValue)) in transitionStates {
      let realToValue = !isReversed ? toValue : fromValue
      let realFromValue = currentValue(for: key)
      transitionStates[key] = (realFromValue, realToValue)
    }

    // we need to update the duration to reflect current state
    targetState.duration = isReversed ? elapsedTime - targetState.delay : duration - elapsedTime

    let realDelay = max(0, targetState.delay - elapsedTime)
    animate(delay: realDelay)
  }

  func seek(layer: CALayer, elapsedTime: TimeInterval) {
    let timeOffset = elapsedTime - targetState.delay
    for (key, anim) in layer.animations {
      anim.speed = 0
      anim.timeOffset = max(0, min(anim.duration - 0.01, timeOffset))
      layer.removeAnimation(forKey: key)
      layer.add(anim, forKey: key)
    }
  }

  override func seek(to elapsedTime: TimeInterval) {
    seek(layer:snapshot.layer, elapsedTime:elapsedTime)
    if let contentLayer = contentLayer {
      seek(layer:contentLayer, elapsedTime:elapsedTime)
    }
    if let overlayLayer = overlayLayer {
      seek(layer: overlayLayer, elapsedTime: elapsedTime)
    }
  }

  override func clean() {
    super.clean()
    overlayLayer = nil
  }

  override func startAnimations(isAppearing: Bool) {
    if let beginState = targetState.beginState?.state {
      let appeared = viewState(targetState: beginState)
      for (key, value) in appeared {
        snapshot.layer.setValue(value, forKeyPath: key)
      }
      if let (color, opacity) = beginState.overlay {
        let overlay = getOverlayLayer()
        overlay.backgroundColor = color
        overlay.opacity = Float(opacity)
      }
    }

    let disappeared = viewState(targetState: targetState)

    for (key, disappearedState) in disappeared {
      let isAppearingState = currentValue(for: key)
      let toValue = isAppearing ? isAppearingState : disappearedState
      let fromValue = !isAppearing ? isAppearingState : disappearedState
      transitionStates[key] = (fromValue, toValue)
    }

    animate(delay: targetState.delay)
  }
}
