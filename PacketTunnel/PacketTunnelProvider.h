//
//  PacketTunnelProvider.h
//  PacketTunnel
//
//  Created by xc-76 on 2022/5/11.
//

#import <NetworkExtension/NetworkExtension.h>

@import OpenVPNAdapter;

@interface NEPacketTunnelFlow ()<OpenVPNAdapterPacketFlow>

@end

@interface PacketTunnelProvider : NEPacketTunnelProvider

@property(nonatomic,strong, nullable) OpenVPNAdapter *vpnAdapter;
@property(nonatomic,strong, nullable) OpenVPNReachability *openVpnReach;

typedef void(^StartHandler)(NSError * _Nullable);
typedef void(^StopHandler)(void);
@property(nonatomic,copy, nullable) StartHandler startHandler;
@property(nonatomic,copy, nullable) StopHandler stopHandler;

@end
