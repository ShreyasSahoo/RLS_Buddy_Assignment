//
//  HeartRateManager.swift
//  RLS-Buddy-Assignment
//
//  Created by Shreyas Sahoo on 09/06/24.
//

import HealthKit




class HeartRateManager {
    static let shared = HeartRateManager()
    private let healthStore = HKHealthStore()
    private var backgroundFetchTimer: Timer?
    private var isBackgroundFetchActive = false

    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        let readTypes: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .heartRate)!]
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            completion(success, error)
        }
    }

    func startHeartRateQuery(completion: @escaping ([HKQuantitySample]) -> Void) {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { query, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                print("Error fetching heart rate samples: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            completion(samples)
        }
        
        healthStore.execute(query)
    }

    func setupObserverQuery() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Observer query failed: \(error.localizedDescription)")
                return
            }
            
            print("New heart rate data received in the background")
            
            self?.fetchLatestHeartRateSample { sample in
                if let sample = sample {
                    print("New heart rate sample: \(sample)")
                    NotificationCenter.default.post(name: .newHeartRateSample, object: sample)
                }
                completionHandler()
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchLatestHeartRateSample(completion: @escaping (HKQuantitySample?) -> Void) {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let sample = samples?.first as? HKQuantitySample, error == nil else {
                print("Error fetching latest heart rate sample: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            completion(sample)
        }
        
        healthStore.execute(query)
    }
    
    func startBackgroundFetching() {
        isBackgroundFetchActive = true
        backgroundFetchTimer = Timer.scheduledTimer(timeInterval: 7200, target: self, selector: #selector(stopBackgroundFetching), userInfo: nil, repeats: false)
        setupObserverQuery()
        print("Background fetching started")
    }
    
    @objc func stopBackgroundFetching() {
        isBackgroundFetchActive = false
        backgroundFetchTimer?.invalidate()
        backgroundFetchTimer = nil
        print("Background fetching stopped after 2 hours")
    }

    var isFetchingActive: Bool {
        return isBackgroundFetchActive
    }
}
