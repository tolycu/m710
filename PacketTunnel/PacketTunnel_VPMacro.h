//   
//   PacketTunnel_VPMacro.h
//   m208vpm
//   
//   Created  by hf on 2021/6/18 14:03
//   
//   少写bug，多思考


   

#ifndef PacketTunnel_VPMacro_h
#define PacketTunnel_VPMacro_h

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

#endif /* PacketTunnel_VPMacro_h */
