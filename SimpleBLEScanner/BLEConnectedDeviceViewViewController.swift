//
//  BLEConnectedDeviceViewViewController.swift
//  SimpleBLEScanner
//
//  Created by hai on 2/12/20.
//  Copyright © 2020 biorithm. All rights reserved.
//

import UIKit
import CoreBluetooth


class BLEConnectedDeviceViewViewController: UIViewController {
    
    let table: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    var characteristicOfAService = [String]()
    var serviceIDs =  [String]()
    var characteristicIDs = [[String]]()
    var numberOfRowsInSection = [Int]()
    var centralManager: CBCentralManager!
    var blePeripheral: BLEPeripheral!
    
    init(centralManager: CBCentralManager!, blePeripheral: BLEPeripheral!) {
        self.centralManager = centralManager
        self.blePeripheral =  blePeripheral
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor  = .white
        title = "Connected BLE"
        
        table.frame = view.bounds
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
        
        self.centralManager?.delegate = self
        self.blePeripheral?.delegate = self
        
        if self.blePeripheral != nil {
            self.blePeripheral.gatProfile.removeAll()
            self.centralManager?.connect(self.blePeripheral.peripheral, options: nil)
        }
    }
    
}

extension BLEConnectedDeviceViewViewController: CBCentralManagerDelegate, BLEPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        print("Centeral manager update: checking state")
        
        switch central.state {
        case .poweredOn:
            print("BLE on")
        default:
            print("BLE unavailable")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected to \(peripheral.name ?? "unknown")")
        blePeripheral.connected(peripheral: peripheral)
        blePeripheral.peripheral.discoverServices(nil)
        table.reloadData()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to peripheral")
        print(error.debugDescription)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected peripheral")
        dismiss(animated: true, completion: nil)
    }
    
    func blePeripheral(readRssi rssi: NSNumber, blePeripheral: BLEPeripheral) {
        characteristicOfAService.removeAll()
        characteristicIDs.removeAll()
        print("RSSI: \(rssi.stringValue)")
        for service in blePeripheral.gatProfile {
            characteristicOfAService.removeAll()
            serviceIDs.append("\(service.uuid.uuidString)" )
            
            if let characteristics  = service.characteristics {
                for characteristic in characteristics {
//                    blePeripheral.readValue(from: characteristic)
                    characteristicOfAService.append(characteristic.uuid.uuidString)
                }
                characteristicIDs.append(characteristicOfAService)
            }
        }
        
        print(characteristicIDs)
        self.table.reloadData()
    }
}

extension BLEConnectedDeviceViewViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return characteristicIDs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characteristicIDs[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text  = characteristicIDs[indexPath.section][indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = serviceIDs[section]
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.backgroundColor = UIColor(hex: 0xD6DBDF)
        return label
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected service  ")
        let vc = ServiceView(centralManager: centralManager,
                             blePeripheral: blePeripheral,
                             index: indexPath)
        
        vc.title = "Service Connected"
        vc.modalPresentationStyle =  .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension UIColor {

    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }

}


