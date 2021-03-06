//
//  SportAppConfig.h
//  sportqr
//
//  Created by Hoho Wu on 2022/3/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define APP_CONFIG ([SportAppConfig sharedInstance])

@interface SportAppConfig : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic,strong, nullable) NSString *cacheStr;
@property(nonatomic,assign) BOOL isLoadCamera;
@property(nonatomic,assign) BOOL isShowSetting; //是否展示设置界面
@property(nonatomic,strong) UIViewController *homeController;

/**
 服务器列表请求时间
 */
@property(nonatomic,strong) NSString *loadVpTime;
//@property(nonatomic,strong) NSMutableArray<ServerVpnModel *> *servers;  /** 免费VPN */
//@property(nonatomic,strong) NSMutableArray<ServerVpnModel *> *pro_servers;  /** 付费VPN */
@property(nonatomic,strong) NSString *country_short;//中国区限制
@property(nonatomic,assign) NEVPNStatus status;   //当前vpn状态

@end


@interface SportAppConfig (UserInfo)

- (NSString *)getDeviceIMSI;
- (NSString *)getDeviceISOCountryCode;

- (void)changeVpnStatue:(NEVPNStatus)status;

@end 

NS_ASSUME_NONNULL_END
