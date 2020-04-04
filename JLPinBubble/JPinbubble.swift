//
//  BubbleView.swift
//  JLPinBubble
//
//  Created by jack on 2020/3/30.
//  Copyright © 2020 jack. All rights reserved.
//

import SwiftUI

struct JPinbubble: View {
    @EnvironmentObject var model: JBubbleViewModel
    var onlyShowNum: Bool
    var scale:CGFloat = 1.0
    
    var body: some View {
        ZStack{
            Image(self.model.imageName)
            .resizable()
            Text(self.onlyShowNum ? String(self.model.num) : self.model.text)
                .foregroundColor(.red).scaleEffect(1 / self.scale)
        }.scaledToFit()
    }
    
}


struct BubbleView_Previews: PreviewProvider {
    static var bubbleList = JBubbleCanvasViewModel.bubbleCanvasDataSource
    static var previews: some View {
        JPinbubble(onlyShowNum: true, scale: 1.0).environmentObject(bubbleList.list[0])
            .previewLayout(.fixed(width: 40, height: 30))
    }
}
