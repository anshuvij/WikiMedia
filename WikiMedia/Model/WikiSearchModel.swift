//
//  WikiSearchModel.swift
//  WikiMedia
//
//  Created by Anshu Vij on 1/23/21.
//

import Foundation
struct WikiSearchModel : Codable {
    let query : Query
}

struct Query : Codable {
    let pages : [Pages]
}

struct Pages : Codable {
    let title : String?
    let fullurl : String?
    let thumbnail : Thumbnail?
    
}

struct Thumbnail : Codable {
    let source : String?
    let width: Int?
    let height : Int?
}
