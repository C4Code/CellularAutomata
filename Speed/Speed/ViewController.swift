//
//  ViewController.swift
//  Speed
//
//  Created by travis on 2014-12-10.
//  Copyright (c) 2014 C4. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var globalStart = CFAbsoluteTimeGetCurrent()
    var map = [Bool]()

    override func viewDidLoad() {
        var startTime = CFAbsoluteTimeGetCurrent()
        let w = Int(view.frame.size.width)
        let h = Int(view.frame.size.height/4)
        if true {
            //Code Generation settings
            //None:                 0.0214930176734924
            //Fastest:              0.00241899490356445
            //Fastest unchecked:    0.00237900018692017
            self.map = Array(count: (w*h), repeatedValue:false)
            self.map[w/2] = true

        }
//        else {
//            //Code Generation settings
//            //None:                 2.38802695274353
//            //Fastest:              0.011913001537323
//            //Fastest unchecked:    0.0432270169258118
//            map = [Bool]()
//            for i in 0..<w*h {
//                map.append(false)
//            }
//            map[w/2] = true
//        }
        
        var endTime = CFAbsoluteTimeGetCurrent()
        println("\(endTime) - \(startTime) = \(endTime-startTime)")
        
        var rules = [String:Bool]()
        rules["000"] = false
        rules["100"] = true
        rules["010"] = true
        rules["001"] = true
        rules["110"] = false
        rules["101"] = false
        rules["011"] = true
        rules["111"] = false
        
         map[w/2] = true

//        startTime = CFAbsoluteTimeGetCurrent()
        if false {
            //None:                 10.7011860013008
            //Fastest:              3.65389502048492
            //Fastest unchecked:    3.64138394594193
            for row in 1..<h-1 {
                for col in 1..<w-1 {
                    let a = map[(row-1) * w + col - 1]
                    let b = map[(row-1) * w + col]
                    let c = map[(row-1) * w + col + 1]
                    
                    let rule: String = "\(Int(a))\(Int(b))\(Int(c))"
                    let result = rules[rule]!
                    let curr = row*w + col
                    map[curr] = result
                }
            }
        } else {
            solve(w, h: h, map: map, rules: rules)
        }
//        endTime = CFAbsoluteTimeGetCurrent()
//        println("\(endTime) - \(startTime) = \(endTime-startTime)")
    }

    private func solve(w: Int, h: Int, var map: [Bool], rules: [String:Bool])
    {
        //None:                 10.889406979084
        //Fastest:              3.81317800283432
        //Fastest unchecked:    3.82226002216339
        if false {
//            let startTime = CFAbsoluteTimeGetCurrent()
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
//                for row in 1..<h-1 {
//                    for col in 1..<w-1 {
//                        let a = map[(row-1) * w + col - 1]
//                        let b = map[(row-1) * w + col]
//                        let c = map[(row-1) * w + col + 1]
//                        
//                        let rule: String = "\(Int(a))\(Int(b))\(Int(c))"
//                        let result = rules[rule]!
//                        let curr = row*w + col
//                        map[curr] = result
//                    }
//                }
//                dispatch_async(dispatch_get_main_queue()) {
//                    let endTime = CFAbsoluteTimeGetCurrent()
//                    println("\(endTime) - \(startTime) = \(endTime-startTime)")
//                }
//            }
        } else {
//            self.map = Array(count: (w*h), repeatedValue:false)
            //100 (iphone 5s)
            //None:                 0.0335760116577148
            //Fastest:              0.0306529998779297
            //Fastest unchecked:    0.0308279991149902

            //w/2 < 200 ? w/2 : 200 (moiPhone 5s)
            //None:                 0.0280070304870605
            //Fastest:              0.0254120230674744
            //Fastest unchecked:    0.0270950198173523

            //w/2 < 200 ? w/2 : 200 (iPhone 6 plus sim)
            //None:                 0.00519198179244995
            //Fastest:              0.00509697198867798
            //Fastest unchecked:    0.00814199447631836
            let start = CFAbsoluteTimeGetCurrent()
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            let group = dispatch_group_create()
                for row in 1..<h {
                    var start = 1
                    var skip = w/2 < 200 ? w/2 : 200
                    
                    let rowqueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                    let rowgroup = dispatch_group_create()
                    dispatch_group_async(rowgroup, rowqueue, {
                        do {
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                                let startTime = CFAbsoluteTimeGetCurrent()
                                for var col = start; col < start + skip; col++ {
                                    if col >= w - 1 { break }
                                    let a = self.map[(row-1) * w + col - 1]
                                    let b = self.map[(row-1) * w + col]
                                    let c = self.map[(row-1) * w + col + 1]
                                    
                                    let rule: String = "\(Int(a))\(Int(b))\(Int(c))"
                                    let result = rules[rule]!
                                    let curr = row*w + col
                                    self.map[curr] = result
                                }
                            }
                            start += skip
                        } while start < w
                    })
                    dispatch_group_wait(rowgroup, DISPATCH_TIME_FOREVER);
                    print(".")
                }
            let end = CFAbsoluteTimeGetCurrent()
            println()
            println(">\(end) - \(start) = \(end-start)")
        }
    }
}

