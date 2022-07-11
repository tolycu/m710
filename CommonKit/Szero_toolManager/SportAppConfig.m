//
//  SportAppConfig.m
//  sportqr
//
//  Created by Hoho Wu on 2022/3/2.
//

#import "SportAppConfig.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation SportAppConfig


+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static SportAppConfig *appConfig;
    dispatch_once(&onceToken, ^{
        appConfig = [self new];
    });
    return appConfig;
}

- (instancetype)init{
    self = [super init];
    if (self) {
       
    }
    return self;
}

@end



@implementation SportAppConfig (UserInfo)

- (NSString *)getDeviceIMSI {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    NSString *mcc = [carrier mobileCountryCode];
    NSString *mnc = [carrier mobileNetworkCode];
        
    if (mcc != nil && mnc != nil) {
        NSString *imsi = [NSString stringWithFormat:@"%@%@", mcc, mnc];
        return imsi;
    } else {
        return @"";
    }
}


- (NSString *)getDeviceISOCountryCode {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
//    BOOL use = carrier.allowsVOIP;
//    NSString *name = carrier.carrierName;
    NSString *code = carrier.isoCountryCode;
    
    if (code != nil) {
        return code;
    } else {
        return @"";
    }
}

- (void)changeVpnStatue:(NEVPNStatus)status{
    [self willChangeValueForKey:@"status"];
    self.status = status;
    [self didChangeValueForKey:@"status"];
}


@end
