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
    @IBOutlet weak var segmentedControl_Unit: UISegmentedControl!
    @IBAction func unitChanged(sender : UISegmentedControl) {
        switch segmentedControl_Unit.selectedSegmentIndex {
        case 0:
            print("Selected µSv/hr")
            dose_unit = "µSv/hr"
            lineChartView.leftAxis.removeAllLimitLines()
            chartData.removeDataSet(chartDataSet)
            self.updatePlot( self.reducedDataUSV )
        case 1:
            print("Selected mRem/hr")
            dose_unit = "mRem/hr"
            lineChartView.leftAxis.removeAllLimitLines()
            chartData.removeDataSet(chartDataSet)
            self.updatePlot( self.reducedDataREM )
        default:
            break; 
        }
    }

    private var labelLeadingMarginInitialConstant: CGFloat!

    var reducedDataUSV: csvStruct!
    var reducedDataREM: csvStruct!
    var dose_unit: String!
    var shortDoseUnit:String! = "USV"
    var time_unit: String! = "Day"
    var chartDataSet:LineChartDataSet!
    var chartData:LineChartData!

    struct csvStruct {
        var times: [NSDate]
        var doses: [Double]

        func length() -> Int {
            return doses.count
        }
        
        /*subscript(start: Int, end: Int) -> csvStruct {
            get {
                return csvStruct(times: Array(times[start...end]), doses: Array(doses[start...end]))
            }
        }*/
        subscript(range : Range<Int>) -> csvStruct {
            get {
                return csvStruct(times: Array(times[range.startIndex..<range.endIndex]), doses: Array(doses[range.startIndex..<range.endIndex]))
            }
        }
        subscript(index: Int) -> csvStruct {
            get {
                return csvStruct(times: [times[index]], doses: [doses[index]])
            }
        }
        
        init(times: [NSDate], doses: [Double]) {
            self.times = times
            self.doses = doses
        }

    }

    func main() {
        getData()
    }

    func getShortName( longName:String ) -> String {
        if longName == "Campolindo High School" {
            return "campolindo"
        } else if longName == "Pinewood High School" {
            return "pinewood"
        } else if longName == "Etcheverry Hall" {
            return "etchhall"
        } else if longName == "Etcheverry Hall Roof" {
            return "etchhall_roof"
        } else if longName == "LBL" {
            return "lbl"
        } else {
            return ""
        }
    }
    
    func getData() {
        var url = "https://radwatch.berkeley.edu/sites/default/files/dosenet/"
        url += "etch.csv"
        //url += (self.getShortName() + ".csv")
        //print((self.getShortName() + ".csv"))

        Alamofire.request(.GET, url).responseString { response in
            switch response.result {
            case .Success:
                print("SUCCESS")
                if let value = response.result.value {
                    let allData = self.csvParse( CSwiftV(String: value) )
                    self.reducedDataUSV = self.reduceData( allData.csvStruct, sampleSize: allData.sampleSize, scaleFactor: allData.scaleFactor )
                    self.reducedDataREM = self.reducedDataUSV
                    for i in 0..<self.reducedDataREM.length() {
                        self.reducedDataREM.doses[Int(i)] /= 10
                    }
                    self.initPlot()
                    self.updatePlot( self.reducedDataUSV )
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
        
        var sampleSize:Int = 1
        var scaleFactor:Double = 1
        
        switch(shortDoseUnit) { // Scale dose relative to CPM
        case "CPM":
            scaleFactor = 1
            dose_unit = "CPM"
        case "USV":
            scaleFactor = CPMtoUSV
            dose_unit = "µSv/hr"
        case "REM":
            scaleFactor = CPMtoUSV/10
            dose_unit = "mRem/hr"
        case "cigarette":
            scaleFactor = CPMtoUSV*0.00833333335
            dose_unit = "Cigarettes/hr"
        case "medical":
            scaleFactor = CPMtoUSV*0.2
            dose_unit = "X-rays/hr"
        case "plane":
            scaleFactor = CPMtoUSV*0.420168067
            dose_unit = "Air travel/hr"
        default:
            scaleFactor = CPMtoUSV
            print("Defaulting on µSv/hr, unit: \(shortDoseUnit)")
        }
        
        for row in rows {
            times.append(stringToDate(row[0]))
            doses.append(Double(row[1])!*scaleFactor)
        }
        
        let output = csvStruct(times:times, doses:doses)
        var numEntries:Int = output.length()
        
        let newestData:(csvStruct) = output[output.length()-2]
        let oldestData:(csvStruct) = output[0]
        var endDate:NSDate! = newestData.times[0]
        let startDate:NSDate! = oldestData.times[0]

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
            print("Defaulting on Hour")
        }
        print("Time selected: \(time_unit)")
        
        var reducedOutput:csvStruct
        var reducedDoses:[Double] = []
        var reducedTimes:[NSDate] = []
        
        for i in (output.length() - numEntries)..<(output.length()) {
            if (output.times[i] < endDate) { break }
            reducedDoses.append(output.doses[i])
            reducedTimes.append(output.times[i])
        }
        
        reducedOutput = csvStruct(times: reducedTimes, doses: reducedDoses)
        //print(reducedOutput.doses[0...2])

        return (reducedOutput, sampleSize, scaleFactor)
    }

    func reduceData( data : csvStruct, sampleSize : Int, scaleFactor: Double) -> csvStruct {
        var times:[NSDate]! = []
        var doses:[Double]! = []
        var doseErrors:[Double]! = []
        let groups = Int(floor(Double(data.length()/sampleSize)))
        var n:Int = 0
        
        print(data.doses[0...2])
        
        print("Original length: \(data.length())")
        print("Upper index: \(groups)")
        print("Sample size: \(sampleSize)")
        //print(data[0])
        //print(data[data.length()-1])
        
        while n < groups-1 {
            n += 1
            let subData:(csvStruct) = data[(n*sampleSize)...((n+1)*sampleSize)] // Sub-sample with manually implemented struct
            
            var average:Double = 0
            for i in 0..<subData.length() {
                // this_data = sub_data[i]
                average += subData.doses[i]*5 // total counts was already averaged over 5 minute interval
            }
            let t = Double(subData.length())/5
            let error:Double = sqrt(average)/t
            average = average/t
            let d = Int(round(Double(subData.length()/2)))
            let midDate = subData.times[d] //subDates[d]
            
            times.append(midDate)
            doses.append(average*scaleFactor)
            doseErrors.append(error*scaleFactor)
        }
        
        let out = csvStruct(times:times, doses:doses)
        /*print("Reduced length: \(out.length())")
        print(out[0...2].doses)*/
        
        return out
    }

    func initPlot() {
        lineChartView.noDataText = "Error: No data received"
        lineChartView.descriptionText = ""
        lineChartView.animate(xAxisDuration: 2, easingOption: ChartEasingOption.EaseInOutSine)
        lineChartView.rightAxis.enabled = false
        
    }
    
    func updatePlot( data : csvStruct ) {
        //print(data.times[0...5])
        //print(data.doses[0...2])

        var dataEntries: [ChartDataEntry] = []

        for i in 0..<data.times.count {
            let dataEntry = ChartDataEntry(value: data.doses[i], xIndex: i)
            dataEntries.append(dataEntry)
        }

        self.chartDataSet = LineChartDataSet(yVals:dataEntries, label:"Radiation levels over time in \(self.dose_unit)")
        self.chartDataSet.colors = ChartColorTemplates.liberty()
        self.chartDataSet.drawFilledEnabled = true
        self.chartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        self.chartDataSet.drawCirclesEnabled = false
        self.chartDataSet.lineWidth = 0.2

        self.chartData = LineChartData(xVals: data.times, dataSet: chartDataSet)
        self.chartData.setDrawValues(false)
        
        let ll = ChartLimitLine(limit: self.chartData.average, label: "Average: \(NSString(format: "%.4f", self.chartData.average)) \(self.dose_unit)")
        lineChartView.leftAxis.addLimitLine(ll)
        
        lineChartView.data = self.chartData
        lineChartView.notifyDataSetChanged()
        
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
    dateFormatter.dateFormat = "yyyy-MM-DD HH:mm:ss"
    let date = dateFormatter.dateFromString(str)
    return date!
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
