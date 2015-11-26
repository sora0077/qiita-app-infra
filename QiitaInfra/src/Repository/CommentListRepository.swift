//
//  CommentListRepository.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/25.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import QiitaKit
import BrightFutures
import RealmSwift

extension QiitaRepository {
    
    final class CommentList: CommentListRepository {
        
        private let session: QiitaSession
        
        private let item_id: String
        
        init(session: QiitaSession, item: ItemProtocol) {
            self.session = session
            self.item_id = item.id
        }
        
        func values() throws -> [CommentProtocol] {
            
            let realm = try Realm()
            guard let list = realm.objects(RefItemCommentList)
                .filter("item_id = %@", item_id).first else
            {
                return []
            }
            var ret: [CommentProtocol] = []
            for p in list.pages {
                for c in p.comments {
                    ret.append(c)
                }
            }
            return ret
        }
        
        func update() -> Future<[CommentProtocol], QiitaInfraError> {
            return update(force: false)
        }
        
        func update(force force: Bool) -> Future<[CommentProtocol], QiitaInfraError> {
            
            func check() -> Future<(ListItemComments, Bool)?, QiitaInfraError> {
                
                let item_id = self.item_id
                
                return realm {
                    let realm = try Realm()
                    
                    let results = realm.objects(RefItemCommentList)
                        .filter("item_id = %@", item_id)
                    
                    guard let list = results.filter("ttl > %@", RefItemCommentList.ttl).first else {
                        return (ListItemComments(id: item_id), true)
                    }
                    guard let page = list.pages.last?.next_page.value else {
                        return nil
                    }
                    return (ListItemComments(id: item_id, page: page), false)
                }
            }
            
            func fetch(token: ListItemComments, isNew: Bool) -> Future<[CommentProtocol], QiitaInfraError> {
                
                let item_id = self.item_id
                
                return session.request(token)
                    .mapError(QiitaInfraError.QiitaAPIError)
                    .flatMap { res in
                        realm {
                            let realm = try Realm()
                            
                            realm.beginWrite()
                            let results = realm.objects(RefItemCommentList)
                                .filter("item_id = %@", item_id)
                            
                            if isNew {
                                realm.delete(results.flatMap { $0.pages.map { $0 } })
                                realm.delete(results)
                            }
                            
                            let entity: RefItemCommentList
                            if let list = results.first where !isNew {
                                entity = list
                                let page = RefItemCommentListPage.create(realm, res)
                                realm.add(page)
                                entity.pages.append(page)
                                realm.add(entity, update: true)
                            } else {
                                entity = RefItemCommentList.create(realm, item_id, res)
                                realm.add(entity, update: true)
                            }
                            
                            try realm.commitWrite()
                            
                            var ret: [CommentProtocol] = []
                            for p in entity.pages {
                                for c in p.comments {
                                    ret.append(c)
                                }
                            }
                            return ret
                        }
                    }
            }
            
            func get(_: [CommentProtocol] = []) -> Future<[CommentProtocol], QiitaInfraError> {
                
                let item_id = self.item_id
                return Realm.read(ImmediateOnMainExecutionContext)
                    .mapError(QiitaInfraError.RealmError)
                    .map { realm in
                        guard let page = realm.objects(RefItemCommentList)
                            .filter("item_id = %@", item_id)
                            .first?.pages.last else
                        {
                            return []
                        }
                        return page.comments.map { $0 }
                    }
            }
            
            return check().flatMap { res -> Future<[CommentProtocol], QiitaInfraError> in
                guard let (token, isNew) = res else {
                    return Future(value: [])
                }
                
                return fetch(token, isNew: isNew)
            }.flatMap(get)
        }
    }
}
