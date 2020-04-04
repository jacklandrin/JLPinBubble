//
//  BubbleCanvas.swift
//  JLPinBubble
//
//  Created by jack on 2020/4/3.
//  Copyright © 2020 jack. All rights reserved.
//

import SwiftUI

struct BubbleCanvas<Content:View>: View {
    @EnvironmentObject var bubbleViewList : BubbleListViewModel
    
    @State var switchbool:Bool = true
    @State var scale:CGFloat = 1.0
    @State var lastScale:CGFloat = 1.0
    @State var offset = CGSize.zero
    @State var lastOffset = CGSize.zero
    
    private var bubbleList:[UUID : BubbleView] = [:]
    
    public var bubbleTapAction:(BubbleViewModel)->()
    
    let viewBuilder:() -> Content
    
    
    init(bubbleTapAction: @escaping (BubbleViewModel) -> (), @ViewBuilder builder: @escaping () -> Content) {
        self.bubbleTapAction = bubbleTapAction
        self.viewBuilder = builder
    }
    
    var body: some View {
        ZStack.init(alignment: .bottom){
            ForEach(self.bubbleViewList.list, id: \.id){bubble in
                BubbleView(onlyShowNum: self.bubbleViewList.onlyShowNum, scale: self.scale).environmentObject(bubble).onTapGesture(count:1){
                bubble.tapAction{ b in
                    self.bubbleTapAction(b)
                }
                }.offset(x:CGFloat(bubble.logitude) , y:CGFloat(bubble.latitude))
                .frame(width: self.bubbleViewList.bubbleSize.width / self.scale, height: self.bubbleViewList.bubbleSize.height / self.scale)
            }
        }.background(viewBuilder(), alignment: .center)
        .scaledToFill()
        .offset(x:self.offset.width / 2, y: self.offset.height / 2)
        .scaleEffect(self.scale)
            .simultaneousGesture(MagnificationGesture()
                .onChanged{value in
                    self.scale = value.magnitude * self.lastScale
                    if value.magnitude < 1 {
                        self.bubbleViewList.judgetOverlap(self.scale)
                    } else {
                        self.bubbleViewList.judgeDivided(self.scale)
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
        BubbleCanvas(bubbleTapAction: {bubble in
            bubble.num += 1
        }){
            Image(BubbleListViewModel.bubbleList.backgroundImg)
        }.environmentObject(BubbleListViewModel.bubbleList)
    }
}
