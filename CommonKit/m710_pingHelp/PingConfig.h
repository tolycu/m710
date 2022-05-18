//
//  PingConfig.h
//  startvpn
//
//  Created by 李光尧 on 2021/7/13.
//

#import <Foundation/Foundation.h>
#import "PingHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface PingConfig : NSObject

- (void)pingValueWithModel:(Expert_ServerVPNModel *)model WithBlock:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
