## 3.1.3

- [pr-76](https://github.com/CosmicMind/Motion/pull/76): Added missing module for Swift Package Manager.
* Updated Xcode 11 settings.

## 3.1.2

* Updated layout version in Xcode project.

## 3.1.1

* Added installation instructions to README.

## 3.1.0

- Updated to swift 4.2.
- [pr-45](https://github.com/CosmicMind/Motion/pull/45): Fixed issue-44, view is hidden below status bar during call.
  - [issue-44](https://github.com/CosmicMind/Motion/issues/44): View is hidden below status bar when a call is active.
- [pr-50](https://github.com/CosmicMind/Motion/pull/50): Allow framework to be linked from extensions.
- [pr-53](https://github.com/CosmicMind/Motion/pull/53): Bug fixes and `MotionViewTransition`.
  - Made `MotionTransition.{start|update|finish|cancel}` methods public.
  - Changed to updating model before firing animations for `CALayer` animations.
  - Added reverting `XXForNextTransition` options back to default.
  - Fixed issue when interactive transition was cancelled it was calling finish instead of cancel.
  - Fixed appearance transition callbacks for transition cancellation.
  - Fixed resume time was calculated incorrectly.
  - Fixed ~0.001 seconds precision issue by storing current time.
  - Added `MotionViewTransition` to make transitions of views possible.
- [pr-54](https://github.com/CosmicMind/Motion/pull/54): Added setCompletionCallbackForNextTransition.
- [pr-55](https://github.com/CosmicMind/Motion/pull/55): Fixed UITabBarController had userinteraction enabled during transition.

## 1.5.0

* Updated for Swift 4.2.

## 1.4.3

* [pr-42](https://github.com/CosmicMind/Motion/pull/42): Fixed unbalanced calls to begin/end appearance transitions.
  * [issue-29](https://github.com/CosmicMind/Motion/issues/29): Unbalanced calls to begin/end appearance.

## 1.4.2

* [pr-40](https://github.com/CosmicMind/Motion/pull/40): Fixed delegation issue, where UINavigationController and UITabBarController were not correctly calling their delegate methods.

## 1.4.1

* Minor cleanup.

## 1.4.0

* Updated for Xcode 9.3. 

## 1.3.5

* [issue-26](https://github.com/CosmicMind/Motion/issues/26): Fixed typo. 

## 1.3.4

* [issue-1022](https://github.com/CosmicMind/Material/issues/1022): Fixed alpha issue, where alpha was being set to 1 and not respecting the initial set alpha value.

## 1.3.3

* [issue-24](https://github.com/CosmicMind/Motion/issues/24): Fixed regression where view lifecycle functions were not being called.

## 1.3.2

* Fixed unbalanced calls in Motion transitions.

## 1.3.1

* Updated isMotionEnabled check, as it was determined incorrectly. 

## 1.3.0

* Reworked Motion internals.

## 1.2.5

* `UIViewController.motionModalTransitionType` renamed to `UIViewController.motionTransitionType`.
* Updated logic steps for `TabsController.motionTransitionType` and child view controller `motionTransitionType` values.

## 1.2.4

* Added begin / end transition methods for from / to view controllers.

## 1.2.3

* Replaced DispatchQueue.main.async calls to Motion.async.

## 1.2.2

* Updated Motion for iOS 11, where snapshot would no longer include a container view.

## 1.2.1

* Submodule access rights update for [Material](https://github.com/CosmicMind/Material).

## 1.2.0

* Updated to `Swift 4`.
* Fixed a couple memory leaks.

## 1.1.2

* Minor internal updates.

## 1.1.1

* Added Motion logo to README.

## 1.1.0

* [issue-5](https://github.com/CosmicMind/Motion/issues/5): Added the ability to add custom timing functions.
* [issue-4](https://github.com/CosmicMind/Motion/issues/4): Fixed an issue where a white flash occurred when pushing/popping a view controller.
* [issue-8](https://github.com/CosmicMind/Motion/issues/8): Added the ability to add animation immediately.
* [issue-6](https://github.com/CosmicMind/Motion/issues/6): Added the ability to animate views that are not paired.
