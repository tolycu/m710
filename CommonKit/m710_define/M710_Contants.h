//
//  M710_Contants.h
//  m710qrcode
//
//  Created by xc-76 on 2022/4/21.
//

#ifndef M710_Contants_h
#define M710_Contants_h


static NSString *const QR_Phone = @"TEL"; /*  电话 */
static NSString *const QR_VCARD = @"VCARD"; /* 联系人 VCard */
static NSString *const QR_TwitterName = @"twitter://user?screen_name="; /* twitter name */
static NSString *const QR_TwitterUrl = @"https://twitter.com/"; /* twitter url */
static NSString *const QR_fbID = @"fb://profile/"; /* twitter name */
static NSString *const QR_fbUrl = @"https://www.facebook.com/profile.php?id="; /* twitter url */

static NSString *const QR_Whatsapp = @"whatsapp:send?phone="; /* whatsapp */
static NSString *const QR_HTTP = @"HTTP"; /* 网址 */
static NSString *const QR_PRODUCT = @"PRODUCT"; /* 产品 */

static NSString *const P_Google = @"https://www.google.com/m?q="; /* google */
static NSString *const P_Amazon = @"https://www.amazon.com/s?k="; /* amazon */
static NSString *const P_Ebay = @"https://www.ebay.com/sch/i.html?_nkw="; /* ebay */

/// 和后台交互的加密操作
static NSString *const XC_EncryptKey = @"H3TEff7Gh5uf5Etu";
static NSString *const XC_EncryptInitVector = @"HTGGE57ThHTef5NF";
static NSString *const XC_DecryptKey = @"GESG3YsagHRGSge2";
static NSString *const XC_DecryptInitVector = @"GSEg2rJyG6Yg3GEX";

static NSString *const k_APPStore = @"https://apps.apple.com/app/id1612611744"; /* appstore */
static NSString *const APP_EMAIL = @"scannerlabfor709@protonmail.com"; /* e_mail */
static NSString *const privacy_url = @"https://scanner-lab.com/Privacy";
static NSString *const terms_url = @"https://scanner-lab.com/Service";

static NSString *const APP_shareText = @"The best Private VPN for iPhone. Fast and stable proxy you deserve.";


// 相机权限提示
static NSString *const APP_Camera_Alert = @"\"ScannerLab\"Would Like to Access the Camera";
// 相册权限提示
static NSString *const APP_Photo_Alert = @"\"ScannerLab\"Would Like to Access the Photo";
// 通信录权限提示
static NSString *const APP_Contacts_Alert = @"\"ScannerLab\"Would Like to Access the Contacts";

// 第一次弹出相机权限
static NSString *const APP_Camera = @"APP_Camera";

// 订阅广告
typedef NS_ENUM(NSUInteger, DataStringQRType) {
    DataStringQRType_text = 0,
    DataStringQRType_phone = 1,
    DataStringQRType_card = 2,
    DataStringQRType_url = 3,
    DataStringQRType_wifi = 4,
    DataStringQRType_barcode = 5,
    DataStringQRType_FB = 6,
    DataStringQRType_whatsapp = 7,
    DataStringQRType_Twitter = 8,
};

#endif /* M710_Contants_h */
