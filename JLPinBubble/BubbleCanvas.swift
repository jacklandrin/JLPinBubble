//
//  BubbleCanvas.swift
//  JLPinBubble
//
//  Created by jack on 2020/4/3.
//  Copyright © 2020 jack. All rights reserved.
//

import SwiftUI

struct BubbleCanvas: View {
    @EnvironmentObject var bubbleViewList : BubbleListViewModel
    
    @State var switchbool:Bool = true
    @State var scale:CGFloat = 1.0
    @State var lastScale:CGFloat = 1.0
    @State var offset = CGSize.zero
    @State var lastOffset = CGSize.zero
    
    private var bubbleList:[UUID : BubbleView] = [:]
    
    public var bubbleTapAction:(BubbleViewModel)->()
    
    
    init(bubbleTapAction: @escaping (BubbleViewModel) -> ()) {
        self.bubbleTapAction = bubbleTapAction
        
    }
    
    var body: some View {
        ZStack{
            Image(self.bubbleViewList.backgroundImg)
            
            ZStack.init(alignment: .center){
                ForEach(self.bubbleViewList.list, id: \.id){bubble in
                   BubbleView(onlyShowNum: self.bubbleViewList.onlyShowNum).environmentObject(bubble).onTapGesture(count:1){
                    bubble.tapAction{ b in
                        self.bubbleTapAction(b)
                    }
                    }.offset(x:CGFloat(bubble.logitude) , y:CGFloat(bubble.latitude))
                    .frame(width: self.bubbleViewList.bubbleSize.width / self.scale, height: self.bubbleViewList.bubbleSize.height / self.scale)
                    }
            }.scaledToFill()
        }
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
        }).environmentObject(BubbleListViewModel.bubbleList)
    }
}
