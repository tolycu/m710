
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface SOneVPTool : NSObject

+ (instancetype)shareInstance;

#pragma mark - 字符串
- (NSString *)readStringWithFileName:(NSString *)fileName;
- (BOOL)writeWithFileName:(NSString *)fileName contentStr:(NSString *)contentStr;

#pragma mark - 字典
- (BOOL)writeWithFileName:(NSString *)fileName dic:(NSDictionary *)dic;
- (NSDictionary *)readDicWithFileName:(NSString *)fileName;

- (NSString *)filePathWithFileName:(NSString *)fileName;

#pragma mark - 沙盒加密存数据
- (BOOL)Encrypt_writeDataWithFileContent:(NSString *)fileContent fileName:(NSString *)fileName;
- (NSString *)Encrypt_readFileContentWithFileName:(NSString *)fileName;
- (NSData *)Encrypt_readDataWithFileName:(NSString *)fileName;

/// 弹窗提示
/// @param controller 控制器
/// @param title 标题
/// @param comfirmTitle 确认按钮文字
/// @param cancelTitle 取消按钮文字
/// @param completionHandler 回调
+ (void)alertWithController:(nullable UIViewController *)controller
                      title:(NSString *)title
               comfirmTitle:(NSString *)comfirmTitle
                cancelTitle:(NSString *_Nullable)cancelTitle
   comfirmCompletionHandler:(void (^)(void))completionHandler;

+ (void)exitApplication;

/// 是否开启了VPN
+ (BOOL)isOpenVPNForDevice;


@end

NS_ASSUME_NONNULL_END
