//
//  SocketC.c
//  SocketOC
//
//  Created by 黄穆斌 on 16/10/29.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

// MARK: - Include

// #include "SocketC.h"

// MARK: Socket

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <dirent.h>
#include <netdb.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/select.h>

// MARK: - Impelement

// MARK: - Tools

/** 设置 socket 文件是否进行堵塞，用于进行超时控制 */
void socket_c_block(int socket, int on) {
    int flags = fcntl(socket, F_GETFL, 0);
    if (on == 0) {
        fcntl(socket, F_SETFL, flags | O_NONBLOCK);
    } else {
        flags &= ~ O_NONBLOCK;
        fcntl(socket, F_SETFL, flags);
    }
}

/** 关闭 socket 连接 */
int socket_c_close(int socket) {
    return close(socket);
}

/** 断开连接 */
int socket_c_shutdown(int socket, int howto) {
    return shutdown(socket, howto);
}

// MARK: - TCP

/** 根据地址进行 Socket 连接 */
int socket_c_connect(const char * host, int port, int timeout, int ipv) {
    // 获取地址
    struct sockaddr_in addr_in;
    struct hostent *   host_in;
    host_in = gethostbyname(host);
    if (host_in == NULL) {
        return -1;
    }
    bcopy((char *)host_in->h_addr, (char *)&addr_in.sin_addr, host_in->h_length);
    addr_in.sin_family = host_in->h_addrtype;
    addr_in.sin_port   = htons(port);
    
    // 设置 Socket
    int sock = -1;
    sock = socket(host_in->h_addrtype, SOCK_STREAM, 0);
    socket_c_block(sock,0);
    
    // 连接
    connect(sock, (struct sockaddr *)&addr_in, sizeof(addr_in));
    
    // 设置
    fd_set          fdwrite;
    struct timeval  tvSelect;
    
    FD_ZERO(&fdwrite);
    FD_SET(sock, &fdwrite);
    
    tvSelect.tv_sec = timeout;
    tvSelect.tv_usec = 0;
    
    int retval = select(sock + 1, NULL, &fdwrite, NULL, &tvSelect);
    if (retval < 0) {
        close(sock);
        return -2;
    } else if(retval == 0){ //timeout
        close(sock);
        return -3;
    }else{
        int error  = 0;
        int errlen = sizeof(error);
        getsockopt(sock, SOL_SOCKET, SO_ERROR, &error, (socklen_t *)&errlen);
        if(error != 0){
            close(sock);
            return -4; //connect fail
        }
        socket_c_block(sock, 1);
        int set = 1;
        setsockopt(sock, SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(int));
        return sock;
    }
}

/** 读取 socket 数据 */
int socket_c_read(int sock, char * data, int len, int timeout){
    if (timeout > 0) {
        fd_set fdset;
        struct timeval time;
        time.tv_usec = 0;
        time.tv_sec  = timeout;
        FD_ZERO(&fdset);
        FD_SET(sock, &fdset);
        int ret = select(sock + 1, &fdset, NULL, NULL, &time);
        if (ret <= 0) {
            return ret; // select-call failed or timeout occurred (before anything was sent)
        }
    }
    int readlen=(int)read(sock, data, len);
    return readlen;
}


/** 写数据到 Socket 文件中 */
int socket_c_write(int sock, const char * data, int len){
    int bytes = 0;
    while (len - bytes > 0) {
        int writed_len=(int)write(sock, data + bytes, len - bytes);
        if (writed_len < 0) {
            return -1;
        }
        bytes += writed_len;
    }
    return bytes;
}

/** 监听 socket */
int socket_c_listen(const char * addr,int port){
    //create socket
    int sock   = socket(AF_INET, SOCK_STREAM, 0);
    int optval = 1;
    setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &optval, sizeof(optval));
    
    //bind
    struct sockaddr_in addr_in;
    memset(&addr_in, '\0', sizeof(addr_in));
    addr_in.sin_family      = AF_INET;
    addr_in.sin_addr.s_addr = inet_addr(addr);
    addr_in.sin_port        = htons(port);
    
    int r = bind(sock, (struct sockaddr *)&addr_in, sizeof(addr_in));
    
    if (r == 0) {
        if (listen(sock, 128) == 0) {
            return sock;
        }else{
            return -2;//listen error
        }
    }else{
        return -1;//bind error
    }
}

/** 等待连接 */
int socket_c_accept(int sock, char * remoteip, int * remoteport) {
    socklen_t clilen;
    struct sockaddr_in cli_addr;
    clilen = sizeof(cli_addr);
    int newsockfd   = accept(sock, (struct sockaddr *) &cli_addr, &clilen);
    char * clientip = inet_ntoa(cli_addr.sin_addr);
    memcpy(remoteip, clientip, strlen(clientip));
    *remoteport = cli_addr.sin_port;
    if(newsockfd > 0){
        return newsockfd;
    }else{
        return -1;
    }
}


// MARK: - UDP

int socket_c_server(const char *addr, int port){
    //create socket
    int sock=socket(AF_INET, SOCK_DGRAM, 0);
    int reuseon   = 1;
    int r = -1;
    //bind
    struct sockaddr_in serv_addr;
    serv_addr.sin_len    = sizeof(struct sockaddr_in);
    serv_addr.sin_family = AF_INET;
    if(addr == NULL || strlen(addr) == 0 || strcmp(addr, "255.255.255.255") == 0) {
        r = setsockopt( sock, SOL_SOCKET, SO_BROADCAST, &reuseon, sizeof(reuseon) );
        serv_addr.sin_port        = htons(port);
        serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    }else{
        r = setsockopt( sock, SOL_SOCKET, SO_REUSEADDR, &reuseon, sizeof(reuseon) );
        serv_addr.sin_addr.s_addr = inet_addr(addr);
        serv_addr.sin_port = htons(port);
        memset( &serv_addr, '\0', sizeof(serv_addr));
    }
    if(r==-1){
        return -1;
    }
    r=bind(sock, (struct sockaddr *) &serv_addr, sizeof(serv_addr));
    if(r==0){
        return sock;
    }else{
        return -1;
    }
}


int socket_c_recive(int socket_fd,char *outdata,int expted_len,char *remoteip,int* remoteport){
    struct sockaddr_in  cli_addr;
    socklen_t clilen=sizeof(cli_addr);
    memset(&cli_addr, 0x0, sizeof(struct sockaddr_in));
    int len=(int)recvfrom(socket_fd, outdata, expted_len, 0, (struct sockaddr *)&cli_addr, &clilen);
    char *clientip=inet_ntoa(cli_addr.sin_addr);
    memcpy(remoteip, clientip, strlen(clientip));
    *remoteport=cli_addr.sin_port;
    return len;
}
//return socket fd
int socket_c_client(){
    //create socket
    int socketfd=socket(AF_INET, SOCK_DGRAM, 0);
    int reuseon   = 1;
    setsockopt( socketfd, SOL_SOCKET, SO_REUSEADDR, &reuseon, sizeof(reuseon) );
    return socketfd;
}
//enable broadcast
void enable_broadcast(int socket_fd){
    int reuseon   = 1;
    setsockopt( socket_fd, SOL_SOCKET, SO_BROADCAST, &reuseon, sizeof(reuseon) );
}

int socket_c_get_server_ip(char *host,char *ip){
    struct hostent *hp;
    struct sockaddr_in addr;
    hp = gethostbyname(host);
    if(hp==NULL){
        return -1;
    }
    bcopy((char *)hp->h_addr, (char *)&addr.sin_addr, hp->h_length);
    char *clientip=inet_ntoa(addr.sin_addr);
    memcpy(ip, clientip, strlen(clientip));
    return 0;
}
//send message to addr and port
int socket_c_sendto(int socket_fd,char *msg,int len, char *toaddr, int topotr){
    struct sockaddr_in addr;
    socklen_t addrlen=sizeof(addr);
    memset(&addr, 0x0, sizeof(struct sockaddr_in));
    addr.sin_family=AF_INET;
    addr.sin_port=htons(topotr);
    addr.sin_addr.s_addr=inet_addr(toaddr);
    int sendlen=(int)sendto(socket_fd, msg, len, 0, (struct sockaddr *)&addr, addrlen);
    return sendlen;
}
