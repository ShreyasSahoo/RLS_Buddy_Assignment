//
//  HeartRateCell.swift
//  RLS-Buddy-Assignment
//
//  Created by Shreyas Sahoo on 10/06/24.
//

import UIKit

class HeartRateCell: UITableViewCell {
    static let identifier = "HeartRateCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        self.backgroundColor = .clear
        let containerView = UIView()
        containerView.backgroundColor = .systemPink
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        
        let dateLabel = UILabel()
        dateLabel.textColor = .white
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dateLabel)
        
        let heartRateLabel = UILabel()
        heartRateLabel.numberOfLines = 0
        heartRateLabel.textColor = .white
        heartRateLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(heartRateLabel)
        
        dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        
        heartRateLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5).isActive = true
        heartRateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
        heartRateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        heartRateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        
        self.dateLabel = dateLabel
        self.heartRateLabel = heartRateLabel
    }
    
    var dateLabel: UILabel!
    var heartRateLabel: UILabel!
}
