//
//  Szero_GlobalConfigModel.h
//  sportqr
//
//  Created by Hoho Wu on 2022/3/6.
//

#import <Foundation/Foundation.h>
#import "ADConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Szero_GlobalConfigModel : NSObject

@property(nonatomic,assign) long IStartPageTime;   //启动时长
@property(nonatomic,strong) NSArray<ADConfigModel *> *adCfgs;  //广告配置

@property(nonatomic,assign) BOOL IExtraAd;             //额外广告开关
@property(nonatomic,assign) BOOL ViewHistoryAllowAds;  //
@property(nonatomic,assign) BOOL EntryCreateQrAllowAds;
@property(nonatomic,assign) NSInteger NativeDianJiLimit;
@property(nonatomic,assign) NSInteger BannerDianJiLimit;

@property(nonatomic,strong) NSString *PreCountry;
@property(nonatomic,strong) NSDictionary *connectModes;
@property(nonatomic,assign) long GlobalGetGap;
@property(nonatomic,assign) long MaxConnectTime;

@end

NS_ASSUME_NONNULL_END
//[1]    (null)    @"IExtraAd" : YES
//[2]    (null)    @"NativeDianJiLimit" : (long)1
//[3]    (null)    @"connectModes" : @"3 elements"
//[4]    (null)    @"IStartPageTime" : (long)10
//[5]    (null)    @"ViewHistoryAllowAds" : YES
//[6]    (null)    @"EntryCreateQrAllowAds" : YES
//[7]    (null)    @"PreCountry" : @"UK、AD"
//[8]    (null)    @"GlobalGetGap" : (long)1
//[9]    (null)    @"BannerDianJiLimit" : (long)1
//[10]    (null)    @"MaxConnectTime" : (long)1
