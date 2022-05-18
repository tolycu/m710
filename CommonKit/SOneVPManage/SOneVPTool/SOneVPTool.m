
#import "SOneVPTool.h"
#import <ifaddrs.h>
#import <UIKit/UIKit.h>
#import "NSString+SOneExtension.h"



@implementation SOneVPTool

+ (instancetype)shareInstance {
    static SOneVPTool *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SOneVPTool alloc] init];
    });    
    return manager;
}

#pragma mark - 字符串
- (NSString *)readStringWithFileName:(NSString *)fileName {
    return [NSString stringWithContentsOfFile:[self filePathWithFileName:fileName] encoding:NSUTF8StringEncoding error:nil];
}

- (BOOL)writeWithFileName:(NSString *)fileName contentStr:(NSString *)contentStr {
    return [contentStr writeToFile:[self filePathWithFileName:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

#pragma mark - 字典
- (BOOL)writeWithFileName:(NSString *)fileName dic:(NSDictionary *)dic {
    return [dic writeToFile:[self filePathWithFileName:fileName] atomically:YES];
}

- (NSDictionary *)readDicWithFileName:(NSString *)fileName {
    return [NSDictionary dictionaryWithContentsOfFile:[self filePathWithFileName:fileName]];
}

#pragma mark -
// 沙盒路径
- (NSString *)filePathWithFileName:(NSString *)fileName {
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    docDir = [docDir stringByAppendingPathComponent:@"SFVPCache_705"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:docDir isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    docDir = [docDir stringByAppendingPathComponent:fileName];
    return docDir;
}


+ (void)alertWithController:(nullable UIViewController *)controller
                      title:(NSString *)title
               comfirmTitle:(NSString *)comfirmTitle
                cancelTitle:(NSString *_Nullable)cancelTitle
   comfirmCompletionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:title preferredStyle:UIAlertControllerStyleAlert];
    if (comfirmTitle.length > 0) {
        [alertVC addAction:[UIAlertAction actionWithTitle:comfirmTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (completionHandler) {
                completionHandler();
            }
        }]];
    }
    if (cancelTitle.length > 0) {
        [alertVC addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
    }
    if (!controller) {
        controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    [controller presentViewController:alertVC animated:YES completion:nil];
}

+ (void)exitApplication {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [UIView animateWithDuration:1.0f animations:^{
        window.alpha = 0;
    }completion:^(BOOL finished) {
        exit(0);
    }];
}

+ (BOOL)isOpenVPNForDevice {
   BOOL flag = NO;
   NSString *version = [UIDevice currentDevice].systemVersion;
   // need two ways to judge this.
   if (version.doubleValue >= 9.0) {
       NSDictionary *dict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
       NSArray *keys = [dict[@"__SCOPED__"] allKeys];
       for (NSString *key in keys) {
           if ([key rangeOfString:@"tap"].location != NSNotFound ||
               [key rangeOfString:@"tun"].location != NSNotFound ||
               [key rangeOfString:@"ipsec"].location != NSNotFound ||
               [key rangeOfString:@"ppp"].location != NSNotFound) {
               flag = YES;
               break;
           }
       }
   } else {
       struct ifaddrs *interfaces = NULL;
       struct ifaddrs *temp_addr = NULL;
       int success = 0;
       
       success = getifaddrs(&interfaces);
       if (success == 0) {
           // Loop through linked list of interfaces
           temp_addr = interfaces;
           while (temp_addr != NULL) {
               NSString *string = [NSString stringWithFormat:@"%s" , temp_addr->ifa_name];
               if ([string rangeOfString:@"tap"].location != NSNotFound ||
                   [string rangeOfString:@"tun"].location != NSNotFound ||
                   [string rangeOfString:@"ipsec"].location != NSNotFound ||
                   [string rangeOfString:@"ppp"].location != NSNotFound) {
                   flag = YES;
                   break;
               }
               temp_addr = temp_addr->ifa_next;
           }
       }
       // Free memory
       freeifaddrs(interfaces);
   }
   return flag;
}


#pragma mark - 沙盒加密存数据
- (BOOL)Encrypt_writeDataWithFileContent:(NSString *)fileContent fileName:(NSString *)fileName {
    // 存到沙盒
    if (fileContent.length > 0 && fileName.length > 0)  {
        NSData *data = [NSString vp_encryptAES:fileContent];
        return [data writeToFile:[self filePathWithFileName:fileName] atomically:YES];
    }
    return NO;
}

- (NSString *)Encrypt_readFileContentWithFileName:(NSString *)fileName  {
    NSData *data = [NSData dataWithContentsOfFile:[self filePathWithFileName:fileName]];
    data = [NSString vp_decryptAES:data];
    NSString *fileContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return fileContent;
}

- (NSData *)Encrypt_readDataWithFileName:(NSString *)fileName  {
    NSData *data = [NSData dataWithContentsOfFile:[self filePathWithFileName:fileName]];
    data = [NSString vp_decryptAES:data];
    return data;
}

@end
