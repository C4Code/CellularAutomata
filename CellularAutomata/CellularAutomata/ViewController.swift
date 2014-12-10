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
    override func viewDidLoad() {
        
        let w = Int(view.frame.size.width)
        let h = Int(view.frame.size.height/4)
        var map = Array(count: (w*h), repeatedValue:false)
        
        map[w/2] = true

        rules["000"] = false
        rules["100"] = true
        rules["010"] = true
        rules["001"] = true
        rules["110"] = false
        rules["101"] = false
        rules["011"] = true
        rules["111"] = false
        
        let layer = CALayer()
        let scale: CGFloat = 1
        layer.frame = CGRectMake(0, 0, scale, scale)
        layer.backgroundColor = UIColor.whiteColor().CGColor

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGFloat(w), CGFloat(h)), true, 10.0)

        for row in 1..<h-1 {
            for col in 1..<w-1 {
                let a = map[(row-1) * w + col - 1]
                let b = map[(row-1) * w + col]
                let c = map[(row-1) * w + col + 1]
        
                let rule: String = "\(Int(a))\(Int(b))\(Int(c))"
                let result = rules[rule]!
                let curr = row*w + col
                map[curr] = result
                
                if result == true {
                    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), CGFloat(col), CGFloat(row));
                    layer.renderInContext(UIGraphicsGetCurrentContext())
                    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), CGFloat(-col), CGFloat(-row));
                }
            }
        }
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let data = UIImagePNGRepresentation(img);
        
        let path = docsDir()+"/img.png"
        
        data.writeToFile(path, atomically: true)
        
        let imgv = UIImageView(image: img)
        view.addSubview(imgv)
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
}


