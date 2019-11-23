//
//  WebAPIDefs.swift
//  iOS
//
//  Created by David Hariri on 2019-10-13.
//  Copyright © 2019 David Hariri. All rights reserved.
//

import Foundation

let API_BASE_URI = "https://api.little.site"

enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
    case delete = "DELETE"
}

enum APIPath: String {
    case auth = "/auth/"
    case events = "/events/"
}

struct APIResponse {
    var data: Data?
    let code: Int
}

struct APIAuthRequest: Encodable {
    let name: String?
    let appleToken: String
    
    enum CodingKeys : String, CodingKey {
        case name
        case appleToken = "apple_token"
    }
}

struct APIAuthResponse: Decodable {
    let token: APIToken
    let user: APIUser
    let sites: [APISite]
}

struct APIUser: Codable, Identifiable {
    let id: Int
    let appleId: String
    let email: String
    let name: String
    let dateCreated: Date
    let dateUpdated: Date
    
    enum CodingKeys : String, CodingKey {
        case id
        case appleId = "apple_id"
        case email
        case name
        case dateCreated = "date_created"
        case dateUpdated = "date_updated"
    }
}

struct APIToken: Codable, Identifiable {
    let dateCreated: Date
    let dateUpdated: Date
    let expired: Bool
    let id: Int
    let token: String
    let userId: Int
    
    enum CodingKeys : String, CodingKey {
        case dateCreated = "date_created"
        case dateUpdated = "date_updated"
        case expired
        case id
        case token
        case userId = "user_id"
    }
}

struct APISite: Codable, Identifiable {
    let dateCreated: Date
    let dateUpdated: Date
    let handle: String
    let id: Int
    let userId: Int
    
    enum CodingKeys : String, CodingKey {
        case dateCreated = "date_created"
        case dateUpdated = "date_updated"
        case handle
        case id
        case userId = "user_id"
    }
}

enum APIEventType: String, Codable {
    case SignOut = "sign out"
    case SignIn = "sign in"
    case CheckIn = "check in"
    case View = "view"
}

struct APIEventRequest: Codable {
    let type: APIEventType
    let resource: String?
}

struct APIEvent: Codable, Identifiable {
    let id: Int
    let userId: Int?
    let dateCreated: Date
    let dateUpdated: Date
    let type: APIEventType
    let resource: String?
    
    enum CodingKeys : String, CodingKey {
        case dateCreated = "date_created"
        case dateUpdated = "date_updated"
        case type
        case resource
        case id
        case userId = "user_id"
    }
}
