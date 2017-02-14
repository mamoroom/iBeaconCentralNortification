//
//  BeaconDelegate.swift
//  iBeaconCentralNortification
//
//  Created by MAMORU on 2017/02/10.
//  Copyright © 2017年 PARTY. All rights reserved.
//
import UIKit
import CoreLocation

public protocol BeaconDelegate : NSObjectProtocol {
    
    func didEnterRegion()
    func didExitRegion()
    func didRangeBeacons(_ rssi: Int, accuracy: Double)
}
