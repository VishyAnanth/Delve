//
//  mainViewController.swift
//  Tender
//
//  Created by Vishal Anantharaman on 3/28/20.
//  Copyright © 2020 Vishal Anantharaman. All rights reserved.
//

import UIKit
import Firebase

class mainViewController: UIViewController, CAAnimationDelegate {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var grad = CAGradientLayer()
    var swipablecontainer = SwipableViewContainer()


    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        let restaurantsRef = db.collection("restaurants")
        swipablecontainer = SwipableViewContainer(frame: CGRect(x: 0, y: -50, width: self.view.frame.width, height: self.view.frame.height))
        swipablecontainer.layer.zPosition = 10
        self.view.addSubview(swipablecontainer)
                
        self.setGradientBackground(colorTop: UIColor(red: 200/255, green: 0/255, blue: 100/255, alpha: 1), colorBottom: UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1), object: self.view)
        _ = Timer.scheduledTimer(timeInterval: 4,target: self, selector: #selector(self.animate), userInfo: nil, repeats: true)
        
        restaurantsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
                return
            }
            for document in snapshot!.documents {
                let vieww = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
                vieww.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
                let pathReference = self.storage.reference(withPath: "\(document.data()["Image"] as! String)")
                pathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(error)
                        return
                    } else {
                        let image = UIImage(data: data!)
                        let imView = UIImageView(frame: vieww.frame)
                        imView.image = image
                        vieww.addSubview(imView)
                    }
                }
                let name = UILabel(frame: CGRect(x: 0, y: 330, width: 290, height: 50))
                name.text = (document.data()["Name"] as! String)
                name.textAlignment = .center
                name.font = name.font.withSize(20)
                name.layer.zPosition = 100
                name.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                name.textColor = .white
                vieww.addSubview(name)
                vieww.accessibilityIdentifier = (document.data()["Image"] as! String).replacingOccurrences(of: ".jpg", with: "")
                self.swipablecontainer.enqueue(card: vieww)
            }
        }
        let finishedLabel = UILabel(frame: CGRect(x: 0, y: 200, width: self.view.frame.width, height: 50))
        finishedLabel.text = "That's all for now"
        finishedLabel.textColor = .white
        finishedLabel.textAlignment = .center
        swipablecontainer.addSubview(finishedLabel)
        
        self.setupButtons()
    }
    
    func setupButtons() {
        let dislikeButton = UIImageView(frame: CGRect(x: 20, y: self.view.frame.height - 160, width: 50, height: 50))
        dislikeButton.image = UIImage(systemName: "hand.thumbsdown.fill")
        dislikeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dislikeClicked(_:))))
        dislikeButton.isUserInteractionEnabled = true
        dislikeButton.tintColor = .white
        dislikeButton.layer.zPosition = 100
        self.view.addSubview(dislikeButton)
        
        let likeButton = UIImageView(frame: CGRect(x: self.view.frame.width - 70, y: self.view.frame.height - 160, width: 50, height: 50))
        likeButton.image = UIImage(systemName: "heart.fill")
        likeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.likeClicked(_:))))
        likeButton.tintColor = .white
        likeButton.isUserInteractionEnabled = true
        likeButton.layer.zPosition = 100
        self.view.addSubview(likeButton)
    }
    func setGradientBackground(colorTop: UIColor, colorBottom: UIColor, object: AnyObject) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = object.bounds
        grad = gradientLayer
        
        UIView.transition(with: self.view, duration: 5, options: UIView.AnimationOptions.curveEaseIn, animations: { [weak self] () -> Void in
            self!.view.layer.insertSublayer(self!.grad, at: 0)
        }, completion: nil)
    }
    
    @objc func dislikeClicked(_ tap: UITapGestureRecognizer) {
        for i in stride(from: self.swipablecontainer.subviews.count - 1, to: 0, by: -1) {
            if(self.swipablecontainer.subviews[i] is SwipableView) {
                self.swipablecontainer.viewSwipedLeft(swippableView: self.swipablecontainer.subviews[i] as! SwipableView)
                break
            }
        }
    }
    @objc func likeClicked(_ tap: UITapGestureRecognizer) {
        for i in stride(from: self.swipablecontainer.subviews.count - 1, to: 0, by: -1) {
            if(self.swipablecontainer.subviews[i] is SwipableView) {
                self.swipablecontainer.viewSwipedRight(swippableView: self.swipablecontainer.subviews[i] as! SwipableView)
                break
            }
        }
    }
    @objc func animate() {
        let fromColors = self.grad.colors
        let toColors : [AnyObject] = [UIColor(red: CGFloat(Float.random(in: 0...0.1)), green: CGFloat(Float.random(in: 0...0.2)), blue: CGFloat(Float.random(in: 0...0.7)), alpha: 1).cgColor, UIColor(red: CGFloat(Float.random(in: 0...1)), green: CGFloat(Float.random(in: 0...0.2)), blue: CGFloat(Float.random(in: 0...0.2)), alpha: 1).cgColor]
        self.grad.colors = toColors
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = 4
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.delegate = self
        self.grad.add(animation, forKey:"animateGradient")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
