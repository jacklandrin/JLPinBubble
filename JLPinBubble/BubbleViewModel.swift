//
//  BubbleViewModel.swift
//  JLPinBubble
//
//  Created by jack on 2020/3/30.
//  Copyright © 2020 jack. All rights reserved.
//

import SwiftUI
import Combine

class BubbleViewModel : ObservableObject, Codable, Identifiable {
    
    
    let id = UUID()
    var imageName: String = ""
    var text: String = ""
    @Published var num: Int = 0
    var logitude: Float = 0.0
    var latitude: Float = 0.0
    var subBubble:[BubbleViewModel] = []
    
    
    init(imageName:String, text:String, num: Int, logitude: Float, latitude: Float) {
        self.imageName = imageName
        self.text = text
        self.num = num
        self.logitude = logitude
        self.latitude = latitude
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(imageName, forKey: .imageName)
        try container.encode(text, forKey: .text)
        try container.encode(logitude, forKey: .logitude)
        try container.encode(latitude, forKey: .latitude)
    }
    
    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let imageName = try values.decode(String.self, forKey: .imageName)
        let text =  try values.decode(String.self, forKey: .text)
        let num = try values.decode(Int.self, forKey: .num)
        let logitude = try values.decode(Float.self, forKey: .logitude)
        let latitude = try values.decode(Float.self, forKey: .latitude)
        self.init(imageName: imageName, text: text, num : num, logitude: logitude, latitude: latitude)
    }
    
    enum CodingKeys: String, CodingKey {
        //case id
        case imageName
        case text
        case num
        case logitude
        case latitude
    }

    
    public func tapAction(action:(BubbleViewModel) -> ()) {
        action(self)
    }

}

var testData = [
    BubbleViewModel(imageName:"icon1",text:"Hello",num:0,logitude:30.0,latitude:50.0),
    BubbleViewModel(imageName:"icon2",text:"Bonjour",num:1,logitude:100.0,latitude:90.0),
    BubbleViewModel(imageName:"icon3",text:"Guten Tag",num:2,logitude:240.0,latitude:10.0)
]

extension BubbleViewModel{
    
    
    static var helloBubble = BubbleListViewModel.bubbleList.list[0]
    
}

class BubbleListViewModel : ObservableObject, Codable, Identifiable{
    
    init(_ list:[BubbleViewModel] = [], onlyShowNum:Bool, bubbleSize:CGSize, backgroundImg:String) {
        self.list = list
        self.onlyShowNum = onlyShowNum
        self.bubbleSize = bubbleSize
        self.backgroundImg = backgroundImg
    }
    
    convenience init(_ list:[BubbleViewModel] = [], bubbleSize:CGSize, backgroundImg: String) {
        self.init(list, onlyShowNum:false, bubbleSize: bubbleSize, backgroundImg: backgroundImg)
    }
    
    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let list = try values.decode(Array<BubbleViewModel>.self, forKey: .list)
        let bubbleWidth = try values.decode(CGFloat.self, forKey: .bubbleWidth)
        let bubbleHeight = try values.decode(CGFloat.self, forKey: .bubbleHeight)
        let onlyShowNum = try values.decode(Bool.self, forKey: .onlyShowNum)
        let backgroundImg = try values.decode(String.self, forKey: .backgroundImg)
        self.init(list, onlyShowNum: onlyShowNum, bubbleSize: CGSize(width: bubbleWidth, height: bubbleHeight), backgroundImg: backgroundImg)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(list, forKey: .list)
        try container.encode(bubbleSize.width, forKey: .bubbleWidth)
        try container.encode(bubbleSize.height, forKey: .bubbleHeight)
        try container.encode(onlyShowNum, forKey: .onlyShowNum)
        try container.encode(backgroundImg, forKey: .backgroundImg)
    }
    
    enum CodingKeys: String, CodingKey {
        case list
        case bubbleWidth
        case bubbleHeight
        case onlyShowNum
        case backgroundImg
    }
    
    @Published var list:[BubbleViewModel] = testData {
        didSet{didChange.send(self)}
    }

    @Published var onlyShowNum: Bool {
           didSet{didChange.send(self)}
    }
    
    var bubbleSize:CGSize = .zero {
        didSet{didChange.send(self)}
    }
    
    
    var backgroundImg:String = "" {
        didSet{didChange.send(self)}
    }
    
    var mergeOperation: (BubbleViewModel, BubbleViewModel) -> BubbleViewModel = { bubble1, bubble2 in
       BubbleViewModel(imageName:bubble1.imageName,text:bubble1.text + bubble2.text,num:bubble1.num + bubble2.num,logitude:(bubble1.logitude + bubble2.logitude) / 2,latitude:(bubble1.latitude + bubble2.latitude) / 2)
        
        } {
        didSet{
            didChange.send(self)
        }
    }
    
    var didChange = PassthroughSubject<BubbleListViewModel, Never>()
    
    
    func isCollide(_ scale:CGFloat, rect1:BubbleViewModel, rect2:BubbleViewModel) -> Bool {
        let displayWidth = self.bubbleSize.width / scale
        let displayHeight = self.bubbleSize.height / scale
        let isCollide = rect1.logitude < rect2.logitude + Float(displayWidth) &&
        rect1.logitude + Float(displayWidth) > rect2.logitude &&
        rect1.latitude < rect2.latitude + Float(displayHeight) &&
        Float(displayHeight) + rect1.latitude > rect2.latitude
        return isCollide
    }
    
    func judgetOverlap(_ scale:CGFloat) {
        let bubbleList = self.list
        if bubbleList.count < 2 {
            return
        } else if bubbleList.count == 2 {
            if judgeTwoBubbleCollide(bubbleList, index1: 0, index2: 1, scale: scale){ return }
        } else {
            for i in 0..<bubbleList.count {
                for j in i + 1..<bubbleList.count {
                    let isCollide = judgeTwoBubbleCollide(bubbleList,index1: i, index2: j, scale: scale)
                    if isCollide {
                        break
                    }
                    
               }
            }
        }
        
        
    }
    
    func judgeTwoBubbleCollide(_ bubbleList:[BubbleViewModel],index1:Int, index2:Int, scale: CGFloat) -> Bool {
        
        let rect1 = bubbleList[index1]
        let rect2 = bubbleList[index2]
        if isCollide(scale, rect1: rect1, rect2: rect2) {
            print("collided")
            self.mergeIntoOne(bubbleIndex1: index1, bubbleIndex2: index2)
            return true
        } else {
            print("uncollided")
            return false
        }
        
    }
    
    
    func mergeIntoOne(bubbleIndex1:Int,bubbleIndex2:Int) {
        let bubble1 = self.list[bubbleIndex1]
        let bubble2 = self.list[bubbleIndex2]
        //let newBubble:BubbleViewModel =  BubbleViewModel(imageName:bubble1.imageName,text:bubble1.text + bubble2.text,num:bubble1.num + bubble2.num,logitude:(bubble1.logitude + bubble2.logitude) / 2,latitude:(bubble1.latitude + bubble2.latitude) / 2)
        let newBubble = self.mergeOperation(bubble1,bubble2)
        newBubble.subBubble = [bubble1,bubble2]
        self.list.removeAll{$0.id == bubble1.id}
        self.list.removeAll{$0.id == bubble2.id}
        
        self.list.append(newBubble)
        
    }
    
    func judgeDivided(_ scale:CGFloat) {
        let bubbleList = self.list
        for bubble in bubbleList {
            if bubble.subBubble.count == 2 {
                let bubble1 = bubble.subBubble[0]
                let bubble2 = bubble.subBubble[1]
                
                if !self.isCollide(scale ,rect1: bubble1, rect2: bubble2) {
                    self.list.append(bubble1)
                    self.list.append(bubble2)
                    self.list.removeAll{$0.id == bubble.id}
                }
            }
        }
    }

}


extension BubbleListViewModel {
    static var bubbleList:BubbleListViewModel = bubbleData//BubbleListViewModel(testData,onlyShowNum:true, bubbleSize:  CGSize(width:80.0,height:30.0))
}


