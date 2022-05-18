
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (vpExtension)

- (id)vp_toArrayOrDictionary;
+ (nullable NSString*)vp_jsonFromObj:(id _Nonnull)obj;

+ (NSData * _Nonnull)vp_encryptAES:(NSString *)content;
+ (NSData *)vp_decryptAES:(NSData *)content;

@end

NS_ASSUME_NONNULL_END
