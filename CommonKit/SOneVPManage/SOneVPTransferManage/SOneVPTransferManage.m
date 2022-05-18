
#import "SOneVPTransferManage.h"
#import "NSString+SOneExtension.h"
#import "SOneVPLog.h"



static NSString *kConfigFile = @"configFile";
static NSString *kGroupId = @"group.iqr.expert.qrcode";

@interface SOneVPTransferManage() {
    FileName *_fileName;
}

@end

@implementation SOneVPTransferManage


+ (instancetype)shareInstance {
    static SOneVPTransferManage *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SOneVPTransferManage alloc] init];
    });
    return manager;
}

+ (void)setObject:(id)value forKey:(NSString *)key {
    NSString *str = [self fileContentWithFileName:kConfigFile];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[str vp_toArrayOrDictionary]];
    if (!dic) {
        dic = [[NSMutableDictionary alloc] init];
    }
    if (value && key) {
        [dic setObject:value forKey:key];
        [self saveFile:[NSString vp_jsonFromObj:dic] fileName:kConfigFile];
    }
}

+ (id)objectForKey:(NSString *)key {
    NSString *str = [self fileContentWithFileName:kConfigFile];
    NSDictionary *dic = [str vp_toArrayOrDictionary];
    
    if ([dic.allKeys containsObject:key]) {
        return dic[key];
    } else {
        return nil;
    }
}

+ (BOOL)saveFile:(NSString *)fileContent fileName:(NSString *)fileName {
    if (!fileContent) {
        return NO;
    }
    NSError *err = nil;
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kGroupId];
    containerURL = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Library/Caches/%@", fileName]];
    
    BOOL result = [fileContent writeToURL:containerURL atomically:YES encoding:NSUTF8StringEncoding error:&err];
    if (!result) {
    } else {
    }
    return result;
}

+ (NSString *)fileContentWithFileName:(NSString *)fileName {
    NSError *err = nil;
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kGroupId];
    containerURL = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Library/Caches/%@", fileName]];
    NSString *value = [NSString stringWithContentsOfURL:containerURL encoding:NSUTF8StringEncoding error:&err];
    return value;
}

+ (BOOL)isVipStatus {
    return NO;
}

- (FileName *)fileName {
    if (!_fileName) {
        _fileName = [[FileName alloc] init];
    }
    return _fileName;
}

@end

@implementation FileName

- (NSString *)openVpnConnectInfo {
    return @"kOpenVPNConnectInfo";
}


@end
