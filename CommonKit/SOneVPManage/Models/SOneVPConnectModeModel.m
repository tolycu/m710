

#import "SOneVPConnectModeModel.h"


@implementation SOneVPConnectModeModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"configs":[VPConnectModeConfigsModel class]};
}

+ (instancetype)modelWithType:(VPConnectMode)type {
    SOneVPConnectModeModel *model = [[SOneVPConnectModeModel alloc] init];
    if (type == SOneVPConnectModeIKEV2) {
        model.mode = VPConnectTunnelModeIkev2;
    } else if (type == SOneVPConnectModeOPENVPN_TCP) {
        model.mode = VPConnectTunnelModeOpenVP;
        VPConnectModeConfigsModel *config = [[VPConnectModeConfigsModel alloc] init];
        config.type = OpenVPProtocolTypeTCP;
        model.configs = @[config];
    } else if (type == SOneVPConnectModeOPENVPN_UDP) {
        model.mode = VPConnectTunnelModeOpenVP;
        VPConnectModeConfigsModel *config = [[VPConnectModeConfigsModel alloc] init];
        config.type = OpenVPProtocolTypeUDP;
        model.configs = @[config];
    }
    return model;
}



@end

@implementation VPConnectModeConfigsModel



@end
