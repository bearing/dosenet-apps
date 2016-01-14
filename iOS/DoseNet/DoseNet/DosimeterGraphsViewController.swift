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

let CPMtoUSV:Double = 0.036

class DosimeterGraphsViewController: UIViewController {
    @IBOutlet weak var labelLeadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var lineChartView: LineChartView!

    private var labelLeadingMarginInitialConstant: CGFloat!

    var data: csvStruct!
    var dose_unit: String! = "µSv/hr"
    var time_unit: String! = "Day"

    struct csvStruct {
        var times: [NSDate]
        var doses: [Double]
        var doseErrors: [Double]

        func length() -> Int {
            return times.count
        }
        
        subscript(index: Int) -> csvStruct {
            get {
                return csvStruct(times: [times[index]], doses: [doses[index]], doseErrors: [doseErrors[index]])
            }
        }
        
        init(times: [NSDate], doses: [Double], doseErrors: [Double]) {
            self.times = times
            self.doses = doses
            self.doseErrors = doseErrors
        }

    }

    func main() {
        getData()
    }

    func getData() {
        var url = "https://radwatch.berkeley.edu/sites/default/files/dosenet/"
        url += "etch.csv"
        //url += self.getShortName()

        Alamofire.request(.GET, url).responseString { response in
            switch response.result {
            case .Success:
                print("SUCCESS")
                if let value = response.result.value {
                    let allData = self.csvParse( CSwiftV(String: value) )
                    self.data = allData.csvStruct
                    self.data = self.reduceData(
                            self.data, sampleSize: allData.sampleSize, scaleFactor: allData.scaleFactor )
                    self.updatePlot(self.data)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }

    /*
    Process CSV (data, dose_unit, time_unit)
        #entries = lines.length
        newest_data = lines[lines.length-2].split(",")
        oldest_data = lines[1].split(",")
        end_date = new Date(parseDate(newest_data[0]))
        start_date = new Date(parseDate(oldest_data[0]))

        switch time_unit -> case time_options
            get end date
            #entries
            get sample size

        Parse date
        Get sample size (time)
        # of intervals
    Avg. data
    Plot data (location, dose, time, div)
        Get Title text
            data label
            y text

    */

    func csvParse(csv: CSwiftV) -> (csvStruct: csvStruct!, sampleSize: Int, scaleFactor: Double) {
        
        let rows = csv.rows
        var times:[NSDate]! = []
        var doses:[Double]! = []
        var doseErrors:[Double]! = []
        
        var sampleSize:Int = 1
        var scaleFactor:Double = 1
        
        for row in rows {
            times.append(stringToDate(row[0]))
            doses.append(Double(row[1])!)
            doseErrors.append(Double(row[2])!)
        }
        
        let output = csvStruct(times:times, doses:doses, doseErrors:doseErrors)
        var numEntries:Int = output.length()
        
        let newestData:(csvStruct) = output[output.length()-2]
        let oldestData:(csvStruct) = output[0]
        var endDate:NSDate! = newestData.times[0]
        let startDate:NSDate! = oldestData.times[0]

        /*print(times[0...5])
        print(doses[0...5])
        print(doseErrors[0...5])*/

        switch(time_unit) { // Time clipping
        case "Hour":
            endDate = endDate.dateByAddingTimeInterval(-1*3600)
            numEntries = min(numEntries, 13) // 12 5 minute intervals in last hour
        case "Day":
            endDate = endDate.dateByAddingTimeInterval(-24*3600)
            numEntries = min(numEntries, 289) // 288 5 minute intervals in last day
            sampleSize = 6
        case "Week":
            endDate = endDate.addNoOfDays(-7*24*3600)
            numEntries = min(numEntries, 2017) // 2016 in last week
            sampleSize = 12
        case "Month":
            endDate = endDate.addNoOfDays(-30*24*3600)
            numEntries = min(numEntries, 8641) // 8640 in last month (30 days)
            sampleSize = 48
        case "Year":
            endDate = endDate.addNoOfDays(-365*24*3600)
            numEntries = min(numEntries, 105121) // 105120 in last year
            sampleSize = 288 // compress to once a day
        case "All":
            // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            endDate = NSDate(timeIntervalSinceReferenceDate: endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970)
            // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        default: // "Hour"
            endDate = endDate.dateByAddingTimeInterval(-1*3600)
            numEntries = min(numEntries, 13) // 12 5 minute intervals in last hour
        }
        
        switch(dose_unit) { // Scale dose relative to CPM
        case "CPM":
            scaleFactor = 1
        case "USV":
            scaleFactor = CPMtoUSV
        case "REM":
            scaleFactor = CPMtoUSV/10
        case "cigarette":
            scaleFactor = CPMtoUSV*0.00833333335
        case "medical":
            scaleFactor = CPMtoUSV*0.2
        case "plane":
            scaleFactor = CPMtoUSV*0.420168067
        }

        return (output, sampleSize, scaleFactor)
    }

    func reduceData( data : csvStruct, sampleSize : Int, scaleFactor: Double) -> csvStruct {
        var averagedData = []
        let tmp:Int = Int(data.length()/sampleSize)
        for n in 0..<tmp {
            let sub_data = data.slice(n*sampleSize, (n+1)*sampleSize) //Sub-sample
            var average = 0
            print(sub_data.count)
            for i in 0..<sub_data.count {
                var this_data = sub_data[i];
                average += this_data[1]*5; // total counts was already averaged over 5 minute interval
            }
            error = Math.sqrt(average)/sub_data.length/5;
            average = average/sub_data.length/5;
            var d = round(sub_data.length/2);
            print(d)
            var mid_data = sub_data[d];
            var date = mid_data[0];
            averaged_data.push([date,[average*scale,error*scale]]);
        }


        return data
    }

    func updatePlot( data : csvStruct) {
        /*print(data.times[0...5])
        print(data.dose[0...5])
        print(data.doseError[0...5])*/

        lineChartView.noDataText = "Error: No data received"
        lineChartView.descriptionText = "Radiation levels over time"

        var dataEntries: [ChartDataEntry] = []

        for i in 0..<data.times.count {
            let dataEntry = ChartDataEntry(value: data.doses[i], xIndex: i)
            dataEntries.append(dataEntry)
        }

        let chartDataSet = LineChartDataSet(yVals:dataEntries, label:dose_unit)
        chartDataSet.colors = ChartColorTemplates.liberty()
        let chartData = LineChartData(xVals: data.doses, dataSet: chartDataSet)
        lineChartView.data = chartData
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        main()
    }

    override func didReceiveMemoryWarning() {
        // Dispose of any resources that can be recreated.
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

/* https://stackoverflow.com/questions/26198526/nsdate-comparison-using-swift */

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }

public func stringToDate( str: String ) -> NSDate {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter.dateFromString(str)!
}

extension NSDate {
    func addNoOfDays(noOfDays:Int) -> NSDate! {
        let cal:NSCalendar = NSCalendar.currentCalendar()
        cal.timeZone = NSTimeZone(abbreviation: "UTC")!
        let comps:NSDateComponents = NSDateComponents()
        comps.day = noOfDays
        return cal.dateByAddingComponents(comps, toDate: self, options: NSCalendarOptions(rawValue: 0))
    }
}
