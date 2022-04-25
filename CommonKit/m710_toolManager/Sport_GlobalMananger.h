//
//  Sport_GlobalMananger.h
//  camera
//
//  Created by 李光尧 on 2021/12/27.
//

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>
#import "AFNetworking.h"
#import "Sport_CardModel.h"
#import "XCWebViewController.h"
NS_ASSUME_NONNULL_BEGIN

#define TOOL_MANAGE ([Sport_GlobalMananger sharedInstance])

@interface Sport_GlobalMananger : NSObject


+ (instancetype)sharedInstance;

@property(nonatomic,assign) NEVPNStatus status;   //当前vpn状态
- (void)changeVpnStatue:(NEVPNStatus)status;

/**
 验证 电话号码
 */
+ (BOOL)deptNumInputShouldNumber:(NSString *)string;

/**
 是否是有效的条形码
 */
+ (BOOL)isBarCodeNumText:(NSString *)str;

/**
 返回扫码类型
 */
+ (DataStringQRType)qrDataAnalysisType:(NSString *)string;
+ (NSString *)creatHistoryImageString:(DataStringQRType)type;
+ (NSString *)creatTypeString:(DataStringQRType)type;

- (void)saveScan:(NSString *)stringValue;
- (void)saveCreat:(NSString *)stringValue;
/**
 是否是iPad
 */
+ (BOOL)checkoutDeviceIsiPad;

/** 分享 */
- (void)startShare;
- (void)startShareString:(NSString *)string;
- (void)startShareImage:(UIImage *)image;

/**
 联系人
 */
- (void)saveMeCardNewContact:(NSString *)string;
- (void)saveVCardNewContact:(NSString *)string;


/** 请求参数 */
- (NSString *)getDeviceIMSI;
- (NSString *)getDeviceISOCountryCode;

/** 获取aid */
- (NSString *)getDeviceIDInKeychain;

//弹出权限
- (void)showAlterToPrivacy:(NSString *)title;

/** 发送邮件 */
- (void)sendEmail;
- (void)sendEmailAddress:(NSString *)address;

- (void)isCanVisitPhotoLibrary:(void(^)(BOOL isAllow))result;

/** 获取广告跟踪权限 */
+ (void)checkoutAdPrivacy:(nullable void(^)(BOOL allow))result;

/** 实现渐变色 */
- (CAGradientLayer *)setGradualChangingColor:(UIView *)view fromColor:(UIColor *)fromHexColorStr toColor:(UIColor *)toHexColorStr;


- (void)pushHideTabbarController:(UIViewController *)controller;

/**
 发送短信
 */
- (void)sendSMS:(NSString *)string;


/**
 选择购物平台
 */
- (void)showSelectPlatform:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
