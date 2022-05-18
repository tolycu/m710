//
//  SOneServerModel.h
//  
//
//  Created by sf on 2021/4/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOneServerModel : NSObject

@property (nonatomic, strong) NSString *host;
/**
 openvpn 用
 */
@property (nonatomic, strong) NSString *oports;

/**
 ikev 用
 */
@property (nonatomic, strong) NSString *tports;

@end

NS_ASSUME_NONNULL_END
