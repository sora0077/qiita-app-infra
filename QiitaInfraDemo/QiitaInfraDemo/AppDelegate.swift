//
//  AppDelegate.swift
//  QiitaInfraDemo
//
//  Created by 林達也 on 2015/11/25.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import UIKit
import QiitaInfra
import QiitaKit
import APIKit

extension ListItemComments: DebugRequestToken {}
extension ListUsers: DebugRequestToken {}

let infra = try! QiitaInfra(session: QiitaSession(clientId: "", clientSecret: ""))

struct MockItem: ItemProtocol {
    
    /// HTML形式の本文
    /// example: <h1>Example</h1>
    var rendered_body: String = ""
    
    /// Markdown形式の本文
    /// example: # Example
    var body: String = ""
    
    /// この投稿が共同更新状態かどうか (Qiita:Teamでのみ有効)
    var coediting: Bool = false
    
    /// データが作成された日時
    /// example: 2000-01-01T00:00:00+00:00
    var created_at: String = ""
    
    /// 投稿の一意なID
    /// example: 4bd431809afb1bb99e4f
    var id: String = ""
    
    /// 限定共有状態かどうかを表すフラグ (Qiita:Teamでは無効)
    var `private`: Bool = false
    
    /// 投稿に付いたタグ一覧
    /// example: [{"name"=>"Ruby", "versions"=>["0.0.1"]}]
    var tag_names: [String] = []
    
    /// 投稿のタイトル
    /// example: Example title
    var title: String = ""
    
    /// データが最後に更新された日時
    /// example: 2000-01-01T00:00:00+00:00
    var updated_at: String = ""
    
    /// 投稿のURL
    /// example: https://qiita.com/yaotti/items/4bd431809afb1bb99e4f
    var url: String = ""
    
    /// Qiita上のユーザを表します。
    var user_id: String = ""
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        print(NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true))
        
        var item1 = MockItem()
        item1.id = "c686397e4a0f4f11683d"
        
        let list = infra.repository.comment.itemComments(item1)
        
        list.update().onSuccess { res in
            print("1", try? list.values().count)
        }
        list.update().onSuccess { res in
            print("2", try? list.values().count)
            list.update().onSuccess { res in
                print("3", try? list.values().count)
            }
        }
        
        
        let users = infra.repository.user.users()
        users.update().onSuccess { res in
            print(try? users.values().count)
            
            try! infra.repository.user.cache("uasi")
            
        }.onFailure { e in
            print(e)
        }

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

