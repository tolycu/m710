//
//  Expert_ServerVPNModel.h
//  sportqr
//
//  Created by Hoho Wu on 2022/3/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Expert_ServerVPNModel : NSObject

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
