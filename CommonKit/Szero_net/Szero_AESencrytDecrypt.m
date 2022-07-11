//
//  Szero_AESencrytDecrypt.m
//  startvpn
//
//  Created by 李光尧 on 2020/12/4.
//

#import "Szero_AESencrytDecrypt.h"

@implementation Szero_AESencrytDecrypt


+ (NSString *)aesPostWithDict:(NSDictionary *)dict {
    static NSString *kAESSignKey = @"api2.ilovescanqr.com";
    NSString *jsonString = [NSString stringWithFormat:@"%@%@", kAESSignKey, [dict mj_JSONString]];
    NSData *testData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];//字符串转化成 data
    char *dataByte = (char *)[testData bytes];
    NSInteger len = testData.length + 1;
    char *newByte = malloc(sizeof(char)*(len));
    newByte[0] = kAESSignKey.length; //增加签名长度
    for (int i = 1; i <= [testData length]; i++)
    {
        newByte[i] = dataByte[i - 1];
    }
    //byte-->data-->string
    NSData *adata = [[NSData alloc] initWithBytes:newByte length:len];
    NSString *result = [[NSString alloc] initWithData:adata encoding:NSUTF8StringEncoding];
    
    free(newByte);
    return result;
}

+ (NSData * _Nonnull)encryptAESWithContentData:(NSData *)contentData
                                           key:(NSString *)encryptKey
                                        vector:(NSString *)encryptVec
                                       keySize:(size_t)keySize {
    
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
    if (cryptStatus == kCCSuccess)
    { //对加密后的数据进行 base64 编码

        NSData *data = [NSData dataWithBytesNoCopy:encryptedBytes length:actualOutSize];
//        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return data;
    }
    free(encryptedBytes);
    return nil;

}

+ (NSData * _Nonnull)encryptAES:(NSString *)content
                            key:(NSString *)encryptKey
                         vector:(NSString *)encryptVec
                        keySize:(size_t)keySize {
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    return [self encryptAESWithContentData:contentData key:encryptKey vector:encryptVec keySize:keySize];
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
