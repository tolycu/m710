//
//  HomeAdapter.h
//  startvpn
//
//  Created by 李光尧 on 2020/12/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define Adapter_MANAGE ([HomeAdapter sharedInstance])

@interface HomeAdapter : NSObject

@property(nonatomic,assign) long expert_certVer;
@property(nonatomic,strong) NSString *expert_certUrl;


//最优服务器
@property(nonatomic,strong) Expert_ServerVPNModel *bestServer;
- (void)changeBestServer:(Expert_ServerVPNModel *)server;

//限制国家
@property(nonatomic,strong) NSString *country_short;
//全部所有国家
@property(nonatomic,strong) NSArray<Expert_ServerVPNModel *> *servers;
// 全局配置
@property(nonatomic,strong) Expert_GlobalConfigModel *globalModel;


+ (instancetype)sharedInstance;

- (void)getConfigWithCompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler;

- (void)getVpnListWithCompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler;


- (void)getVpnCerWithParams:(NSDictionary *)params  CompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler;

- (void)getAppPostionInfoWithCompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler;

/**  上传服务器ping值 */
- (void)upLoadServersPingWithParams:(NSArray *)params CompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler;

//上报当前服务器连接状态
- (void)uploadCurrentServersStatusWithModel:(Expert_ServerVPNModel *)connectModel
                               connectInfos:(NSArray *)connectInfos
                          CompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler;


+ (void)pingVPNServers:(NSArray <Expert_ServerVPNModel *> *)vpnList WithCompletionHandler:(void(^)(void))completionHandler;
+ (Expert_ServerVPNModel *)getBestVpnFrom:(NSArray <Expert_ServerVPNModel *>*)list;

@end

NS_ASSUME_NONNULL_END

