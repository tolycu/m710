//   
//   SOneVPIkeV2Model.h
//   VPNProject
//   
//   Created  by  2022/12/10 10:19
//   Copyright © 2022 . All rights reserved.
//			🐶
//   

   

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOneVPIkeV2Model : NSObject

@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *remoteIdentifier;
@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) NSString *ikev2Cert;

@end

NS_ASSUME_NONNULL_END
