
#import "SOneVPManage.h"
#import "SOneVPIkeV2Model.h"
#import "SOneVPConnectModeModel.h"
#import "SOneVPTransferManage.h"
#import "SOneVPUserDefaults.h"
#import "SOneVPLog.h"
#import "NSString+SOneExtension.h"
#import "SOneVPTool.h"
#import "SOneVPConnectDataInfo.h"
#import <MJExtension/MJExtension.h>
#import "SOneCertManage.h"
#import "NSData+SOneExtension.h"
#import "SOneVPTool/SOneVPTool.h"



#define SOneAPPName [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]

#pragma mark - log
#ifdef DEBUG
#define DebugLog(s, ... )

#else
#define DebugLog(s, ... )
#endif




static NSString *kConnectDurationKey = @"kConnectDurationKey";


@interface SOneVPManage()

@property (nonatomic, assign) NEVPNStatus checkStatus;

@property (nonatomic, strong) NEVPNManager *ikev2Manager;
@property (nonatomic, strong) NETunnelProviderManager *openManager;

@property (nonatomic, strong) SOneServerModel *serverModel;


@property (nonatomic, copy, nullable) StopCompletionHandler stopConnectCompletionHandler;
@property (nonatomic, copy, nullable) ConnectCompletionHandler connectCompletionHandler;
@property (nonatomic, copy, nullable) ConnectCompletionHandler autoConnectCompletionHandler;

/// 连接状态的回调
@property (nonatomic, copy, nullable) ConnectStatusCompletionHandler statusCompletionHandler;


@property (nonatomic, strong) NSArray <SOneVPConnectModeModel *> *autoConnectModeArray;

@property (nonatomic, strong) SOneVPConnectModeModel *currentConnectModel;

/// 实际的连接模式 两种
@property (nonatomic, assign) VPConnectTunnelMode connectMode;

/// 当前连接成功所需时长
@property (nonatomic, assign) NSTimeInterval currentConnectDuration;

@property (nonatomic, strong) NSMutableArray *connectLogArray;

@end

@implementation SOneVPManage

+ (instancetype)sharedInstance {
    static SOneVPManage *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SOneVPManage alloc] init];
        
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _connectMode = [SOneVPUserDefaults intValueForKey:kConnectMode];
        [self initConfig];
        [self observerStatus];
    }
    return self;
}

- (void)initConfig {
    [self settingDefaultConfigForAutoConnect];
}

/// ikev2是否支持默认端口号
/// @param port 端口号
- (BOOL)supportIkev2WithPort:(NSString *)port {
    NSDictionary *dic = [self analyPortsWithPortStr:port];
    if ([dic.allKeys containsObject:@"udp"]) {
        NSArray *udps = dic[@"udp"];
        for (NSString *port in udps) {
            if ([port isEqualToString:@"500"]) {
                return YES;
            }
        }
    }
    
    if ([dic.allKeys containsObject:@"tcp"]) {
        NSArray *tcps = dic[@"tcp"];
        for (NSString *port in tcps) {
            if ([port isEqualToString:@"500"]) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - public
- (void)settingAutoConnectWithObj:(id)obj {
    NSArray <SOneVPConnectModeModel *> *array = [SOneVPConnectModeModel mj_objectArrayWithKeyValuesArray:obj];
    if (array.count > 0) {
        self.autoConnectModeArray = array;
    }
}

- (void)settingDefaultConfigForAutoConnect {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"AutoModeConfig" ofType:@"txt"];
    NSString *configStr = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *defaultDic = [configStr vp_toArrayOrDictionary];
    NSArray <SOneVPConnectModeModel *> *array = [SOneVPConnectModeModel mj_objectArrayWithKeyValuesArray:defaultDic[@"connectModes"]];
    self.autoConnectModeArray = array;
}

- (void)connectWithServerHost:(NSString *)host
                   openvpPort:(NSString *)openvpPort
                         mode:(VPConnectMode)mode
            completionHandler:(nullable ConnectCompletionHandler) completionHandler {
    SOneServerModel *serverModel = [[SOneServerModel alloc] init];
    serverModel.host = host;
    serverModel.oports = openvpPort;
    [self connectWithServerModel:serverModel mode:mode completionHandler:completionHandler];
}

- (void)connectWithServerModel:(SOneServerModel *)serverModel
                          mode:(VPConnectMode)mode
             completionHandler:(nullable ConnectCompletionHandler) completionHandler {
    
    __weak typeof(self) weakself = self;
    if ([self.delegate respondsToSelector:@selector(vpnFunctionEnable)]) {
        if ([self.delegate vpnFunctionEnable]) {
            self.connectCompletionHandler = nil;
            [self stopConnectWithCompletionHandler:^(BOOL stopSuccess, NEVPNStatus status, NSError * _Nullable error) {
                // 先断开
                [weakself p_stopToConnectWithServerModel:serverModel mode:mode completionHandler:completionHandler];
            }];
        } else {
            [SOneVPTool alertWithController:nil title:@"This service is not available in the region for policy reasons" comfirmTitle:@"OK" cancelTitle:nil comfirmCompletionHandler:^{
                if ([self.delegate respondsToSelector:@selector(exitAppWhenVPNNullable)] && [self.delegate exitAppWhenVPNNullable]) {
                    [SOneVPTool exitApplication];
                }
            }];
        }
    } else {
        NSAssert([self.delegate respondsToSelector:@selector(vpnFunctionEnable)], @"必须实现对应的方法 vpnFunctionEnable ，才允许上线");
    }
}

- (void)p_stopToConnectWithServerModel:(SOneServerModel *)serverModel
                                  mode:(VPConnectMode)mode
                     completionHandler:(nullable ConnectCompletionHandler) completionHandler {
    
    self.showConnectMode = mode;
    self.serverModel = serverModel;
    
    [self.connectLogArray removeAllObjects];
    if (self.showConnectMode == SOneVPConnectModeAUTO) {
        [self p_beginConnectWithServerModel:serverModel
                          connectModelArray:self.autoConnectModeArray
                               currentIndex:0
                          completionHandler:^(BOOL connectSuccess, NEVPNStatus status, NSError * _Nullable error) {
            if (status == NEVPNStatusConnected) {
                completionHandler(YES, status, error);
            } else {
                completionHandler(NO, status, error);
            }
        }];
        
    } else {
        // 手动连接
        SOneVPConnectModeModel *model = [SOneVPConnectModeModel modelWithType:self.showConnectMode];

        [self p_beginConnectWithServerModel:serverModel
                               connectModel:model
                          completionHandler:^(BOOL connectSuccess, NEVPNStatus status, NSError * _Nullable error) {
            if (status == NEVPNStatusConnected) {
                completionHandler(YES, status, error);
            } else {
                completionHandler(NO, status, error);
            }
        }];
    }
}

- (void)p_beginConnectWithServerModel:(SOneServerModel *)serverModel
                    connectModelArray:(NSArray <SOneVPConnectModeModel *> *)connectModelArray
                         currentIndex:(NSUInteger)currentIndex
                    completionHandler:(nullable ConnectCompletionHandler) completionHandler {
        
    if (currentIndex < connectModelArray.count) {
        SOneVPConnectModeModel *connectModel = connectModelArray[currentIndex];
        
        __weak typeof(self) weakself = self;
        
        self.currentConnectModel = connectModel;
        __block NSUInteger index = currentIndex;
        [self p_beginConnectWithServerModel:serverModel
                               connectModel:connectModel
                          completionHandler:^(BOOL connectSuccess, NEVPNStatus status, NSError * _Nullable error) {
            __strong typeof(self) strongself = weakself;
            if (error.code == NEVPNErrorConfigurationReadWriteFailed) {
                // 取消授权
                !completionHandler ? nil : completionHandler(NO, status, error);
                return;
            }
            
            if (status == NEVPNStatusConnected) {
                !completionHandler ? nil : completionHandler(YES, status, error);
            } else {
                index ++;
                [strongself p_beginConnectWithServerModel:serverModel
                                        connectModelArray:connectModelArray
                                             currentIndex:index
                                        completionHandler:completionHandler];
            }
        }];
    } else {
        !completionHandler ? nil : completionHandler(NO, NEVPNStatusDisconnected, nil);
    }
    
}

- (void)p_beginConnectWithServerModel:(SOneServerModel *)serverModel
                         connectModel:(SOneVPConnectModeModel * _Nullable)connectModel
                    completionHandler:(nullable ConnectCompletionHandler) completionHandler {
    // 开始连接
    [SOneVPUserDefaults saveWithInt:[[NSDate date] timeIntervalSince1970] key:kConnectDurationKey];
    __weak typeof(self) weakself = self;
    if (connectModel.mode == VPConnectTunnelModeIkev2) {
        [[SOneVPConnectDataInfo shareInstance] addIkev2WithHost:serverModel.host];
    }
    
    self.connectCompletionHandler = ^(BOOL connectSuccess, NEVPNStatus status, NSError * _Nullable error) {
        __strong typeof(self) strongself = weakself;
        
        // 连接完成,处理连接信息
        if (connectModel.mode == VPConnectTunnelModeIkev2) {
            NSDictionary *ikev2 = [[SOneVPConnectDataInfo shareInstance] endIkev2WithHost:serverModel.host success:connectSuccess];
            [strongself.connectLogArray addObject:ikev2];
        } else if (connectModel.mode == VPConnectTunnelModeOpenVP) {
            NSString *str = [SOneVPTransferManage fileContentWithFileName:SOneVPTransferManage.shareInstance.fileName.openVpnConnectInfo];
            NSArray *array = [str vp_toArrayOrDictionary];
            [strongself.connectLogArray addObjectsFromArray:array];
        }
        
        NSTimeInterval startTimeInterval = [SOneVPUserDefaults intValueForKey:kConnectDurationKey];
        NSTimeInterval endTimeInterval = [[NSDate date] timeIntervalSince1970];
        
        // 记录每次连接的数据
        weakself.currentConnectDuration = endTimeInterval - startTimeInterval;
        !completionHandler ? nil : completionHandler(connectSuccess, status, error);
    };
    
    [self configWithServerAddress:serverModel.host
                      openVpPorts:serverModel.oports
                       ikev2Ports:serverModel.tports
                     connectModel:connectModel];
}

- (void)configWithServerAddress:(NSString *)serverAddress
                    openVpPorts:(NSString *)openVpPorts
                     ikev2Ports:(NSString *)ikev2Ports
                   connectModel:(SOneVPConnectModeModel * _Nullable)connectModel {
    [SOneVPUserDefaults saveWithObj:serverAddress key:kAddressKey];
    [SOneVPUserDefaults saveWithObj:openVpPorts key:kOpenVpPortStrKey];
    [SOneVPUserDefaults saveWithObj:ikev2Ports key:kIkev2PortStrKey];
    self.connectMode = connectModel.mode;
    switch (connectModel.mode) {
        case VPConnectTunnelModeIkev2:
            [self configIKEV2WithServerAddress:serverAddress];
            break;
        case VPConnectTunnelModeOpenVP:
            [self configOpenVpWithServerAddress:serverAddress port:openVpPorts connectModel:connectModel];
            break;
    }
}

- (void)startConnectWithType:(VPConnectTunnelMode)mode {
    [self startConnectWithType:mode completionHandler:nil];
}

- (void)startConnectWithType:(VPConnectTunnelMode)mode
           completionHandler:(ConnectCompletionHandler) completionHandler {
    // 开始连接的时间戳
    switch (self.connectMode) {
        case VPConnectTunnelModeIkev2:
            [self startIKEV2WithFirst:YES];
            break;
        case VPConnectTunnelModeOpenVP:
            [self startOpenVp];
            break;
    }
}

- (void)stopConnect {
    [self stopConnectWithCompletionHandler:nil];
}

- (void)stopConnectWithCompletionHandler:(StopCompletionHandler) completionHandler {
    self.stopConnectCompletionHandler = completionHandler;
    
    if (self.ikev2Manager.connection.status == NEVPNStatusConnected
        || self.ikev2Manager.connection.status == NEVPNStatusConnecting
        || self.ikev2Manager.connection.status == NEVPNStatusDisconnecting
        || self.ikev2Manager.connection.status == NEVPNStatusReasserting
        
        || self.openManager.connection.status == NEVPNStatusDisconnecting
        || self.openManager.connection.status == NEVPNStatusConnected
        || self.openManager.connection.status == NEVPNStatusConnecting
        || self.openManager.connection.status == NEVPNStatusReasserting) {
        
        if (self.ikev2Manager.connection.status == NEVPNStatusConnected
            || self.ikev2Manager.connection.status == NEVPNStatusConnecting
            || self.ikev2Manager.connection.status == NEVPNStatusDisconnecting
            || self.ikev2Manager.connection.status == NEVPNStatusReasserting) {
            [self.ikev2Manager.connection stopVPNTunnel];
        } if (self.openManager.connection.status == NEVPNStatusDisconnecting
                   || self.openManager.connection.status == NEVPNStatusConnected
                   || self.openManager.connection.status == NEVPNStatusConnecting
                   || self.openManager.connection.status == NEVPNStatusReasserting) {
            [SOneVPTransferManage setObject:@"1" forKey:kStopConnectByApp];
            [self.openManager.connection stopVPNTunnel];
        }
    } else {
        if (self.stopConnectCompletionHandler) {
            self.stopConnectCompletionHandler(YES, NEVPNStatusDisconnected, nil);
            self.stopConnectCompletionHandler = nil;
        }
    }
}
//checkAuthorStatusWithCompletionHandler
+ (void)checkAuthorStatusWithCompletionHandler:(void (^)(BOOL isAuthor))completionHandler {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    __block BOOL isOpenVPNAuthor = NO;
    __block BOOL isIkev2Author = NO;
    
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
        for (NETunnelProviderManager *itemManager in managers) {
            if ([itemManager.localizedDescription isEqualToString:SOneAPPName]) {
                isOpenVPNAuthor = YES;
            }
        }
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    
    NEVPNManager *ikev2 = [NEVPNManager sharedManager];
    [ikev2 loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        isIkev2Author = ikev2.connection.status != NEVPNStatusInvalid;
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        completionHandler ? completionHandler(isOpenVPNAuthor || isIkev2Author) : nil;
    });
}

+ (void)authorVPNConfigWithCompletionHandler:(void (^)(BOOL isAuthor))completionHandler {
    
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
        for (NETunnelProviderManager *itemManager in managers) {
            if ([itemManager.localizedDescription isEqualToString:SOneAPPName]) {
                !completionHandler ? : completionHandler(YES);
                return;
            }
        }
        
        NETunnelProviderManager *manager = [[NETunnelProviderManager alloc] init];
        NETunnelProviderProtocol *tunel = [[NETunnelProviderProtocol alloc] init];
        
        NSAssert([SOneVPManage sharedInstance].providerBundleIdentifier, @"属性providerBundleIdentifier不能为空，请用 PacketTunnel BundleId 赋值");
        tunel.providerBundleIdentifier = [SOneVPManage sharedInstance].providerBundleIdentifier;
        
        tunel.serverAddress = SOneAPPName;
        
        tunel.disconnectOnSleep = NO;
        
        [manager setProtocolConfiguration:tunel];
        [manager setEnabled:YES];
        manager.localizedDescription = SOneAPPName;
        manager.onDemandEnabled = YES;
        
        [manager saveToPreferencesWithCompletionHandler:^(NSError *error) {
            if (error.code == NEVPNErrorConfigurationReadWriteFailed || error.code == NEVPNErrorConfigurationInvalid) {
                // 取消授权
                !completionHandler ? : completionHandler(NO);
            } else {
                !completionHandler ? : completionHandler(YES);
            }
        }];
    }];
}

#pragma mark - 网络状态
- (void)observerStatus {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVpnStateChange:)
                                                 name:NEVPNStatusDidChangeNotification
                                               object:nil];
}

- (void)getConnectStatusWithCompletionHandler:(nullable ConnectStatusCompletionHandler)completionHandler {
    
    __weak typeof(self) weakself = self;
    self.statusCompletionHandler = completionHandler;
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    
    /// 查看VPN状态的值
    self.checkStatus = NEVPNStatusDisconnected;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // openvpn
        [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
            
            for (NETunnelProviderManager *itemManager in managers) {
                if ([itemManager.localizedDescription isEqualToString:SOneAPPName]) {
                    self.openManager = itemManager;
                    continue;
                }
            }
            if (!self.openManager) {
                self.openManager = [[NETunnelProviderManager alloc] init];
            }
            
            NEVPNStatus currentstatus = self.openManager.connection.status;
            if (self.statusCompletionHandler &&
                (currentstatus == NEVPNStatusConnected
                 || currentstatus == NEVPNStatusConnecting
                 || currentstatus == NEVPNStatusDisconnecting)) {
                weakself.checkStatus = currentstatus;
            }
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // ikev2
        weakself.ikev2Manager = [NEVPNManager sharedManager];
        [weakself.ikev2Manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
            NEVPNStatus currentstatus = self.ikev2Manager.connection.status;
            if (self.statusCompletionHandler &&
                (currentstatus == NEVPNStatusConnected
                 || currentstatus == NEVPNStatusConnecting
                 || currentstatus == NEVPNStatusDisconnecting)) {
                weakself.checkStatus = currentstatus;
            }
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (self.statusCompletionHandler) {
            weakself.showConnectMode = [SOneVPUserDefaults intValueForKey:kShowConnectMode];
            weakself.status = weakself.checkStatus;
            !weakself.statusCompletionHandler ? nil: weakself.statusCompletionHandler(weakself.status, weakself.showConnectMode);
            weakself.statusCompletionHandler = nil;
        }
    });
}

#pragma mark - 外部参数
- (NSString *)currentConnectPortForOpenVP {
    if (self.connectMode == VPConnectTunnelModeOpenVP) {
        NSString *port = [SOneVPTransferManage objectForKey:@"serverPort"];
        return port.length > 0 ? port : @"";
    }
    return @"";
}

- (OpenVPProtocolType)currentConnectProtoForOpenVP {
    if (self.connectMode == VPConnectTunnelModeOpenVP) {
        NSString *proto = [SOneVPTransferManage objectForKey:@"serverProto"];
        if ([proto.lowercaseString containsString:@"udp"]) {
            return OpenVPProtocolTypeUDP;
        } else if ([proto.lowercaseString containsString:@"tcp"]) {
            return OpenVPProtocolTypeTCP;
        }
        return 0;
    } else {
        return 0;
    }
}

- (NSString *)startModeName {
    switch (self.connectMode) {
        case VPConnectTunnelModeIkev2:
            return @"ikev";
            break;
        case VPConnectTunnelModeOpenVP:
            return @"openvp";
    }
}

/// 实际连接的协议
- (VPConnectMode)connectModeForTunnel {
    switch (self.connectMode) {
        case VPConnectTunnelModeIkev2:
            return SOneVPConnectModeIKEV2;
        case VPConnectTunnelModeOpenVP:
        {
            NSString *proto = [SOneVPTransferManage objectForKey:@"serverProto"];
            if ([proto.lowercaseString containsString:@"udp"]) {
                return SOneVPConnectModeOPENVPN_UDP;
            } else if ([proto.lowercaseString containsString:@"tcp"]) {
                return SOneVPConnectModeOPENVPN_TCP;
            }
        }
    }
    return SOneVPConnectModeUNKNOWN;
}

- (NSTimeInterval)currentConnectDuration {
    return _currentConnectDuration;
}

- (NSArray *)connectInfo {
    return self.connectLogArray;
}

#pragma mark - 监听VP状态
- (void)onVpnStateChange:(NSNotification *)notification {
    if ([[notification.object class] isSubclassOfClass:[NEVPNConnection class]]) {
        NEVPNConnection *connection = notification.object;
        NEVPNStatus status = connection.status;
        if (connection.connectedDate) {
            self.connectedDate = connection.connectedDate;
        }
        
        NSString *str = NEVPNStatusString(status);
        log4cplus_info("测试", " %s", str.UTF8String);
        
        NSString *connectName;
        if ([[notification.object class] isSubclassOfClass:[NETunnelProviderSession class]]) {
            // openvpn
            connectName = @"openvpn";
            if (_connectMode == VPConnectTunnelModeIkev2) {
                return;
            }
        } else {
            // ikev2
            connectName = @"ikev2";
            if (_connectMode != VPConnectTunnelModeIkev2) {
                return;
            }
        }
        
        if (status == self.status) {
            return;
        }
        
        if (self.statusCompletionHandler) {
            self.showConnectMode = [SOneVPUserDefaults intValueForKey:kShowConnectMode];
            self.statusCompletionHandler(status, self.showConnectMode);
        }
    
        [self dealWithStatus:status];
        // 打印
        NSString *connetType;
        switch (self.connectMode) {
            case VPConnectTunnelModeIkev2:
                connetType = @"ikev2";
                break;
            case VPConnectTunnelModeOpenVP:
                connetType = @"openvpn";
                break;
        }
        
        NSString *connectStatus = NEVPNStatusString(status);
        DebugLog(@"%@ %@ %@ ==== ", connectName, connetType, connectStatus)
        log4cplus_info("PacketTunnelProvider", "vpn status === %s", connectStatus.UTF8String);
    }
}

- (void)dealWithStatus:(NEVPNStatus)status {
    // 更新状态变量
    switch (status) {
        case NEVPNStatusInvalid:
            break;
        case NEVPNStatusDisconnected:
            // 断开连接的回调
            if (self.stopConnectCompletionHandler) {
                _status = status;
                self.stopConnectCompletionHandler(YES, _status, nil);
                self.stopConnectCompletionHandler = nil;
            } else if (self.connectCompletionHandler) {
                // 判断上次的状态
                if (self.status == NEVPNStatusDisconnecting) {
                    // 上一次的状态是 NEVPNStatusDisconnecting
                    _status = status;
                    if (self.connectCompletionHandler) {
                        self.connectCompletionHandler(NO, status, nil);
                    }
                }
            } else {
                _status = status;
                [[NSNotificationCenter defaultCenter] postNotificationName:VPNotificationNameVpConnectDidChange object:@(_status)];
            }
            break;
        case NEVPNStatusConnecting:
        case NEVPNStatusReasserting:
            break;
        case NEVPNStatusConnected:
            // 第一次开启广告之前
            [SOneVPUserDefaults saveWithInt:1 key:kCompletedVPNAuthorizedKey];
            // 连接成功的时间戳
            _status = status;
            if (self.connectCompletionHandler) {
                self.connectCompletionHandler(YES, _status, nil);
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:VPNotificationNameVpConnectDidChange object:@(_status)];
            }
            break;
        case NEVPNStatusDisconnecting:
            break;
        default:
            break;
    }
    _status = status;
    if ([self.delegate respondsToSelector:@selector(vpnManagerStatus:)]) {
        [self.delegate vpnManagerStatus:status];
    }
}

#pragma mark - openvp
- (void)configOpenVpWithServerAddress:(NSString *)serverAddress
                                 port:(NSString *)port
                         connectModel:(SOneVPConnectModeModel * _Nullable)connectModel {
    // 重新生成文件
    [self updateFileWithServerAddress:serverAddress port:port connectModel:connectModel];
    
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
        if(error){
            // 取消授权
            if (self.connectCompletionHandler) {
                self.connectCompletionHandler(NO, self.status, error);
            }
            return;
        }
        for (NETunnelProviderManager *itemManager in managers) {
            if ([itemManager.localizedDescription isEqualToString:SOneAPPName]) {
                self.openManager = itemManager;
                continue;
            }
        }
        if (!self.openManager) {
            self.openManager = [[NETunnelProviderManager alloc] init];
        }
        
        NETunnelProviderProtocol *tunel = [[NETunnelProviderProtocol alloc] init];
        NSData *data = [self readOpenVpConfig];
        if (data) {
            tunel.providerConfiguration = @{@"ovpn": data};
        } else {
            if (self.connectCompletionHandler) {
                self.connectCompletionHandler(NO, self.status, error);
            }
            return;
        }
        
        NSAssert(self.providerBundleIdentifier, @"属性providerBundleIdentifier不能为空，请用 PacketTunnel BundleId 赋值");
        tunel.providerBundleIdentifier = self.providerBundleIdentifier;
        
        tunel.serverAddress = SOneAPPName;
        NSAssert(tunel.serverAddress.length > 0, @"为了VPN正常连接，请配置应用名称(dispaly Name)");
        
        tunel.disconnectOnSleep = NO;
        tunel.proxySettings.exceptionList = @[@""];
        
        
        [self.openManager setProtocolConfiguration:tunel];
        [self.openManager setEnabled:YES];
        self.openManager.localizedDescription = SOneAPPName;
        self.openManager.onDemandEnabled = YES;
        
        [self.openManager saveToPreferencesWithCompletionHandler:^(NSError *error) {
            if(error) {
                DebugLog(@"Save error: %@", error);
                if (error.code == NEVPNErrorConfigurationReadWriteFailed) {
                    // 取消授权
                    if (self.connectCompletionHandler) {
                        self.connectCompletionHandler(NO, self.status, error);
                    }
                } else {
                    [self dealErrorWithOpenVpnManager];
                }
            } else {
                [self startConnectWithType:self.connectMode];
            }
        }];
    }];
    
}

- (void)dealErrorWithOpenVpnManager {
    
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
        if(error){
            // 取消授权
            if (self.connectCompletionHandler) {
                self.connectCompletionHandler(NO, self.status, error);
            }
            return;
        }
        for (NETunnelProviderManager *itemManager in managers) {
            if ([itemManager.localizedDescription isEqualToString:SOneAPPName]) {
                self.openManager = itemManager;
                continue;
            }
        }
        
        [self.openManager saveToPreferencesWithCompletionHandler:^(NSError *error) {
            if(error) {
                DebugLog(@"Save error: %@", error);
                if (self.connectCompletionHandler) {
                    self.connectCompletionHandler(NO, self.status, error);
                }
            } else {
                [self startConnectWithType:self.connectMode];
            }
        }];
    }];
}

- (void)startOpenVp {
    [self.openManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if(!error){
            NSError *startError = nil;
            [SOneVPTransferManage setObject:@"1" forKey:kStartConnectByApp];

            [self.openManager.connection startVPNTunnelAndReturnError:&startError];
            if(startError) {
                if (self.connectCompletionHandler) {
                    self.connectCompletionHandler(NO, self.openManager.connection.status, startError);
                }
                DebugLog(@"Start error: %@", startError.localizedDescription);
            }
        }
    }];
}

/**
 移除配置
 */
- (void)removePreferences {
    [self.ikev2Manager removeFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}

#pragma mark - ikev2
- (void)configIKEV2WithServerAddress:(NSString *)serverAddress {
    
    [[NEVPNManager sharedManager] loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if(error) {
            DebugLog(@"Load error: %@", error);
            // 取消授权
            if (self.connectCompletionHandler) {
                self.connectCompletionHandler(NO, self.status, error);
            }
        } else {
            NEVPNProtocolIKEv2* ikev = [[NEVPNProtocolIKEv2 alloc] init];
            
            ikev.serverAddress = serverAddress;
            ikev.username = [SOneCertManage shareInstance].certModel.account;
            
            ikev.remoteIdentifier = [SOneCertManage shareInstance].certModel.remoteIdentifier;
            ikev.localIdentifier = SOneAPPName;
            
            
            
            NSString *kPasswordKey = [NSString stringWithFormat:@"%@%@", SOneAPPName, [SOneCertManage shareInstance].certModel.password];
            
            if (!ikev.passwordReference) {
                [NSData createKeychainValue:[SOneCertManage shareInstance].certModel.password forIdentifier:kPasswordKey];
                ikev.passwordReference = [NSData searchKeychainCopyMatching:kPasswordKey];
            }
            
            ikev.useExtendedAuthentication = YES;
            ikev.disconnectOnSleep = NO;
            
            if (!self.ikev2Manager) {
                self.ikev2Manager = [NEVPNManager sharedManager];
            }
            [self.ikev2Manager setEnabled:YES];
            
            self.ikev2Manager.protocolConfiguration = ikev;
            [self.ikev2Manager setLocalizedDescription:SOneAPPName];
            
            [self.ikev2Manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                if(error) {
                    if (error.code == NEVPNErrorConfigurationReadWriteFailed) {
                        // 取消授权
                        if (self.connectCompletionHandler) {
                            self.connectCompletionHandler(NO, self.status, error);
                        }
                    } else {
                        [self gotoIkev2Manager];
                    }
                    DebugLog(@"Save error: %@", error);
                } else {
                    [self startConnectWithType:self.connectMode];
                }
            }];
        }
        
    }];

}

- (void)gotoIkev2Manager {
    [[NEVPNManager sharedManager] loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
       if(error) {
           DebugLog(@"Load error: %@", error);
       } else {
           if (!self.ikev2Manager) {
               self.ikev2Manager = [NEVPNManager sharedManager];
           }
           
           [self.ikev2Manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
               if(error) {
                   // 取消授权
                   if (self.connectCompletionHandler) {
                       self.connectCompletionHandler(NO, self.status, error);
                   }
                   DebugLog(@"Save error: %@", error);
               } else {
                   [self startConnectWithType:self.connectMode];
               }
           }];
       }
    }];
}

- (void)startIKEV2WithFirst:(BOOL)isFirst {
    [self.ikev2Manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            return;
        }
        NSError *connectionError;
        [[self.ikev2Manager connection] startVPNTunnelAndReturnError:&connectionError];
        
        if (connectionError) {
            if (connectionError.code == NEVPNErrorConfigurationInvalid) {
                DebugLog(@"NEVPNErrorConfigurationInvalid")
                if (isFirst) {
                    [self startIKEV2WithFirst:NO];
                    return;
                }
            } else if (connectionError.code == NEVPNErrorConfigurationDisabled) {
                DebugLog(@"NEVPNErrorConfigurationDisabled")
            }
            if (self.connectCompletionHandler) {
                self.connectCompletionHandler(NO, self.ikev2Manager.connection.status, connectionError);
            }
                        
        }
    }];
}

#pragma mark - .ovpn 文件修改
- (BOOL)updateFileWithServerAddress:(NSString *)serverAddress
                               port:(NSString *)port
                       connectModel:(SOneVPConnectModeModel * _Nullable)connectModel {
    
    NSString *fileContent = [SOneCertManage shareInstance].certModel.openvpCert;
    if (fileContent.length > 0) {
        // 解析端口数据
        NSDictionary *dic = [self analyPortsWithPortStr:port];
        // 拼接配置信息
        NSString *configStr = [self configFileContentWithServerAddress:serverAddress dic:dic connectModel:connectModel];
        fileContent = [fileContent stringByAppendingString:configStr];
        // 写入文件到沙盒
        [self writeConfigWithFileContent:fileContent];
        
        return YES;
    } else {
        return NO;
    }
}

/// 解析端口号
/// @param ports ports description
- (NSDictionary *)analyPortsWithPortStr:(NSString *)ports {
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    if (ports) {
        NSArray *array = [ports componentsSeparatedByString:@","];
        NSMutableArray *tcpPorts = [[NSMutableArray alloc] init];
        NSMutableArray *udpPorts = [[NSMutableArray alloc] init];
        
        for (NSString *itemStr in array) {
            NSArray *ports = [itemStr componentsSeparatedByString:@":"];
            if ([ports.firstObject isEqualToString:@"tcp"]) {
                [tcpPorts addObject:ports.lastObject];
            } else if ([ports.firstObject isEqualToString:@"udp"]) {
                [udpPorts addObject:ports.lastObject];
            }
        }
        
        [resultDic setObject:tcpPorts forKey:@"tcp"];
        [resultDic setObject:udpPorts forKey:@"udp"];
    }
    return resultDic.copy;
}

- (NSArray *)portsWithPortStr:(NSString *)portStr key:(NSString *)key {
    if (portStr) {
        NSArray *array = [portStr componentsSeparatedByString:@","];
        NSMutableArray *portItems = [[NSMutableArray alloc] init];
        for (NSString *itemStr in array) {
            NSArray *str = [itemStr componentsSeparatedByString:@":"];
            if ([[str.firstObject uppercaseString] isEqualToString:key.uppercaseString]) {
                [portItems addObject:str.lastObject];
            }
        }
        return portItems;
    }
    return nil;
}

- (NSString *)configFileContentWithServerAddress:(NSString *)serverAddress
                                             dic:(NSDictionary *)dic
                                    connectModel:(SOneVPConnectModeModel * _Nullable)connectModel {
    __block NSString *openVPConfig = @"";
    
    if (connectModel.configs.count > 0) {
        [connectModel.configs enumerateObjectsUsingBlock:^(VPConnectModeConfigsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *ports = @(obj.port).stringValue;
            NSString *type = obj.type == OpenVPProtocolTypeTCP ? @"tcp":@"udp";

            if (obj.port == 0) {
                // 没有指定端口号，处理所有端口
                NSArray *tcpPortArray = dic[type];
                NSMutableArray <NSString *>*configStrArray = [[NSMutableArray alloc] init];
                
                for (NSString *port in tcpPortArray) {
                    NSString *configStr = [self insertContentWithServerAddress:serverAddress port:port type:type];
                    [configStrArray addObject:configStr];
                }
                
                // 这里加个随机
                NSArray *resultArray = [configStrArray sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
                    int seed = arc4random_uniform(2);
                    if (seed) {
                        return [obj1 compare:obj2];
                    } else {
                        return [obj2 compare:obj1];
                    }
                }];
                
                
                // 拼接
                [resultArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    openVPConfig = [openVPConfig stringByAppendingString:obj];
                }];
                
            } else if ([dic[type] containsObject:ports]) {
                NSString *configStr = [self insertContentWithServerAddress:serverAddress
                                                                      port:ports
                                                                      type:type];
                openVPConfig = [openVPConfig stringByAppendingString:configStr];
            } else {
                DebugLog(@"%@", ports)
            }
            
        }];
    } else {
        // 处理所有端口
        NSArray *tcpPortArray = dic[@"tcp"];
        NSMutableArray <NSString *>*configStrArray = [[NSMutableArray alloc] init];
        for (NSString *port in tcpPortArray) {
            NSString *configStr = [self insertContentWithServerAddress:serverAddress port:port type:@"tcp"];
            [configStrArray addObject:configStr];
        }
        
        NSArray *udpPortArray = dic[@"udp"];
        for (NSString *port in udpPortArray) {
            NSString *configStr = [self insertContentWithServerAddress:serverAddress port:port type:@"udp"];
            [configStrArray addObject:configStr];
        }
        // 这里加个随机
        NSArray *resultArray = [configStrArray sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
            int seed = arc4random_uniform(2);
            if (seed) {
                return [obj1 compare:obj2];
            } else {
                return [obj2 compare:obj1];
            }
        }];
        
        [resultArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            openVPConfig = [openVPConfig stringByAppendingString:obj];
        }];
    }
    return openVPConfig;
}

- (NSString *)insertContentWithServerAddress:(NSString *)serverAddress
                                        port:(NSString *)port
                                        type:(NSString *)type {
    NSString *insertStr = @"";
    insertStr = [insertStr stringByAppendingString:@"\n<connection>\n"];
    insertStr = [insertStr stringByAppendingFormat:@"remote %@ %@ %@\n", serverAddress, port, type];
    insertStr = [insertStr stringByAppendingString:@"connect-timeout 5\n connect-retry 0\n</connection>"];
    return insertStr;
}

// 获取模板
- (NSString *)readFileTemplateWithFileName:(NSString *)fileName
                                 extension:(NSString *)extension {
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:fileName withExtension:extension];
    NSData *fileData = [[NSData alloc] initWithContentsOfURL:fileUrl];
    fileData = [NSString vp_decryptAES:fileData];
    NSString *fileContent = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    return fileContent;
}

static NSString *sandboxOpenVP = @"sandboxopen.vp";
// 拼接存储
- (void)writeConfigWithFileContent:(NSString *)fileContent {
    // 存到沙盒
    [[SOneVPTool shareInstance] Encrypt_writeDataWithFileContent:fileContent fileName:sandboxOpenVP];
}

- (NSData *)readOpenVpConfig {
    
    NSData *data = [NSData dataWithContentsOfFile:[[SOneVPTool shareInstance] filePathWithFileName:sandboxOpenVP]];
    data = [NSString vp_decryptAES:data];
    
#ifdef DEBUG
    NSString *certStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", certStr);
#endif
    
    return data;
}

#pragma mark - lazy
- (NEVPNManager *)ikev2Manager {
    return _ikev2Manager;
}

- (void)setConnectMode:(VPConnectTunnelMode)connectMode {
    _connectMode = connectMode;
    [SOneVPUserDefaults saveWithInt:_connectMode key:kConnectMode];
}

- (NSMutableArray *)connectLogArray {
    if (!_connectLogArray) {
        _connectLogArray = [[NSMutableArray alloc] init];
    }
    return _connectLogArray;
}

@end
