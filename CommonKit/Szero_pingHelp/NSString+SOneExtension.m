

#import "NSString+SOneExtension.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>


/// 客户端本地涉及到的加密操作
NSString *const kEncryptInitVector = @"10af4d2f3a5ba8ed";
NSString *const kEncryptKey = @"3ac5f19cd7378a12";


@implementation NSString (vpExtension)

- (id)vp_toArrayOrDictionary {
    NSData *jsonData=[self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }
    if(error){
        NSLog(@"json解析失败：%@",error);
    }
    return nil;
}

+ (nullable NSString*)vp_jsonFromObj:(id _Nonnull)obj {
    if (!obj) {
        return nil;
    }
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark - 加密解密
//确定密钥长度，这里选择 AES-128。
+ (NSData * _Nonnull)vp_encryptAES:(NSString *)content {
    return [self encryptAES:content key:kEncryptKey vector:kEncryptInitVector keySize:kCCKeySizeAES128];
}

+ (NSData *)vp_decryptAES:(NSData *)content {
    return [self decryptAES:content key:kEncryptKey vector:kEncryptInitVector keySize:kCCKeySizeAES128];
}

+ (NSData * _Nonnull)encryptAES:(NSString *)content
                            key:(NSString *)encryptKey
                         vector:(NSString *)encryptVec
                        keySize:(size_t)keySize {
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = contentData.length;
    // 为结束符'\\0' +1
    char keyPtr[keySize + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [encryptKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    // 密文长度 <= 明文长度 + BlockSize
    size_t encryptSize = dataLength + kCCBlockSizeAES128;
    void *encryptedBytes = malloc(encryptSize);
    size_t actualOutSize = 0;
    NSData *initVector = [encryptVec dataUsingEncoding:NSUTF8StringEncoding];
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,  //系统默认使用CBC，然后指明使用PKCS7Padding
                                          keyPtr,
                                          keySize,
                                          initVector.bytes,
                                          contentData.bytes,
                                          dataLength,
                                          encryptedBytes,
                                          encryptSize,
                                          &actualOutSize);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytesNoCopy:encryptedBytes length:actualOutSize];
        return data;
    }
    free(encryptedBytes);
    return nil;
}

+ (NSData * _Nonnull)decryptAES:(NSData *)content key:(NSString *)key vector:(NSString *)vector keySize:(size_t)keySize {
    // 把base64 String 转换成 Data
    NSUInteger dataLength = content.length;
    char keyPtr[keySize + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    size_t decryptSize = dataLength + kCCBlockSizeAES128;
    void *decryptedBytes = malloc(decryptSize);
    size_t actualOutSize = 0;
    NSData *initVector = [vector dataUsingEncoding:NSUTF8StringEncoding];
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          keySize,
                                          initVector.bytes,
                                          content.bytes,
                                          dataLength,
                                          decryptedBytes,
                                          decryptSize,
                                          &actualOutSize);
    if (cryptStatus == kCCSuccess)
    {
        NSData *data = [NSData dataWithBytesNoCopy:decryptedBytes length:actualOutSize];
        return data;
    }
    free(decryptedBytes);
    
    return nil;
}




@end
