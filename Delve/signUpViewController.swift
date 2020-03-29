//
//  signUpViewController.swift
//  Tender
//
//  Created by Vishal Anantharaman on 3/28/20.
//  Copyright © 2020 Vishal Anantharaman. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class signUpViewController: UIViewController, CAAnimationDelegate {
    @IBOutlet weak var username: UITextField! {
        didSet {
            username.tintColor = UIColor.lightGray
            username.setIcon(UIImage(systemName: "person.fill")!)
        }
    }
    @IBOutlet weak var reenter: UITextField! {
        didSet {
            reenter.tintColor = UIColor.lightGray
            reenter.setIcon(UIImage(systemName: "lock.fill")!)
        }
    }
    @IBOutlet weak var password: UITextField! {
        didSet {
            password.tintColor = UIColor.lightGray
            password.setIcon(UIImage(systemName: "lock.fill")!)
        }
    }
    @IBOutlet weak var signUpButton: UIButton!
    
    var grad = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        self.setupViews()
        
        self.setGradientBackground(colorTop: UIColor(red: 200/255, green: 0/255, blue: 100/255, alpha: 1), colorBottom: UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1), object: self.view)
        _ = Timer.scheduledTimer(timeInterval: 4,target: self, selector: #selector(self.animate), userInfo: nil, repeats: true)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:))))
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        UserDefaults.standard.set(nil, forKey: "_USERNAME")
        UserDefaults.standard.set(nil, forKey: "_PASSWORD")
        do {
            try Auth.auth().signOut()
        } catch {
            print("error")
        }
        // Do any additional setup after loading the view.
    }
    
    func setupViews() {
        self.signUpButton.layer.cornerRadius = self.signUpButton.frame.height / 2
        self.signUpButton.layer.borderWidth = 1
        self.signUpButton.layer.borderColor = UIColor.white.cgColor
        
        self.username.textColor = .darkGray
        self.password.textColor = .darkGray
        self.reenter.textColor = .darkGray
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
    @objc func viewTapped(_ tap: UITapGestureRecognizer) {
        self.username.resignFirstResponder()
        self.password.resignFirstResponder()
        self.reenter.resignFirstResponder()
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        self.view.frame = CGRect(x: 0, y: -50, width: self.view.frame.width, height: self.view.frame.height)
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        if(self.username.text == "" || self.password.text == "" || self.reenter.text == "") {
            let hud = JGProgressHUD(style: .dark)
            hud.textLabel.text = "Invalid fields"
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2)
        } else {
            guard let email = self.username.text, let password = self.password.text else {
                return
            }
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if let error = error {
                    let hud = JGProgressHUD(style: .dark)
                    hud.textLabel.text = error.localizedDescription
                    hud.show(in: self.view)
                    hud.dismiss(afterDelay: 2)
                    return
                }
                UserDefaults.standard.set(email, forKey: "_USERNAME")
                UserDefaults.standard.set(password, forKey: "_PASSWORD")
                self.performSegue(withIdentifier: "signupToMain", sender: self)
            }
        }
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
