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

let realmQueue = Queue(queueLabel: "realm")

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

public func QiitaRepositoryDefaultProvider(session session: QiitaSession) -> QiitaRepositoryProtocol {
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

public final class QiitaInfra {
    
    private let repository: QiitaRepositoryProtocol
    
    public init(repository: QiitaRepositoryProtocol) {
        self.repository = repository
        
    }
}

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
