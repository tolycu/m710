//
//  AESencrytDecrypt.h
//  startvpn
//
//  Created by 李光尧 on 2020/12/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AESencrytDecrypt : NSObject

/**
 请求数据 重签名
 */
+ (NSString *)aesPostWithDict:(NSDictionary *)dict;

/**
 data 加密
 */
+ (NSData * _Nonnull)encryptAESWithContentData:(NSData *)contentData
                                           key:(NSString *)encryptKey
                                        vector:(NSString *)encryptVec
                                       keySize:(size_t)keySize;

/**
 string 加密
 */
+ (NSData * _Nonnull)encryptAES:(NSString *)content
                            key:(NSString *)encryptKey
                         vector:(NSString *)encryptVec
                        keySize:(size_t)keySize;
/**
 data 解密
 */
+ (NSData * _Nonnull)decryptAES:(NSData *)content key:(NSString *)key vector:(NSString *)vector keySize:(size_t)keySize;

@end

NS_ASSUME_NONNULL_END
