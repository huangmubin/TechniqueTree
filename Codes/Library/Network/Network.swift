//
//  Network.swift
//  Socket
//
//  Created by 黄穆斌 on 16/10/30.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

import Foundation

// MARK: - Network
/**
 网络访问类
 */
public class Network: NSObject {
    
    // MARK: Datas
    
    /// 标题
    public var label: String
    
    
    /// 网络会话
    var session: URLSession!
    /// 网络会话队列
    var sessionQueue = OperationQueue()
    
    
    /// 网络会话类型
    let type: Network.SessionType
    
    
    /// 网络队列最大并发数
    var concurrentMax: Int = 1
    /// 当前网络任务数量
    var concuttentCount: Int {
        var i = 0
        tasks.forEach({ i += $0.running ? 1 : 0 })
        return i
    }
    
    
    /// 任务队列
    fileprivate var tasks: [Network.Task] = []
    /// 操作队列
    fileprivate let queue: DispatchQueue
    
    
    /// 任务默认标示符
    fileprivate var id: Int = 0
    
    // MARK: Init
    
    /// 根据类型初始化网络会话。
    init(label: String, type: Network.SessionType) {
        self.type  = type
        self.label = label
        self.queue = DispatchQueue(label: label)
        
        /**************/
        /* 设置网络会话 */
        /**************/
        
        super.init()
        
        self.sessionQueue.maxConcurrentOperationCount = 1
        switch type {
        case .order:
            session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: sessionQueue)
        case .background:
            session = URLSession(configuration: URLSessionConfiguration.background(withIdentifier: label), delegate: self, delegateQueue: sessionQueue)
        case .upload:
            session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: sessionQueue)
        }
        
    }
    
}

// MARK: - Network Methods

extension Network {
    
    fileprivate func resume() {
        queue.async {
            let count = self.concuttentCount
            if count < self.concurrentMax {
                for task in self.tasks {
                    if !task.running {
                        task.running = true
                        task.task.resume()
                        return
                    }
                }
            }
        }
    }
    
}

// MARK: - Session Delegate

// URLSessionDelegate URLSessionTaskDelegate URLSessionTaskDelegate
extension Network: URLSessionDataDelegate, URLSessionDownloadDelegate {
    
    // MARK: URLSessionDelegate
    /*
    /// 检查下载证书
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        print("检查下载证书: \(challenge)")
        completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
    }
    
    /// 证书无效错误
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("证书无效错误: \(error)")
    }
    */
    // MARK: URLSessionTaskDelegate
    
    
    /**
     发送特定任务的最后一次消息，如果任务已经完成 error 将会是 nil.
     */
    @available(OSX 10.9, *)
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.queue.async {
            if let index = self.tasks.index(where: { $0.task.taskDescription == task.taskDescription }) {
                self.tasks[index].completeBlock?(self.tasks[index], error)
                self.tasks.remove(at: index)
                self.resume()
            }
        }
    }
    
    /*
    /**
     重定向网络任务。
     让 HTTP 请求试图重定向到另一个 URL。你必须要调用 completionHandler 来允许重定向，通过一个修改后的 request 或传递 nil 来让该重定向响应的主体作为有效负载被传递过去。默认是在遵循重定向。
     在后台会话中，重定向永远遵守，所以不会调用这个方法。
     */
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Swift.Void) {
        completionHandler(nil)
    }
    
    /**
     任务接收到请求的证书验证时调用。如果没有实现该方法，会话证书将会是 NOT, 并采用默认处理。
     */
    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        
    }
    
    /* Sent if a task requires a new, unopened body stream.  This may be
     * necessary when authentication has failed for any request that
     * involves a body stream.
     */
    /**
     在任务需要一个新的还没开放的 body 流时调用。在认证失败的时候，可能必须给请求调用一个 body 流。
     */
    public func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Swift.Void) {
        
    }
    
    /**
     定期通知代理上传的进度，这还包括任务的性能信息。
     */
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
    }
    
    /**
     发送任务的完成状态信息
     */
    @available(OSX 10.12, *)
    public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        
    }
    */
    
    // MARK: URLSessionTaskDelegate
    
    /** 接收到响应 */
    @available(OSX 10.9, *)
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        self.queue.async {
            if let index = self.tasks.index(where: { $0.task.taskDescription == dataTask.taskDescription }) {
                self.tasks[index].taskResponse = response
                self.tasks[index].responseBlock?(self.tasks[index])
            }
        }
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    /** 接收到数据 */
    @available(OSX 10.9, *)
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.queue.async {
            if let index = self.tasks.index(where: { $0.task.taskDescription == dataTask.taskDescription }) {
                self.tasks[index].data.append(data)
                self.tasks[index].dataSize = self.tasks[index].data.count
                self.tasks[index].receiveBlock?(self.tasks[index], self.tasks[index].dataSize)
            }
        }
    }
    
    /*
    /** 下载任务已经开始 */
    @available(OSX 10.9, *)
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        
    }
    
    
    /** 流任务已经开始 */
    @available(OSX 10.11, *)
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        
    }
    
    /** 即将缓存响应 */
    @available(OSX 10.9, *)
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Swift.Void){
        completionHandler(nil)
    }
    */
    
    // MARK: URLSessionDownloadDelegate
    
    /** URLSession Download 必须, 下载完成。必须在这里将下载好的文件进行转移。然后将会调用  URLSession:task:didCompleteWithError:  */
    @available(OSX 10.9, *)
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        self.queue.sync {
            if let index = self.tasks.index(where: { $0.task.taskDescription == downloadTask.taskDescription }) {
                self.tasks[index].downloadFinishBlock?(self.tasks[index], location)
            }
        }
    }
    
    
    /** 定期发送下载进度的通知 */
    @available(OSX 10.9, *)
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.queue.async {
            if let index = self.tasks.index(where: { $0.task.taskDescription == downloadTask.taskDescription }) {
                self.tasks[index].totalSize = Int(totalBytesWritten)
                self.tasks[index].dataSize  = Int(bytesWritten)
                self.tasks[index].receiveBlock?(self.tasks[index], self.tasks[index].dataSize)
            }
        }
    }
    
    /** 下载任务开始的时候调用，如果下载错误，Error 的 userinfo 中会有 NSURLSessionDownloadTaskResumeData 关键字来标记开始的数据。 */
    @available(OSX 10.9, *)
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64){
        
    }
}

// MARK: - Interface

extension Network {
    
    /// 创建并添加下载任务。线程安全。
    public func order(identify: String? = nil, path: String, method: String = "GET", header: [String: String]? = nil, body: Data? = nil, time: TimeInterval? = nil) -> Network.Task? {
        if type == .upload {
            assert(false)
            return nil
        }
        return queue.sync {
            if let index = self.tasks.index(where: { $0.identify == identify }) {
                if self.tasks[index].task.state != URLSessionTask.State.running {
                    let task = self.tasks.remove(at: index)
                    self.tasks.insert(task, at: 0)
                    return task
                }
            }
            if let request = Network.request(path: path, method: method, header: header, body: body, time: time) {
                self.id += 1
                var order: URLSessionTask
                if self.type == .order {
                    order = self.session.dataTask(with: request)
                } else {
                    order = self.session.downloadTask(with: request)
                }
                order.taskDescription = identify ?? "\(self.id)"
                
                let task = Network.Task(identify: order.taskDescription!, path: path, method: method, header: header, body: body, time: time, task: order)
                self.tasks.append(task)
                
                task.network = self
                return task
            }
            return nil
        }
    }
}

// MARK: - Tools

extension Network {
    
    /// 创建 Request
    class func request(path: String, method: String = "GET", header: [String: String]? = nil, body: Data? = nil, time: TimeInterval? = nil) -> URLRequest? {
        
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
    
}

// MARK: - Data Struct

// MARK: - Type

extension Network {
    enum SessionType {
        case order
        case background
        case upload
    }
}

// MARK: - Task

extension Network {
    /**
     任务封装
     */
    public class Task {
        
        // MARK: Data
        
        weak var network: Network?
        
        // MARK: Task Info
        
        var identify: String
        var path: String
        var method: String
        var header: [String: String]?
        var body: Data?
        var time: TimeInterval?
        
        // MARK: Network
        
        var task: URLSessionTask
        var taskResponse: URLResponse?
        
        var responseBlock: ((Network.Task) -> Void)?
        var receiveBlock: ((Network.Task, Int) -> Void)?
        var downloadFinishBlock: ((Network.Task, URL) -> Void)?
        var completeBlock: ((Network.Task, Error?) -> Void)?
        
        // MARK: Data
        
        lazy var data: Data = Data()
        var totalSize: Int = 0
        var dataSize: Int = 0
        
        // MARK: State
        
        var running: Bool = false
        
        // MARK: Init
        
        init(identify: String, path: String, method: String, header: [String: String]?, body: Data?, time: TimeInterval?, task: URLSessionTask) {
            self.identify = identify
            self.path     = path
            self.method   = method
            self.header   = header
            self.body     = body
            self.time     = time
            self.task     = task
        }
    }
}

// MARK: - Task Interface
extension Network.Task {
    
    @discardableResult
    func resume() -> Network.Task {
        self.network?.resume()
        return self
    }
    
    @discardableResult
    func cancel() -> Network.Task {
        self.task.cancel()
        self.running = false
        return self
    }
    
    @discardableResult
    func suspend() -> Network.Task {
        self.task.suspend()
        self.running = false
        return self
    }
    
    func response(block: @escaping (Network.Task) -> Void) -> Network.Task {
        self.responseBlock = block
        return self
    }
    
    func receive(block: @escaping (Network.Task, Int) -> Void) -> Network.Task {
        self.receiveBlock = block
        return self
    }
    
    func downloaded(block: @escaping (Network.Task, URL) -> Void) -> Network.Task {
        self.downloadFinishBlock = block
        return self
    }
    
    func complete(block: @escaping (Network.Task, Error?) -> Void) -> Network.Task {
        self.completeBlock = block
        return self
    }
}
