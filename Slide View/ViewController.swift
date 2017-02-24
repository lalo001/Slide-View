//
//  ViewController.swift
//  Slide View
//
//  Created by Eduardo Valencia on 2/23/17.
//  Copyright © 2017 Eduardo Valencia. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var container: UIView!
    var overlay: UIView!
    var containerTopConstraint: NSLayoutConstraint?
    var containerHeightConstraint: NSLayoutConstraint?
    var height: CGFloat = 45
    var alwaysVisibleHeight: CGFloat = 60
    var midStateHeight: CGFloat = 0
    let midStateConstant: CGFloat = 75
    
    override func loadView() {
        super.loadView()
        midStateHeight = self.view.frame.height/2 - midStateConstant
        let blur = UIBlurEffect(style: .regular)
        container = UIVisualEffectView(effect: blur)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .red
        self.view.addSubview(container)
        let maskLayer = CAShapeLayer()
        let roundedRect = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height*1.5)
        maskLayer.path = UIBezierPath(roundedRect: roundedRect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 15, height: 30)).cgPath
        container.layer.mask = maskLayer
        
        let containerHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[container]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["container" : container])
        containerHeightConstraint = NSLayoutConstraint(item: container, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.view.bounds.height*1.5)
        containerTopConstraint = NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: -(self.view.bounds.height - alwaysVisibleHeight))
        self.view.addConstraints(containerHorizontalConstraints)
        if let containerHeightConstraint = containerHeightConstraint {
            self.view.addConstraint(containerHeightConstraint)
        }
        if let containerTopConstraint = containerTopConstraint {
            self.view.addConstraint(containerTopConstraint)
        }
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureDetected(_:)))
        panGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(panGestureRecognizer)
        
        overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.black
        overlay.alpha = 0
        self.view.insertSubview(overlay, belowSubview: container)
        
        let overlayHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[overlay]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["overlay" : overlay])
        let overlayVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[overlay]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["overlay" : overlay])
        self.view.addConstraints(overlayHorizontalConstraints)
        self.view.addConstraints(overlayVerticalConstraints)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewWillLayoutSubviews() {
        midStateHeight = self.view.frame.height/2 - midStateConstant
        let height = self.view.bounds.height*1.5
        containerHeightConstraint?.constant = height
    }
    
    // MARK: - UIPanGestureRecognizer Functions
    
    func panGestureDetected(_ gestureRecognizer: UIPanGestureRecognizer) {
        let location = gestureRecognizer.translation(in: self.view)
        let velocity = gestureRecognizer.velocity(in: self.view)
        let downMaxY = self.view.frame.height - alwaysVisibleHeight
        let duration: TimeInterval = 0.15
        let midStateY = self.view.bounds.height - midStateHeight
        if (velocity.y < 0 && container.frame.origin.y > height) || (velocity.y > 0 && container.frame.origin.y < downMaxY) || velocity.y == 0 {
            var futureOriginY = self.container.frame.origin.y + location.y
            if velocity.y < 0 && futureOriginY < height {
                futureOriginY = height
                containerTopConstraint?.constant = -(futureOriginY)
            } else if velocity.y > 0 && futureOriginY > downMaxY {
                futureOriginY = downMaxY
                containerTopConstraint?.constant = -(futureOriginY)
            }
            let containerHeight = container.frame.height/1.5
            let halfContainer = (containerHeight - midStateHeight)/2
            let bottomHalfContainer = containerHeight - halfContainer/2
            let limitVelocity: CGFloat = 800
            let currentOriginY = container.frame.origin.y
            if velocity.y < -limitVelocity && (gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled) {
                // Quick swipe up
                print("Quick up")
                if currentOriginY >= midStateY {
                    containerTopConstraint?.constant = -(self.view.bounds.height - midStateHeight)
                } else {
                    containerTopConstraint?.constant = -height
                }
                let springVelocity: CGFloat = abs(velocity.y/100)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: springVelocity*1.5, initialSpringVelocity: springVelocity, options: .curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            } else if velocity.y > limitVelocity && (gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled) {
                // Quick swipe down
                print("Quick down")
                if currentOriginY >= halfContainer {
                    containerTopConstraint?.constant = -(self.view.bounds.height - alwaysVisibleHeight)
                } else {
                    containerTopConstraint?.constant = -(self.view.bounds.height - midStateHeight)
                }
                let springVelocity: CGFloat = abs(velocity.y/100)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: springVelocity*1.5, initialSpringVelocity: springVelocity, options: .curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            } else if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
                // Move normally
                print("Move")
                if futureOriginY >= bottomHalfContainer {
                    containerTopConstraint?.constant = -(self.view.bounds.height - alwaysVisibleHeight)
                } else if futureOriginY >= halfContainer {
                    containerTopConstraint?.constant = -(self.view.bounds.height - midStateHeight)
                } else if futureOriginY < halfContainer {
                    containerTopConstraint?.constant = -height
                }
                UIView.animate(withDuration: duration, animations: {
                    self.view.layoutIfNeeded()
                })
            } else {
                print("Minimum Movement Required")
                containerTopConstraint?.constant = -(futureOriginY)
            }
        }
        let currentYOrigin = container.frame.origin.y
        if currentYOrigin <= midStateY && currentYOrigin >= height {
            let distance = abs(midStateY - currentYOrigin)
            let newAlpha = (distance*0.4)/(midStateY - height)
            print("New Alpha: \(newAlpha)")
            UIView.animate(withDuration: 0.15, animations: {
                self.overlay.alpha = newAlpha
            })
        }
        gestureRecognizer.setTranslation(.zero, in: self.view)
    }
    
}

