
#import "SOneVPConnectDataInfo.h"
#import "SOneVPLog.h"
#import "SOneVPMacros.h"
#import "NSString+SOneExtension.h"
#import "SOneVPTransferManage.h"


@interface SOneVPConnectDataInfo()

@property (nonatomic, strong) NSMutableArray *msgArray;

@property (nonatomic, strong) NSMutableDictionary *ikev2Info;

@end

@implementation SOneVPConnectDataInfo

+ (instancetype)shareInstance {
    static SOneVPConnectDataInfo *connectData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        connectData = [[SOneVPConnectDataInfo alloc] init];
    });
    return connectData;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.msgArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addItemWithMessage:(NSString *)message {
//    Contacting 185.168.20.248:112 via UDP
    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (message) {
        [self.msgArray addObject:message];
        log4cplus_info("PTVPN_log", "整理数据: message %s", message.UTF8String);
    }
}

- (void)addItemWithEvent:(OpenVPNAdapterEvent)event {
    // 记录时刻
    [self.msgArray addObject:@(event)];
    [self.msgArray addObject:[NSDate date]];
    
    log4cplus_info("PTVPN_log", "整理数据: event %s", [AdapterEventString(event) UTF8String]);
    if (event == OpenVPNAdapterEventDisconnected ||
        event == OpenVPNAdapterEventConnected) {
        // 整理数据成字典数组
        NSMutableArray<NSMutableDictionary *> *resultArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.msgArray.count; i ++) {
            id obj = self.msgArray[i];
            if ([obj isKindOfClass:[NSNumber class]]) {
                NSNumber *num = obj;
                if (num.intValue == OpenVPNAdapterEventResolve) {
                    // 开始时间
                    NSMutableDictionary *itemDic = [[NSMutableDictionary alloc] init];
                    [resultArray addObject:itemDic];
                }
            } else if ([obj isKindOfClass:[NSString class]]){
                //  解析  Contacting 185.168.20.248:112 via UDP
                NSString *message = (NSString *)obj;
                NSArray *array = [message componentsSeparatedByString:@" "];
                if (array.count == 4) {
                    NSString *ipAndPort = array[1];
                    NSArray *items = [ipAndPort componentsSeparatedByString:@":"];
                    NSString *host = items.firstObject;
                    NSString *port = items.lastObject;
                    NSString *portType = array.lastObject;
                    
                    NSMutableDictionary *dic = resultArray.lastObject;
                    [dic setObject:host.length > 0 ? host : @"数据错误" forKey:@"host"];
                    [dic setObject:@1 forKey:@"status"];
                    [dic setObject:@(port.intValue) forKey:@"port"];
                    [dic setObject:[portType.uppercaseString isEqualToString:@"UDP"] ? @1: @2 forKey:@"type"];
                    
                } else {
                    // 数据错误
                }
            } else if ([obj isKindOfClass:[NSDate class]]) {
                NSDate *date = (NSDate *)obj;
                NSMutableDictionary *lastItem = resultArray.lastObject;
                // 记录当前端口的开始时间
                if ([lastItem objectForKey:@"start"]) {
                    // 已经连接成功，或者失败；处理最后一个数据 event = OpenVPNAdapterEventDisconnected || OpenVPNAdapterEventConnected
                    // 处理时间段
                    NSNumber *startDate = lastItem[@"start"];
                    // 时间戳
                    [lastItem setObject:@(@(date.timeIntervalSince1970 * 1000 - startDate.doubleValue * 1000).intValue) forKey:@"times"];
                    [lastItem setObject:@(date.timeIntervalSince1970) forKey:@"end"];
                    // 记录最后一口端口号是成功还是失败
                    [lastItem setObject:event == OpenVPNAdapterEventConnected ? @0: @1 forKey:@"status"];
                    NSString *resultStr = [NSString vp_jsonFromObj:lastItem];
                    log4cplus_info("PTVPN_log", "数据 last %s", resultStr.UTF8String);
                } else {
                    // 连接下一个端口号，event == OpenVPNAdapterEventResolve
                    [lastItem setObject:@(date.timeIntervalSince1970) forKey:@"start"];
                    if (resultArray.count > 1) {
                        // 处理之前端口的连接时间
                        NSMutableDictionary *preItem = resultArray[resultArray.count - 2];
                        [preItem setObject:@(date.timeIntervalSince1970) forKey:@"end"];
                        // 处理时间段
                        NSNumber *startDate = preItem[@"start"];
                        // 时间戳
                        [preItem setObject:@(@(date.timeIntervalSince1970 * 1000 - startDate.doubleValue * 1000).intValue) forKey:@"times"];
                        
                        NSString *resultStr = [NSString vp_jsonFromObj:preItem];
                        log4cplus_info("PTVPN_log", "数据 next %s", resultStr.UTF8String);
                    }
                }
            }
        }
        
        NSString *resultStr = [NSString vp_jsonFromObj:resultArray];
        log4cplus_info("PTVPN_log", "结果 %s %lu 元素", resultStr.UTF8String, (unsigned long)resultArray.count);
        [SOneVPTransferManage saveFile:resultStr fileName:SOneVPTransferManage.shareInstance.fileName.openVpnConnectInfo];
    }
}

- (void)addIkev2WithHost:(NSString *)host {
    if (self.ikev2Info.allKeys > 0) {
        // 清理旧数据
        [self.ikev2Info removeAllObjects];
    }
    
    [self.ikev2Info setObject:host forKey:@"host"];
    [self.ikev2Info setObject:@([NSDate date].timeIntervalSince1970) forKey:@"start"];
}

- (NSDictionary *)endIkev2WithHost:(NSString *)host
                           success:(BOOL)success {
    if ([self.ikev2Info[@"host"] isEqualToString:host]) {
        [self.ikev2Info setObject:success ? @0: @1 forKey:@"status"];
        [self.ikev2Info setObject:@([NSDate date].timeIntervalSince1970) forKey:@"end"];
        
        NSNumber *startDate = self.ikev2Info[@"start"];
        NSNumber *endDate = self.ikev2Info[@"end"];
        [self.ikev2Info setObject:@(@(endDate.doubleValue * 1000 - startDate.doubleValue * 1000).intValue) forKey:@"times"];
        [self.ikev2Info setObject:@3 forKey:@"type"];
        [self.ikev2Info setObject:@500 forKey:@"port"];
    }
    return self.ikev2Info;
}

- (NSDictionary *)ikev2ConnectInfo {
    return self.ikev2Info;
}

#pragma mark - private
- (NSMutableDictionary *)ikev2Info {
    if (!_ikev2Info) {
        _ikev2Info = [[NSMutableDictionary alloc] init];
    }
    return _ikev2Info;
}

@end

/**
 接口数据
 "portsInfo":[
             {
                 "port":500,//int
                 "status":0,//int,0成功，1失败
                 "times":3958,//int
                 "type":1， //1 代表 open udp 2 openvpn tcp 3代表 ikev
             }
         ]
 */

/**
 * 解析port host times 的相关逻辑，
 * 这个是连接成功的日志
 * SOneVPConnectDataInfo.m, -[SOneVPConnectDataInfo addItemWithEvent:](line 61) PTVPN_log:整理数据: event OpenVPNAdapterEventResolve
 * SOneVPConnectDataInfo.m, -[SOneVPConnectDataInfo addItemWithMessage:](line 50) PTVPN_log:整理数据: message Contacting 193.38.139.159:111 via TCP
 * SOneVPConnectDataInfo.m, -[SOneVPConnectDataInfo addItemWithEvent:](line 61) PTVPN_log:整理数据: event OpenVPNAdapterEventResolve
 * SOneVPConnectDataInfo.m, -[SOneVPConnectDataInfo addItemWithMessage:](line 50) PTVPN_log:整理数据: message Contacting 193.38.139.159:443 via TCP
 * SOneVPConnectDataInfo.m, -[SOneVPConnectDataInfo addItemWithEvent:](line 61) PTVPN_log:整理数据: event OpenVPNAdapterEventResolve
 * SOneVPConnectDataInfo.m, -[SOneVPConnectDataInfo addItemWithMessage:](line 50) PTVPN_log:整理数据: message Contacting 193.38.139.159:102 via TCP
 * SOneVPConnectDataInfo.m, -[SOneVPConnectDataInfo addItemWithEvent:](line 61) PTVPN_log:整理数据: event OpenVPNAdapterEventConnected
 
 
 
 */


/**
 导出的数据
 {
     "status" : 1,
     "port" : 111,
     "end" : 1623986522.9284921,
     "start" : 1623986520.648927,
     "times" : 2.2795650959014893,
     "host" : "185.172.112.121",
     "type" : 2
   },
   {
     "status" : 1,
     "port" : 443,
     "end" : 1623986532.9837999,
     "start" : 1623986522.9284921,
     "times" : 10.055307865142822,
     "host" : "185.172.112.121",
     "type" : 2
   },
   {
     "status" : 1,
     "port" : 8080,
     "end" : 1623986540.7156601,
     "start" : 1623986532.9837999,
     "times" : 7.7318601608276367,
     "host" : "185.172.112.121",
     "type" : 2
   }
 
 */
