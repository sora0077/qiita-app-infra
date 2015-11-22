//
//  QiitaInfra.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/20.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import QiitaKit

public protocol QiitaRepositoryProtocol {
    
    var accessToken: AccessTokenRepository { get }
    
}

final class QiitaRepository: QiitaRepositoryProtocol {
    
    let accessToken: AccessTokenRepository = QiitaRepository.AccessToken()
}

public final class QiitaInfra {
    
    private let api: QiitaKit
    private let repository: QiitaRepositoryProtocol
    
    public init(api: QiitaKit, repository: QiitaRepositoryProtocol = QiitaRepository()) {
        self.api = api
        self.repository = repository
    }
}