

#import <Foundation/Foundation.h>

@import OpenVPNAdapter;

NS_ASSUME_NONNULL_BEGIN



@interface SOneVPConnectDataInfo : NSObject

+ (instancetype)shareInstance;
- (void)addItemWithMessage:(NSString *)message;
- (void)addItemWithEvent:(OpenVPNAdapterEvent)event;

- (void)addIkev2WithHost:(NSString *)host;
- (NSDictionary *)endIkev2WithHost:(NSString *)host
                           success:(BOOL)success;

- (NSDictionary *)ikev2ConnectInfo;

@end

NS_ASSUME_NONNULL_END
