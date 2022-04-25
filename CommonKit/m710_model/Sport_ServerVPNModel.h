//
//  Sport_ServerVPNModel.h
//  sportqr
//
//  Created by Hoho Wu on 2022/3/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Sport_ServerVPNModel : NSObject

@property(nonatomic,assign) long slab_load;
@property(nonatomic,strong) NSString *city;
@property(nonatomic,strong) NSString *slab_country;
@property(nonatomic,strong) NSString *slab_oports;
@property(nonatomic,strong) NSString *slab_tports;
@property(nonatomic,strong) NSString *slab_countryName;
@property(nonatomic,strong) NSString *slab_host;
@property(nonatomic,strong) NSString *slab_alisaName;
@property(nonatomic,strong) NSString *slab_groupName;
@property(nonatomic,strong) NSString *icon;
@property(nonatomic,assign) long slab_osType;

@property(nonatomic,assign) int ping;

@end

NS_ASSUME_NONNULL_END
