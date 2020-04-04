//
//  BubbleCanvas.swift
//  JLPinBubble
//
//  Created by jack on 2020/4/3.
//  Copyright © 2020 jack. All rights reserved.
//

import SwiftUI

struct JBubbleCanvas<Content:View>: View {
    @EnvironmentObject var bubbleCanvasDataSource : JBubbleCanvasViewModel
    
    @State var switchbool:Bool = true
    @State var scale:CGFloat = 1.0
    @State var lastScale:CGFloat = 1.0
    @State var offset = CGSize.zero
    @State var lastOffset = CGSize.zero
    
    public var bubbleTapAction:(JBubbleViewModel)->()
    
    let viewBuilder:() -> Content
    
    
    init(bubbleTapAction: @escaping (JBubbleViewModel) -> (), @ViewBuilder builder: @escaping () -> Content) {
        self.bubbleTapAction = bubbleTapAction
        self.viewBuilder = builder
    }
    
    var body: some View {
        ZStack.init(alignment: .bottom){
            ForEach(self.bubbleCanvasDataSource.list, id: \.id){bubble in
                JPinbubble(onlyShowNum: self.bubbleCanvasDataSource.onlyShowNum, scale: self.scale).environmentObject(bubble).onTapGesture(count:1){
                bubble.tapAction{ b in
                    self.bubbleTapAction(b)
                }
                }.offset(x:CGFloat(bubble.logitude) , y:CGFloat(bubble.latitude))
                .frame(width: self.bubbleCanvasDataSource.bubbleSize.width / self.scale, height: self.bubbleCanvasDataSource.bubbleSize.height / self.scale)
            }
        }.background(viewBuilder(), alignment: .center)
        .scaledToFill()
        .offset(x:self.offset.width / 2, y: self.offset.height / 2)
        .scaleEffect(self.scale)
            .simultaneousGesture(MagnificationGesture()
                .onChanged{value in
                    self.scale = value.magnitude * self.lastScale
                    if value.magnitude < 1 {
                        self.bubbleCanvasDataSource.judgetOverlap(self.scale)
                    } else {
                        self.bubbleCanvasDataSource.judgeDivided(self.scale)
                    }
            }
            .onEnded{ value in
                self.lastScale = self.scale
                }
            )
            .simultaneousGesture(DragGesture()
        .onChanged { gesture in
            let size = gesture.translation
            self.offset = CGSize(width: size.width + self.lastOffset.width, height: size.height + self.lastOffset.height)
            }
            .onEnded{gesture in
                self.lastOffset = self.offset
            })
    }
    
}

struct BubbleCanvas_Previews: PreviewProvider {
    static var previews: some View {
        JBubbleCanvas(bubbleTapAction: {bubble in
            bubble.num += 1
        }){
            Image(JBubbleCanvasViewModel.bubbleCanvasDataSource.backgroundImg)
        }.environmentObject(JBubbleCanvasViewModel.bubbleCanvasDataSource)
    }
}
