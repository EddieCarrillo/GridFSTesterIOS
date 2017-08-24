//
//  ViewController.swift
//  GridFSTester
//
//  Created by my mac on 8/23/17.
//  Copyright © 2017 GangsterSwagMuffins. All rights reserved.
//

import UIKit

typealias Parameters = [String: String]

class ViewController: UIViewController, URLSessionTaskDelegate {
    
    let resourceUrl = "http://localhost:3000/api/files/petworld_icon.png"
    let postUrl = "http://localhost:3000/api/files/upload"
    
    
    
    @IBOutlet weak var loadedImage: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        postImage(success: {
            self.fetchImage(success: { (image: UIImage) in
                print("Success")
                self.loadedImage.image = image
            }) { (error: Error) in
                print("Failure")
            }
            
        }) { (error: Error) in
            print("ERROR \(error)")

        }
        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func postImage(success: @escaping () -> Void, fail: @escaping (Error) -> Void){
        let url = URL(string: postUrl)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        var urlRequest = URLRequest(url: url!)
       // let imageData = UIImagePNGRepresentation(UIImage(named: "petworld_icon")!)
        let boundary = generateBoundary()
        
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        urlRequest.httpBody = createDataBody(withParameters: nil, image: UIImage(named: "petworld_icon")! , boundary: boundary)
        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error{
                fail(error)
            }else if let response = response{
                let response = response as! HTTPURLResponse
                print("RESPONSE: \(response)")
                let code = response.statusCode
                print(code)
                if (code != 200){
                    let error = NSError(domain: "Bad request", code: code, userInfo: nil)
                    fail(error)
                }else{
                    success()
                }
                
            }
    
        
    }
        
        task.resume()
    }
    
    
    
    
    
    
    func fetchImage(success: @escaping (UIImage) -> Void, fail: @escaping (Error) -> Void){
        let url = URL(string: resourceUrl)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let urlRequest = URLRequest(url: url!)
        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error{
               fail(error)
            }else if let response = response{
            let response = response as! HTTPURLResponse
                print("RESPONSE: \(response)")
                let code = response.statusCode
                print(code)
                if (code != 200){
                    let error = NSError(domain: "Bad request", code: code, userInfo: nil)
                    fail(error)
                }else if let data = data{
                    let image = UIImage(data: data)
                    success(image!)
                }

            }
            
//            print("\n\n\n\n\nDATA:  \(data)")
//            print("\n\n\n\n\nERROR:  \(error)")
            
        }
        
        task.resume()
        
        print("fetchImage called")
        
    }
    
    
    func generateBoundary() -> String{
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createDataBody(withParameters params: Parameters?, image: UIImage, boundary: String) -> Data{
        
        
        let lineBreak = "\r\n"
        var body = Data()
        
        if let params = params{
            
            for (key, value) in params {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; file=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        
        
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=file; filename=petworld_icon.png\(lineBreak)")
            body.append("Content-Type: image/png\(lineBreak + lineBreak)")
            body.append(UIImagePNGRepresentation(image)!)
            body.append(lineBreak)
        
        
           body.append("--\(boundary)--\(lineBreak)")
        
        return body
        
        
        
        
    }
    


}


extension Data{
    mutating func append(_ string: String){
        if let data = string.data(using: .utf8){
            append(data)
        }
    }
}

