//
//  ViewController.swift
//  RLS-Buddy-Assignment
//
//  Created by Shreyas Sahoo on 09/06/24.
//

import UIKit
import HealthKit

class HeartRateTableViewController: UITableViewController {
    private var heartRateSamples: [(heartRate: Double, date: Date)] = []
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Heart Rate Monitor"
        tableView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tableView.register(HeartRateCell.self, forCellReuseIdentifier: HeartRateCell.identifier)
        tableView.separatorStyle = .none
        
        HeartRateManager.shared.authorizeHealthKit { success, error in
            if success {
                DispatchQueue.main.async {
                    self.startFetchingHeartRate()
                }
            } else {
                print("HealthKit authorization denied!")
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func startFetchingHeartRate() {
        fetchHeartRate()
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(fetchHeartRate), userInfo: nil, repeats: true)
    }

    @objc private func fetchHeartRate() {
        HeartRateManager.shared.startHeartRateQuery { [weak self] samples in
            guard let self = self else { return }
            DispatchQueue.main.async {
                print("Health samples fetched!")
                print("Heart Rate Samples: \(self.heartRateSamples)")
                self.heartRateSamples = samples.map { sample in
                    let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                    let date = sample.startDate
                    return (heartRate, date)
                }
                self.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heartRateSamples.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HeartRateCell.identifier, for: indexPath) as! HeartRateCell
        let sample = heartRateSamples[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy - HH:mm:ss"
        let dateStr = dateFormatter.string(from: sample.date)
        cell.heartRateLabel.text = "Heart Rate: \(sample.heartRate) BPM at \(dateStr)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
