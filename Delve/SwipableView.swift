import Foundation
import UIKit


protocol SwipableViewDelegate
{
    func viewSwipedLeft(swippableView: SwipableView)
    func viewSwipedRight(swippableView: SwipableView)
}


class SwipableView: UIView {
    
    private var xFromCenter: CGFloat!
    private var yFromCenter: CGFloat!
    
    private var originalPoint: CGPoint!
    
    private let ROTATION_ANGLE: CGFloat = 3.14 / 8.0
    private let ROTATION_STRENGTH: CGFloat = 320
    private let ROTATION_MAX: CGFloat = 1
    private let SCALE_MAX: CGFloat = 0.93
    private let SCALE_SCTRENGHT: CGFloat = 4
    private let ACTION_MARGIN: CGFloat = 120
    
    var delegate: SwipableViewDelegate!
    
    init(frame: CGRect, content: UIView) {
        super.init(frame: frame)
        
        setupViewWithContent(content: content)
        setupPanGestureRecognizer()
    }
    
    func setupPanGestureRecognizer() {
        let panRecognizer = UIPanGestureRecognizer()
        panRecognizer.addTarget(self, action: #selector(self.beingDragged(gr:)))
        addGestureRecognizer(panRecognizer)
        
    }
    
    @objc func beingDragged(gr:UIPanGestureRecognizer){
        xFromCenter = gr.translation(in: self).x
        yFromCenter = gr.translation(in: self).y
        
            switch gr.state {
            case .began:
                originalPoint = center
                break
            case .changed:
                //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
                let rotationStrength = min(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX)
                
                //%%% degree change in radians
                let rotationalAngel = (CGFloat)(ROTATION_ANGLE * rotationStrength)
                
                //%%% amount the height changes when you move the card up to a certain point
                let scale = max(1 - abs(rotationStrength) / SCALE_SCTRENGHT, SCALE_MAX);
                
                //%%% move the object's center by center + gesture coordinate
                center = CGPoint(x: self.originalPoint.x + xFromCenter, y: self.originalPoint.y + yFromCenter);
                
                //%%% rotate by certain amount
                var transform = CGAffineTransform(rotationAngle: rotationalAngel);
                
                //%%% scale by certain amount
                let scaleTransform = transform.scaledBy(x: scale, y: scale);
                
                //%%% apply transformations
                transform = scaleTransform;
                //            updateOverlay:xFromCenter];
                break
            case .ended:
                afterSwipAction()
                break
            case .possible:break;
            case .cancelled:break;
            case .failed:break;
            @unknown default:
                break;
        }
    }
    
    func rightAction() {
        let finishPoint = CGPoint(x: 500, y: 2*yFromCenter + self.originalPoint.y)
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.center = finishPoint
            }) { (success: Bool) -> Void in
                self.removeFromSuperview()
        }
        
        delegate.viewSwipedRight(swippableView: self)
    }
    
    func leftAction() {
        let finishPoint = CGPoint(x: -500, y: 2*yFromCenter + self.originalPoint.y)
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.center = finishPoint
            }) { (success: Bool) -> Void in
                self.removeFromSuperview()
        }
        
        delegate.viewSwipedLeft(swippableView: self)
    }
    
    func afterSwipAction() {
        if xFromCenter > ACTION_MARGIN {
            rightAction()
        } else if xFromCenter < -ACTION_MARGIN {
            leftAction()
        } else {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.center = self.originalPoint
                self.transform = CGAffineTransform(rotationAngle: 0)
            })
        }
    }
    
    func setupViewWithContent(content: UIView) {
        content.layer.cornerRadius = 8
        layer.cornerRadius = 4;
        layer.shadowRadius = 3;
        layer.shadowOpacity = 0.2;
        layer.shadowOffset = CGSize(width: 1, height: 1);
        
        content.frame = bounds
        addSubview(content)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
