//
//  ADConfigSetting.m
//  scanqr
//
//  Created by 李光尧 on 2021/3/1.
//

#import "ADConfigSetting.h"

@implementation ADConfigSetting

/**
 初始化广告类型
 */
+ (ADDataType)getLoadADtype:(NSString *)type{
    if ([type isEqualToString:@"admob_nav"]) {
        return ADDataType_nav;
    }else if ([type isEqualToString:@"admob_int"]){
        return ADDataType_int;
    }else if ([type isEqualToString:@"admob_open"]){
        return ADDataType_open;
    }else if ([type isEqualToString:@"admob_ban"]){
        return ADDataType_banner;
    }else {
        return ADDataType_reward;
    }
}

+ (BOOL)isLimitShowADWithAllowForkey:(NSString *)key{
 
    NSInteger limit = [key isEqualToString:APP_Native_Count]?Adapter_MANAGE.globalModel.NativeDianJiLimit:Adapter_MANAGE.globalModel.BannerDianJiLimit;
    if (limit == 0) {
        return YES;
    }
    NSDictionary *dict = [XCUserDefault objectForKey:key];
    if (dict) {
        NSString *dateStr = [dict jk_stringForKey:@"date"];
        NSInteger index = [dict jk_integerForKey:@"index"];
        if ([dateStr isEqualToString:[NSDate jk_currentYMDDateString]] && index > limit-1) {
            return NO;
        }
    }
    return YES;
}

+ (void)clickADWithAddLimitForkey:(NSString *)key{
    NSDictionary *dict = [XCUserDefault objectForKey:key];
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    if (dict) {
        NSString *dateStr = [dict jk_stringForKey:@"date"];
        NSInteger index = [dict jk_integerForKey:@"index"];
        if ([dateStr isEqualToString:[NSDate jk_currentYMDDateString]]) {
            index = index+1;
            [tempDic jk_setInteger:index forKey:@"index"];
            [tempDic jk_setString:dateStr forKey:@"date"];
            [NSUserDefaults jk_setObject:tempDic forKey:key];
            return;
        }
    }
    [tempDic jk_setInteger:1 forKey:@"index"];
    [tempDic jk_setString:[NSDate jk_currentYMDDateString] forKey:@"date"];
    [NSUserDefaults jk_setObject:tempDic forKey:key];
}

+ (ADConfigModel *)filterADPosition:(ADPositionType)type{
    switch (type) {
        case ADPositionType_start:
        {
            ADConfigModel *bestConfigModel;
            for (ADConfigManage *object in AD_MANAGE.adConfigs) {
                if ([object.configModel.expert_adPlace isEqualToString:AD_start]) {
                    if (!object.configModel.expert_adSwitch) {
                        return nil;
                    }else if(object.configModel.model && object.configModel.requestAD){
                        bestConfigModel = object.configModel;
                    }
                }
            }
            
            for (ADConfigManage *object in AD_MANAGE.adConfigs) {
                if (object.configModel.model && object.configModel.requestAD) {
                    ADDataType temp = [ADConfigSetting getLoadADtype:object.configModel.model.expert_type];
                    if (temp == ADDataType_int || temp == ADDataType_open) {
                        if (!bestConfigModel || bestConfigModel.model.expert_weight < object.configModel.model.expert_weight) {
                            bestConfigModel = object.configModel;
                        }
                    }
                }
            }
            return bestConfigModel;
            
        }
            break;
        case ADPositionType_home:
        {
            if (![ADConfigSetting isLimitShowADWithAllowForkey:APP_Banner_Count]) {
                return nil;
            }
            
            ADConfigModel *bestConfigModel;
            for (ADConfigManage *object in AD_MANAGE.adConfigs) {
                if ([object.configModel.expert_adPlace isEqualToString:AD_home]) {
                    if (!object.configModel.expert_adSwitch) {
                        return nil;
                    }else if(object.configModel.model && object.configModel.requestAD){
                        bestConfigModel = object.configModel;
                    }
                }
            }
            for (ADConfigManage *object in AD_MANAGE.adConfigs) {
                if (object.configModel.model && object.configModel.requestAD) {
                    ADDataType temp = [ADConfigSetting getLoadADtype:object.configModel.model.expert_type];
                    if (temp == ADDataType_banner ) {
                        if (!bestConfigModel || bestConfigModel.model.expert_weight < object.configModel.model.expert_weight) {
                            bestConfigModel = object.configModel;
                        }
                    }
                }
            }
            return bestConfigModel;
        }
            break;
        case ADPositionType_finish:
        {
            ADConfigModel *bestConfigModel;
            for (ADConfigManage *object in AD_MANAGE.adConfigs) {
                if ([object.configModel.expert_adPlace isEqualToString:AD_finish]) {
                    if (!object.configModel.expert_adSwitch) {
                        return nil;
                    }else if(object.configModel.model && object.configModel.requestAD){
                        bestConfigModel = object.configModel;
                    }
                }
            }
            
            for (ADConfigManage *object in AD_MANAGE.adConfigs) {
                if (object.configModel.model && object.configModel.requestAD) {
                    ADDataType temp = [ADConfigSetting getLoadADtype:object.configModel.model.expert_type];
                    if ( temp == ADDataType_int) {
                        if (!bestConfigModel || bestConfigModel.model.expert_weight < object.configModel.model.expert_weight) {
                            bestConfigModel = object.configModel;
                        }
                    }
                }
            }
            return bestConfigModel;
        }
            break;
        case ADPositionType_report:
        {
            if (![ADConfigSetting isLimitShowADWithAllowForkey:APP_Native_Count]) {
                return nil;
            }
            
            ADConfigModel *bestConfigModel;
            for (ADConfigManage *object in AD_MANAGE.adConfigs) {
                if ([object.configModel.expert_adPlace isEqualToString:AD_report]) {
                    if (!object.configModel.expert_adSwitch) {
                        return nil;
                    }else if(object.configModel.model && object.configModel.requestAD){
                        bestConfigModel = object.configModel;
                    }
                }
            }
            
            for (ADConfigManage *object in AD_MANAGE.adConfigs) {
                if (object.configModel.model && object.configModel.requestAD) {
                    ADDataType temp = [ADConfigSetting getLoadADtype:object.configModel.model.expert_type];
                    if (temp == ADDataType_nav) {
                        if (!bestConfigModel || bestConfigModel.model.expert_weight < object.configModel.model.expert_weight) {
                            bestConfigModel = object.configModel;
                        }
                    }
                }
            }
            return bestConfigModel;
        }
            break;
        case ADPositionType_extra:
        {
            if (!Adapter_MANAGE.globalModel.IExtraAd) {
                return nil;
            }
            ADConfigModel *bestConfigModel;
            for (ADConfigManage *object in AD_MANAGE.adConfigs) {
                if (object.configModel.model && object.configModel.requestAD) {
                    ADDataType temp = [ADConfigSetting getLoadADtype:object.configModel.model.expert_type];
                    if ( temp == ADDataType_int) {
                        if (!bestConfigModel || bestConfigModel.model.expert_weight < object.configModel.model.expert_weight) {
                            bestConfigModel = object.configModel;
                        }
                    }
                }
            }
            return bestConfigModel;
        }
            break;
        default:
            break;
    }
    return nil;
}

@end

