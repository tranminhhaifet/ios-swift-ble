//
//  BLEPeripheralDelegate.swift
//  SimpleBLEScanner
//
//  Created by hai on 3/12/20.
//  Copyright © 2020 biorithm. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc protocol BLEPeripheralDelegate: class {
    
    @objc optional func blePeripheral(readRssi rssi: NSNumber, blePeripheral: BLEPeripheral)
    
    @objc optional func blePeripheralOnRead(peripheral: BLEPeripheral!)
}
