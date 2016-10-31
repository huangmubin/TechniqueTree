//
//  Socket.swift
//  Socket
//
//  Created by 黄穆斌 on 16/10/29.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

import Foundation

// MAKR: - Import SocketC

// MARK: TCP

@_silgen_name("socket_c_close") func c_close(sock: Int32) -> Int32
@_silgen_name("socket_c_connect") func c_connet(host: UnsafePointer<Int8>, port: Int32, timeout: Int32, ipv: Int32) -> Int32
@_silgen_name("socket_c_read") func c_read(sock: Int32, data: UnsafePointer<UInt8>, len: Int32, timeout: Int32) -> Int32
@_silgen_name("socket_c_write") func c_write(sock: Int32, data: UnsafePointer<UInt8>, len: Int32) -> Int32
@_silgen_name("socket_c_listen") func c_listen(address: UnsafePointer<Int8>, port: Int32) -> Int32
@_silgen_name("socket_c_accept") func c_accept(sock: Int32, ip: UnsafePointer<Int8>, port: UnsafePointer<Int32>) -> Int32

// MARK: UDP

@_silgen_name("socket_c_server") func c_server(host: UnsafePointer<Int8>, port:Int32) -> Int32
@_silgen_name("socket_c_recive") func c_recive(sock: Int32, data: UnsafePointer<UInt8>, len: Int32, address: UnsafePointer<Int8>, port: UnsafePointer<Int32>) -> Int32
@_silgen_name("socket_c_client") func c_client() -> Int32
@_silgen_name("socket_c_get_server_ip") func c_get_server_ip(host: UnsafePointer<Int8>, ip: UnsafePointer<Int8>) -> Int32
@_silgen_name("socket_c_sentto") func c_sentto(sock: Int32, data: UnsafePointer<UInt8>, len: Int32, address: UnsafePointer<UInt8>, port: Int32) -> Int32
@_silgen_name("enable_broadcast") func c_enable_broadcast(sock: Int32)


// MARK: - Scoket

public class Socket {
    
    var address: String
    var port: Int32
    var sock: Int32?
    
    init() {
        self.address = ""
        self.port    = 0
    }
    
    
    /// 关闭套接字
    func close() -> Bool {
        if let s = sock {
            if c_close(sock: s) == 0 {
                return true
            }
        }
        return false
    }
    
}

// MARK: - TCP

public class TCP: Socket {
    
    init(address: String, port: Int32) {
        super.init()
        self.address = address
        self.port    = port
    }
    
}

// MARK: - ipv4 TCP Client And Sever

extension TCP {
    
    /// 连接 Socket
    func connect(timeout: Int32) -> Bool {
        let sock = c_connet(host: self.address, port: self.port, timeout: timeout, ipv: 4)
        if sock > 0 {
            self.sock = sock
            return true
        }
        return false
    }
    
    /// 监听地址
    func listen() -> Bool {
        let sock = c_listen(address: self.address, port: self.port)
        if sock > 0 {
            self.sock = sock
            return true
        }
        return false
    }
    
    /// 获取服务端
    func accept() -> TCP? {
        if let s = sock {
            var buffer      = [Int8](repeating: 0x0,count: 16)
            var port: Int32 = 0
            let client_sock = c_accept(sock: s, ip: &buffer, port: &port)
            if client_sock < 0 {
                return nil
            }
            
            let client = TCP(address: String(cString: buffer, encoding: String.Encoding.utf8) ?? "", port: port)
            client.sock    = client_sock
            return client
        }
        return nil
    }
    
}

// MARK: - TCP Send And Read

extension TCP {
    
    
    /// 发送数据
    func send(byte: [UInt8]) -> Bool {
        if let s = sock {
            let size = Int32(byte.count)
            if c_write(sock: s, data: byte, len: size) == size {
                return true
            }
        }
        return false
    }
    
    /// 发送数据
    func send(text: String) -> Bool {
        if let s = sock {
            let size = Int32(text.characters.count)
            if c_write(sock: s, data: text, len: size) == size {
                return true
            }
        }
        return false
    }
    
    /// 发送数据
    func send(data: Data) -> Bool {
        if let s = sock {
            let size = Int32(data.count)
            if c_write(sock: s, data: data.map({ return $0 }), len: size) == size {
                return true
            }
        }
        return false
    }
    
    /// 读取数据
    func read(length: Int, timeout: Int32 = -1) -> [UInt8]? {
        if let s = sock {
            var buffer: [UInt8] = [UInt8](repeating: 0x0,count: length)
            let size = c_read(sock: s, data: &buffer, len: Int32(length), timeout: timeout)
            if size <= 0 {
                return nil
            }
            return Array(buffer[0 ..< Int(size)])
        }
        return nil
    }
    
}


// MARK: - UDP


public class UDP: Socket {
    
    init?(address: String, port: Int32, server: Bool) {
        super.init()
        self.address = address
        self.port    = port
        if server {
            let sock = c_server(host: self.address, port: self.port)
            if sock > 0 {
                self.sock = sock
                return
            }
        } else {
            var buffer: [Int8] = [Int8](repeating: 0x0,count: 16)
            if c_get_server_ip(host: address, ip: &buffer) == 0 {
                if let server_address = String(cString: buffer, encoding: String.Encoding.utf8) {
                    self.address = server_address
                    self.sock    = c_client()
                    if self.sock! > 0 {
                        return
                    }
                }
            }
        }
        return nil
    }
}


// MARK: - ipv4 UDP

extension UDP {
    
    /// 允许进行广播
    func enableBroadcast() {
        if let s = sock {
            c_enable_broadcast(sock: s)
        }
    }
    
}

// MARK: - UDP Send Read

extension UDP {
    
    /// 发送数据
    func send(byte: [UInt8]) -> Bool {
        if let s = sock {
            let size = Int32(byte.count)
            if c_sentto(sock: s, data: byte, len: size, address: self.address, port: self.port) == size {
                return true
            }
        }
        return false
    }
    
    /// 发送数据
    func send(text: String) -> Bool {
        if let s = sock {
            let size = Int32(text.characters.count)
            if c_sentto(sock: s, data: text, len: size, address: self.address, port: self.port) == size {
                return true
            }
        }
        return false
    }
    
    /// 发送数据
    func send(data: Data) -> Bool {
        if let s = sock {
            let size = Int32(data.count)
            if c_sentto(sock: s, data: data.map({ return $0 }), len: size, address: self.address, port: self.port) == size {
                return true
            }
        }
        return false
    }
    
    func recv(length: Int) -> ([UInt8]?, String, Int) {
//        if let s = sock {
//            var buffer = [Int8](repeating: 0x0, count: length)
//            var remote_address = [UInt8](repeating: 0x0, count: 16)
//            var remote_port: Int32 = 0
//            let readSize = c_recive(sock: s, data: buffer, len: Int32(length), address: &remote_address, port: &remote_port)
//            
//            let port = Int(remote_port)
//            var address = String(cString: remote_address, encoding: String.Encoding.utf8) ?? ""
//            
//            
//        }
        return (nil, "", 0)
    }
}
