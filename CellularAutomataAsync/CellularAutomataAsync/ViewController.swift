//
//  ViewController.swift
//  CellularAutomataAsync
//
//  Created by travis on 2014-12-10.
//  Copyright (c) 2014 C4. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var currentArray = [Bool]()
    var firstRow = [Bool]()
    override func viewDidLoad() {
        delay(0.1, {
            var array = [Bool]()
            let w = 100
            let h = 3
            self.firstRow = Array(count: w, repeatedValue:false)
            self.firstRow[w/2] = true
            self.solve(w, h, &array)
        })
    }
    
    func solved(array:[Bool]) {
        currentArray.removeAll()
        currentArray += firstRow
        currentArray += array
        println("curr[\(currentArray.count)]")
    }
    
    private func solve(w: Int, _ h: Int, inout _ array:[Bool]) {
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
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}

