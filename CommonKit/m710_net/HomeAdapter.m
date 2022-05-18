//
//  HomeAdapter.m
//  startvpn
//
//  Created by 李光尧 on 2020/12/7.
//

#import "HomeAdapter.h"
#import "XCClient.h"
#import "NSString+SOneExtension.h"
#import "SOneVPTool.h"
#import "SOneCertManage.h"
#import "PingConfig.h"


@interface HomeAdapter ()<NSURLSessionDelegate>

@property(nonatomic,strong)NSURLSessionDownloadTask *downloadTask;

@end

@implementation HomeAdapter


+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static HomeAdapter *tool;
    dispatch_once(&onceToken, ^{
        tool = [self new];
    });
    return tool;
}

- (instancetype)init{
    self = [super init];
    if (self) {
       
    }
    return self;
}

- (void)changeBestServer:(Expert_ServerVPNModel *)server{
    [self willChangeValueForKey:@"bestServer"];
    Adapter_MANAGE.bestServer = server;
    [self didChangeValueForKey:@"bestServer"];
}

/** 全局配置 */
- (void)getConfigWithCompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler{
    NSMutableDictionary *body = [self commonParamWithDic:@{}];
    NSString *url = [NSString stringWithFormat:@"%@%@",BASE_URL,BASE_Conf];
    [XC_CLIENT post:url params:body success:^(id  _Nonnull response) {
        NSLog(@"请求成功--全局配置");
        NSString *vpnFilePath = [[SOneVPTool shareInstance]filePathWithFileName:@"globalConfig.qr"];
        NSData *vpnData = [NSString vp_encryptAES:[response mj_JSONString]];
        [vpnData writeToFile:vpnFilePath atomically:YES];
        [self handelFormmitConfig:response];
        completionHandler(YES,nil);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"请求失败--全局配置");
        NSDictionary *dict;
        NSString *vpnFilePath = [[SOneVPTool shareInstance]filePathWithFileName:@"globalConfig.qr"];
        NSData *vpnStrData = [NSString vp_decryptAES:[NSData dataWithContentsOfFile:vpnFilePath]];
        NSString *ikev2Str = [[NSString alloc] initWithData:vpnStrData encoding:NSUTF8StringEncoding];
        NSDictionary *tempDic = [ikev2Str mj_JSONObject];
        if (tempDic) {
            dict = tempDic;
            [self handelFormmitConfig:dict];
            completionHandler(YES,error);
        }else{
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"globalConfig" ofType:@"qr"];
            NSData *vpnStrData = [NSString vp_decryptAES:[NSData dataWithContentsOfFile:filePath]];
            NSString *ikev2Str = [[NSString alloc] initWithData:vpnStrData encoding:NSUTF8StringEncoding];
            NSDictionary *tempDic = [ikev2Str mj_JSONObject];
            [self handelFormmitConfig:tempDic];
            completionHandler(YES,error);
        }
    }];
}

- (void)handelFormmitConfig:(id _Nonnull)response{
    NSDictionary *dict = [response objectForKey:@"data"];
    Adapter_MANAGE.globalModel = [Expert_GlobalConfigModel mj_objectWithKeyValues:dict];
    
//    //权重排序
//    [Adapter_MANAGE.globalModel.adCfgs jk_each:^(ADConfigModel *object) {
//        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"expert_weight" ascending:NO];
//        NSArray<ADDataModel *> *sortArr = [object.expert_adSource  sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//        object.expert_adSource = sortArr;
//    }];
//
//    //  加载广告
//    [Adapter_MANAGE.globalModel.adCfgs jk_each:^(ADConfigModel *obj) {
//        ADConfigManage *manage = [[ADConfigManage alloc] init];
//        manage.configModel = obj;
//        [AD_MANAGE.adConfigs addObject:manage];
//    }];
}

/** vp列表*/
- (void)getVpnListWithCompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler{
    NSMutableDictionary *body = [self commonParamWithDic:@{}];
    NSString *url = [NSString stringWithFormat:@"%@%@",BASE_URL,BASE_Vpn_List];
    [XC_CLIENT post:url params:body success:^(id  _Nonnull response) {
        NSLog(@"请求成功--vps列表");
        NSString *vpnFilePath = [[SOneVPTool shareInstance]filePathWithFileName:@"vpn.list"];
        NSData *vpnData = [NSString vp_encryptAES:[response mj_JSONString]];
        [vpnData writeToFile:vpnFilePath atomically:YES];
        [self handleResponse:response];
        completionHandler(YES,nil);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"请求失败--vps列表");
        NSDictionary *dict;
        NSString *vpnFilePath = [[SOneVPTool shareInstance]filePathWithFileName:@"vpn.list"];
        NSData *vpnStrData = [NSString vp_decryptAES:[NSData dataWithContentsOfFile:vpnFilePath]];
        NSString *ikev2Str = [[NSString alloc] initWithData:vpnStrData encoding:NSUTF8StringEncoding];
        NSDictionary *tempDic = [ikev2Str mj_JSONObject];
        if (tempDic) {
            dict = tempDic;
            [self handleResponse:dict];
            completionHandler(YES,error);
        } else {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"default_serverList" ofType:@"txt"];
            NSString *configStr = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            NSDictionary *dict = [configStr mj_JSONObject];
            [self handleResponse:dict];
            completionHandler(YES,error);
        }
        NSLog(@"");
    }];
}

- (void)handleResponse:(id  _Nonnull)response{
    NSDictionary *dict = [response objectForKey:@"data"];
    Adapter_MANAGE.servers = [Expert_ServerVPNModel mj_objectArrayWithKeyValuesArray:dict[@"servers"]];
}

/** vp证书 */
- (void)getVpnCerWithParams:(NSDictionary *)params  CompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler{
    NSMutableDictionary *body = [self commonParamWithDic:params];
    NSString *url = [NSString stringWithFormat:@"%@%@",BASE_URL,BASE_Vpn_Cer];
    [XC_CLIENT post:url params:body success:^(id  _Nonnull response) {
        
        NSString *vpnFilePath = [[SOneVPTool shareInstance]filePathWithFileName:@"open.vp"];
        NSData *vpnData = [NSString vp_encryptAES:[response mj_JSONString]];
        [vpnData writeToFile:vpnFilePath atomically:YES];
        [[SOneCertManage shareInstance] updateLocalCert:response ver:Adapter_MANAGE.expert_certVer];
        NSLog(@"请求成功--证书");
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"请求成功--证书");
        NSDictionary *dict;
        NSString *vpnFilePath = [[SOneVPTool shareInstance]filePathWithFileName:@"open.vp"];
        NSData *vpnStrData = [NSString vp_decryptAES:[NSData dataWithContentsOfFile:vpnFilePath]];
        NSString *ikev2Str = [[NSString alloc] initWithData:vpnStrData encoding:NSUTF8StringEncoding];
        NSDictionary *tempDic = [ikev2Str mj_JSONObject];
        if (tempDic) {
            dict = tempDic;
            [[SOneCertManage shareInstance] updateLocalCert:dict ver:Adapter_MANAGE.expert_certVer];
            completionHandler(YES,error);
        } else {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"open" ofType:@"vp"];
            NSData *vpnStrData = [NSString vp_decryptAES:[NSData dataWithContentsOfFile:filePath]];
            NSString *ikev2Str = [[NSString alloc] initWithData:vpnStrData encoding:NSUTF8StringEncoding];
            NSDictionary *tempDic = [ikev2Str mj_JSONObject];
            [[SOneCertManage shareInstance] updateLocalCert:tempDic ver:Adapter_MANAGE.expert_certVer];
            completionHandler(YES,error);
        }
    }];
}

- (void)getAppPostionInfoWithCompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler{
    NSMutableDictionary *body = [self commonParamWithDic:@{}];
    NSString *url = [NSString stringWithFormat:@"%@%@",BASE_URL,BASE_App_PostionInfo];
    [XC_CLIENT post:url params:body success:^(id  _Nonnull response) {
        NSDictionary *dict = [response objectForKey:@"data"];
        Adapter_MANAGE.country_short = dict[@"expert_country_short"];
        NSLog(@"请求成功--app");
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"请求成功--app");
    }];
}

- (void)upLoadServersPingWithParams:(NSArray *)params CompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict = [self commonParamWithDic:@{}];
    [dict jk_setObj:params forKey:@"serversStatus"];  //ping值信息
    
    NSDate *lastDate = [XCUserDefault objectForKey:Upload_Ping_Date];
    NSDate *date = [NSDate jk_dateWithMinutesBeforeNow:30];
    if (lastDate && [lastDate jk_isLaterThanDate:date]) {
        NSLog(@"ping 未上传");
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",BASE_URL,BASE_VPN_UpLoad];
    [XC_CLIENT post:url params:dict success:^(id  _Nonnull response) {
        [XCUserDefault setObject:[NSDate date] forKey:Upload_Ping_Date];
        NSLog(@"请求成功---ping上传");
        completionHandler(YES,nil);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"请求失败---ping上传");
        completionHandler(NO,error);
    }];
}

- (void)uploadCurrentServersStatusWithModel:(Expert_ServerVPNModel *)connectModel
                               connectInfos:(NSArray *)connectInfos
                          CompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params = [self commonParamWithDic:params];
    [params setObject:connectModel.expert_host forKey:@"slap_ip"];
    
    NSMutableDictionary *currentStatusDic = [[NSMutableDictionary alloc] init];
    [currentStatusDic setValue:@(connectModel.ping) forKey:@"expert_pingTime"];
    [currentStatusDic setObject:connectModel.expert_host forKey:@"expert_serverIp"];
    [currentStatusDic setObject:@0 forKey:@"expert_auto"];
    if (connectInfos) {
        NSMutableArray *infos = [NSMutableArray array];
        for (NSDictionary *object in connectInfos) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            for (NSString *title in object.allKeys) {
                if ([title isEqualToString:@"port"]) {
                    [dict setObject:object[title] forKey:@"expert_port"];
                }else if ([title isEqualToString:@"status"]){
                    [dict setObject:object[title] forKey:@"expert_status"];
                }else if ([title isEqualToString:@"times"]){
                    [dict setObject:object[title] forKey:@"expert_times"];
                }else if ([title isEqualToString:@"type"]){
                    [dict setObject:object[title] forKey:@"expert_type"];
                }else{
                    [dict setObject:object[title] forKey:title];
                }
            }
            [infos addObject:dict];
        }
        [currentStatusDic setObject:infos forKey:@"portsInfo"];
    }
    [params setObject:currentStatusDic forKey:@"expert_currentServer"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BASE_URL,BASE_VPNStatus_UpLoad];
    [XC_CLIENT post:url params:params success:^(id  _Nonnull response) {
        NSLog(@"请求成功---VPN状态上传");
        completionHandler(YES,nil);
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"请求失败---VPN状态上传");
        completionHandler(NO,error);
    }];
}

   
- (NSMutableDictionary *)commonParamWithDic:(NSDictionary *)dic {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:dic];
    [dict jk_setString:[TOOL_MANAGE getDeviceIDInKeychain] forKey:@"expert_aid"];
    [dict jk_setString:[[NSString jk_currentLanguage] componentsSeparatedByString:@"-"].firstObject forKey:@"expert_lang"];
    [dict jk_setInt:[[[UIDevice jk_systemVersion] componentsSeparatedByString:@"."].firstObject intValue] forKey:@"expert_sdk"];
    [dict jk_setString:[NSString jk_identifier] forKey:@"expert_pkg"];
    [dict jk_setInt:(int)[NSObject jk_build] forKey:@"expert_ver"];
    [dict jk_setString:[TOOL_MANAGE getDeviceIMSI] forKey:@"expert_plmn"]; //运营商短码
    [dict jk_setString:[TOOL_MANAGE getDeviceISOCountryCode] forKey:@"expert_simCountryIos"]; //国家码
    [dict jk_setBool:[SOneVPTool isOpenVPNForDevice] forKey:@"expert_bvpn"];
    [dict jk_setString:[self readCurrentCountry] forKey:@"expert_country"];
    return dict;
}


- (NSString *)readCurrentCountry{
    return self.country_short?self.country_short:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
}


+ (void)pingVPNServers:(NSArray <Expert_ServerVPNModel *> *)vpnList WithCompletionHandler:(void(^)(void))completionHandler{
    dispatch_group_t pingHelp = dispatch_group_create();
    for (Expert_ServerVPNModel *object in vpnList) {
        dispatch_group_enter(pingHelp);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[[PingConfig alloc] init] pingValueWithModel:object WithBlock:^{
                dispatch_group_leave(pingHelp);
            }];
        });
    }
    dispatch_group_notify(pingHelp, dispatch_get_main_queue(), ^{
        if (completionHandler) {
            completionHandler();
        }
    });
}


+ (Expert_ServerVPNModel *)getBestVpnFrom:(NSArray <Expert_ServerVPNModel *>*)list{

    NSArray<Expert_ServerVPNModel *> *dataSource = nil;
    NSString *country = [Adapter_MANAGE.globalModel.vpCountryFirst uppercaseString];
    if (country && country.length) {
        dataSource = [list jk_filter:^BOOL(Expert_ServerVPNModel *val) {
            return [country jk_containsaString:val.expert_country];
        }];
    }
    
    NSArray *temp = [dataSource?dataSource:list jk_filter:^BOOL(Expert_ServerVPNModel *val) {
        return val.ping != 0;
    }];
    
    if (!temp.count && dataSource.count) {
        int r = arc4random() % [dataSource count];
        return [dataSource jk_objectWithIndex:r] ;
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ping" ascending:YES];
    NSArray<Expert_ServerVPNModel *> *sortArr = [temp sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    float osType = 0.0;
    int lowPing = sortArr.firstObject.ping;
    NSMutableArray<Expert_ServerVPNModel *> *mutArr = [NSMutableArray array];
    Expert_ServerVPNModel *bestVpn;
    for (Expert_ServerVPNModel *object in sortArr) {
        if (object.ping <= lowPing*1.2) {
            [mutArr addObject:object];
            if (osType == 0) {
                osType = object.expert_osType;
            }else{
                if (object.expert_osType < osType) {
                    osType = object.expert_osType;
                }
            }
        }
    }
    
    NSArray<Expert_ServerVPNModel *> *mustArr = [mutArr jk_filter:^BOOL(Expert_ServerVPNModel *object) {
        return object.expert_osType == osType;
    }];
    
    int low = arc4random() % [mustArr count];
    bestVpn = [mutArr jk_objectWithIndex:low];
    
    if (bestVpn) {
        return bestVpn;
    }else{
        int r = arc4random() % [list count];
        return [list jk_objectWithIndex:r] ;
    }
}

@end
