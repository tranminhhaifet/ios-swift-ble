//
//  BLEViewController.swift
//  SimpleBLEScanner
//
//  Created by hai on 2/12/20.
//  Copyright © 2020 biorithm. All rights reserved.
//

import UIKit
import CoreBluetooth


class BLEViewController: UIViewController {
    
    var scanCountDown: Int = 0
    let scanTimeout: Int = 5
    var scanTimer: Timer!
    var blePeripherals =  [BLEPeripheral]()
    
    var centralManager: CBCentralManager!
    
    let tableView: UITableView = {
        let table =  UITableView()
        table.register(BLETableViewCell.self, forCellReuseIdentifier: BLETableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "BLE Scanner"
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Scan",
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(didTapBLEScanButton))
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource =  self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    @objc func didTapBLEScanButton() {
        print("BLE scanning ...")

        if scanCountDown > 0 {
            stopBLEScan()

        } else {
            // start scan
            startBLEScan()
        }
    }
    
    func startBLEScan() {
        blePeripherals.removeAll()
        tableView.reloadData()
        scanCountDown = scanTimeout
        scanTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(updateScanCounter),
                                         userInfo: nil,
                                         repeats: true)
        if let centralManager = centralManager {
            centralManager.scanForPeripherals(withServices: nil,
                                              options: nil)
        }
    }
    
    func stopBLEScan()  {
        print("BLE stop scanning ")
        if let centralManager = centralManager {
            centralManager.stopScan()
        }
        
        scanTimer.invalidate()
        scanCountDown = 0
    }
    

    @objc func updateScanCounter() {
        
        if scanCountDown > 0 {
            print("\(scanCountDown) seconds until BLE stop scanning")
            scanCountDown -= 1
        } else {
            stopBLEScan()
        }
    }

}


extension BLEViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blePeripherals.count
//        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BLETableViewCell.identifier, for: indexPath) as? BLETableViewCell else { return UITableViewCell() }
        
        cell.delegate = self
        cell.indexPath = indexPath
        let peripheral = blePeripherals[indexPath.row]
        cell.configure(peripheral)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected row \(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}


extension BLEViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central Manger Updated")
        
        switch central.state {
        case .poweredOn:
            print("BLE power on")
        case .poweredOff:
            print("BLE power off")
        case .resetting:
            print("BLE is reseting")
        case .unauthorized:
            print("BLE is unauthorized")
        case .unsupported:
            print("BLE is unsupported")
        case .unknown:
            print("BLE is unknown")
        default:
            print("ERROR")
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        var peripheralFound = false
        for blePeripheral in blePeripherals {
            if blePeripheral.peripheral.identifier == peripheral.identifier {
                peripheralFound = true
                break
            }
        }
        
        if !peripheralFound {
            var advertisedName = "Unknown"
        
            // Get name of peripheral
            if let alternateName = BLEPeripheral.getAlternateBroadcastFromAdvertisementData(advertisementData: advertisementData) {
                if alternateName != "" {
                    advertisedName = alternateName
                } else {
                    if let peripheralName = peripheral.name {
                        advertisedName = peripheralName
                    }
                }
            }
            
            // Get name of peripheral
            if let peripheralName = peripheral.name {
                advertisedName = peripheralName
            }
            
            let blePeripheral = BLEPeripheral(delegate: nil, peripheral: peripheral)
            blePeripheral.rssiValue = RSSI
            blePeripheral.deviceName = advertisedName
            blePeripherals.append(blePeripheral)
            tableView.reloadData()
        }
    }
    
}

extension BLEViewController: ConnectButtonDelegate {
    func pushConnectViewController(at index: IndexPath) {
        
        // Check is connectable before
        
        if (blePeripherals.count > index.row ) {
            let vc = BLEConnectedDeviceViewViewController(centralManager: centralManager,
                                                          blePeripheral: blePeripherals[index.row])
                 self.navigationController?.pushViewController(vc, animated: true)
        } else {
            
            let vc = BLEConnectedDeviceViewViewController(centralManager: centralManager,
                                                               blePeripheral: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
