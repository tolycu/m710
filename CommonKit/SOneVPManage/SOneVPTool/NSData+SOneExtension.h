
   


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (vp_Extension)

+ (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier;

+ (NSData *)searchKeychainCopyMatching:(NSString *)identifier;

+ (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier;



@end

NS_ASSUME_NONNULL_END
