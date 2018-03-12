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
  fileprivate var state = [String: (Any?, Any?)]()
  
  /// A reference to the animation timing function.
  fileprivate var timingFunction = CAMediaTimingFunction.standard
  
  /// Current animations.
  var animations = [(CALayer, String, CAAnimation)]()
  
  /// Layer which holds the content.
  fileprivate var contentLayer: CALayer? {
    let firstLayer = snapshot.layer.sublayers?.get(0)
    if firstLayer?.bounds == snapshot.bounds {
      return firstLayer
    }
    return nil
  }
  
  /// Layer which holds the overlay.
  fileprivate var overlayLayer: CALayer?
  
  override func clean() {
    super.clean()
    overlayLayer = nil
  }
  
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
  
  override func apply(state: MotionTargetState) {
    let targetState = viewState(targetState: state)
    
    for (key, targetValue) in targetState {
      if nil == self.state[key] {
        let current = currentValue(for: key)
        self.state[key] = (current, current)
      }
      
      let oldAnimations = animations
      animations = []
      animate(key: key, beginTime: 0, duration: 100, fromValue: targetValue, toValue: targetValue)
      animations = oldAnimations
    }
  }
  
  override func resume(at progress: TimeInterval, isReversed: Bool) -> TimeInterval {
    for (key, (fromValue, toValue)) in state {
      state[key] = (currentValue(for: key), isReversed ? fromValue : toValue)
    }
    
    if isReversed {
      if progress > targetState.delay + duration {
        let backDelay = progress - (targetState.delay + duration)
        return animate(delay: backDelay, duration: duration)
        
      } else if progress > targetState.delay {
        return animate(delay: 0, duration: duration - progress - targetState.delay)
      }
      
    } else {
      if progress <= targetState.delay {
        return animate(delay: targetState.delay - progress, duration: duration)
        
      } else if progress <= targetState.delay + duration {
        let timePassedDelay = progress - targetState.delay
        return animate(delay: 0, duration: duration - timePassedDelay)
      }
    }
    
    return 0
  }
  
  override func seek(to progress: TimeInterval) {
    let timeOffset = CGFloat(progress - targetState.delay)
    
    for (layer, key, anim) in animations {
      anim.speed = 0
      anim.timeOffset = CFTimeInterval(timeOffset.clamp(0, CGFloat(anim.duration - 0.001)))
      layer.removeAnimation(forKey: key)
      layer.add(anim, forKey: key)
    }
  }
  
  override func startAnimations() -> TimeInterval {
    if let beginStateModifiers = targetState.beginState {
      let beginState = MotionTargetState(modifiers: beginStateModifiers)
      
      let appeared = viewState(targetState: beginState)
      
      for (k, v) in appeared {
        snapshot.layer.setValue(v, forKeyPath: k)
      }
      
      if let (color, opacity) = beginState.overlay {
        let overlay = getOverlayLayer()
        overlay.backgroundColor = color
        overlay.opacity = Float(opacity)
      }
    }
    
    let disappeared = viewState(targetState: targetState)
    
    for (k, disappearedState) in disappeared {
      let appearingState = currentValue(for: k)
      let toValue = isAppearing ? appearingState : disappearedState
      let fromValue = !isAppearing ? appearingState : disappearedState
      state[k] = (fromValue, toValue)
    }
    
    return animate(delay: targetState.delay, duration: duration)
  }
}

fileprivate extension MotionCoreAnimationViewContext {
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
      return (overlayLayer?.presentation() ?? overlayLayer)?.value(forKeyPath: key)
    }
    
    if false != snapshot.layer.animationKeys()?.isEmpty {
      return snapshot.layer.value(forKeyPath: key)
    }
    
    return (snapshot.layer.presentation() ?? snapshot.layer).value(forKeyPath: key)
  }
  
  /**
   Retrieves the animation for a given key.
   - Parameter key: String.
   - Parameter beginTime: A TimeInterval.
   - Parameter duration: A TimeInterval.
   - Parameter fromValue: An optional Any value.
   - Parameter toValue: An optional Any value.
   - Parameter ignoreArc: A Boolean value to ignore an arc position.
   */
  func getAnimation(key: String, beginTime: TimeInterval, duration: TimeInterval, fromValue: Any?, toValue: Any?, ignoreArc: Bool = false) -> CAPropertyAnimation {
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
      a.duration = a.settlingDuration
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
   Sets a new size for the given view.
   - Parameter view: A UIView.
   - Parameter newSize: A CGSize.
   */
  func setSize(view: UIView, newSize: CGSize) {
    let oldSize = view.bounds.size
    
    if .noSnapshot != targetState.snapshotType {
      if 0 == oldSize.width || 0 == oldSize.height || 0 == newSize.width || 0 == newSize.height {
        for v in view.subviews {
          v.center = newSize.center
          v.bounds.size = newSize
          setSize(view: v, newSize: newSize)
        }
      } else {
        let sizeRatio = oldSize / newSize
        
        for v in view.subviews {
          let center = v.center
          let size = v.bounds.size
          v.center = center / sizeRatio
          v.bounds.size = size / sizeRatio
          setSize(view: v, newSize: size / sizeRatio)
        }
      }
      
      view.bounds.size = newSize
      
    } else {
      view.bounds.size = newSize
      view.layoutSubviews()
    }
  }
  
  /**
   Executes a UIView based animation.
   - Parameter duration: A TimeInterval.
   - Parameter delay: A TimeInterval.
   - Parameter _ animations: An animation block.
   */
  func uiViewBasedAnimate(duration: TimeInterval, delay: TimeInterval, _ animations: @escaping () -> Void) {
    CALayer.motionAddedAnimations = []
    
    if let (stiffness, damping) = targetState.spring {
      UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: animations, completion: nil)
      
      let addedAnimations = CALayer.motionAddedAnimations!
      CALayer.motionAddedAnimations = nil
      
      for (layer, key, anim) in addedAnimations {
        if #available(iOS 9.0, *), let anim = anim as? CASpringAnimation {
          anim.stiffness = stiffness
          anim.damping = damping
          self.addAnimation(anim, for: key, to: layer)
        } else {
          layer.removeAnimation(forKey: key)
          addAnimation(anim, for: key, to: layer)
        }
      }
      
    } else {
      CATransaction.begin()
      CATransaction.setAnimationTimingFunction(timingFunction)
      UIView.animate(withDuration: duration, delay: delay, options: [], animations: animations, completion: nil)
      
      let addedAnimations = CALayer.motionAddedAnimations!
      CALayer.motionAddedAnimations = nil
      
      for (layer, key, anim) in addedAnimations {
        layer.removeAnimation(forKey: key)
        self.addAnimation(anim, for: key, to: layer)
      }
      
      CATransaction.commit()
    }
  }
  
  /**
   Adds an animation to a given layer.
   - Parameter _ animation: A CAAnimation.
   - Parameter for key: A String.
   - Parameter to layer: A CALayer.
   */
  func addAnimation(_ animation: CAAnimation, for key: String, to layer: CALayer) {
    let motionAnimationKey = "motion.\(key)"
    animations.append((layer, motionAnimationKey, animation))
    layer.add(animation, forKey: motionAnimationKey)
  }
  
  /**
   Retrieves the duration of an animation, including the
   duration of the animation and the initial delay.
   - Parameter key: A String.
   - Parameter beginTime: A TimeInterval.
   - Parameter duration: A TimeInterval.
   - Parameter fromValue: A optional Any value.
   - Parameter toValue: A optional Any value.
   - Returns: A TimeInterval.
   */
  @discardableResult
  func animate(key: String, beginTime: TimeInterval, duration: TimeInterval, fromValue: Any?, toValue: Any?) -> TimeInterval {
    let anim = getAnimation(key: key, beginTime: beginTime, duration: duration, fromValue: fromValue, toValue: toValue)
    
    if let overlayKey = overlayKey(for: key) {
      addAnimation(anim, for: overlayKey, to: getOverlayLayer())
      
    } else {
      switch key {
      case "cornerRadius", "contentsRect", "contentsScale":
        addAnimation(anim, for: key, to: snapshot.layer)
        
        if let v = contentLayer {
          addAnimation(anim.copy() as! CAAnimation, for: key, to: v)
        }
        
        if let v = overlayLayer {
          addAnimation(anim.copy() as! CAAnimation, for: key, to: v)
        }
        
      case "bounds.size":
        guard let fromSize = (fromValue as? NSValue)?.cgSizeValue, let toSize = (toValue as? NSValue)?.cgSizeValue else {
          addAnimation(anim, for: key, to: snapshot.layer)
          break
        }
        
        setSize(view: snapshot, newSize: fromSize)
        uiViewBasedAnimate(duration: anim.duration, delay: beginTime - currentTime) { [weak self] in
          guard let `self` = self else {
            return
          }
          
          self.setSize(view: self.snapshot, newSize: toSize)
        }
        
      default:
        addAnimation(anim, for: key, to: snapshot.layer)
      }
    }
    
    return anim.duration + anim.beginTime - beginTime
  }
  
  /**
   Animates the contentLayer and overlayLayer with a given delay.
   - Parameter delay: A TimeInterval.
   - Parameter duration: A TimeInterval.
   - Returns: A TimeInterval.
   */
  func animate(delay: TimeInterval, duration: TimeInterval) -> TimeInterval {
    for (layer, key, _) in animations {
      layer.removeAnimation(forKey: key)
    }
    
    if let tf = targetState.timingFunction {
      timingFunction = tf
    }
    
    var timeUntilStop = duration
    
    animations = []
    
    for (key, (fromValue, toValue)) in state {
      let neededTime = animate(key: key, beginTime: currentTime + delay, duration: duration, fromValue: fromValue, toValue: toValue)
      timeUntilStop = max(timeUntilStop, neededTime)
    }
    
    return timeUntilStop + delay
  }
  
  /**
   Constructs a map of key paths to animation state values.
   - Parameter targetState state: A MotionModifier.
   - Returns: A map of key paths to animation values.
   */
  func viewState(targetState ts: MotionTargetState) -> [String: Any?] {
    var ts = ts
    var values = [String: Any?]()
    
    if let size = ts.size {
      if ts.useScaleBasedSizeChange ?? targetState.useScaleBasedSizeChange ?? false {
        let currentSize = snapshot.bounds.size
        ts.append(.scale(x: size.width / currentSize.width, y: size.height / currentSize.height))
        
      } else {
        values["bounds.size"] = NSValue(cgSize:size)
      }
    }
    
    if let position = ts.position {
      values["position"] = NSValue(cgPoint:position)
    }
    
    if let opacity = ts.opacity, !(snapshot is UIVisualEffectView) {
      values["opacity"] = NSNumber(value: opacity)
    }
    
    if let cornerRadius = ts.cornerRadius {
      values["cornerRadius"] = NSNumber(value: cornerRadius.native)
    }
    
    if let backgroundColor = ts.backgroundColor {
      values["backgroundColor"] = backgroundColor
    }
    
    if let zPosition = ts.zPosition {
      values["zPosition"] = NSNumber(value: zPosition.native)
    }
    
    if let borderWidth = ts.borderWidth {
      values["borderWidth"] = NSNumber(value: borderWidth.native)
    }
    
    if let borderColor = ts.borderColor {
      values["borderColor"] = borderColor
    }
    
    if let masksToBounds = ts.masksToBounds {
      values["masksToBounds"] = masksToBounds
    }
    
    if ts.displayShadow {
      if let shadowColor = ts.shadowColor {
        values["shadowColor"] = shadowColor
      }
      
      if let shadowRadius = ts.shadowRadius {
        values["shadowRadius"] = NSNumber(value: shadowRadius.native)
      }
      
      if let shadowOpacity = ts.shadowOpacity {
        values["shadowOpacity"] = NSNumber(value: shadowOpacity)
      }
      
      if let shadowPath = ts.shadowPath {
        values["shadowPath"] = shadowPath
      }
      
      if let shadowOffset = ts.shadowOffset {
        values["shadowOffset"] = NSValue(cgSize: shadowOffset)
      }
    }
    
    if let contentsRect = ts.contentsRect {
      values["contentsRect"] = NSValue(cgRect: contentsRect)
    }
    
    if let contentsScale = ts.contentsScale {
      values["contentsScale"] = NSNumber(value: contentsScale.native)
    }
    
    if let transform = ts.transform {
      values["transform"] = NSValue(caTransform3D: transform)
    }
    
    if let (color, opacity) = ts.overlay {
      values["overlay.backgroundColor"] = color
      values["overlay.opacity"] = NSNumber(value: opacity.native)
    }
    
    return values
  }
}
