//
//  BubbleView.swift
//  JLPinBubble
//
//  Created by jack on 2020/3/30.
//  Copyright © 2020 jack. All rights reserved.
//

import SwiftUI

struct BubbleView: View {
    @EnvironmentObject var model: BubbleViewModel
    var onlyShowNum: Bool
    
    var body: some View {
        ZStack{
            Image(self.model.imageName)
            .resizable()
            Text(self.onlyShowNum ? String(self.model.num) : self.model.text)
                .foregroundColor(.red)
        }
    }
    
}


struct BubbleView_Previews: PreviewProvider {
    static var bubbleList = BubbleListViewModel.bubbleList
    static var previews: some View {
        BubbleView(onlyShowNum: true).environmentObject(bubbleList.list[0])
            .previewLayout(.fixed(width: 40, height: 30))
    }
}
