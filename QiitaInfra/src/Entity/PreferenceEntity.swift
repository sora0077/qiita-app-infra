//
//  PreferenceEntity.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/24.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift

final class PreferenceEntity: Object, PreferenceProtocol {

    private dynamic var id: Int = 1
    
    dynamic var authenticatedUserId: String? = nil
    
    dynamic var launchCount: Int = 1
    
    dynamic var lastLaunchDate: NSDate = NSDate()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension PreferenceEntity {
    
    static func prepare() throws {
        
        let realm = try GetRealm()
        guard let pref = realm.objectForPrimaryKey(PreferenceEntity.self, key: 1) else {
            let pref = PreferenceEntity()
            
            try realm.write {
                realm.add(pref)
            }
            return
        }
        
        try realm.write {
            pref.launchCount += 1
            pref.lastLaunchDate = NSDate()
        }
    }
    
    static func sharedPreference(realm: Realm) -> PreferenceEntity {
        
        let pref = realm.objectForPrimaryKey(PreferenceEntity.self, key: 1)
        return pref!
    }
}

