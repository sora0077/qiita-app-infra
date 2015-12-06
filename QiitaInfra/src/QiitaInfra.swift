//
//  QiitaInfra.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/20.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import QiitaKit
import BrightFutures

public enum QiitaInfraError: ErrorType {
    
    case QiitaAPIError(QiitaKitError)
    case RealmError(NSError)
}

public protocol QiitaRepository {
    
    init(session: QiitaSession)
    
    var accessToken: AccessTokenRepository { get }
    
    var authenticatedUser: AuthenticatedUserRepository { get }
    
    var comment: CommentRepository { get }
    
    var user: UserRepository { get }
}

final class QiitaRepositoryImpl: QiitaRepository {
    
    private let session: QiitaSession
    
    private(set) lazy var accessToken: AccessTokenRepository = QiitaRepositoryImpl.AccessToken(session: self.session)
    
    private(set) lazy var authenticatedUser: AuthenticatedUserRepository = QiitaRepositoryImpl.AuthenticatedUser(session: self.session)
    
    private(set) lazy var comment: CommentRepository = QiitaRepositoryImpl.Comment(session: self.session)
    
    private(set) lazy var user: UserRepository = QiitaRepositoryImpl.User(session: self.session)
    
    init(session: QiitaSession) {
        self.session = session
    }
}

import RealmSwift
public final class QiitaInfra {
    
    public let session: QiitaSession
    public let repository: QiitaRepository
    
    public init(session: QiitaSession, repository: QiitaRepository.Type = QiitaRepositoryImpl.self) throws {
        
        self.session = session
        self.repository = repository.init(session: session)
        
        try PreferenceEntity.prepare()
        
        print(PreferenceEntity.sharedPreference(try GetRealm()))
    }
}


let cacheTimeoutInterval: NSTimeInterval = -30 * 60


