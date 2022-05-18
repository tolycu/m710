
#import "SOneVPCertModel.h"

@implementation SOneVPCertModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"account":@"username",
             @"remoteIdentifier":@"remoteId",
             @"ikev2Cert":@"strongswan",
             @"openvpCert":@"ovpn"
    };
}
@end
