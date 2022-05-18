


#import <Foundation/Foundation.h>
#import "SOneVPCertModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface SOneCertManage : NSObject

+ (instancetype)shareInstance;


@property (nonatomic, strong) SOneVPCertModel *certModel;
/// 是否是最新版本号
/// @param ver 版本号
- (BOOL)localIsLastestVersionWithVer:(NSInteger)ver;

/// 更新本地缓存
/// @param localCert 最新证书文件
/// @param ver 证书版本号
- (void)updateLocalCert:(NSDictionary *)localCert ver:(NSInteger)ver;

@end

NS_ASSUME_NONNULL_END
