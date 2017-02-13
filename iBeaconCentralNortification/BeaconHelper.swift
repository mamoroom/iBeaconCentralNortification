//
//  BeaconHelper.swift
//  iBeaconCentralNortification
//
//  Created by MAMORU on 2017/02/11.
//  Copyright © 2017年 PARTY. All rights reserved.
//

import Foundation

class BeaconHelper : NSObject, BeaconDelegate {
    
    var beaconManager: BeaconManager = BeaconManager.sharedInstance
    var ArrayOfDidEnterRegionFuncs: Array<() -> Void>
    var ArrayOfDidExitRegionFuncs: Array<() -> Void>
    
    //シングルトン
    static let sharedInstance = BeaconHelper()
    
    override init() {
        debugPrint("[init] BeaconHelper")
        ArrayOfDidEnterRegionFuncs = []
        ArrayOfDidExitRegionFuncs  = []
        super.init()
        beaconManager.delegate = self
    }
    
    func setDidEnterRegionFunc(func_did_enter: @escaping ()->Void) {
       self.ArrayOfDidEnterRegionFuncs.append(func_did_enter)
    }
    func setDidExitRegionFunc(func_did_exit: @escaping ()->Void) {
       self.ArrayOfDidExitRegionFuncs.append(func_did_exit)
    }
    
    func didEnterRegion() {
        for _func in self.ArrayOfDidEnterRegionFuncs {
            _func()
        }
    }
    
    func didExitRegion() {
        for _func in self.ArrayOfDidExitRegionFuncs {
            _func()
        }
    }
}
