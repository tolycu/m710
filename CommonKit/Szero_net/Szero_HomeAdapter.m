//
//  Szero_HomeAdapter.m
//  startvpn
//
//  Created by 李光尧 on 2020/12/7.
//

#import "Szero_HomeAdapter.h"
#import "XCClient.h"
#import "SOneVPTool.h"
#import "NSString+SOneExtension.h"

@interface Szero_HomeAdapter ()<NSURLSessionDelegate>

@property(nonatomic,strong)NSURLSessionDownloadTask *downloadTask;

@end

@implementation Szero_HomeAdapter


+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static Szero_HomeAdapter *tool;
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

/** 全局配置 */
- (void)getConfigWithCompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler{
    NSMutableDictionary *body = [self commonParamWithDic:@{}];
    NSString *url = [NSString stringWithFormat:@"%@%@",BASE_URL,BASE_Conf];
    [XC_CLIENT post:url params:body success:^(id  _Nonnull response) {
        NSLog(@"请求成功--全局配置");
        [FIRAnalytics logEventWithName:Global_Configration_Get_Gap parameters:@{@"status":@"success"}];
        NSString *vpnFilePath = [[SOneVPTool shareInstance]filePathWithFileName:@"globalConfig.qr"];
        NSData *vpnData = [NSString vp_encryptAES:[response mj_JSONString]];
        [vpnData writeToFile:vpnFilePath atomically:YES];
        [self handelFormmitConfig:response];
        completionHandler(YES,nil);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"请求失败--全局配置");
        [FIRAnalytics logEventWithName:Global_Configration_Get_Gap parameters:@{@"status":@"fail"}];
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
    Adapter_MANAGE.globalModel = [Szero_GlobalConfigModel mj_objectWithKeyValues:dict];
    
    //权重排序
    [Adapter_MANAGE.globalModel.adCfgs jk_each:^(ADConfigModel *object) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"expert_weight" ascending:NO];
        NSArray<ADDataModel *> *sortArr = [object.expert_adSource  sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        object.expert_adSource = sortArr;
    }];

    //加载广告
    [Adapter_MANAGE.globalModel.adCfgs jk_each:^(ADConfigModel *obj) {
        ADConfigManage *manage = [[ADConfigManage alloc] init];
        manage.configModel = obj;
        [AD_MANAGE.adConfigs addObject:manage];
    }];
}

/** vps列表 */
- (void)getVpnListWithCompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler{
    NSMutableDictionary *body = [self commonParamWithDic:@{}];
    NSString *url = [NSString stringWithFormat:@"%@%@",BASE_URL,BASE_Vpn_List];
    [XC_CLIENT post:url params:body success:^(id  _Nonnull response) {
        NSLog(@"请求成功--vpn列表全局配置");
        NSString *vpnFilePath = [[SOneVPTool shareInstance]filePathWithFileName:@"vpnlist.qr"];
        NSData *vpnData = [NSString vp_encryptAES:[response mj_JSONString]];
        [vpnData writeToFile:vpnFilePath atomically:YES];
        [self handleResponse:response];
        completionHandler(YES,nil);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"请求失败--vpn列表配置");
        NSDictionary *dict;
        NSString *vpnFilePath = [[SOneVPTool shareInstance]filePathWithFileName:@"vpnlist.qr"];
        NSData *vpnStrData = [NSString vp_decryptAES:[NSData dataWithContentsOfFile:vpnFilePath]];
        NSString *ikev2Str = [[NSString alloc] initWithData:vpnStrData encoding:NSUTF8StringEncoding];
        NSDictionary *tempDic = [ikev2Str mj_JSONObject];
        if (tempDic) {
            dict = tempDic;
            [self handleResponse:dict];
            completionHandler(YES,error);
        }else{
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"vpnlist" ofType:@"qr"];
            NSData *vpnStrData = [NSString vp_decryptAES:[NSData dataWithContentsOfFile:filePath]];
            NSString *ikev2Str = [[NSString alloc] initWithData:vpnStrData encoding:NSUTF8StringEncoding];
            NSDictionary *tempDic = [ikev2Str mj_JSONObject];
            [self handleResponse:tempDic];
            completionHandler(YES,error);
        }
    }];
}

- (void)handleResponse:(id _Nonnull)response{
    NSDictionary *dict = [response objectForKey:@"data"];
    Adapter_MANAGE.servers = [Szero_ServerVPNModel mj_objectArrayWithKeyValuesArray:dict[@"servers"]];
}

/** vps列表 */
- (void)getAppPostionInfoWithCompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler{
    NSMutableDictionary *body = [self commonParamWithDic:@{}];
    NSString *url = [NSString stringWithFormat:@"%@%@",BASE_URL,BASE_App_PostionInfo];
    [XC_CLIENT post:url params:body success:^(id  _Nonnull response) {
        NSDictionary *dict = [response objectForKey:@"data"];
        Adapter_MANAGE.country_short = dict[@"expert_country_short"];
        NSLog(@"请求成功--app定位");
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"请求失败--app定位");
    }];
}

/**ping值信息上传 */
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

/**vpn状态信息上传 */
- (void)uploadCurrentServersStatusWithModel:(Szero_ServerVPNModel *)connectModel
                               connectInfos:(NSArray *)connectInfos
                          CompletionHandler:(void(^)(BOOL success,NSError *error))completionHandler {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params = [self commonParamWithDic:params];
    [params setObject:connectModel.expert_host forKey:@"expert_ip"];
    
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

@end
