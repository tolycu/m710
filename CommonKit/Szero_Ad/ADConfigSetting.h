//
//  ADConfigSetting.h
//  scanqr
//
//  Created by 李光尧 on 2021/3/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADConfigSetting : NSObject

/**
 广告类型
 */
+ (ADDataType)getLoadADtype:(NSString *)type;



/**
 广告位 是否能展示广告
 */
+ (BOOL)isLimitShowADWithAllowForkey:(NSString *)key;

/**
 点击 广告位
 */
+ (void)clickADWithAddLimitForkey:(NSString *)key;

/**
 展示广告
 */
+ (ADConfigModel *)filterADPosition:(ADPositionType)type;


@end

NS_ASSUME_NONNULL_END
