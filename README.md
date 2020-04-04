# JLPinBubble Mergeable PinBubble in SwiftUI
## What is JLPinBubble?
**JPinBubble** is a control that contains a series of pin bubbles which can be merged and divided when they are closed to each other. It could be applied to map apps as indicator of specific locations. As users pinch the screen to zoom the map in , the two overlapped bubbles will merge into one, vice versa. 

The git address is [https://github.com/jacklandrin/JLPinBubble](https://github.com/jacklandrin/JLPinBubble)
## Requirement
* iOS 13
* Swift 5.2
* Xcode 11

## How to use it?
**JLBubbleCanvas** should be declared in your View's body. You can define the bubble's tap action in the initial function, and it has a viewbuilder that you can add the background view on the canvas. For example:
```
JLBubbleCanvas(bubbleTapAction: {bubble in
            ...tapAction
        }){
            Image("image name")
        }
```

**JLBubbleCanvasViewModel** is the view model of JLBubbleCanvas. It declares the bubbles array, bubble's size, the switch of showing number and the background image's name. Additional, serval functions that control merge and division are defined in this class. There are two functions provided for the View:
```
func judgetOverlap(_ scale:CGFloat)
func judgeDivided(_ scale:CGFloat)
```

**JLBubbleViewModel** is the view model of **JLBubbleView** that is used for showing a pin bubble. A pin bubble contains a image as bubble's background picture, a text, a num and its position information. While two bubbles merge into a new bubble, the new one's subBubble will put them into itself in case they could be restored. 