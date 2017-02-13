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
    
    @IBOutlet var status: UILabel!
    @IBOutlet var uuid: UILabel!
    @IBOutlet var major: UILabel!
    @IBOutlet var minor: UILabel!
    @IBOutlet var accuracy: UILabel!
    @IBOutlet var rssi: UILabel!
    @IBOutlet var distance: UILabel!
    
    var beaconHelper: BeaconHelper = BeaconHelper.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        beaconHelper.setDidEnterRegionFunc(func_did_enter: didEnterRegion)
        beaconHelper.setDidExitRegionFunc(func_did_exit: didExitRegion)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didEnterRegion() {
        status.textColor = UIColor.blue
        status.text = "entered"
        debugPrint("[Event] ViewController:Entered!")
        
    }
    
    func didExitRegion() {
        status.textColor = UIColor.red
        status.text = "exited"
        debugPrint("[Event] ViewController:Exit!")
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

