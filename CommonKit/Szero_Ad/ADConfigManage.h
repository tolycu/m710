//
//  ADConfigManage.h
//  startvpn
//
//  Created by 李光尧 on 2020/12/9.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "ADConfigModel.h"
#import "ADConfigSetting.h"

#define AD_MANAGE ([ADManage sharedInstance])

NS_ASSUME_NONNULL_BEGIN

@interface ADConfigManage : NSObject

@property(nonatomic,strong) ADConfigModel *configModel; //广告配置

@end


@interface ADManage : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic,strong) NSMutableArray<ADConfigManage *> *adConfigs;

- (void)resetADConfigManage;


@end

NS_ASSUME_NONNULL_END
