

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>
#import "SOneVPConnectModeModel.h"
#import "SOneServerModel.h"
#import "SOneVPMacros.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *kAddressKey = @"kAddressKey";
static NSString *kOpenVpPortStrKey = @"kOpenVpPortStrKey";
static NSString *kIkev2PortStrKey = @"kIkev2PortStrKey";
static NSString *kModeKey = @"kModeKey";

static NSString *kShowConnectMode = @"kShowConnectMode";
static NSString *kConnectMode = @"kConnectMode";

static NSString *kCompletedVPNAuthorizedKey = @"kCompletedVPNAuthorizedKey";



static NSString *const VPNotificationNameVpConnectDidChange = @"VPNotificationNameVpConnectDidChange";

#define NEVPNStatusString(enum) [@[\
@"NEVPNStatusInvalid",\
@"NEVPNStatusDisconnected",\
@"NEVPNStatusConnecting",\
@"NEVPNStatusConnected",\
@"NEVPNStatusReasserting",\
@"NEVPNStatusDisconnecting"] objectAtIndex:enum]



typedef void(^ConnectCompletionHandler)(BOOL connectSuccess, NEVPNStatus status, NSError * _Nullable error);
typedef void(^StopCompletionHandler)(BOOL stopSuccess,  NEVPNStatus status, NSError * _Nullable error);
typedef void(^ConnectStatusCompletionHandler)(NEVPNStatus status, VPConnectMode mode);


@class SOneVPConnectModeModel;
@protocol SOneVPManageDelegate <NSObject>

@required
- (void)vpnManagerStatus:(NEVPNStatus)status;

// vpn 功能是否可用 vip或者当前地区政策不允许
- (BOOL)vpnFunctionEnable;

/// 当政策原因，VPN不可用事，是否退出APP
- (BOOL)exitAppWhenVPNNullable;
@end

@class SOneServerModel;
@interface SOneVPManage : NSObject

+ (instancetype)sharedInstance;

#pragma mark - 初始化设置
// openvpn bundleIdentifier
@property (nonatomic, strong) NSString *providerBundleIdentifier;

/// 代理
@property (nonatomic, weak) id<SOneVPManageDelegate> delegate;

#pragma mark - 连接信息
/// 连接状态
@property (nonatomic, assign) NEVPNStatus status;
// 连接成功的时间点
@property (nonatomic, strong) NSDate *connectedDate;
/// 连接方式
@property (nonatomic, assign) VPConnectMode showConnectMode;

#pragma mark - 外部可用参数
/// 用于统计的连接信息 上报数据
- (NSArray *)connectInfo;

/// 当前连接端口号
- (NSString *)currentConnectPortForOpenVP;

- (OpenVPProtocolType)currentConnectProtoForOpenVP;

/// 实际连接的协议
- (VPConnectMode)connectModeForTunnel;

/// 当前连接耗时
- (NSTimeInterval)currentConnectDuration;

// 连接模式
- (NSString *)startModeName;

#pragma mark - 配置
- (void)settingAutoConnectWithObj:(id)obj;

#pragma mark - vpn操作相关
- (void)connectWithServerHost:(NSString *)host
                   openvpPort:(NSString *)openvpPort
                         mode:(VPConnectMode)mode
            completionHandler:(nullable ConnectCompletionHandler) completionHandler;

- (void)connectWithServerModel:(SOneServerModel *)serverModel
                          mode:(VPConnectMode)mode
             completionHandler:(nullable ConnectCompletionHandler) completionHandler;

/// 断开
- (void)stopConnect;
- (void)stopConnectWithCompletionHandler:(nullable StopCompletionHandler) completionHandler;

/// 获取连接状态
/// @param completionHandler 回调
- (void)getConnectStatusWithCompletionHandler:(nullable ConnectStatusCompletionHandler) completionHandler;

/// 检查VPN是否已经授权
/// @param completionHandler 回调
+ (void)checkAuthorStatusWithCompletionHandler:(void (^)(BOOL isAuthor))completionHandler;

/// 授权VPN权限
/// @param completionHandler 回调
+ (void)authorVPNConfigWithCompletionHandler:(void (^)(BOOL isAuthor))completionHandler;

#pragma mark - other
/// 端口号是否支持ikev2 500 4500， 以前用到的
/// @param port 端口字符串
- (BOOL)supportIkev2WithPort:(NSString *)port;
/// 初始化本地配置
- (void)initConfig;


@end

NS_ASSUME_NONNULL_END
