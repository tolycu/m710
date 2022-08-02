//
//  Szero_ServerVPNModel.h
//  szeroqr
//
//  Created by xc-76 on 2022/8/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Szero_ServerVPNModel : NSObject

@property(nonatomic,assign) long expert_load;
@property(nonatomic,strong) NSString *city;
@property(nonatomic,strong) NSString *expert_country;
@property(nonatomic,strong) NSString *expert_oports;
@property(nonatomic,strong) NSString *expert_tports;
@property(nonatomic,strong) NSString *expert_countryName;
@property(nonatomic,strong) NSString *expert_host;
@property(nonatomic,strong) NSString *expert_alisaName;
@property(nonatomic,strong) NSString *expert_groupName;
@property(nonatomic,strong) NSString *icon;
@property(nonatomic,assign) long expert_osType;

@property(nonatomic,assign) int ping;

@end

NS_ASSUME_NONNULL_END
