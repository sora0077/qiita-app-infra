//
//  ListItemCommentsRepository.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/28.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import QiitaKit
import BrightFutures
import RealmSwift
import QueryKit

extension QiitaRepository {
    
    final class ListItemComments: CommentListRepository {
        
        private let util: CommentListRepositoryUtil<RefCommentListEntity, QiitaKit.ListItemComments>
        
        init(session: QiitaSession, item: ItemProtocol) {
            
            let key = "ListItemComments::\(item.id)"
            let item_id = item.id
            self.util = CommentListRepositoryUtil(
                session: session,
                query: RefCommentListEntity.key == key,
                entityProvider: { realm, res in
                    RefCommentListEntity.create(realm, key, res)
                },
                tokenProvider: { page in
                    QiitaKit.ListItemComments(id: item_id, page: page ?? 1)
                }
            )
        }
    }
}

extension QiitaRepository.ListItemComments {
    
    func values() throws -> [CommentProtocol] {
        return try util.values()
    }
    
    func update(force force: Bool) -> Future<[CommentProtocol], QiitaInfraError> {
        return util.update(force)
    }
}
