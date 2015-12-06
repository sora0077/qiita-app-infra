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
    
    static func read(context: ExecutionContext = ImmediateOnMainExecutionContext) -> Future<Realm, NSError> {
        
        return future(context: context) { _ -> Result<Realm, NSError> in
            do {
                let realm = try GetRealm()
                realm.refresh()
                return .Success(realm)
            } catch {
                return .Failure(error as NSError)
            }
        }
    }
}

private let realmQueue = Queue(queueLabel: "realm")

func realm<T>(context: ExecutionContext = realmQueue.context, _ f: () throws -> T) -> Future<T, QiitaInfraError> {
    return Future<T, NSError>(context: context) {
        return try f()
        }.mapError(QiitaInfraError.RealmError)
}

func realm_sync<T>(f: () throws -> T) throws -> T {
    do {
        return try f()
    }
    catch {
        throw QiitaInfraError.RealmError(error as NSError)
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

func ?? <T, E>(lhs: Future<T?, E>, @autoclosure(escaping) rhs: () -> Future<T?, E>) -> Future<T?, E> {
    return lhs.flatMap {
        $0.map(Future.init) ?? rhs()
        }.recoverWith { _ in
            rhs()
    }
}

func ?? <T, E>(lhs: Future<T?, E>, @autoclosure(escaping) rhs: () -> Future<T, E>) -> Future<T, E> {
    return lhs.flatMap {
        $0.map(Future.init) ?? rhs()
        }.recoverWith { _ in
            rhs()
    }
}

func ?? <T, E>(lhs: Future<T?, E>, @autoclosure(escaping) rhs: () -> T?) -> Future<T?, E> {
    return lhs.flatMap {
        $0.map(Future.init) ?? Future(value: rhs())
    }.recoverWith { _ in
        Future(value: rhs())
    }
}

func ?? <T, E>(lhs: Future<T?, E>, @autoclosure(escaping) rhs: () -> T) -> Future<T, E> {
    return lhs.flatMap {
        $0.map(Future.init) ?? Future(value: rhs())
    }.recoverWith { _ in
        Future(value: rhs())
    }
}

