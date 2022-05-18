

#import <Foundation/Foundation.h>
#import "SOneVPMacros.h"


NS_ASSUME_NONNULL_BEGIN



@class VPConnectModeConfigsModel;
@interface SOneVPConnectModeModel : NSObject

@property (nonatomic, assign) VPConnectTunnelMode mode;
@property (nonatomic, strong) NSArray <VPConnectModeConfigsModel *> *configs;

+ (instancetype)modelWithType:(VPConnectMode)type;

@end

@interface VPConnectModeConfigsModel : NSObject
@property (nonatomic, assign, readonly) int timeout;
@property (nonatomic, assign) OpenVPProtocolType type;
@property (nonatomic, assign) int port;

@end
NS_ASSUME_NONNULL_END
