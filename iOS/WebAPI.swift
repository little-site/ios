//
//  WebAPI.swift
//  iOS
//
//  Created by David Hariri on 2019-10-05.
//  Copyright © 2019 David Hariri. All rights reserved.
//

import Foundation
import os

class WebAPI {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    init() {
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    private func makeRequest(withPath path: APIPath, withToken token: APIToken?, withPayload payload: Data?, withType type: HTTPMethod, didComplete: @escaping (APIResponse) -> Void, didError: @escaping (Error) -> Void) {
        os_log("WebAPI: makeRequest was called")
        var request = URLRequest(url: URL(string: "\(API_BASE_URI)\(path.rawValue)")!)
        request.httpMethod = type.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        if token != nil {
            request.setValue(token!.token, forHTTPHeaderField: "Authorization")
        }

        if payload != nil {
            request.httpBody = payload
        }
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            // Check for an error during the request
            guard error == nil else {
                os_log("Error during a request", log: .network, type: .error)
                didError(error!)
                return
            }
            
            let responseObj = response as! HTTPURLResponse
            
            // Pull out response data from the succesful response
            os_log("Request succeeded with status code %{public}ld", log: .network, type:.info, responseObj.statusCode)
            didComplete(APIResponse(data: data, code: responseObj.statusCode))
        }.resume()
    }
    
    func authenticateUser(identificationToken: Data?, nameComponents: PersonNameComponents?, didComplete: @escaping (APIAuthResponse) -> Void, didError: @escaping (Error) -> Void) {
        os_log("WebAPI: authenticateUser was called")
        var fullName: String? = nil
        
        if nameComponents != nil {
            let formatter = PersonNameComponentsFormatter()
            fullName = formatter.string(from: nameComponents!)
        }
        
        let tokenStr = String(data: identificationToken!, encoding: .utf8)
        let authRequestBody = APIAuthRequest(name: fullName, appleToken: tokenStr!)
        
        do {
            let encodedPayload = try self.encoder.encode(authRequestBody)
            
            self.makeRequest(withPath: .auth, withToken: nil, withPayload: encodedPayload, withType: .post, didComplete: { (response) in
                do {
                    let authResponse = try self.decoder.decode(APIAuthResponse.self, from: response.data!)
                    didComplete(authResponse)
                } catch {
                    print(error)
                    os_log("authenticateUser: Error decoding response", type: .error)
                    didError(error)
                }
            }) { (error) in
                didError(error)
            }
        } catch {
            os_log("authenticateUser: Error encoding request payload", type: .error)
            didError(error)
            return
        }
    }
    
    func testAuthToken(withToken token: APIToken, didComplete: @escaping (APIAuthResponse) -> Void, didError: @escaping (Error) -> Void) {
        os_log("WebAPI: testAuthToken was called")
        
        self.makeRequest(withPath: .auth, withToken: token, withPayload: nil, withType: .get, didComplete: { (response) in
            do {
                let authResponse = try self.decoder.decode(APIAuthResponse.self, from: response.data!)
                didComplete(authResponse)
            } catch {
                os_log("testAuthToken: Error decoding response", type: .error)
                didError(error)
            }
        }) { (error) in
            didError(error)
        }
    }
    
    func createEvent(withEventType type: APIEventType, withToken token: APIToken?, withResource resource: String?) {
        os_log("WebAPI: createEvent was called")
        
        do {
            let eventRequestBody = APIEventRequest(type: type, resource: resource)
            let encodedPayload = try self.encoder.encode(eventRequestBody)
            
            self.makeRequest(withPath: .events, withToken: token, withPayload: encodedPayload, withType: .post, didComplete: { (response) in
                os_log("createEvent: Created event", log: .network)
            }) { (error) in
                os_log("createEvent: Failed to create event", log: .network, type: .error)
            }
        } catch {
            os_log("createEvent: Error encoding request payload", type: .error)
        }
    }
}
