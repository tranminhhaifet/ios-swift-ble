//
//  BLETableViewCell.swift
//  SimpleBLEScanner
//
//  Created by hai on 2/12/20.
//  Copyright © 2020 biorithm. All rights reserved.
//

import UIKit

protocol ConnectButtonDelegate {
    
    func pushConnectViewController(at index: IndexPath)

}

class BLETableViewCell: UITableViewCell {
    
    var delegate: ConnectButtonDelegate!
    var indexPath: IndexPath!
    
    static let identifier = "BLETableViewCell"
    
    private let connectButton:  UIButton = {
        let button = UIButton()
        button.setTitle("Connect", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let seriveName: UILabel = {
        let serviceName = UILabel()
        serviceName.textColor = .black
        serviceName.font = .systemFont(ofSize: 12)
        serviceName.text = "UUID"
        return  serviceName
    }()
    
    private let deviceNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.text = "Device Name"
        return label
    }()
    
    private let uuidLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.text = "UUID"
        return label
    }()
    
    private let rssiLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.text = "RSSI"
        return label
    }()
    
    public func configure(_ blePeripheral: BLEPeripheral!) {
        
        if blePeripheral != nil {
            deviceNameLabel.text = blePeripheral.deviceName
            seriveName.text = blePeripheral.serviceName
            rssiLabel.text = blePeripheral.rssiValue.stringValue
            uuidLabel.text = "UUID-\(blePeripheral.peripheral.identifier.uuidString)"
        }
        else {
            deviceNameLabel.text = "N/A"
            seriveName.text = "No services"
            rssiLabel.text = "90"
        }
      }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        deviceNameLabel.text = "N/A"
        uuidLabel.text = "N/A"
        rssiLabel.text = "90"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        contentView.addSubview(deviceNameLabel)
        contentView.addSubview(uuidLabel)
        contentView.addSubview(seriveName)
        contentView.addSubview(connectButton)
        
        connectButton.addTarget(self, action: #selector(didTapConnectButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        deviceNameLabel.frame = CGRect(x: 10,
                                       y: 0,
                                       width: 200,
                                       height: 40)
        uuidLabel.frame = CGRect(x: 10,
                                  y: 40,
                                  width: 400,
                                  height: 20)
        connectButton.frame = CGRect(x: contentView.frame.size.width-100,
                                     y: 10,
                                     width: 90,
                                     height: 35)
    }
    
    @objc func didTapConnectButton() {
        self.delegate?.pushConnectViewController(at: indexPath)
    }

}
