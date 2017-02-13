//
//  BeaconHelper.swift
//  iBeaconCentralNortification
//
//  Created by MAMORU on 2017/02/10.
//  Copyright © 2017年 PARTY. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import UserNotifications
import CoreData

class BeaconManager : NSObject, CLLocationManagerDelegate {
    
    var delegate: BeaconDelegate!
    var trackLocationManager = CLLocationManager()
    var beaconRegion: CLBeaconRegion!
    
    //シングルトン
    static let sharedInstance = BeaconManager()
    
    override init() {
        debugPrint("[init] BeaconManager")
        super.init()
        
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            return
        }
        trackLocationManager.delegate = self
        trackLocationManager.allowsBackgroundLocationUpdates = true
        trackLocationManager.startUpdatingLocation()
        
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        if(status == CLAuthorizationStatus.notDetermined) {
            // 認証ダイアログを表示
            self.trackLocationManager.requestAlwaysAuthorization();
        }
        
        // BeaconのUUIDを設定
        let uuid:NSUUID? = NSUUID(uuidString: Consts.beaconUUID)
        let regionid: String! = Consts.beaconRegionIdentifier
        
        //Beacon領域を作成
        self.beaconRegion = CLBeaconRegion(proximityUUID: uuid as! UUID, identifier: regionid)
        self.beaconRegion.notifyEntryStateOnDisplay = true
        self.beaconRegion.notifyOnEntry = true
        self.beaconRegion.notifyOnExit = true
        //trackLocationManager.startMonitoring(for: self.beaconRegion)
        
        //Push通知認証ダイヤログ
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
            if error != nil {
                return
            }
            if granted {
                debugPrint("[認証:PUSH通知] Authorized")
            } else {
                debugPrint("[認証:PUSH通知] Dennied")
            }
        })
        
        return
    }
    
    //毎回呼ばれる
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 認証のステータス
        var statusStr = ""
        //debugPrint("CLAuthorizationStatus: \(statusStr)")
        
        // 認証のステータスをチェック
        switch (status) {
        case .notDetermined:
            statusStr = "NotDetermined"
        case .restricted:
            statusStr = "Restricted"
        case .denied:
            statusStr = "Denied"
        case .authorizedAlways:
            statusStr = "AuthorizedAlways"
        case .authorizedWhenInUse:
            statusStr = "AuthorizedWhenInUse"
        }
        
        debugPrint("[認証:位置情報] \(statusStr)")
        //観測を開始させる
        trackLocationManager.startMonitoring(for: self.beaconRegion)
    }
    
    //観測開始成功
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        debugPrint("[観測] START");
        
        //観測開始に成功したら、領域内にいるかどうかの判定をおこなう。→（didDetermineState）へ
        trackLocationManager.requestState(for: self.beaconRegion);
    }
    
    //領域内にいるかどうかを判定する
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for inRegion: CLRegion) {
        switch (state) {
        case .inside: // すでに領域内にいる場合は（didEnterRegion）は呼ばれない
            trackLocationManager.startRangingBeacons(in: beaconRegion);
            // →(didRangeBeacons)で測定をはじめる
            break;
            
        case .outside:
            // 領域外→領域に入った場合はdidEnterRegionが呼ばれる
            break;
            
        case .unknown:
            // 不明→領域に入った場合はdidEnterRegionが呼ばれる
            break;
        }
    }
    
    //領域に入った時
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        // →(didRangeBeacons)で測定をはじめる
        self.trackLocationManager.startRangingBeacons(in: self.beaconRegion)
        
        debugPrint("[Event] BeaconManager:Entered!")
        delegate.didEnterRegion()
        sendLocalNotificationWithMessage(message: "Beacon領域に入りました", region: region)
    }
    
    //領域から出た時
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        //測定を停止する
        self.trackLocationManager.stopRangingBeacons(in: self.beaconRegion)
        
        //debugPrint("Exit!")
        delegate.didExitRegion()
        sendLocalNotificationWithMessage(message: "Beacon領域から出ました", region: region)
        
    }
    
    //領域内にいるので測定をする
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if (beacons.count > 0) {
            let beacon = beacons[0];
            debugPrint("[Log] \(beacon.accuracy)")
            debugPrint("[Log] \(beacon.proximity)")
        }
    }
    
    func sendLocalNotificationWithMessage(message: String!, region: CLRegion!) {
        //let r: CLBeaconRegion = region as! CLBeaconRegion;
        
        let content = UNMutableNotificationContent()
        content.title = message
        content.subtitle = "Guests"
        content.sound = UNNotificationSound.default()
        
        let URL = NSURL(string: "https://0m8b791v7g.execute-api.us-east-1.amazonaws.com/beta")
        let serverData = NSData(contentsOf: URL as! URL)
        content.body = NSString(data:serverData as! Data, encoding:String.Encoding.utf8.rawValue) as! String// 新登場！
        
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.viewContext
        
        let query: NSFetchRequest<User> = User.fetchRequest()
        do {
            let fetchResults = try viewContext.fetch(query)
            if fetchResults.count > 0 {
                let record = fetchResults[0] as NSManagedObject
                switch record.value(forKey: "id") {
                    case 0 as Int:
                        content.subtitle = "Guests"
                    case 1 as Int:
                        content.subtitle = "LoggedInUser"
                    default:
                        break
                }
            }
        } catch {
            content.subtitle = "ERROR"
        }
        
        // 0.1秒後に発火
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "BeaconNortification",
                                            content: content,
                                            trigger: trigger)
        
        // ローカル通知予約
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
