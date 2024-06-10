//
//  AppDelegate.swift
//  RLS-Buddy-Assignment
//
//  Created by Shreyas Sahoo on 09/06/24.
//

import UIKit

extension Notification.Name {
    static let newHeartRateSample = Notification.Name("newHeartRateSample")
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard HeartRateManager.shared.isFetchingActive else {
            completionHandler(.noData)
            return
        }
        
        HeartRateManager.shared.fetchLatestHeartRateSample { sample in
            DispatchQueue.main.async {
                if let sample = sample {
                    print("Background fetch: New heart rate sample: \(sample)")
                    NotificationCenter.default.post(name: .newHeartRateSample, object: sample)
                    completionHandler(.newData)
                } else {
                    completionHandler(.noData)
                }
            }
        }
    }
}
