//
//  NetworkManager.swift
//  iBeaconCentralNortification
//
//  Created by MAMORU on 2017/02/14.
//  Copyright © 2017年 PARTY. All rights reserved.
//

import Foundation

class NetworkManager {
    init() {
    }
    
    func getFromApi(requestId: Int16) -> NSData {
        let apiURL = NSURL(string: Consts.baseAPI + "?id=\(requestId)")
        let result = NSData(contentsOf: apiURL as! URL)
        return result!
    }
}
