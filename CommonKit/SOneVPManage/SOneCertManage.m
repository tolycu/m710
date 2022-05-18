

#import "SOneCertManage.h"
#import "SOneVPTool.h"
#import "NSString+SOneExtension.h"
#import "SOneVPUserDefaults.h"
#import <MJExtension/MJExtension.h>

static NSString *const kRemoteCertFileName = @"kRemoteCertFileName";

@interface SOneCertManage () {
    SOneVPCertModel *_certModel;
}


@end

@implementation SOneCertManage

+ (instancetype)shareInstance {
    static SOneCertManage *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SOneCertManage alloc] init];
        [manager configContent];
    });
    return manager;
}

- (void)configContent {
    NSDictionary *dic = [[SOneVPTool shareInstance] readDicWithFileName:kRemoteCertFileName];
    
    NSMutableDictionary *localDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    if (!(localDic.allKeys.count > 0)) {
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:kRemoteCertFileName withExtension:nil];
        NSData *fileData = [[NSData alloc] initWithContentsOfURL:fileUrl];
        fileData = [NSString vp_decryptAES:fileData];
        NSString *fileContent = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
        
        localDic = [[NSMutableDictionary alloc] initWithDictionary:[fileContent vp_toArrayOrDictionary]];
        // 处理本地数据的版本号
        if ([localDic.allKeys containsObject:@"cerVer"]) {
            [localDic setObject:@0 forKey:@"cerVer"];
        }
    }
    _certModel = [SOneVPCertModel mj_objectWithKeyValues:localDic];
}

#pragma mark - public
/// 是否是最新的证书
- (BOOL)localIsLastestVersionWithVer:(NSInteger)ver {
    return !(ver > self.certModel.cerVer);
}

/// 更新本地缓存
/// @param localCert 最新证书文件
/// @param ver 证书版本号
- (void)updateLocalCert:(NSDictionary *)localCert ver:(NSInteger)ver {
    if (![self localIsLastestVersionWithVer:ver]) {
        NSMutableDictionary *localData = [[NSMutableDictionary alloc] initWithDictionary:localCert];
        [localData setObject:@(ver) forKey:@"cerVer"];
        
        BOOL result = [[SOneVPTool shareInstance] Encrypt_writeDataWithFileContent:[NSString vp_jsonFromObj:localData] fileName:kRemoteCertFileName];
        if (result) {
            _certModel = [SOneVPCertModel mj_objectWithKeyValues:localData];
        }
    }
}

@end
