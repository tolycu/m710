//
//  Carmera_GlobalMananger.m
//  camera
//
//  Created by 李光尧 on 2021/12/27.
//

#import "Expert_GlobalMananger.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>

#import <ContactsUI/CNContactViewController.h>
#import <ContactsUI/CNContactPickerViewController.h>
#import <Social/Social.h>

#import "HomeAdapter.h"

#define kBundleIdentifier [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]

@interface Expert_GlobalMananger ()<CNContactPickerDelegate,CNContactViewControllerDelegate,MFMailComposeViewControllerDelegate>

@property(nonatomic,strong) CNContactViewController *controller;

@end


@implementation Expert_GlobalMananger

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static Expert_GlobalMananger *tool;
    dispatch_once(&onceToken, ^{
        tool = [self new];
    });
    return tool;
}


-(instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (void)changeVpnStatue:(NEVPNStatus)status{
    [self willChangeValueForKey:@"status"];
    self.status = status;
    [self didChangeValueForKey:@"status"];
}

- (BOOL)checkoutSelect:(Expert_ServerVPNModel *)vpnModel{
    if (Adapter_MANAGE.bestServer) {
        if ([vpnModel.expert_host isEqualToString:Adapter_MANAGE.bestServer.expert_host]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)deptNumInputShouldNumber:(NSString *)string{
    
    NSString *regex =@"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:string]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isBarCodeNumText:(NSString *)str{
    NSString * regex = @"^[0-9]*$";
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    if (isMatch && str.length) {
        return YES;
    }else{
        return NO;
    }
}

+ (DataStringQRType)qrDataAnalysisType:(NSString *)string{
    string = [string uppercaseString];
    NSArray *tempArr = [string componentsSeparatedByString:@":"];
    NSString *header = tempArr.firstObject;
    if (tempArr.count > 1) {
        if ([header isEqualToString:QR_Phone]) {
            return DataStringQRType_phone;
        }else if ([string jk_containsaString:QR_VCARD]){
            return DataStringQRType_card;
        }else if ([header jk_containsaString:@"WIFI"]){
            return DataStringQRType_wifi;
        }else if ([header jk_containsaString:QR_Whatsapp]){
            return DataStringQRType_whatsapp;
        }else if ([header jk_containsaString:QR_HTTP]){
            return DataStringQRType_url;
        }else if ([header jk_containsaString:QR_PRODUCT]){
            return DataStringQRType_barcode;
        }else if ([string jk_containsaString:QR_TwitterName] ||
                  [string jk_containsaString:QR_TwitterUrl]){
            return DataStringQRType_Twitter;
        }else if ([header jk_containsaString:QR_fbID] ||
                  [header jk_containsaString:QR_fbUrl]){
            return DataStringQRType_FB;
        }
    }
    return DataStringQRType_text;
}





+ (BOOL)checkoutDeviceIsiPad{
    NSString *deviceType = [UIDevice currentDevice].model;
    if ([deviceType isEqualToString:@"iPad"]) {
        return YES;
    }
    return NO;
}

- (NSString *)getDeviceIMSI {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    NSString *mcc = [carrier mobileCountryCode];
    NSString *mnc = [carrier mobileNetworkCode];
        
    if (mcc != nil && mnc != nil) {
        NSString *imsi = [NSString stringWithFormat:@"%@%@", mcc, mnc];
        return imsi;
    } else {
        return @"";
    }
}


- (NSString *)getDeviceISOCountryCode {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
//    BOOL use = carrier.allowsVOIP;
//    NSString *name = carrier.carrierName;
    NSString *code = carrier.isoCountryCode;
    
    if (code != nil) {
        return code;
    } else {
        return @"";
    }
}

- (NSString *)getDeviceIDInKeychain {
    NSString *saveKey = [NSString stringWithFormat:@"%@%@", kBundleIdentifier, @"saveKey"];
    NSString *getUDIDInKeychain = (NSString *)[self load:saveKey];
    if (!getUDIDInKeychain ||[getUDIDInKeychain isEqualToString:@""]||[getUDIDInKeychain isKindOfClass:[NSNull class]]) {
        CFUUIDRef uuid = CFUUIDCreate(nil);
        CFStringRef uuidString = CFUUIDCreateString(nil,uuid);
        NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL, uuidString));
        CFRelease(uuid);
        CFRelease(uuidString);
        [self save:saveKey data:result];
        getUDIDInKeychain = (NSString *)[self load:saveKey];
    }
    getUDIDInKeychain = [getUDIDInKeychain stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return getUDIDInKeychain.lowercaseString;
}

- (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
   return [NSMutableDictionary dictionaryWithObjectsAndKeys:
          (__bridge_transfer id)kSecClassGenericPassword,(__bridge_transfer id)kSecClass,
           service, (__bridge_transfer id)kSecAttrService,
           service, (__bridge_transfer id)kSecAttrAccount,
          (__bridge_transfer id)kSecAttrAccessibleAfterFirstUnlock,(__bridge_transfer id)kSecAttrAccessible,
          nil];
}

-(void)save:(NSString *)service data:(id)data {
   //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
   //Delete old item before add new item
   SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
   //Add new object to search dictionary(Attention:the data format)
   [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge_transfer id)kSecValueData];
   //Add item to keychain with the search dictionary
   SecItemAdd((__bridge_retained CFDictionaryRef)keychainQuery, NULL);
}
  
- (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
   //Configure the search setting
   [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];
   [keychainQuery setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];
    CFDataRef keyData = NULL;
   if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
       @try {
          ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)keyData];
       } @catch (NSException *e) {
          NSLog(@"Unarchive of %@ failed: %@", service, e);
       } @finally {
       }
    }
    return ret;
}

- (void)showAlterToPrivacy:(NSString *)title{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Don't Allow" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:confirm];
    [alertVC addAction:cancelAction];
    [[self currentController] presentViewController:alertVC animated:YES completion:nil];
}

- (void)startShareString:(NSString *)string{
    //调用系统的分享
    NSArray *activityItemsArray = @[@"IQR-Scanning Expert",string];
    
    UIActivity *ty = [[UIActivity alloc] init];
    [ty prepareWithActivityItems:activityItemsArray];
    NSArray *activityArray = @[ty];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItemsArray applicationActivities:activityArray];
    if ([activityVC respondsToSelector:@selector(popoverPresentationController)]) {
            activityVC.popoverPresentationController.sourceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            activityVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 30, 30);
            activityVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
    [[self currentController] presentViewController:activityVC animated:YES completion:nil];
}

- (void)startShareImage:(UIImage *)image{
    //调用系统的分享
    NSArray *activityItemsArray = @[@"IQR-Scanning Expert",image];
    
    UIActivity *ty = [[UIActivity alloc] init];
    [ty prepareWithActivityItems:activityItemsArray];
    NSArray *activityArray = @[ty];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItemsArray applicationActivities:activityArray];
    if ([activityVC respondsToSelector:@selector(popoverPresentationController)]) {
            activityVC.popoverPresentationController.sourceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            activityVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 30, 30);
            activityVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
    [[self currentController] presentViewController:activityVC animated:YES completion:nil];
}

- (void)startShare{
    //调用系统的分享
    NSURL *shareUrl = [NSURL URLWithString:k_APPStore];
    NSArray *activityItemsArray = @[APP_shareText,shareUrl];
    
    UIActivity *ty = [[UIActivity alloc] init];
    [ty prepareWithActivityItems:activityItemsArray];
    NSArray *activityArray = @[ty];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItemsArray applicationActivities:activityArray];
    if ([activityVC respondsToSelector:@selector(popoverPresentationController)]) {
            activityVC.popoverPresentationController.sourceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            activityVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 30, 30);
            activityVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
    [[self currentController] presentViewController:activityVC animated:YES completion:nil];
}


#pragma mark - 发送邮件
- (void)sendEmail {
    [self sendEmailAddress:APP_EMAIL];
}

#pragma mark - 发送VIP邮件
- (void)sendEmailAddress:(NSString *)address {
    MFMailComposeViewController *mailVC = [MFMailComposeViewController new];
    if (!mailVC) {
        [[self currentController].view makeToast:@"No email account has been set up yet. Please go to the system to add an account first" duration:1.5 position:CSToastPositionCenter];
        return;
    }
    mailVC.mailComposeDelegate = self;
    [mailVC setSubject:@"[IQR-Scanning Expert] Feedback"];
    [mailVC setToRecipients:@[address]];
    [[self currentController] presentViewController:mailVC animated:YES completion:nil];
}


// 实现代理方法
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result == MFMailComposeResultSent) {
        NSLog(@"发送成功");
    } else if (result == MFMailComposeResultFailed) {
        NSLog(@"发送失败");
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 相册权限检测
- (void)isCanVisitPhotoLibrary:(void(^)(BOOL isAllow))result {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        result(YES);
    }else if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted){
        [TOOL_MANAGE showAlterToPrivacy:APP_Photo_Alert];
        result(NO);
    }else{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            // 回调是在子线程的
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    result(YES);
                }else{
                    result(NO);
                }
            });
        }];
    }
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
      
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
      
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
      
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
              
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
              
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
      
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
              
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
         // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                                 CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                                 CGImageGetColorSpace(aImage.CGImage),
                                                 CGImageGetBitmapInfo(aImage.CGImage));
        CGContextConcatCTM(ctx, transform);
        switch (aImage.imageOrientation) {
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                // Grr...
                CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
                break;
                  
            default:
                CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
                break;
        }
          
        // And now we just create a new UIImage from the drawing context
        CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
        UIImage *img = [UIImage imageWithCGImage:cgimg];
        CGContextRelease(ctx);
        CGImageRelease(cgimg);
        return img;
    }


+ (void)checkoutAdPrivacy:(nullable void(^)(BOOL allow))result{
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            NSString *idfa = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
            NSLog(@"IDFA---%@",idfa);
            dispatch_async(dispatch_get_main_queue(), ^{
                // 获取到权限后，依然使用老方法获取idfa
                if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                    if (result) {
                        result(YES);
                    }
                } else {
                    if (result) {
                        result(NO);
                    }
                }
            });
        }];
    } else {
        // 判断在设置-隐私里用户是否打开了广告跟踪
        if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
            NSString *idfa = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
            NSLog(@"%@",idfa);
            if (result) {
                result(YES);
            }
        } else {
            if (result) {
                result(NO);
            }
        }
    }
}



- (CAGradientLayer *)setGradualChangingColor:(UIView *)view fromColor:(UIColor *)fromHexColorStr toColor:(UIColor *)toHexColorStr{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.bounds;
    gradientLayer.colors = @[(__bridge id)fromHexColorStr.CGColor,(__bridge id)toHexColorStr.CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    gradientLayer.locations = @[@0.5,@1];
    return gradientLayer;
}


- (void)saveMeCardNewContact:(NSString *)string{
    NSArray *tempArr = [[string stringByReplacingOccurrencesOfString:@"MECARD:" withString:@""] componentsSeparatedByString:@";"];
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    for (NSString *object in tempArr) {
        NSArray *strArr = [object componentsSeparatedByString:@":"];
        [mutDic jk_setObj:strArr.lastObject forKey:strArr.firstObject];
    }
    Expert_CardModel *model = [Expert_CardModel mj_objectWithKeyValues:mutDic];
    if (!model.TEL || !model.N) {
        [[self currentController].view makeToast:@"Unable to open" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    CNMutableContact *contact = [[CNMutableContact alloc] init];
    [self setExpert_CardModel:model ForContact:contact existContect:NO];
    _controller = [CNContactViewController viewControllerForNewContact:contact];
    _controller.delegate = self;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:_controller];
    navigation.navigationBar.backgroundColor = [UIColor colorWithString:@"#35E89B"];
    [[self currentController] presentViewController:navigation animated:YES completion:nil];
}

- (void)saveVCardNewContact:(NSString *)string{
    
    NSArray *tempArr = [string componentsSeparatedByString:@"\r\n"];
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    for (NSString *object in tempArr) {
        NSArray *strArr = [object componentsSeparatedByString:@":"];
        [mutDic jk_setObj:strArr.lastObject forKey:strArr.firstObject];
    }
    Expert_CardModel *model = [Expert_CardModel mj_objectWithKeyValues:mutDic];
    
    if (!model.TEL || !model.N) {
        [[self currentController].view makeToast:@"Unable to open" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    CNMutableContact *contact = [[CNMutableContact alloc] init];
    [self setExpert_CardModel:model ForContact:contact existContect:NO];
    _controller = [CNContactViewController viewControllerForNewContact:contact];
    _controller.delegate = self;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:_controller];
    navigation.navigationBar.backgroundColor = [UIColor colorWithString:@"#35E89B"];
    [[self currentController] presentViewController:navigation animated:YES completion:nil];
}


//设置要保存的contact对象
- (void)setExpert_CardModel:(Expert_CardModel *)model ForContact:(CNMutableContact *)contact existContect:(BOOL)exist{
    if (!exist) {
        NSArray *nameArr;
        if ([model.N jk_containsaString:@";"]) {
            nameArr = [model.N componentsSeparatedByString:@";"];
        }else{
            nameArr = [model.N componentsSeparatedByString:@","];
        }
        if (nameArr.count>1) {
            contact.familyName = nameArr.lastObject;
            contact.givenName = nameArr.firstObject;
        }else{
            contact.givenName = model.N;
        }
        //电话
        CNLabeledValue *phoneNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:model.TEL]];
        contact.phoneNumbers = @[phoneNumber];
        
        //网址:
        if (model.URL) {
            CNLabeledValue *url = [CNLabeledValue labeledValueWithLabel:CNLabelURLAddressHomePage value:model.URL];
            contact.urlAddresses = @[url];
        }
        
        //邮箱:
        if (model.EMAIL) {
            CNLabeledValue *mail = [CNLabeledValue labeledValueWithLabel:CNLabelEmailiCloud value:model.EMAIL];
            contact.emailAddresses = @[mail];
        }
        
        //注意:
        if (model.NOTE) {
            contact.note = model.NOTE;
        }
        //昵称
        if (model.NICKNAME) {
            contact.nickname = model.NICKNAME;
        }
    }
}

- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact{
    
    [self.controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)pushHideTabbarController:(UIViewController *)controller{
    [self currentController].hidesBottomBarWhenPushed = YES;
    [[self currentController].navigationController pushViewController:controller animated:YES];
    [self currentController].hidesBottomBarWhenPushed = NO;
}

- (void)sendSMS:(NSString *)string{
    NSString *smsContentStr = [string stringByReplacingOccurrencesOfString:@"SMS:" withString:@""];
    NSArray *tempArr = [smsContentStr componentsSeparatedByString:@":"];
    NSString *urlStr = [NSString stringWithFormat:@"sms:%@//&body=%@", tempArr.firstObject,tempArr.lastObject];
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]; // 对中文进行编码
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:url];
    }
}


/**
 选择购物平台
 */
- (void)showSelectPlatform:(NSString *)string{
    
    string = [string stringByReplacingOccurrencesOfString:@"Product:" withString:@""];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:@"Choose one to open this product." preferredStyle:[Expert_GlobalMananger checkoutDeviceIsiPad]?UIAlertControllerStyleAlert:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *google = [UIAlertAction actionWithTitle:@"Google Shopping" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        Expert_WebViewController *vc = [Expert_WebViewController new];
        vc.url = [NSString stringWithFormat:@"%@%@",P_Google,string];
        [TOOL_MANAGE pushHideTabbarController:vc];
    }];
    UIAlertAction *amazon = [UIAlertAction actionWithTitle:@"Amazon" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        Expert_WebViewController *vc = [Expert_WebViewController new];
        vc.url = [NSString stringWithFormat:@"%@%@",P_Amazon,string];
        [TOOL_MANAGE pushHideTabbarController:vc];
    }];

    UIAlertAction *ebay = [UIAlertAction actionWithTitle:@"EBay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        Expert_WebViewController *vc = [Expert_WebViewController new];
        vc.url = [NSString stringWithFormat:@"%@%@",P_Ebay,string];
        [TOOL_MANAGE pushHideTabbarController:vc];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:google];
    [alertVC addAction:amazon];
    [alertVC addAction:ebay];
    [alertVC addAction:cancelAction];
    [[self currentController] presentViewController:alertVC animated:YES completion:nil];
}


- (BOOL)isHaveScan:(NSString *)stringValue{
    NSArray *historys = [[NSUserDefaults standardUserDefaults] objectForKey:@"Scan_History"];
    __block BOOL isHave = NO;
    [historys jk_each:^(NSDictionary *object) {
        NSString *tempStr = [object jk_stringForKey:@"resultStr"];
        if ([stringValue isEqualToString:tempStr]) {
            isHave = YES;
        }
    }];
    return isHave;
}

- (void)saveScan:(NSString *)stringValue{
    
    if (![NSUserDefaults jk_boolForKey:APP_QRCode_Cache]) {
        return;
    }
    
    NSString *dateStr = [NSDate jk_currentDateStringWithFormat:@"MM/dd/YYYY"];
    NSString *keyStr = @"Scan_History";
    
    NSArray *historys = [[NSUserDefaults standardUserDefaults] objectForKey:keyStr];
    NSMutableArray *mutArr = [NSMutableArray arrayWithArray:historys];
    if ([self isHaveScan:stringValue]) {
        [mutArr removeObject:stringValue];
    }
    [mutArr insertObject:@{@"resultStr":stringValue,@"dateStr":dateStr} atIndex:0];
    [NSUserDefaults jk_setObject:mutArr forKey:keyStr];
}

- (BOOL)isHaveCreate:(NSString *)stringValue{
    NSString *keyStr = @"Creat_History";
    NSArray *historys = [[NSUserDefaults standardUserDefaults] objectForKey:keyStr];
    __block BOOL isHave = NO;
    [historys jk_each:^(NSDictionary *object) {
        NSString *tempStr = [object jk_stringForKey:@"resultStr"];
        if ([stringValue isEqualToString:tempStr]) {
            isHave = YES;
        }
    }];
    return isHave;
}

- (void)saveCreat:(NSString *)stringValue{
    
    if (![NSUserDefaults jk_boolForKey:APP_QRCode_Cache]) {
        return;
    }
    NSString *dateStr = [NSDate jk_currentDateStringWithFormat:@"MM/dd/YYYY"];
    NSString *keyStr = @"Creat_History";
    
    NSArray *historys = [[NSUserDefaults standardUserDefaults] objectForKey:keyStr];
    NSMutableArray *mutArr = [NSMutableArray arrayWithArray:historys];
    if ([self isHaveCreate:stringValue]) {
        [mutArr removeObject:stringValue];
    }
    [mutArr insertObject:@{@"resultStr":stringValue,@"dateStr":dateStr} atIndex:0];
    [NSUserDefaults jk_setObject:mutArr forKey:keyStr];
}


@end
