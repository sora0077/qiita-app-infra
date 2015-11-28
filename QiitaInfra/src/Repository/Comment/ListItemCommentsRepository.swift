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
        
        private let session: QiitaSession
        
        private let item_id: String
        
        private let util: CommentListRepositoryUtil<RefItemCommentList, QiitaKit.ListItemComments>
        
        init(session: QiitaSession, item: ItemProtocol) {
            self.session = session
            self.item_id = item.id
            
            self.util = CommentListRepositoryUtil(
                session: session,
                query: RefItemCommentList.item_id == item.id
            )
        }
    }
}

extension QiitaRepository.ListItemComments {
    
    func values() throws -> [CommentProtocol] {
        return try util.values()
    }
    
    func update(force force: Bool) -> Future<[CommentProtocol], QiitaInfraError> {
        
        let item_id = self.item_id
        return util.update(force)(
            entityProvider: { realm, res in
                RefItemCommentList.create(realm, item_id, res)
            },
            tokenProvider: { page in
                ListItemComments(id: item_id, page: page ?? 1)
            }
        )
    }
}
