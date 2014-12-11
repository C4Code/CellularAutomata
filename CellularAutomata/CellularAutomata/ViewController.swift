//
//  ViewController.swift
//  CellularAutomata
//
//  Created by travis on 2014-12-09.
//  Copyright (c) 2014 C4. All rights reserved.
//

import UIKit

public struct Pixel {
    var a:UInt8 = 255
    var r:UInt8
    var g:UInt8
    var b:UInt8
    
    init(_ r: UInt8, _ g: UInt8, _ b: UInt8) {
        self.r = r
        self.g = g
        self.b = b
    }
}

class ViewController: UIViewController {
    var rules = [String:Bool]()
    var map = [Bool]()
    var currentContext = UIGraphicsGetCurrentContext()
    
    override func viewDidLoad() {
        self.rules["000"] = false
        self.rules["001"] = true
        self.rules["010"] = true
        self.rules["011"] = false
        self.rules["100"] = true
        self.rules["101"] = true
        self.rules["110"] = false
        self.rules["111"] = false
        createImages(rules)
    }
    
    func mega() {
        delay(1, closure: {
            for a in 0...1 {
                for b in 0...1 {
                    for c in 0...1 {
                        for d in 0...1 {
                            for e in 0...1 {
                                for f in 0...1 {
                                    for g in 0...1 {
                                        for h in 0...1 {
                                            self.rules["000"] = Bool(a)
                                            self.rules["100"] = Bool(b)
                                            self.rules["010"] = Bool(c)
                                            self.rules["001"] = Bool(d)
                                            self.rules["110"] = Bool(e)
                                            self.rules["101"] = Bool(f)
                                            self.rules["011"] = Bool(g)
                                            self.rules["111"] = Bool(h)
                                            self.createImages(self.rules)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    func createImages(rules: [String:Bool]) {
        let w = Int(100)
        let h = Int(200)
        for i in 0...1    {
            autoreleasepool({
                self.map = Array(count: (w*h), repeatedValue:false)
                self.map[w/2] = true
                self.solve(w, h, rules)

                //                let img = self.draw(w, h)
                let img = self.drawAsync(w, h)
                let imgv = UIImageView(image: img)
                imgv.center = self.view.center
                self.view.addSubview(imgv)
                var title: String = ""
                
//                var arr = Array(rules.keys)
//                arr.sort { $0 < $1 }
//                for i in 0..<arr.count {
//                    var key = arr[i]
//                    var s = rules[key]! ? "1" : "0"
//                    title += s
//                }
                
//                let data = UIImagePNGRepresentation(img);
//                data.writeToFile(self.docsDir()+"/CA_\(title)_\(i).png", atomically: true)
            })
        }
    }
    
    private func drawAsync(w: Int, _ h: Int) -> UIImage {
        var imgarr = Array(count: (w*h), repeatedValue:UIImage())
        for row in 0..<h {
            let rowqueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

            let group = dispatch_group_create()
            
            dispatch_group_async(group, rowqueue, {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGFloat(w), CGFloat(1)), true, 5.0)
                let ctx = UIGraphicsGetCurrentContext()
                for col in 0..<w-1 {
                    let layer = CALayer()
                    layer.frame = CGRectMake(0, 0, 1, 1)
                    layer.backgroundColor = UIColor.whiteColor().CGColor
                    if self.map[row*w+col] {
                        CGContextTranslateCTM(ctx, CGFloat(col), 0);
                        layer.renderInContext(ctx)
                    }
                }
                let img = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                imgarr.insert(img, atIndex: row)
            })
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
        }
        
        let imgSize = CGSizeMake(CGFloat(w), CGFloat(h))
        UIGraphicsBeginImageContextWithOptions(imgSize, true, 5.0)
        for i in 0..<imgarr.count {
            let slice = imgarr[i]
            let frame = CGRectMake(0, CGFloat(i), imgSize.width, 1)
            slice.drawInRect(frame)
        }
        let img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return img
    }

    private func draw(w: Int, _ h: Int) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGFloat(w), CGFloat(h)), true, 5.0)
        let layer = CALayer()
        layer.frame = CGRectMake(0, 0, 1, 1)
        layer.backgroundColor = UIColor.whiteColor().CGColor
        for row in 0..<h {
                for col in 0..<w-1 {
                    if self.map[row*w+col] {
                        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), CGFloat(col), CGFloat(row));
                        layer.renderInContext(UIGraphicsGetCurrentContext())
                        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), CGFloat(-col), CGFloat(-row));
                    }
                }
        }
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }

    private func solve(w: Int, _ h: Int, _ rules: [String:Bool]) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        for row in 1..<h {
            dispatch_sync(queue, { () -> Void in
                
                let rowqueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                let rowgroup = dispatch_group_create()
                dispatch_group_async(rowgroup, rowqueue, {
                    for i in 0...1000 {
                        let skip = 20
                        let start = i * skip + 1
                        if(start >= w) { break }
//                        dispatch_async(rowqueue, {
                            self.solveRowSegment(row, start: start, length: skip, w: w)
//                        })
                    }
                })
                dispatch_group_wait(rowgroup, DISPATCH_TIME_FOREVER)
            })
        }
    }
    
    func solveRowSegment(row: Int, start: Int, length: Int, w : Int) {
        for col in start..<start+length {
            if col >= w - 1 { break }
            let a = self.map[(row-1) * w + col - 1]
            let b = self.map[(row-1) * w + col]
            let c = self.map[(row-1) * w + col + 1]
            
            let rule: String = "\(Int(a))\(Int(b))\(Int(c))"
            let result = rules[rule]!
            let curr = row*w + col
            if result == true {
                self.map[curr] = result
            }
        }
    }
    
    private let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    private let bitmapInfo:CGBitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedFirst.rawValue)
    
    func imageFromPixelData(pixels: [Pixel], width: UInt, height: UInt) -> UIImage {
        let bitsPerComponent: UInt = 8
        let bitsPerPixel: UInt = 32
        
        let c = pixels.count
        let t = Int(width * height)
        
        assert(c == t)
        
        var d = pixels
        let data = NSData(bytes: &d, length: d.count * sizeof(Pixel))
        let provider = CGDataProviderCreateWithCFData(data)
        let img = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, width * UInt(sizeof(Pixel)), rgbColorSpace, bitmapInfo, provider, nil, true, kCGRenderingIntentDefault)
        return UIImage(CGImage: img)!
    }
    
    func docsDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true);
        let basePath: AnyObject = (paths.count > 0) ? paths[0] : "";
        return basePath as String;
    }

    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}


