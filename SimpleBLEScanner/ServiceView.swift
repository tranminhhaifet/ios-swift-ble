//
//  ServiceView.swift
//  SimpleBLEScanner
//
//  Created by hai on 5/12/20.
//  Copyright © 2020 biorithm. All rights reserved.
//

import UIKit
import CoreBluetooth

class ServiceView: UIViewController {
    
    var centralManager: CBManager!
    var blePeripheral: BLEPeripheral!
    var service: CBService!
    var characteristic: CBCharacteristic!
    var index: IndexPath!
    var characteristicDescription = [String]()
    var permissions = [String]()
    
    init(centralManager: CBCentralManager!,
         blePeripheral: BLEPeripheral!,
         index: IndexPath
    ) {
        self.centralManager = centralManager
        self.blePeripheral =  blePeripheral
        self.index = index
        self.service = self.blePeripheral.gatProfile[self.index.section]
        self.characteristic = self.service.characteristics?[self.index.row]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let characteristicTable: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(characteristicTable)
        characteristicTable.frame = view.bounds
        characteristicTable.delegate = self
        characteristicTable.dataSource = self
        blePeripheral.delegate = self
        
        if let peripheral = self.blePeripheral {
            peripheral.readValue(from: self.characteristic)
        }
        
        characteristicTable.reloadData()
    }
}

extension ServiceView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        characteristicDescription.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = characteristicDescription[indexPath.row]
        return cell
    }
}

extension ServiceView: BLEPeripheralDelegate {
    func blePeripheralOnRead(peripheral: BLEPeripheral!) {
        
        print("Called delegate")
        
        self.characteristicDescription.removeAll()
        self.permissions.removeAll()
        
        // check readable service
        if let blePeripheral = self.blePeripheral {
            let isReable =  blePeripheral.isCharacteristic(isRedable: self.characteristic)
            blePeripheral.readValue(from: self.characteristic)
            // Characteristic table information
            characteristicDescription.append("(\(self.service.uuid.uuidString)) \(self.service.uuid)")
            characteristicDescription.append("(\(self.characteristic.uuid.uuidString)) \(self.characteristic.uuid)")
            
            //
            characteristicDescription.append("Value String - \(peripheral.readCharacteristicValue)")
            characteristicDescription.append("Value Hex - \(peripheral.readCharacteristicHex)")
            
            // Readable TODO Read Button and Write Button
            if isReable {
                characteristicDescription.append("Read: YES")
            } else {
                characteristicDescription.append("Read: NO")
            }
            if self.characteristic.isNotifying {
                characteristicDescription.append("Notify: YES")
            } else {
                characteristicDescription.append("Notify: NO")
            }
            // Permission
            if characteristic.permissions.contains(CharacteristicPermissions.read) {
                permissions.append("Read")
            }
            if characteristic.permissions.contains(CharacteristicPermissions.write) {
                permissions.append("Write")
            }
            if characteristic.permissions.contains(CharacteristicPermissions.notify) {
                permissions.append("Notify")
            }
            if characteristic.permissions.contains(CharacteristicPermissions.extended) {
                permissions.append("Extended Properties")
            }
            characteristicDescription.append("\(permissions)")
        }
        self.characteristicTable.reloadData()
    }
}
