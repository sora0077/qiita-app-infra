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
}

extension PreferenceEntity {
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func sharedPreference(realm: Realm, writing: Bool = false) -> PreferenceEntity {
        if let pref = realm.objects(PreferenceEntity).first {
            return pref
        }
        
        if !writing {
            realm.beginWrite()
        }
        
        let pref = PreferenceEntity()
        realm.add(pref)
        
        if !writing {
            try! realm.commitWrite()
        }
        
        return pref
    }
}

