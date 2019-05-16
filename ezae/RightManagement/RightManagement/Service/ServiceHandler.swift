//
//  ServiceHandler.swift
//  right
//
//  Created by Baljeet Gaheer on 13/11/17.
//  Copyright © 2017 Baljeet Gaheer. All rights reserved.
//

import Foundation
enum HttpMethod : String {
    case  GET
    case  POST
    case  DELETE
    case  PUT
}
class ServiceHandler:NSObject {
    var request : URLRequest?
    var session : URLSession?
    static var action: String?
    static func instance() ->  ServiceHandler{
        return ServiceHandler()
    }
    
    static func instance(actionName: String) ->  ServiceHandler{
        self.action = actionName
        return ServiceHandler()
    }
    
    func makeAPICall(url: String,method: HttpMethod, completionHandler:@escaping (Data? ,HTTPURLResponse?  , NSError? ) -> Void) {
        request = URLRequest(url: URL(string: url)!)
        request?.httpMethod = method.rawValue
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        session = URLSession(configuration: configuration)
        session?.dataTask(with: request! as URLRequest) { (data, response, error) -> Void in
            if let data = data {
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    completionHandler(data, response , error as NSError?)
                }else{
                    //show error message to user
                    let statusCode = response
                }
            }
            }.resume()
    }
    
    func makeAPICallImage(url: String,method: HttpMethod,chosenImage:UIImage, completionHandler:@escaping (Data? ,HTTPURLResponse?  , NSError? ) -> Void) {
        
        request = URLRequest(url: URL(string: url)!)
        request?.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        let contentType: String = "multipart/form-data; boundary=\(boundary)"
        request?.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request?.httpBody = createBody(
                                boundary: boundary,
                                data: UIImagePNGRepresentation(chosenImage)!,
                                mimeType: "image/jpg",
                                filename: "userImage.jpg")
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        session = URLSession(configuration: configuration)
        session?.dataTask(with: request! as URLRequest) { (data, response, error) -> Void in
            if let data = data {
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    completionHandler(data, response , error as NSError?)
                }else{
                    //show error message to user
                    //let statusCode = response
                }
            }
            }.resume()
    }
    func createBody(
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        let fileName: String = "imagefile"
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fileName)\"; filename=\"image.png\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type:image/png\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(data)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
//        body.appendString(boundaryPrefix)
//        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
//        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
//        body.append(data)
//        body.appendString("\r\n")
//        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
    
}
extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}
