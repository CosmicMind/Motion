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

public typealias MotionDelayCancelBlock = (Bool) -> Void

public class Motion: MotionController {
    /// A reference to an optional transitioning context provided by UIKit.
    fileprivate weak var transitionContext: UIViewControllerContextTransitioning?
    
    /// A boolean inficating whether or not the transition is animating.
    fileprivate var isAnimating = false
    
    /**
     A boolean indicating if the transition view controller is a
     UINavigationController.
     */
    fileprivate var isNavigationController = false
    
    /**
     A boolean indicating if the transition view controller is a
     UITabBarController.
     */
    fileprivate var isTabBarController = false
    
    /**
     A boolean indicating if the transition view controller is a
     UINavigationController or UITabBarController.
     */
    fileprivate var isContainerController: Bool {
        return isNavigationController || isTabBarController
    }
    
    /// A boolean indicating if the toView is at full screen.
    fileprivate var isToViewFullScreen: Bool {
        return !isContainerController && (.overFullScreen == toViewController!.modalPresentationStyle || .overCurrentContext == toViewController!.modalPresentationStyle)
    }
    fileprivate var isFromViewFullScreen: Bool {
        return !isContainerController && (.overFullScreen == fromViewController!.modalPresentationStyle || .overCurrentContext == fromViewController!.modalPresentationStyle)
    }
    
    /// A reference to the fromViewController.view.
    fileprivate var fromView: UIView {
        return fromViewController!.view
    }
    
    /// A reference to the toViewController.view.
    fileprivate var toView: UIView {
        return toViewController!.view
    }
    
    /// A reference to the screen snapshot.
    fileprivate var screenSnapshot: UIView!
    
    /**
     A reference to a shared Motion instance to control interactive
     transitions.
     */
    public static let shared = Motion()
    
    /// A reference to the source view controller.
    public fileprivate(set) var fromViewController: UIViewController?
    
    /// A reference to the destination view controller.
    public fileprivate(set) var toViewController: UIViewController?
    
    /// A boolean indicating if the view controller is presenting.
    public fileprivate(set) var isPresenting = true
    
    /// A reference to the animation elapsed time.
    public override var elapsedTime: TimeInterval {
        didSet {
            guard isTransitioning else {
                return
            }
            
            transitionContext?.updateInteractiveTransition(CGFloat(elapsedTime))
        }
    }
}

extension Motion {
    /**
     Executes a block of code after a time delay.
     - Parameter duration: An animation duration time.
     - Parameter animations: An animation block.
     - Parameter execute block: A completion block that is executed once
     the animations have completed.
     */
    @discardableResult
    public class func delay(_ time: TimeInterval, execute block: @escaping () -> Void) -> MotionDelayCancelBlock? {
        var cancelable: MotionDelayCancelBlock?
        
        let delayed: MotionDelayCancelBlock = {
            if !$0 {
                DispatchQueue.main.async(execute: block)
            }
            
            cancelable = nil
        }
        
        cancelable = delayed
        
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            cancelable?(false)
        }
        
        return cancelable
    }
    
    /**
     Cancels the delayed MotionDelayCancelBlock.
     - Parameter delayed completion: An MotionDelayCancelBlock.
     */
    public class func cancel(delayed completion: MotionDelayCancelBlock) {
        completion(true)
    }
    
    /**
     Disables the default animations set on CALayers.
     - Parameter animations: A callback that wraps the animations to disable.
     */
    public class func disable(_ animations: (() -> Void)) {
        animate(duration: 0, animations: animations)
    }
    
    /**
     Runs an animation with a specified duration.
     - Parameter duration: An animation duration time.
     - Parameter animations: An animation block.
     - Parameter timingFunction: An MotionAnimationTimingFunction value.
     - Parameter completion: A completion block that is executed once
     the animations have completed.
     */
    public class func animate(duration: CFTimeInterval, timingFunction: MotionAnimationTimingFunction = .easeInEaseOut, animations: (() -> Void), completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setCompletionBlock(completion)
        CATransaction.setAnimationTimingFunction(MotionAnimationTimingFunctionToValue(timingFunction: timingFunction))
        animations()
        CATransaction.commit()
    }
    
    /**
     Creates a CAAnimationGroup.
     - Parameter animations: An Array of CAAnimation objects.
     - Parameter timingFunction: An MotionAnimationTimingFunction value.
     - Parameter duration: An animation duration time for the group.
     - Returns: A CAAnimationGroup.
     */
    public class func animate(group animations: [CAAnimation], timingFunction: MotionAnimationTimingFunction = .easeInEaseOut, duration: CFTimeInterval = 0.5) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.fillMode = MotionAnimationFillModeToValue(mode: .both)
        group.isRemovedOnCompletion = false
        group.animations = animations
        group.duration = duration
        group.timingFunction = MotionAnimationTimingFunctionToValue(timingFunction: timingFunction)
        return group
    }
}

extension Motion {
    /**
     Removes a snapshot from a given view controller.
     - Parameter for viewController: A UIViewController.
     */
    fileprivate func removeSnapshot(for viewController: UIViewController?) {
        guard let v = viewController?.motionSnapshot else {
            return
        }
        
        v.removeFromSuperview()
        viewController?.motionSnapshot = nil
    }
}

extension Motion {
    /// Prepares the screen snapshot.
    fileprivate func prepareScreenSnapshot() {
        screenSnapshot?.removeFromSuperview()
        screenSnapshot = (transitionContainer.window ?? fromView).snapshotView(afterScreenUpdates: true)
        (transitionContainer.window ?? transitionContainer)?.addSubview(screenSnapshot)
    }
    
    /// Prepares the preprocessors.
    fileprivate func preparePreprocessors() {
        preprocessors = [DefaultMotionTransitionPreprocessor()]
    }
    
    /// Prepares the animators.
    fileprivate func prepareAnimators() {
        animators = []
    }
    
    /// Prepares the transitionContainer.
    fileprivate func prepareTransitionContainer() {
        transitionContainer.isUserInteractionEnabled = false
    }
    
    /// Prepares the context.
    fileprivate func prepareContext() {
        context = MotionContext(container: container)
        container.addSubview(toView)
        container.addSubview(fromView)
        context.set(fromViews: fromView.flattenedViewHierarchy, toViews: toView.flattenedViewHierarchy)
        
        for v in preprocessors {
            v.context = context
        }
        
        for v in animators {
            v.context = context
        }
    }
    
    /// Prepares the toView.
    fileprivate func prepareToView() {
        toView.frame = fromView.frame
        toView.updateConstraints()
        toView.setNeedsLayout()
        toView.layoutIfNeeded()
    }
}

extension Motion {
    /// Iterates through all the processors. 
    fileprivate func processContext() {
        for v in preprocessors {
            v.process(fromViews: context.fromViews, toViews: context.toViews)
        }
    }
}

extension Motion {
    /// Starts the transition.
    fileprivate func start() {
        guard isTransitioning else {
            return
        }
        
        removeSnapshot(for: fromViewController)
        removeSnapshot(for: toViewController)
        
        prepareScreenSnapshot()
        preparePreprocessors()
        prepareAnimators()
        prepareTransitionContainer()
        prepareToView()
        prepareContext()
        
        processContext()
    }
    
    fileprivate func completed(isFinished: Bool) {
        transitionContext?.completeTransition(!isFinished)
    }
}

extension Motion {
    /**
     Helper transition function.
     - Parameter from: A UIViewController.
     - Parameter to: A UIViewController.
     - Parameter in container: A UIView.
     - Parameter completion: A completion block.
     */
    fileprivate func transition(from: UIViewController, to: UIViewController, in container: UIView, completion: ((Bool) -> Void)? = nil) {
        guard !isTransitioning else {
            return
        }
        
        isPresenting = true
        transitionContainer = container
        fromViewController = from
        toViewController = to
        
        start()
    }
}

extension Motion: UIViewControllerAnimatedTransitioning {
    /**
     The animation method that is used to coordinate the transition.
     - Parameter using transitionContext: A UIViewControllerContextTransitioning.
     */
    public func animateTransition(using context: UIViewControllerContextTransitioning) {
        guard !isTransitioning else {
            return
        }
        
        transitionContext = context
        fromViewController = fromViewController ?? context.viewController(forKey: .from)
        toViewController = toViewController ?? context.viewController(forKey: .to)
        transitionContainer = context.containerView
        
        start()
    }
    
    /**
     Returns the transition duration time interval.
     - Parameter using transitionContext: An optional UIViewControllerContextTransitioning.
     - Returns: A TimeInterval that is the total animation time including delays.
     */
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0 // Will be updated dynamically.
    }
    
    public func animationEnded(_ transitionCompleted: Bool) {
        isAnimating = !transitionCompleted
    }
}

extension Motion: UIViewControllerTransitioningDelegate {
    var interactiveTransitioning: UIViewControllerInteractiveTransitioning? {
        return self
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = true
        self.fromViewController = fromViewController ?? presenting
        self.toViewController = toViewController ?? presented
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = false
        self.fromViewController = fromViewController ?? dismissed
        return self
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransitioning
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransitioning
    }
}

extension Motion: UIViewControllerInteractiveTransitioning {
    public var wantsInteractiveStart: Bool {
        return true
    }
    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        animateTransition(using: transitionContext)
    }
}

extension Motion: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = .push == operation
        self.fromViewController = fromViewController ?? fromVC
        self.toViewController = toViewController ?? toVC
        self.isNavigationController = true
        
        return self
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransitioning
    }
}

extension Motion: UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return !isAnimating
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransitioning
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isAnimating = true
        
        let fromVCIndex = tabBarController.childViewControllers.index(of: fromVC)!
        let toVCIndex = tabBarController.childViewControllers.index(of: toVC)!
        
        self.isPresenting = toVCIndex > fromVCIndex
        self.fromViewController = fromViewController ?? fromVC
        self.toViewController = toViewController ?? toVC
        self.isTabBarController = true
        
        return self
    }
}
