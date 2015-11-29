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

public protocol QiitaRepositoryProtocol {
    
    var accessToken: AccessTokenRepository { get }
    
    var authenticatedUser: AuthenticatedUserRepository { get }
    
    var comment: CommentRepository { get }
    
    var user: UserRepository { get }
}

func QiitaRepositoryDefaultProvider(session session: QiitaSession) -> QiitaRepositoryProtocol {
    return QiitaRepository(session: session)
}

final class QiitaRepository: QiitaRepositoryProtocol {
    
    private let session: QiitaSession
    
    private(set) lazy var accessToken: AccessTokenRepository = QiitaRepository.AccessToken(session: self.session)
    
    private(set) lazy var authenticatedUser: AuthenticatedUserRepository = QiitaRepository.AuthenticatedUser(session: self.session)
    
    private(set) lazy var comment: CommentRepository = QiitaRepository.Comment(session: self.session)
    
    private(set) lazy var user: UserRepository = QiitaRepository.User(session: self.session)
    
    init(session: QiitaSession) {
        self.session = session
    }
}

import RealmSwift
public final class QiitaInfra {
    
    public let repository: QiitaRepositoryProtocol
    
    public init(session: QiitaSession, repository: QiitaSession -> QiitaRepositoryProtocol = QiitaRepositoryDefaultProvider) {
        self.repository = repository(session)
        
        try! PreferenceEntity.prepare()
        
        print(PreferenceEntity.sharedPreference(try! Realm()))
    }
}


let cacheTimeoutInterval: NSTimeInterval = -30 * 60


