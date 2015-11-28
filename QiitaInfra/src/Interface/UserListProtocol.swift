//
//  UserListProtocol.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/28.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import BrightFutures

public protocol UserListRepository {
    
    func values() throws -> [UserProtocol]
    
    func update() -> Future<[UserProtocol], QiitaInfraError>
    
    func update(force force: Bool) -> Future<[UserProtocol], QiitaInfraError>
}