//
//  PreferenceProtocol.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/24.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation

protocol PreferenceProtocol {
    
    var authenticatedUserId: String? { get set }
    
    var launchCount: Int { get set }
}