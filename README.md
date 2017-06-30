**Motion** is a library used to create beautiful animations and transitions for views, layers, and view controllers.
 
## Requirements

* iOS 8.0+
* Xcode 8.0+

## Communication

- If you **need help**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/cosmicmind). (Tag 'cosmicmind')
- If you'd like to **ask a general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/cosmicmind).
- If you **found a bug**, _and can provide steps to reliably reproduce it_, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Installation

> **Embedded frameworks require a minimum deployment target of iOS 8.**
> - [Download Motion](https://github.com/CosmicMind/Motion/archive/master.zip)

Visit the [Installation](https://github.com/CosmicMind/Motion/wiki/Installation) page to learn how to install Motion using [CocoaPods](http://cocoapods.org) and [Carthage](https://github.com/Carthage/Carthage).

## Changelog

Motion is a growing project and will encounter changes throughout its development. It is recommended that the [Changelog](https://github.com/CosmicMind/Motion/wiki/Changelog) be reviewed prior to updating versions.

## Animations

Motion offers a clean API to add animations to your views and layers. Simply pass in animation structs with configurable parameters. Take a look at some examples below: 

<table>
  <thead>
	  <tr>
		  <th>Animation</th>
		  <th>Property</th>
		  <th>Swift</th>
	  </tr>
  </thead>
  <tbody>
    <tr>
      <td width="40%">
	      <img src="http://www.cosmicmind.com/motion/background_color.gif" />
	      </td>
	      <td width="30%">Border Color</td>
	      <td width="30%">```swift
	      view.animate(.background(color: .cyan))
	      ```
			  </td>
    </tr>
    <tr>
      <td width="40%" style="background-color: #ffffff">
      <img src="http://www.cosmicmind.com/motion/border_color.gif" />
      </td>
      <td width="30%">Border Color & Border Width</td>
      <td width="30%">```swift
      view.animate(.border(color: .cyan), .border(width: 20))
      ```
      </td>
    </tr>
    <tr style="background-color: #fff">
      <td width="40%">
      <img src="http://www.cosmicmind.com/motion/corner_radius.gif" />
      </td>
      <td width="30%">Border Color & Border Width</td>
      <td width="30%">```swift
      view.animate(.border(color: .cyan), .border(width: 20))
      ```
      </td>
    </tr>
    <tr style="background-color: #fff">
      <td width="40%">
      <img src="http://www.cosmicmind.com/motion/depth.gif" />
      </td>
      <td width="30%">Border Color & Border Width</td>
      <td width="30%">```swift
      view.animate(.border(color: .cyan), .border(width: 20))
      ```
      </td>
    </tr>
    <tr style="background-color: #fff">
      <td width="40%">
      <img src="http://www.cosmicmind.com/motion/fade.gif" />
      </td>
      <td width="30%">Border Color & Border Width</td>
      <td width="30%">```swift
      view.animate(.border(color: .cyan), .border(width: 20))
      ```
      </td>
    </tr>
    <tr style="background-color: #fff">
      <td width="40%">
      <img src="http://www.cosmicmind.com/motion/position.gif" />
      </td>
      <td width="30%">Border Color & Border Width</td>
      <td width="30%">```swift
      view.animate(.border(color: .cyan), .border(width: 20))
      ```
      </td>
    </tr>
    <tr style="background-color: #fff">
      <td width="40%">
      <img src="http://www.cosmicmind.com/motion/rotate.gif" />
      </td>
      <td width="30%">Border Color & Border Width</td>
      <td width="30%">```swift
      view.animate(.border(color: .cyan), .border(width: 20))
      ```
      </td>
    </tr>
    <tr style="background-color: #fff">
      <td width="40%">
      <img src="http://www.cosmicmind.com/motion/scale.gif" />
      </td>
      <td width="30%">Border Color & Border Width</td>
      <td width="30%">```swift
      view.animate(.border(color: .cyan), .border(width: 20))
      ```
      </td>
    </tr>
  </tbody>
</table>

## License

The MIT License (MIT)

Copyright (C) 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
