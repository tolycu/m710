
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const kStartConnectByApp = @"kStartConnectByApp";
static NSString *const kStopConnectByApp = @"kStopConnectByApp";



@class FileName;
@interface SOneVPTransferManage : NSObject
+ (instancetype)shareInstance;
+ (void)setObject:(id)value forKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key;

+ (BOOL)saveFile:(NSString *)fileContent fileName:(NSString *)fileName;
+ (NSString *)fileContentWithFileName:(NSString *)fileName;

+ (BOOL)isVipStatus;

@property (nonatomic, strong) FileName *fileName;

@end

@interface FileName : NSObject

- (NSString *)openVpnConnectInfo;

@end
NS_ASSUME_NONNULL_END
