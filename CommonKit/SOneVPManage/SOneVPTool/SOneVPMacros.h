
#ifndef SOneVPMacros_h
#define SOneVPMacros_h

typedef NS_ENUM(NSUInteger, VPConnectTunnelMode) {
    VPConnectTunnelModeOpenVP = 1,
    VPConnectTunnelModeIkev2 = 2
};

typedef NS_ENUM(NSUInteger, OpenVPProtocolType) {
    OpenVPProtocolTypeTCP       = 1,
    OpenVPProtocolTypeUDP       = 2,
};

// 连接模式
typedef NS_ENUM(NSUInteger, VPConnectMode) {
    SOneVPConnectModeUNKNOWN,
    SOneVPConnectModeAUTO,
    SOneVPConnectModeOPENVPN_UDP,
    SOneVPConnectModeOPENVPN_TCP,
    SOneVPConnectModeIKEV2
};

#define VPConnectModeString(enum) [@[\
@"SOneVPConnectModeUNKNOWN",\
@"SOneVPConnectModeAUTO",\
@"SOneVPConnectModeOPENVPN_UDP",\
@"SOneVPConnectModeOPENVPN_TCP",\
@"SOneVPConnectModeIKEV2"] objectAtIndex:enum]


#define VPConnectModeAPIParam(enum) [@[\
@"-1",\
@"0",\
@"1",\
@"2",\
@"3"] objectAtIndex:enum]

#define AdapterEventString(enum) [@[@"OpenVPNAdapterEventDisconnected",\
@"OpenVPNAdapterEventConnected",\
@"OpenVPNAdapterEventReconnecting",\
@"OpenVPNAdapterEventResolve",\
@"OpenVPNAdapterEventWait",\
@"OpenVPNAdapterEventWaitProxy",\
@"OpenVPNAdapterEventConnecting",\
@"OpenVPNAdapterEventGetConfig",\
@"OpenVPNAdapterEventAssignIP",\
@"OpenVPNAdapterEventAddRoutes",\
@"OpenVPNAdapterEventEcho",\
@"OpenVPNAdapterEventInfo",\
@"OpenVPNAdapterEventPause",\
@"OpenVPNAdapterEventResume",\
@"OpenVPNAdapterEventRelay",\
@"OpenVPNAdapterEventUnknown"] objectAtIndex:enum]\

#endif /* SOneVPMacros_h */
