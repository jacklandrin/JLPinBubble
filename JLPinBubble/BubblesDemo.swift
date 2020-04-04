//
//  BubblesDemo.swift
//  JLPinBubble
//
//  Created by jack on 2020/4/4.
//  Copyright © 2020 jack. All rights reserved.
//

import SwiftUI

struct BubblesDemo: View {
    private var bubbleList = BubbleListViewModel.bubbleList
    
    init() {
        bubbleList.mergeOperation = { b1, b2 in
        BubbleViewModel(imageName:b1.imageName,text:b1.text + b2.text,num:b1.num, logitude:(b1.logitude + b2.logitude) / 2,latitude:(b1.latitude + b2.latitude) / 2)
            }
    }
    
    var body: some View {
        BubbleCanvas(bubbleTapAction: {bubble in
            bubble.num += 1
        }).environmentObject(bubbleList)
    }
    
}

struct BubblesDemo_Previews: PreviewProvider {
    static var previews: some View {
        BubblesDemo()
    }
}
