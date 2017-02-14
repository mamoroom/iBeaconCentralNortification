//
//  ViewController.swift
//  iBeaconCentralNortification
//
//  Created by MAMORU on 2017/02/10.
//  Copyright © 2017年 PARTY. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet var l_status: UILabel!
    @IBOutlet var l_rssi: UILabel!
    @IBOutlet var l_timer: UILabel!
    var startTimer: Timer = Timer()
    var countNum: Int = 0
    var isRaging: Bool = false
    
    var beaconHelper: BeaconHelper = BeaconHelper.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        beaconHelper.setDidEnterRegionFunc(func_did_enter: _didEnterRegion)
        beaconHelper.setDidExitRegionFunc(func_did_exit: _didExitRegion)
        beaconHelper.setDidRangeBeaconFunc(func_did_range: _didRangeBeacons)
        debugPrint("[init] ViewController")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func _didEnterRegion() {
        l_status.textColor = UIColor.blue
        l_status.text = "entered"
        debugPrint("[Event] ViewController:Entered!")
    }
    
    func updateTimerLabel() {
        countNum += 1
        let ms = countNum % 100
        let s = (countNum - ms) / 100 % 60
        let m = (countNum - s - ms) / 6000 % 3600
        l_timer.text = String(format: "%02d:%02d.%02d", m, s, ms)
    }
    
    func _didExitRegion() {
        resetView()
        l_status.textColor = UIColor.red
        l_status.text = "exited"
        isRaging = false
        startTimer.invalidate()
        countNum = 0
        debugPrint("[Event] ViewController:Exit!")
    }
    
    func _didRangeBeacons(rssi: Int, accuracy: Double) {
        if (!isRaging) {
            startTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
            isRaging = true
        }
        
        
        if (accuracy == -1.0) {
           l_status.text = "exit proccess"
           view.backgroundColor = UIColor.black
           l_status.textColor = UIColor.white
        } else {
            l_status.text = "ranging"
            let param: CGFloat = (-1)/CGFloat(rssi^2)*60
            debugPrint("[Log] \(rssi):\(param)")
            view.backgroundColor = UIColor(red: CGFloat(param), green: CGFloat(0.3), blue: CGFloat(0.3), alpha: CGFloat(param))
        }
        l_rssi.text = "\(rssi)"
        l_timer.textColor = UIColor.white
    }
    
    func resetView(){
        view.backgroundColor = UIColor.white
        l_status.text   = "NaN"
        l_rssi.text     = "NaN"
        l_timer.text    = "Not raging..."
        l_timer.textColor = UIColor.black
    }
    

    @IBAction func toBeUserA(_ sender: UISegmentedControl) {
        updateUser(index: sender.selectedSegmentIndex)
    }
    
    func updateUser(index: Int) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        do {
            let fetchResults = try viewContext.fetch(request)
            if fetchResults.count > 0 {
                let record = fetchResults[0] as NSManagedObject
                record.setValue(index, forKey: "id")
                debugPrint("[CoreData] Updated with '\(index)'")
            } else {
                let user = NSEntityDescription.entity(forEntityName: "User", in: viewContext)
                let newRecord = NSManagedObject(entity: user!, insertInto: viewContext)
                newRecord.setValue(index, forKey: "id")
                debugPrint("[CoreData] Inserted with '\(index)'")
            }
            try viewContext.save()
        } catch {
        }
        
    }

}

