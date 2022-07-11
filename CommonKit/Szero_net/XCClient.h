//
//  XCClient.h
//  startvpn
//
//  Created by 李光尧 on 2020/11/18.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^statusHandler)(BOOL status);
typedef void (^completionHandler)(BOOL success, NSError *_Nullable error);
// 网络请求结果
typedef void(^CallBackHandler)(id _Nullable dataModel , NSError * _Nullable error);

#define XC_CLIENT ([XCClient sharedInstance])

@interface XCClient : NSObject

+ (instancetype)sharedInstance;

- (void)get:(NSString *)api
     params:(id _Nullable)params
    success:(void(^)(id response))success
    failure:(void(^)(NSError *error))failure;

- (void)post:(NSString *)api
      params:(id _Nullable)params
     success:(void(^)(id response))success
     failure:(void(^)(NSError *error))failure;


+ (void)requestBaseWithUrl:(NSString *)url
                    method:(NSString *)method
                      body:(NSData *)postData
           timeoutInterval:(NSTimeInterval)timeoutInterval
           callBackHandler:(CallBackHandler)callBackHandler;

@end

NS_ASSUME_NONNULL_END
