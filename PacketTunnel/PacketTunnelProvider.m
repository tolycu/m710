//
//  PacketTunnelProvider.m
//  PacketTunnel
//
//  Created by xc-76 on 2022/5/11.
//

#import "PacketTunnelProvider.h"
#import "SOneVPTransferManage.h"
#import "SOneLog.h"
#import "PacketTunnel_VPMacro.h"
#import "SOneVPConnectDataInfo.h"

@interface PacketTunnelProvider ()<OpenVPNAdapterDelegate>

@property (nonatomic, assign) OpenVPNAdapterEvent currentEvent;

@end

@implementation PacketTunnelProvider

- (void)handleAppMessage:(NSData *)messageData completionHandler:(void (^)(NSData * _Nullable))completionHandler {
}

-(void)startTunnelWithOptions:(NSDictionary<NSString *,NSObject *> *)options completionHandler:(void (^)(NSError * _Nullable))completionHandler {

    NETunnelProviderProtocol *proto = (NETunnelProviderProtocol*)self.protocolConfiguration;
    if(!proto){
        return;
    }
    NSDictionary<NSString *,id> *provider = proto.providerConfiguration;
    NSData *fileContent = provider[@"ovpn"];
    
    OpenVPNConfiguration *openVpnConfiguration = [[OpenVPNConfiguration alloc] init];
    openVpnConfiguration.fileContent = fileContent;
    openVpnConfiguration.connectionTimeout = 20;
    
    NSError *error;
    NSString *file = [[NSString alloc] initWithData:fileContent encoding:NSUTF8StringEncoding];
    log4cplus_info("PTVPN_log", "11 %s", file.UTF8String);
    OpenVPNConfigurationEvaluation *properties = [self.vpnAdapter applyConfiguration:openVpnConfiguration error:&error];
    if(error){
        log4cplus_info("PTVPN_log", "%s", error.debugDescription.UTF8String);
        return;
    }
    log4cplus_info("PTVPN_log", "11");
    [properties.servers enumerateObjectsUsingBlock:^(OpenVPNServerEntry * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        log4cplus_info("PTVPN_log", "属性:server %s %s", obj.friendlyName.UTF8String, obj.server.UTF8String);
    }];
    if(!properties.autologin){
        OpenVPNCredentials *credentials = [[OpenVPNCredentials alloc] init];
        credentials.username = [NSString stringWithFormat:@"%@",[options objectForKey:@"username"]];
        credentials.password = [NSString stringWithFormat:@"%@",[options objectForKey:@"password"]];
        [self.vpnAdapter provideCredentials:credentials error:&error];
        if(error){
            return;
        }
    }
    
    [self.openVpnReach startTrackingWithCallback:^(OpenVPNReachabilityStatus status) {
        if(status == OpenVPNReachabilityStatusNotReachable){
            [self.vpnAdapter reconnectAfterTimeInterval:5];
        }
    }];
    
    NSString *connectStatus = [SOneVPTransferManage objectForKey:kStartConnectByApp];
    if (connectStatus.intValue == 1) {
        [SOneVPTransferManage setObject:@"0" forKey:kStartConnectByApp];
        
        [self.vpnAdapter connectUsingPacketFlow:self.packetFlow];
        self.startHandler = completionHandler;
        // 正常通过APP进行连接；
    } else {
        // 禁止非通过容器APP 进行的连接操作；
        NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
        completionHandler(error);
    }
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler{
    NSString *connectStatus = [SOneVPTransferManage objectForKey:kStopConnectByApp];
    if (connectStatus.intValue == 1) {
        [SOneVPTransferManage setObject:@"0" forKey:kStopConnectByApp];
        if ([self.openVpnReach isTracking]) {
            [self.openVpnReach stopTracking];
        }
        [self.vpnAdapter disconnect];
        self.stopHandler = completionHandler;
    } else {
        completionHandler();
    }
}

#pragma mark - OpenVPNAdapterDelegate
- (void)openVPNAdapter:(OpenVPNAdapter *)openVPNAdapter handleError:(NSError *)error{
    log4cplus_info("PTVPN_log", "error %s", error.description.UTF8String);
    
    BOOL isOpen = (BOOL)([error userInfo][OpenVPNAdapterErrorFatalKey]);
    if(isOpen){
        if (self.openVpnReach.isTracking) {
            [self.openVpnReach stopTracking];
        }
        self.startHandler(error);
        self.startHandler = nil;
    }
}

- (void)openVPNAdapterDidReceiveClockTick:(OpenVPNAdapter *)openVPNAdapter {
}

- (void)openVPNAdapter:(OpenVPNAdapter *)openVPNAdapter handleLogMessage:(NSString *)logMessage {
    if (self.currentEvent == OpenVPNAdapterEventResolve) {
        // 开始连接摸一个端口
        [[SOneVPConnectDataInfo shareInstance] addItemWithMessage:logMessage];
    }
    
    [self logWithOpenVPNAdapter:openVPNAdapter];
}

- (void)logWithOpenVPNAdapter:(OpenVPNAdapter *)openVPNAdapter {
    if (openVPNAdapter.connectionInformation) {
        [SOneVPTransferManage setObject:openVPNAdapter.connectionInformation.user forKey:@"user"];
        [SOneVPTransferManage setObject:openVPNAdapter.connectionInformation.serverHost forKey:@"serverHost"];
        NSString *port = openVPNAdapter.connectionInformation.serverPort;
        [SOneVPTransferManage setObject:port forKey:@"serverPort"];
        [SOneVPTransferManage setObject:openVPNAdapter.connectionInformation.serverProto forKey:@"serverProto"];
        [SOneVPTransferManage setObject:openVPNAdapter.connectionInformation.serverIP forKey:@"serverIP"];
        [SOneVPTransferManage setObject:openVPNAdapter.connectionInformation.clientIP forKey:@"clientIP"];
        [SOneVPTransferManage setObject:openVPNAdapter.connectionInformation.tunName forKey:@"tunName"];
        [SOneVPTransferManage setObject:openVPNAdapter.sessionName forKey:@"sessionName"];
    } else {
    }
}

- (void)openVPNAdapter:(OpenVPNAdapter *)openVPNAdapter handleEvent:(OpenVPNAdapterEvent)event message:(NSString *)message {
    // 连接成功之后，才会有端口号数据
    log4cplus_info("PTVPN_log", "连接状态message %s %s", [AdapterEventString(event) UTF8String], message.UTF8String);
    log4cplus_info("PTVPN_log", "连接状态message ip %s  port %s", openVPNAdapter.connectionInformation.serverIP.UTF8String, openVPNAdapter.connectionInformation.serverPort.UTF8String);
    log4cplus_info("PTVPN_log", "日志: event%s %s", [AdapterEventString(event) UTF8String], message.UTF8String);
    log4cplus_info("PTVPN_log", "日志:*********");
    
    self.currentEvent = event;
    if (event == OpenVPNAdapterEventResolve ||
        event == OpenVPNAdapterEventConnected ||
        event == OpenVPNAdapterEventDisconnected) {
        // 开始连接某一个端口
        [[SOneVPConnectDataInfo shareInstance] addItemWithEvent:event];
    }
    
    switch (event) {
        case OpenVPNAdapterEventConnected:
            if(self.reasserting){
                self.reasserting = false;
            }
            self.startHandler(nil);
            self.startHandler = nil;
            break;
        case OpenVPNAdapterEventDisconnected:
            if (self.openVpnReach.isTracking) {
                [self.openVpnReach stopTracking];
            }
            self.stopHandler();
            self.stopHandler = nil;
            break;
        case OpenVPNAdapterEventReconnecting:
            self.reasserting = true;
            break;
        default:
            break;
    }
    
}

- (void)openVPNAdapter:(OpenVPNAdapter *)openVPNAdapter configureTunnelWithNetworkSettings:(NEPacketTunnelNetworkSettings *)networkSettings completionHandler:(void (^)(NSError * _Nullable))completionHandler {
    [self setTunnelNetworkSettings:networkSettings completionHandler:completionHandler];
}

#pragma mark - lazy
- (OpenVPNAdapter*)vpnAdapter{
    if(!_vpnAdapter){
        _vpnAdapter = [[OpenVPNAdapter alloc] init];
        _vpnAdapter.delegate = self;
    }
    return _vpnAdapter;
}

- (OpenVPNReachability*)openVpnReach{
    if(!_openVpnReach){
        _openVpnReach = [[OpenVPNReachability alloc] init];
    }
    return _openVpnReach;
}

@end
