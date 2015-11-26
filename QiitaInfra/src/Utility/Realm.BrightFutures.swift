//
//  Realm.BrightFutures.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/24.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift
import BrightFutures
import Result


extension Realm {
    
    static func read(context: ExecutionContext) -> Future<Realm, NSError> {
        
        return future(context: context) { _ -> Result<Realm, NSError> in
            do {
                let realm = try Realm()
                realm.refresh()
                return .Success(realm)
            } catch {
                return .Failure(error as NSError)
            }
        }
    }
}

extension Future {
    
    convenience init(context: ExecutionContext = ImmediateExecutionContext, throwable: () throws -> T) {
        
        self.init(resolver: { complete in
            context {
                do {
                    complete(.Success(try throwable()))
                } catch {
                    complete(.Failure(error as! E))
                }
            }
        })
    }
}

