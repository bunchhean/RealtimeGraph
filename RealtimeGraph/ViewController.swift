//
//  ViewController.swift
//  RealtimeGraph
//
//  Created by Bunchhean on 11/24/15.
//  Copyright © 2015 Bunchhean. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController, LineChartDelegate {
    
    let objMemory = Memory()
    var label = UILabel()
    var lineChart: LineChart!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("drawLineChat"), userInfo: nil, repeats: true)
        
        //NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("getData"), userInfo: nil, repeats: true)
        
    }
    
    func drawLineChat(){
        var views: [String: AnyObject] = [:]
        
        //label.text = "Total alloc: \(objMemory.total_alloc!)"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = NSTextAlignment.Center
        self.view.addSubview(label)
        views["label"] = label
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-80-[label]", options: [], metrics: nil, views: views))
        
        // simple arrays

       /* var data: [CGFloat] = []
        
        for i in objMemory.total_alloc!.characters {
            let n = CGFloat(("\(i)" as NSString).floatValue)
            data.append(n)
        }*/
        
        let data: [CGFloat] = [1, 2, 4, 3, 6, 8, 2, 5]
       

        // simple line with custom x axis labels
        let xLabels: [String] = ["", "1", "2", "3", "4", "5", "6", "8", "8", "9", "10"]
        
        lineChart = LineChart()
        lineChart.animation.enabled = true
        lineChart.area = true
        lineChart.x.labels.visible = true
        lineChart.x.grid.count = 11
        lineChart.y.grid.count = 10
        lineChart.x.labels.values = xLabels
        lineChart.y.labels.visible = true
        lineChart.addLine(data)
        
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.delegate = self
        
        for view in self.view.subviews {
            
            if view.isKindOfClass(LineChart) {
                view.removeFromSuperview()
            }
        }
        
        self.view.addSubview(lineChart)
        views["chart"] = lineChart
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[chart]-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[label]-[chart(==200)]", options: [], metrics: nil, views: views))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func didSelectDataPoint(x: CGFloat, yValues: Array<CGFloat>) {
        label.text = "Selected Value: \(yValues)"
    }

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        if let chart = lineChart {
            chart.setNeedsDisplay()
        }
    }
    
    
    //////////// Get data from server //////////////////
    
    func getData(){
        
        let urlToRequest = "https://dweet.io/get/latest/dweet/for/gmx-elf-ping"
        let inputData = NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
        do{
            let boardsDictionary = try NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            
            let dictionaryMemory = boardsDictionary?.objectForKey("with")?.valueForKey("content")?.valueForKey("memory") as! NSArray
            
            objMemory.alloc = dictionaryMemory[0].valueForKey("alloc")?.integerValue
            objMemory.frees = dictionaryMemory[0].valueForKey("frees")?.integerValue
            objMemory.heap_alloc = dictionaryMemory[0].valueForKey("heap_alloc")?.integerValue
            objMemory.total_alloc = dictionaryMemory[0].valueForKey("total_alloc")?.stringValue
            
            self.drawLineChat()
            
        }catch let error as NSError{
            print(error)
        }
    }


}

