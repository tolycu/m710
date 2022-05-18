//
//  PingConfig.m
//  startvpn
//
//  Created by 李光尧 on 2021/7/13.
//

#import "PingConfig.h"

@interface PingConfig ()

@property(nonatomic,assign) NSInteger pingCount;

@end

@implementation PingConfig

- (void)pingValueWithModel:(Expert_ServerVPNModel *)model WithBlock:(void (^)(void))completion{
    PingHelper *ping = [[PingHelper alloc] init];
    ping.timeout = 1;
    ping.host = model.expert_host;
    self.pingCount ++;
    [ping pingWithBlock:^(BOOL isSuccess, NSTimeInterval latency) {
        if (isSuccess && latency > 1) {
            model.ping = (int)latency;
            if (completion) {
                completion();
            }
        }else{
            if (self.pingCount<2) {
                [self pingValueWithModel:model WithBlock:^{
                    if (completion) {
                        completion();
                    }
                }];
            }else{
                model.ping = 1000;
                if (completion) {
                    completion();
                }
            }
        }
    }];
}

@end
