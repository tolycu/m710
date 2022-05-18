//
//  SOneVPCertModel.h
//  
//
//  Created by sf on 2021/4/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOneVPCertModel : NSObject

#pragma mark - ikev2
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *remoteIdentifier;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *ikev2Cert;

#pragma mark - openvp
@property (nonatomic, strong) NSString *openvpCert;
/// 证书版本号
@property (nonatomic, assign) NSInteger cerVer;

@end

NS_ASSUME_NONNULL_END

