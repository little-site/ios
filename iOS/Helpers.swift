//
//  Helpers.swift
//  iOS
//
//  Created by David Hariri on 2019-10-26.
//  Copyright © 2019 David Hariri. All rights reserved.
//

import Foundation
import os

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let ui = OSLog(subsystem: subsystem, category: "UI")
    static let storage = OSLog(subsystem: subsystem, category: "Storage")
    static let network = OSLog(subsystem: subsystem, category: "Network")
}

class PersistentStorage {
    var defaultsStore = UserDefaults.standard
    var decoder = JSONDecoder()
    var encoder = JSONEncoder()
    
    func fetchPersistent<T>(withType: T.Type, key: String) -> T? where T : Decodable {
        if let fetchData: Data = self.defaultsStore.data(forKey: key) {
            do {
                let object = try decoder.decode(T.self, from: fetchData)
                os_log("Fetched object from storage", log: .storage)
                return object
            } catch let error {
                print(error)
                os_log("Failed to decode object", log: .storage, type: .error)
                return nil
            }
        } else {
            os_log("Failed to fetch data", log: .storage, type: .error)
            return nil
        }
    }
    
    func writePersistent<T>(withObj: T, key: String) where T : Encodable {
        do {
            let encoded = try encoder.encode(withObj)
            defaultsStore.set(encoded, forKey: key)
            os_log("Wrote object to storage", log: .storage)
        } catch {
            os_log("Failed to write object to storage", log: .storage, type: .error)
        }
    }
    
    func clearPersistent(key: String) {
        defaultsStore.removeObject(forKey: key)
    }
}
