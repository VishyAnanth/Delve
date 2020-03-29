//
//  matchViewController.swift
//  Tender
//
//  Created by Vishal Anantharaman on 3/28/20.
//  Copyright © 2020 Vishal Anantharaman. All rights reserved.
//

import UIKit
import Firebase

class matchViewController: UIViewController, CAAnimationDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    let db = Firestore.firestore()
    var yVal = 10
    var grad = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.frame = self.view.frame
        overrideUserInterfaceStyle = .light
        self.setGradientBackground(colorTop: UIColor(red: 200/255, green: 0/255, blue: 100/255, alpha: 1), colorBottom: UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1), object: self.view)
        _ = Timer.scheduledTimer(timeInterval: 4,target: self, selector: #selector(self.animate), userInfo: nil, repeats: true)
        //let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        /*let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.isUserInteractionEnabled = true
        blurEffectView.layer.zPosition = 100
        blurEffectView.frame = view.bounds
        view.addSubview(blurEffectView)*/
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.scrollView.layer.zPosition = 1000
        self.scrollView.isUserInteractionEnabled = true
        for subv in self.scrollView.subviews {
            print("called")
            subv.removeFromSuperview()
        }
        self.yVal = 10
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 10)
        let restLabel = UILabel(frame: CGRect(x: 10, y: self.yVal, width: Int(self.scrollView.frame.width - 20), height: 40))
        restLabel.adjustsFontSizeToFitWidth = true
        restLabel.minimumScaleFactor = 0.2
        restLabel.textAlignment = .center
        restLabel.text = "Matches"
        restLabel.layer.zPosition = 1000
        restLabel.textColor = .white
        restLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        self.scrollView.addSubview(restLabel)
        self.yVal += 50
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height + 50)
        let swipeRef = db.collection("swipes")
        swipeRef.getDocuments { (snapshot, error) in
            if let err = error {
                print(err)
                return
            }
            for doc in snapshot!.documents {
                if let swipeArr = doc.data()["targets"] as? [String] {
                    if swipeArr.count > 1 {
                        self.db.collection("restaurants").document(doc.documentID).getDocument { (snap, er) in
                            if let er = er {
                                print(er)
                                return
                            }
                            if let restaurantName = snap?.data()!["Name"] as? String {
                                let restLabel = UILabel(frame: CGRect(x: 10, y: self.yVal, width: Int(self.scrollView.frame.width), height: 40))
                                restLabel.adjustsFontSizeToFitWidth = true
                                restLabel.minimumScaleFactor = 0.2
                                restLabel.textAlignment = .left
                                restLabel.text = "   " + restaurantName
                                restLabel.layer.zPosition = 1000
                                restLabel.textColor = .white
                                restLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
                                self.scrollView.addSubview(restLabel)
                                self.yVal += 50
                                self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height + 50)
                                
                                for elem in swipeArr {
                                    if(elem != UserDefaults.standard.string(forKey: "_USERNAME")) {
                                        let container = UIView(frame: CGRect(x: 10, y: self.yVal, width: Int(self.view.frame.width) - 20, height: 80))
                                        container.backgroundColor = .clear
                                        container.layer.cornerRadius = 10
                                        container.layer.borderColor = UIColor.white.cgColor
                                        container.layer.borderWidth = 1
                                        container.layer.zPosition = 1000
                                        
                                        let matchLabel = UILabel(frame: CGRect(x: 10, y: 20, width: container.frame.width - 20, height: 40))
                                        matchLabel.adjustsFontSizeToFitWidth = true
                                        matchLabel.minimumScaleFactor = 0.2
                                        matchLabel.textColor = .white
                                        matchLabel.textAlignment = .center
                                        matchLabel.text = elem
                                        matchLabel.layer.zPosition = 1000
                                        container.addSubview(matchLabel)
                                        self.scrollView.addSubview(container)
                                        self.yVal += 90
                                        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height + 90)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
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
}
