//
//  ViewController.swift
//  CellularAutomataOSX
//
//  Created by travis on 2014-12-11.
//  Copyright (c) 2014 C4. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var allowsRandomPixel = false
    var allowsRandomRule = false
    var ruleIndex = 0
    var currentArray = [Bool]()
    var firstRow = [Bool]()
    
    var pixarr = [Pixel]()
    var pixrow = [Pixel]()
    
    var rules = [[String:Pixel]]()
    var currentRules = [String:Pixel]()
    var imgv = NSImageView()
    
    var baseFilename = ""
    
    var step = 15

    func random(below: Int) -> Int {
        return Int(arc4random_uniform(UInt32(below)))
    }
    
    override func viewDidLoad() {
        
        generateRules()
        let w = 200
        let h = 200
        pixrow = Array(count:w, repeatedValue:Pixel())
        
        switch(step) {
        case 1:
            baseFilename = "CA_5Cluster_Random"
            let start = random(w-20)
            for i in 0...5 {
                pixrow[start + random(20)] = Pixel(255)
            }
        case 2:
            baseFilename = "CA_5Cluster_Balanced"
            let start = random(w-20)
            for i in 0...5 {
                pixrow[start + i * 4] = Pixel(255)
            }
        case 3:
            baseFilename = "CA_10Cluster_Balanced"
            let start = random(w-40)
            for i in 0...10 {
                pixrow[start + i * 4] = Pixel(255)
            }
        case 4:
            baseFilename = "CA_10Cluster_Random"
            let start = random(w-40)
            for i in 0...10 {
                pixrow[start+random(40)] = Pixel(255)
            }
        case 5:
            baseFilename = "CA_4x3Cluster_Wide"
            for i in 0...3 {
                let start = random(w-10)
                for j in 0...2 {
                    pixrow[start + random(10)] = Pixel(255)
                }
            }
        case 6:
            baseFilename = "CA_3x4Cluster_Wide"
            for i in 0...2 {
                let start = random(w-10)
                for j in 0...3 {
                    pixrow[start + random(8)] = Pixel(255)
                }
            }
        case 7:
            baseFilename = "CA_SinglePoint_Balanced_AllowsRandomPixel"
            pixrow[w/2] = Pixel(255)
            self.allowsRandomPixel = true
        case 8:
            baseFilename = "CA_5Cluster_Random_AllowsRandomPixel"
            let start = random(w-20)
            for i in 0...5 {
                pixrow[start + random(20)] = Pixel(255)
            }
            self.allowsRandomPixel = true
        case 9:
            baseFilename = "CA_5Cluster_Balanced_AllowsRandomPixel"
            let start = random(w-20)
            for i in 0...5 {
                pixrow[start + i * 4] = Pixel(255)
            }
            self.allowsRandomPixel = true
        case 10:
            baseFilename = "CA_10Cluster_Balanced_AllowsRandomPixel"
            let start = random(w-40)
            for i in 0...10 {
                pixrow[start + i * 4] = Pixel(255)
            }
            self.allowsRandomPixel = true
        case 11:
            baseFilename = "CA_10Cluster_Random_AllowsRandomPixel"
            let start = random(w-40)
            for i in 0...10 {
                pixrow[start+random(40)] = Pixel(255)
            }
            self.allowsRandomPixel = true
        case 12:
            baseFilename = "CA_4x3Cluster_Wide_AllowsRandomPixel"
            for i in 0...3 {
                let start = random(w-10)
                for j in 0...2 {
                    pixrow[start + random(10)] = Pixel(255)
                }
            }
            self.allowsRandomPixel = true
        case 13:
            baseFilename = "CA_3x4Cluster_Wide_AllowsRandomPixel"
            for i in 0...2 {
                let start = random(w-10)
                for j in 0...3 {
                    pixrow[start + random(8)] = Pixel(255)
                }
            }
        case 14:
            baseFilename = "CA_SinglePoint_Balanced_AllowsRandomRule"
            pixrow[w/2] = Pixel(255)
            allowsRandomRule = true
        case 15:
            baseFilename = "CA_SinglePoint_Balanced_AllowsRandomRule_LessRandom"
            pixrow[w/2] = Pixel(255)
            allowsRandomRule = true
        default:
            baseFilename = "CA_SinglePoint_Balanced"
            pixrow[w/2] = Pixel(255)
        }
        
        nextAsync()
    }
    
    func parseRow(row:[Pixel]) -> [Pixel] {
        let p = Pixel()
        var nextRow = [Pixel]()
        for i in 0...99 {
            nextRow.append(p)
        }
        
        var p3 = [Pixel]()
        p3.append(row[0])
        p3.append(row[1])
        for i in 1...row.count-1 {
            p3.append(row[i+1])
            let pix = self.rule(p3)
            if pix.rule == "1" {
                nextRow[i] = pix
            }
        }
        return nextRow
    }
    
    func restart() {
        step++
        if step > 13 { exit(0) }
        pixrow = Array(count:200, repeatedValue:Pixel())
        ruleIndex = 0
    }
    
    func nextAsync() {
        autoreleasepool { () -> () in
            if self.ruleIndex >= self.rules.count { exit(0)}
            self.currentRules = self.rules[self.ruleIndex]
            self.ruleIndex++
            let w = 200
            let h = 200
            var parr = [Pixel]()
            parr += self.pixrow
            parr += Array(count:(w * (h-1)), repeatedValue:Pixel())
            let startArr = CFAbsoluteTimeGetCurrent()
            var p3 = [parr[0],parr[1],parr[2]]
            var currPos: Int = 0
            let q = dispatch_queue_create("q", DISPATCH_QUEUE_SERIAL)
            for row in 0..<h-1 {
                dispatch_sync(q, {
                    
                    let c = dispatch_queue_create("c\(row)", DISPATCH_QUEUE_CONCURRENT)
                    let g = dispatch_group_create()
                    dispatch_group_async(g, c) {
                        var currPos = (row * w) + 1 //reset the current position for each row
                        var p3 = [parr[currPos-1],parr[currPos],parr[currPos+1]] //reset the p3 array
                        for col in 1..<w-1 {
                            let pix = self.rule(p3)
                            parr[currPos + w] = pix //set the current position in the next row according to the current p3 rule
                            p3.removeAtIndex(0) //shift the rules by removing the first element of p3
                            p3.append(parr[++currPos+1])//increment currPos, then grab the next pixel past that
                        }
                        if self.allowsRandomPixel && self.random(100) < 5 {
                            parr[currPos+self.random(w)] = Pixel(128,128,128)
                        }
                        if self.allowsRandomRule && self.random(200) < 5 {
                            self.currentRules = self.rules[self.random(self.rules.count)]
                        }
                    }
                    dispatch_group_wait(g, DISPATCH_TIME_FOREVER)
                })
            }
            dispatch_sync(q) {
                
                var arr = Array(self.currentRules.keys)
                arr.sort { $0 < $1 }
                
                var filename = self.baseFilename+"_"
                for i in 0..<arr.count {
                    var key = arr[i]
                    var pix = self.currentRules[key]!
                    var s = pix.rule
                    filename += s
                }

                let fm = NSFileManager()
                fm.createDirectoryAtPath(self.docsDir()+"/\(self.baseFilename)/", withIntermediateDirectories: false, attributes: nil, error: nil)
                
                let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true);

                let img = self.imageFromPixelData(parr, width: UInt(w), height: UInt(h))
                let data = img.TIFFRepresentationUsingCompression(NSTIFFCompression.None, factor: 1)!
                data.writeToFile(self.docsDir()+"/\(self.baseFilename)/\(filename).png", atomically: true)
                
                self.delay(0.1, closure: { () -> () in
                    self.nextAsync()
                })
            }
        }
    }
    
    func next() {
        currentRules = rules[random(rules.count)]
        
        let w = 200
        let h = 200
        let startArr = CFAbsoluteTimeGetCurrent()
        var p3 = [pixarr[0],pixarr[1],pixarr[2]]
        var currPos: Int = 0
        for row in 0..<h-1 {
            currPos = (row * w) + 1 //reset the current position for each row
            p3 = [pixarr[currPos-1],pixarr[currPos],pixarr[currPos+1]] //reset the p3 array
            for col in 1..<w-1 {
                pixarr[currPos + w] = rule(p3)//set the current position in the next row according to the current p3 rule
                p3.removeAtIndex(0) //shift the rules by removing the first element of p3
                p3.append(pixarr[++currPos+1])//increment currPos, then grab the next pixel past that
            }
        }
        let endArr = CFAbsoluteTimeGetCurrent()

        imgv.image = imageFromPixelData(pixarr, width: UInt(w), height: UInt(h))
        delay(1, closure: { () -> () in
            self.next()
        })
    }
    
    func generateRules() {
        for a in 0...1 {
            for b in 0...1 {
                for c in 0...1 {
                    for d in 0...1 {
                        for e in 0...1 {
                            for f in 0...1 {
                                for g in 0...1 {
                                    for h in 0...1 {
                                        rules.append([
                                            "000":Pixel(a*255),
                                            "001":Pixel(b*255),
                                            "010":Pixel(c*255),
                                            "011":Pixel(d*255),
                                            "100":Pixel(e*255),
                                            "101":Pixel(f*255),
                                            "110":Pixel(g*255),
                                            "111":Pixel(h*255)
                                            ])
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func imageFromPixelData(pixels: [Pixel], width: UInt, height: UInt) -> NSImage {
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo:CGBitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedFirst.rawValue)
        let bitsPerComponent: UInt = 8
        let bitsPerPixel: UInt = 32
        
        let c = pixels.count
        let t = Int(width * height)
        
//        assert(c == t)
        
        var d = pixels
        let data = NSData(bytes: &d, length: d.count * sizeof(Pixel))
        let provider = CGDataProviderCreateWithCFData(data)
        let img = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, width * UInt(sizeof(Pixel)), rgbColorSpace, bitmapInfo, provider, nil, true, kCGRenderingIntentDefault)
        return NSImage(CGImage: img!, size: CGSizeMake(CGFloat(width), CGFloat(height)))
    }
    
    
    func old() {
        delay(0.1, {
            var array = [Bool]()
            let w = Int(self.view.frame.size.width)
            let h = Int(60)
            self.firstRow = Array(count: w, repeatedValue:false)
            self.firstRow[w/2] = true
        })
    }
    
    func rule(pixels:[Pixel]) -> Pixel {
        return rule(pixels[0],pixels[1],pixels[2])
    }
    
    func rule(a: Pixel, _ b: Pixel, _ c:Pixel) -> Pixel {
        let key = "\(a.rule)\(b.rule)\(c.rule)"
        let result = currentRules[key]!
        return result
    }
    
    func solved(array:[Bool]) {
        currentArray.removeAll()
        currentArray += firstRow
        currentArray += array
    }
    
    private func solveForward(w: Int, _ h: Int, _ firstRow: [Pixel]) -> [Pixel] {
        var map = [Pixel]()
        map += firstRow
        
        return map
    }
    
    private func solveRows(w: Int, _ h: Int, inout _ array:[Bool]) {
        let rowsq = dispatch_queue_create("rowsq", DISPATCH_QUEUE_CONCURRENT)
        
        var rows: [[Bool]] = Array(count: h, repeatedValue:[Bool]())
        for row in 1..<h {
            dispatch_sync(rowsq, {
                let rowq = dispatch_queue_create("rowq\(row)", DISPATCH_QUEUE_CONCURRENT)
                let rowg = dispatch_group_create()
                
                let length = w / 5
                var segments: [[Bool]] = Array(count: 5, repeatedValue:[Bool]())
                var sem = dispatch_semaphore_create(0)
                
                let value = row % 2
                for i in 0..<5 {
                    let start = i * length
                    if start >= w {
                        break
                    }
                    
                    dispatch_group_async(rowg, rowq, {
                        var rowSegMap = Array(count: length, repeatedValue:false)
                        for col in start..<(start+length) {
                            if col >= w { break }
                            rowSegMap[col-start] = Bool(value)
                        }
                        segments[i] = rowSegMap
                        dispatch_semaphore_signal(sem)
                    })
                }
                dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)
                
                dispatch_group_notify(rowg, rowq, {
                    var newrow = [Bool]()
                    for seg in segments {
                        newrow += seg
                    }
                    dispatch_sync(dispatch_get_main_queue(), {
                        rows[row] = newrow
                        if row == h-1 {
                            var array = [Bool]()
                            for i in 0..<rows.count {
                                array += rows[i]
                            }
                            self.solved(array)
                        }
                    })
                })
            })
        }
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

public struct Pixel {
    var a:UInt8 = 255
    var r:UInt8
    var g:UInt8
    var b:UInt8
    
    init() {
        self.init(0,0,0)
    }
    
    init(_ val: Int) {
        self.init(UInt8(val),UInt8(val),UInt8(val))
    }
    
    init(_ r: UInt8, _ g: UInt8, _ b: UInt8) {
        self.r = r
        self.g = g
        self.b = b
    }
    
    var rule: String {
        get {
            if self.r == 0 && self.g == 0 && self.b == 0 { return "0" }
            return "1"
        }
    }
}
