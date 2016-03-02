//
//  YIFY.swift
//  Torrents
//
//  Created by Stephen Radford on 02/03/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import RxCocoa
import RxSwift
import RxAlamofire

class YIFY {
    
    static let base = "https://yts.ag/api/v2/list_movies.json"
    
    class func search(term: String) -> Observable<[[String:String]]> {
        let observable = Variable([[String:String]]())
        
        requestJSON(.GET, base, parameters: ["query_term": term])
            .subscribeNext { r, json in
                if let dict = json as? [String: AnyObject] {
                    if let data = dict["data"]?["movies"] as? [[String:AnyObject]] {
                        observable.value = data.flatMap {
                            [
                                "title": $0["title_long"] as! String,
                                "link": $0["torrents"]![0]!["url"] as! String
                            ]
                        }
                    }
                }
            }.addDisposableTo(disposeBag)
        
        return observable.asObservable()
    }
    
}