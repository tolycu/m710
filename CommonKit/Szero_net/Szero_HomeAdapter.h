//
//  Szero_HomeAdapter.h
//  startvpn
//
//  Created by 李光尧 on 2020/12/7.
//

#import <Foundation/Foundation.h>
#import "Szero_GlobalConfigModel.h"
#import "Szero_ServerVPNModel.h"

NS_ASSUME_NONNULL_BEGIN

#define Adapter_MANAGE ([Szero_HomeAdapter sharedInstance])

@interface Szero_HomeAdapter : NSObject

@property(nonatomic,assign) long expert_certVer;
@property(nonatomic,strong) NSString *expert_certUrl;

//限制国家
@property(nonatomic,strong) NSString *country_short;

// 全局配置
@property(nonatomic,strong) Szero_GlobalConfigModel *globalModel;
// vps列表
@property(nonatomic,strong) NSArray<Szero_ServerVPNModel *> *servers;

+ (instancetype)sharedInstance;

- (void)getConfigWithCompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler;

- (void)getVpnListWithCompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler;

- (void)getAppPostionInfoWithCompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler;



@end

NS_ASSUME_NONNULL_END

