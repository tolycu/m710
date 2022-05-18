//
//  M710_Contants.h
//  m710qrcode
//
//  Created by xc-76 on 2022/4/21.
//

#ifndef M710_Contants_h
#define M710_Contants_h

static NSString * const BASE_URL = @"https://api2.ilovescanqr.com/";  /* 正式环境 */

static NSString * const BASE_Conf = @"expert/conf";
static NSString * const BASE_Vpn_List = @"expert/vpslist";
static NSString * const BASE_App_PostionInfo = @"util/expert/ipJson";
static NSString * const BASE_VPN_UpLoad = @"expert/servers";
static NSString * const BASE_VPNStatus_UpLoad = @"expert/serverstatus";
static NSString * const BASE_Vpn_Cer = @"expert/credentials";

static NSString *const APP_Launched = @"XC_APP_Launched"; /* APP第一次启动 */
static NSString *const Upload_Ping_Date = @"Upload_Ping_Date"; /* ping值上传时间 */
static NSString *const APP_Privacy_Agree = @"APP_Privacy_Agree"; /* 同意隐私协议 */

static NSString *const APP_QRCode_Cache = @"APP_QRCode_Cache"; /* 是否开启扫码缓存 */

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
static NSString *const XC_EncryptKey = @"X8s4ud7BFDTef5NF";
static NSString *const XC_EncryptInitVector = @"Jfs3h6075EtuMM24";
static NSString *const XC_DecryptKey = @"HTGGE576074bDx13";
static NSString *const XC_DecryptInitVector = @"H3TEff7Gud7BFD4b";

static NSString *const k_APPStore = @"https://apps.apple.com/app/id1623312350"; /* appstore */
static NSString *const k_APPStore_Write = @"https://apps.apple.com/app/id1623312350?action=write-review";
static NSString *const APP_EMAIL = @"wangzhen123452022@outlook.com"; /* e_mail */
static NSString *const privacy_url = @"https://scanner-lab.com/Privacy";
static NSString *const terms_url = @"https://scanner-lab.com/Service";

static NSString *const APP_shareText = @"The best Private VPN for iPhone. Fast and stable proxy you deserve.";


// 相机权限提示
static NSString *const APP_Camera_Alert = @"\"IQR-Scanning Expert\"Would Like to Access the Camera";
// 相册权限提示
static NSString *const APP_Photo_Alert = @"\"IQR-Scanning Expert\"Would Like to Access the Photo";
// 通信录权限提示
static NSString *const APP_Contacts_Alert = @"\"IQR-Scanning Expert\"Would Like to Access the Contacts";
// 第一次弹出相机权限
static NSString *const APP_Camera = @"APP_Camera";

static NSString *const History_Connect_VPNS = @"History_Connect_VPNS"; /* vpn */
static NSNotificationName const Current_Connect_Model = @"Current_Connect_Model"; /** 当前连接的VPN */
//关闭设置里的手电筒
static NSNotificationName const App_CloseFlash = @"App_CloseFlash";

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
