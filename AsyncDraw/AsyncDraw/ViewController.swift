//
//  ViewController.swift
//  AsyncDraw
//
//  Created by travis on 2014-12-10.
//  Copyright (c) 2014 C4. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var slices = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let w = self.view.frame.size.width
        let h = self.view.frame.size.height
        self.slices = Array(count: Int(h), repeatedValue: UIImage())
        
        let groupQueue = dispatch_queue_create("groupQueue", DISPATCH_QUEUE_CONCURRENT)
        let group = dispatch_group_create()

        let length = 20
        
        //what a pain in the ass
        //adding a variable here, as in a for loop, doesn't work, you have to pass static values, even copyin them to let values doesn't work...
        
        /* this doesn't work...
        for var row = 0; row < Int(h); row += 50 {
            dispatch_group_async(group, groupQueue) { () -> Void in
                self.create(row, 50, w, h)
            }
        }
        */
        
        for row in 0...100 {
            if row > Int(h) { break }
            dispatch_group_async(group, groupQueue) {
                self.create(row*50, 50, w, h)
            }
        }

    }
    
    func create(s: Int, _ l: Int, _ w: CGFloat, _ h: CGFloat) {
            for row in s..<(s+l-1) {
            if row >= Int(h) { break }
            let layer = CALayer()
            layer.frame = CGRectMake(0, 0, 1, 1)
            layer.backgroundColor = UIColor.blueColor().CGColor
            UIGraphicsBeginImageContext(CGSizeMake(w, 1))
            for j in 0..<10 {
                let x = Int(arc4random_uniform(UInt32(w)))
                CGContextTranslateCTM(UIGraphicsGetCurrentContext(), CGFloat(x), 0)
                layer.renderInContext(UIGraphicsGetCurrentContext())
                CGContextTranslateCTM(UIGraphicsGetCurrentContext(), CGFloat(-x), 0)
            }
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            dispatch_async(dispatch_get_main_queue(), {
                let imgv = UIImageView(image: img)
                let frame = CGRectMake(0, CGFloat(row), self.view.frame.size.width, 1)
                imgv.frame = frame
                self.view.addSubview(imgv)
            })
        }
    }
}

