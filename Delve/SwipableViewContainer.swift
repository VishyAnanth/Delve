//
//  SwipableViewContainer.swift
//  Tender
//
//  Created by Vishal Anantharaman on 3/28/20.
//  Copyright © 2020 Vishal Anantharaman. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SwipableViewContainer: UIView, SwipableViewDelegate {
    
    let db = Firestore.firestore()
    
    private let CARD_WIDTH: CGFloat = 290
    private let CARD_HEIGHT: CGFloat = 386
    
    private var cardQueue: Queue<SwipableView> = Queue()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.layoutSubviews()
        
        setupView()
    }
    
    private func cardFrame() -> CGRect {
        return CGRect(x: (self.frame.size.width - CARD_WIDTH)/2, y: (self.frame.size.height - CARD_HEIGHT)/2, width: CARD_WIDTH, height: CARD_HEIGHT)
    }
    
    func enqueue(card: UIView) {
        let swipableView = SwipableView(frame: cardFrame(), content: card)
        
        if cardQueue.isEmpty() {
            addSubview(swipableView)
        }
        else {
            insertSubview(swipableView, belowSubview: cardQueue.last()!)
        }
        
        swipableView.delegate = self
        cardQueue.enqueue(item: swipableView)
    }
    
    func viewSwipedLeft(swippableView: SwipableView) {
        swippableView.removeFromSuperview()
        
        _ = cardQueue.dequeue()
    }
    
    func viewSwipedRight(swippableView: SwipableView) {
        for elem in swippableView.subviews {
            if elem is UIView {
                let swipeRef = db.collection("swipes").document(elem.accessibilityIdentifier!)
                swipeRef.getDocument { (snapshot, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    if let dataa = snapshot?.data() {
                        if var currentArr = dataa["targets"] as? [String] {
                            if(!currentArr.contains(UserDefaults.standard.string(forKey: "_USERNAME")!)) {
                                let finalArr = currentArr + [UserDefaults.standard.string(forKey: "_USERNAME")]
                                swipeRef.setData(["targets":finalArr])
                            }
                        }
                    } else if(snapshot?.data() == nil) {
                        let finalArr = [UserDefaults.standard.string(forKey: "_USERNAME")]
                        swipeRef.setData(["targets":finalArr])
                    }
                }
                break
            }
        }
        
        swippableView.removeFromSuperview()
        
        _ = cardQueue.dequeue()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
