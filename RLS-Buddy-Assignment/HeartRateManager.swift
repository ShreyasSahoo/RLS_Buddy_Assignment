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
    
    private init() {}
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(false, nil)
            return
        }
        
        let typesToShare: Set<HKSampleType> = []
        let typesToRead: Set<HKObjectType> = [heartRateType]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    func startHeartRateQuery(completion: @escaping ([HKQuantitySample]) -> Void) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, results, error in
            if let error = error {
                print("Failed to fetch heart rate samples: \(error.localizedDescription)")
                return
            }
            
            if let samples = results as? [HKQuantitySample] {
                completion(samples)
            }
        }
        
        healthStore.execute(query)
        
        healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { success, error in
            if let error = error {
                print("Failed to enable background delivery: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchLatestHeartRateSample(completion: @escaping (HKQuantitySample?) -> Void) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }
        
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: mostRecentPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, _ in
            completion(results?.first as? HKQuantitySample)
        }
        
        healthStore.execute(query)
    }
}
