//
//  Network.swift
//  Socket
//
//  Created by 黄穆斌 on 16/10/30.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

import Foundation

// MARK: - Network 2

public class Network: NSObject, URLSessionDataDelegate {
    
    // MARK: Data
    
    public var id: String = ""
    private var session: URLSession!
    private var task: URLSessionDataTask?
    private var sessionQueue: OperationQueue
    public var backQueue: DispatchQueue?
    
    public var completeHandler: ((Response) -> Void)?
    
    func clear() {
        session = nil
        backQueue = nil
        completeHandler = nil
        task?.cancel()
        sessionQueue.cancelAllOperations()
    }
    
    // MARK: Init
    
    init(id: String = "", progress: Bool = false, backQueue: DispatchQueue? = nil) {
        //opreateQueue = DispatchQueue(label: id)
        sessionQueue = OperationQueue()
        super.init()
        self.id = id
        self.progress = progress
        self.backQueue = backQueue
        //let queue = OperationQueue()
        sessionQueue.maxConcurrentOperationCount = 1
        session = URLSession(configuration: .default, delegate: self, delegateQueue: sessionQueue)
    }
    
    // MARK: Queue
    
    var connecting: Response!
    var waitingQueue: [Response] = []
    var firstHeader: Bool = true
    //let opreateQueue: DispatchQueue
    var progress: Bool = false
    
    private func connect() {
        sessionQueue.addOperation {
            if self.connecting == nil && self.waitingQueue.count > 0 {
                self.connecting = self.firstHeader ? self.waitingQueue.removeFirst() : self.waitingQueue.removeLast()
                if let request = self.connecting.request {
                    let task = self.session.dataTask(with: request)
                    task.taskDescription = self.connecting?.id
                    self.task = task
                    task.resume()
                } else {
                    self.connect()
                }
            }
        }
        
        /*
        opreateQueue.async {
            if self.connecting == nil && self.waitingQueue.count > 0 {
                self.connecting = self.firstHeader ? self.waitingQueue.removeFirst() : self.waitingQueue.removeLast()
                if let request = self.connecting.request {
                    let task = self.session.dataTask(with: request)
                    task.taskDescription = self.connecting?.id
                    self.task = task
                    task.resume()
                } else {
                    self.connect()
                }
            }
        }*/
    }
    
    // MARK: Methods
    
    func response(id: String, complete: @escaping (Response?) -> Void) {
        sessionQueue.addOperation { [name = id] in
            if let i = self.waitingQueue.index(where: { $0.id == name }) {
                complete(self.waitingQueue[i])
            } else {
                complete(nil)
            }
        }
    }
    
    /*
    func response(id: String) -> Response? {
        return opreateQueue.sync {
            if let i = self.waitingQueue.index(where: { $0.id == id }) {
                return self.waitingQueue[i]
            }
            return nil
        }
    }
    */
    
    func first(id: String) {
        sessionQueue.addOperation {
            if let i = self.waitingQueue.index(where: { $0.id == id }) {
                let response = self.waitingQueue.remove(at: i)
                if self.firstHeader {
                    self.waitingQueue.insert(response, at: 0)
                } else {
                    self.waitingQueue.append(response)
                }
            }
        }
        
        /*
        opreateQueue.async {
            if let i = self.waitingQueue.index(where: { $0.id == id }) {
                let response = self.waitingQueue.remove(at: i)
                if self.firstHeader {
                    self.waitingQueue.insert(response, at: 0)
                } else {
                    self.waitingQueue.append(response)
                }
            }
        }
        */
    }
    
    func cancel(id: String? = nil) {
        sessionQueue.addOperation { [id = id] in
            if let id = id {
                if self.connecting?.id == id {
                    self.task?.cancel()
                } else {
                    if let i = self.waitingQueue.index(where: { $0.id == id }) {
                        self.waitingQueue.remove(at: i)
                    }
                }
            } else {
                self.waitingQueue.removeAll()
                self.task?.cancel()
            }
        }
        /*
        opreateQueue.async {
            if let id = id {
                if self.connecting?.id == id {
                    self.task?.cancel()
                } else {
                    if let i = self.waitingQueue.index(where: { $0.id == id }) {
                        self.waitingQueue.remove(at: i)
                    }
                }
            } else {
                self.waitingQueue.removeAll()
                self.task?.cancel()
            }
        }
        */
    }
    
    func suspend() {
        self.task?.suspend()
    }
    
    func resume() {
        self.task?.resume()
    }
    
    // MARK: GET PUT
    
    func get(id: String? = nil, url: String, header: [String: String]? = nil, other: Any? = nil, time: TimeInterval? = nil, receiveComplete: ((Response, Error?) -> Void)?) {
        appendResponse(id: id ?? url, url: url, method: "GET", header: header, body: nil, time: time, other: other, receiveResponse: nil, receiveData: nil, receiveComplete: receiveComplete)
    }
    
    func put(id: String? = nil, url: String, header: [String: String]? = nil, body: Any? = nil, other: Any? = nil, receiveComplete: ((Response, Error?) -> Void)?) {
        appendResponse(id: id ?? url, url: url, method: "PUT", header: header, body: body == nil ? nil : Network.body(body!), time: nil, other: other, receiveResponse: nil, receiveData: nil, receiveComplete: receiveComplete)
    }
    
    func post(id: String? = nil, url: String, header: [String: String]? = nil, body: Any? = nil, other: Any? = nil, receiveComplete: ((Response, Error?) -> Void)?) {
        appendResponse(id: id ?? url, url: url, method: "POST", header: header, body: body == nil ? nil : Network.body(body!), time: nil, other: other, receiveResponse: nil, receiveData: nil, receiveComplete: receiveComplete)
    }
    
    func delete(id: String? = nil, url: String, header: [String: String]? = nil, body: Any? = nil, other: Any? = nil, receiveComplete: ((Response, Error?) -> Void)?) {
        appendResponse(id: id ?? url, url: url, method: "DELETE", header: header, body: body == nil ? nil : Network.body(body!), time: nil, other: other, receiveResponse: nil, receiveData: nil, receiveComplete: receiveComplete)
    }
    
    // MARK: Append Methods
    
    func appendResponse(id: String, url: String, method: String, header: [String: String]?, body: Data?, time: TimeInterval?, other: Any?, data: Data? = nil, receiveResponse: ((Response) -> Bool)?, receiveData: ((Response, Data) -> Void)?, receiveComplete: ((Response, Error?) -> Void)?) {
        sessionQueue.addOperation {
            if self.waitingQueue.contains(where: { $0.id == id }) || self.connecting?.id == id {
                return
            }
            
            let response = Response()
            response.id = id
            response.url = url
            response.method = method
            response.header = header
            response.body = body
            response.time = time
            response.other = other
            response.data = data
            
            response.receiveResponse = receiveResponse
            response.receiveData = receiveData
            response.receiveComplete = receiveComplete
            
            self.waitingQueue.append(response)
            self.connect()
        }
        
        /*
        opreateQueue.async {
            if self.waitingQueue.contains(where: { $0.id == id }) || self.connecting?.id == id {
                return
            }
            
            let response = Response()
            response.id = id
            response.url = url
            response.method = method
            response.header = header
            response.body = body
            response.time = time
            response.other = other
            response.data = data
            
            response.receiveResponse = receiveResponse
            response.receiveData = receiveData
            response.receiveComplete = receiveComplete
            
            self.waitingQueue.append(response)
            self.connect()
        }
        */
    }
    
    func append(id: String? = nil, url: String, method: String = "GET", header: [String: String]? = nil, body: Data? = nil, other: Any?, receiveComplete: ((Response, Error?) -> Void)?) {
        appendResponse(id: id ?? url, url: url, method: method, header: header, body: body, time: nil, other: other, receiveResponse: nil, receiveData: nil, receiveComplete: receiveComplete)
    }
    
    @discardableResult
    func link(id: String? = nil, url: String, method: String = "GET", header: [String: String]? = nil, body: Data? = nil, other: Any?, receiveComplete: ((Response, Error?) -> Void)?) -> Network {
        appendResponse(id: id ?? url, url: url, method: method, header: header, body: body, time: nil, other: other, receiveResponse: nil, receiveData: nil, receiveComplete: receiveComplete)
        return self
    }
    
    // MARK: URLSessionDataDelegate
    
    /** 接收到响应 */
    @available(OSX 10.9, *)
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
//        opreateQueue.async {
            print("\(self.id) \(self.connecting.id) - \(Thread.current) - \(self.connecting.header)\nResponse - \(response)")
            self.connecting.response = response
            if self.backQueue == nil {
                if self.connecting.receiveResponse?(self.connecting) == false {
                    completionHandler(.cancel)
                    return
                }
            } else {
                //let connect = self.connecting!
                self.backQueue?.async { [connect = self.connecting!] in
                    if connect.receiveResponse?(connect) == false {
                        completionHandler(.cancel)
                        return
                    }
                }
            }
            completionHandler(.allow)
//        }
    }
    
    /** 接收到数据 */
    @available(OSX 10.9, *)
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//        opreateQueue.async {
            //print("\(self.id) \(self.connecting.id) - dataTask - \(Thread.current) - \(data.count)")
            if self.connecting.data == nil {
                self.connecting.data = data
            } else {
                self.connecting.data?.append(data)
            }
            if self.progress {
                if self.backQueue == nil {
                    self.connecting.receiveData?(self.connecting, data)
                } else {
                    //var connect = self.connecting!
                    self.backQueue?.async { [connect = self.connecting!] in
                        connect.receiveData?(connect, data)
                    }
                }
            }
//        }
    }
    
    /** 发送特定任务的最后一次消息，如果任务已经完成 error 将会是 nil. */
    @available(OSX 10.9, *)
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        opreateQueue.async {
            // FIXME: - Print
            print("Network \(self.connecting.id) - \(Thread.current) - \(self.connecting.code); size = \(self.connecting.data?.count); error = \(error);")
            JSON.printjson(data: self.connecting.data)
            print("")
            
            if let handler = self.completeHandler {
                handler(self.connecting)
            }
            
            self.connecting?.error = error
            if self.backQueue == nil {
                self.connecting.receiveComplete?(self.connecting, error)
                self.connecting.clear()
            } else {
                //let connect = self.connecting!
                self.backQueue?.async { [connect = self.connecting!] in
                    connect.receiveComplete?(connect, error)
                    connect.clear()
                }
            }
            
            self.connecting = nil
            self.task = nil
            self.connect()
//        }
    }
}

// MARK: - Tools

extension Network {
    
    /// 创建 Request
    class func request(path: String, method: String, header: [String: String]?, body: Data?, time: TimeInterval?) -> URLRequest? {
        
        guard let url = URL(string: path) else { return nil }
        var request = URLRequest(url: url)
        
        request.httpMethod = method
        request.httpBody = body
        request.allHTTPHeaderFields = header
        if time != nil {
            request.timeoutInterval = time!
        }
        
        return request
    }
    
    // 创建 JSON 数据
    class func body(_ json: Any) -> Data? {
        if let data = json as? Data {
            return data
        }
        if let data = try? JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) {
            return data
        }
        return nil
    }
    
}

// MARK: - Response

extension Network {
    
    public class Response {
        
        // MARK: Request Data
        
        var id: String = ""
        var url: String = ""
        var method: String = "GET"
        var header: [String: String]?
        var body: Data?
        var time: TimeInterval?
        
        // MARK: Response Data
        
        var response: URLResponse?
        var data: Data?
        var error: Error?
        
        // MARK: Easy Data
        
        subscript(keys: String...) -> String {
            let json = JSON(data: data)
            return json.value(keys).string ?? ""
        }
        
        var code: Int {
            if let http = response as? HTTPURLResponse {
                return http.statusCode
            }
            return 0
        }
        
        func printHttpHeaders() {
            if let http = response as? HTTPURLResponse {
                print("\(id) printHttpHeaders; \(http.allHeaderFields)")
            }
        }
        
        func header<T>(_ key: String) -> T? {
            if let http = response as? HTTPURLResponse {
                if let value = http.allHeaderFields[key] as? T {
                    return value
                }
            }
            return nil
        }
        
        // MARK: Recall
        
        var receiveResponse: ((Response) -> Bool)?
        var receiveData: ((Response, Data) -> Void)?
        var receiveComplete: ((Response, Error?) -> Void)?
        
        // MARK: Methods
        
        var request: URLRequest? {
            return Network.request(path: url, method: method, header: header, body: body, time: time)
        }
        
        func clear() {
            receiveResponse = nil
            receiveData = nil
            receiveComplete = nil
            
            response = nil
            data = nil
            error = nil
        }
        
        // MARK: Other Data
        
        var other: Any?
        
        func infos<T>(key: String, null: T) -> T {
            if let dic = other as? [String: Any] {
                if let data = dic[key] as? T {
                    return data
                }
            }
            return null
        }
        
    }
    
}

// MARK: - Pone

extension Network.Response {
    
    func index() -> IndexPath {
        if let dic = other as? [String: Any] {
            if let row = dic["row"] as? Int, let sec = dic["section"] as? Int {
                return IndexPath(row: row, section: sec)
            }
        }
        return IndexPath(row: 0, section: 0)
    }
    func name() -> String {
        if let dic = other as? [String: Any] {
            if let name = dic["name"] as? String {
                return name
            }
        }
        return ""
    }
    
    func thumb() -> Int {
        if let dic = other as? [String: Any] {
            if let thumb = dic["thumb"] as? Int {
                return thumb
            }
        }
        return 0
    }
    func thumbName() -> String {
        if let dic = other as? [String: Any] {
            if let name = dic["name"] as? String, let thumb = dic["thumb"] as? Int {
                return "\(name)_\(thumb).png"
            }
        }
        return ""
    }
    
    func videoimage() -> Data? {
        if let dic = other as? [String: Any] {
            if let image = dic["image"] as? Data {
                return image
            }
        }
        return nil
    }
    
    func videourl() -> String {
        if let dic = other as? [String: Any] {
            if let url = dic["url"] as? String {
                return url
            }
        }
        return ""
    }
    func videoSize() -> Double {
        if let dic = other as? [String: Any] {
            if let size = dic["size"] as? Double {
                return size
            }
        }
        return 0
    }
}
