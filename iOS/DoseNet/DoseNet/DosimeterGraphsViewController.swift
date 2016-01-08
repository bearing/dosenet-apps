//
//  DosimeterGraphsViewController.swift
//  DoseNet
//
//  Created by Navrit Bal on 06/01/2016.
//  Copyright © 2016 navrit. All rights reserved.
//

import UIKit
import Alamofire
import CSwiftV
import Charts

class DosimeterGraphsViewController: UIViewController {
    @IBOutlet weak var labelLeadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var lineChartView: LineChartView!

    private var labelLeadingMarginInitialConstant: CGFloat!
    
    func main() {
        getData()
    }
    
    func getData() {
        let url = "https://radwatch.berkeley.edu/sites/default/files/dosenet/etch.csv"
        Alamofire.request(.GET, url).responseString { response in
            switch response.result {
            case .Success:
                print("SUCCESS")
                if let value = response.result.value {
                    var data = self.csvParse(value)
                    self.updatePlot(data)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    func csvParse(inputString: String) -> ([String]!, [Double]!, [Double]!) {
        let csv = CSwiftV(String: inputString)
        let rows = csv.rows

        //var times:[NSDate]!
        var times:[String]! = []
        var doses:[Double]! = []
        var doseErrors:[Double]! = []
        
        for row in rows {
            //let dateFormatter = NSDateFormatter()
            //dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            //let date = dateFormatter.dateFromString(row[0])
            //times.append(date!)
            times.append(row[0])
            doses.append(Double(row[1])!)
            doseErrors.append(Double(row[2])!)
        }
        
        /*print(times[0...5])
        print(doses[0...5])
        print(doseErrors[0...5])*/
        
        return (times, doses, doseErrors)
    }
    
    func updatePlot( data : (xVals: [String]!, dose:[Double]!, doseError:[Double]!)) {
        /*print(data.xVals[0...5])
        print(data.dose[0...5])
        print(data.doseError[0...5])*/
        
        lineChartView.noDataText = "Error: No data received"
        lineChartView.descriptionText = "Radiation over time"
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<data.xVals.count {
            let dataEntry = ChartDataEntry(value: data.dose[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(yVals: dataEntries, label: "CPM")
        chartDataSet.colors = ChartColorTemplates.liberty()
        let chartData = LineChartData(xVals: data.dose, dataSet: chartDataSet)
        lineChartView.data = chartData
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        main()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}