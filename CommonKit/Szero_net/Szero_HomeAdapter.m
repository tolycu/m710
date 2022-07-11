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

    //  加载广告
    [Adapter_MANAGE.globalModel.adCfgs jk_each:^(ADConfigModel *obj) {
        ADConfigManage *manage = [[ADConfigManage alloc] init];
        manage.configModel = obj;
        [AD_MANAGE.adConfigs addObject:manage];
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
