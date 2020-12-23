//
//  BLEPeripheral.swift
//  SimpleBLEScanner
//
//  Created by hai on 2/12/20.
//  Copyright © 2020 biorithm. All rights reserved.
//

import UIKit
import CoreBluetooth


class BLEPeripheral: NSObject {
    
    var delegate: BLEPeripheralDelegate?
    var peripheral: CBPeripheral!
    var deviceName: String!
    var rssiValue: NSNumber!
    var serviceName: String!
    var gatProfile = [CBService]()
    var readCharacteristicValue: String = ""
    var readCharacteristicHex: String = ""
    
    init(delegate: BLEPeripheralDelegate?, peripheral: CBPeripheral) {
        super.init()
        self.peripheral = peripheral
        self.peripheral.delegate = self
        self.delegate = delegate 
    }
    
    // Notify BlePeripheral that the peripheral has been connected
    func connected(peripheral: CBPeripheral){
        self.peripheral = peripheral
        self.peripheral.delegate = self
        self.peripheral.readRSSI()
    }
    
    // Connectable
    static func isConnectTable(advertisementData: [String: Any]) -> Bool {
        let isConnectable = advertisementData["kCBAdvDataIsConnectable"] as! Bool
        return isConnectable
    }
    
    static func getAlternateBroadcastFromAdvertisementData(advertisementData: [String : Any]) -> String? {
        // grab thekCBAdvDataLocalName from the advertisementData to see if there's an alternate broadcast name
        if advertisementData["kCBAdvDataLocalName"] != nil {
            return (advertisementData["kCBAdvDataLocalName"] as! String)
        }
        return nil
    }
    
    func readValue(from characteristic: CBCharacteristic) {
        self.peripheral.readValue(for: characteristic)
    }
    
    func isCharacteristic(isRedable characteristic: CBCharacteristic) -> Bool {
        if (characteristic.properties.rawValue & CBCharacteristicProperties.read.rawValue) !=  0 {
            return true
        }
        
        return false
    }
}


extension BLEPeripheral: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        rssiValue = RSSI
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discover service")
        
        if  error != nil  {
            print("Discover service error")
        } else {
            for service in peripheral.services! {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let serviceIdentifier  =  service.uuid.uuidString
        print("service \(serviceIdentifier)")
        gatProfile.append(service)
        
        if let characteristics  = service.characteristics {
            print("Discover \(characteristics.count) characteristic")
            for characteristic in characteristics {
                print("--> \(characteristic.uuid.uuidString)")
            }
        }
        
        delegate?.blePeripheral?(readRssi: rssiValue, blePeripheral: self)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Read value from BLE Characteristic \(characteristic)")
        
        if let value = characteristic.value {
            
            if let stringValue = String(data: value, encoding: .ascii) {
                self.readCharacteristicValue = stringValue
            }
            
            if characteristic.uuid == CBUUID(string: "0x2A19") {
                self.readCharacteristicValue = "\(characteristic.value![0])"
            }
            
            let charSet = CharacterSet(charactersIn: "<>")
            let nsdataStr = NSData.init(data: value)
            let valueHex = nsdataStr.description.trimmingCharacters(in:charSet).replacingOccurrences(of: " ", with: "")
            self.readCharacteristicHex = "0x\(valueHex)"
        }
        
        print("Call delegate")
        delegate?.blePeripheralOnRead?(peripheral: self)
    }
    
}
