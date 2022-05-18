
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOneVPUserDefaults : NSObject


+ (void)saveWithObj:(id)obj key:(NSString *)key;
+ (void)saveWithInt:(NSInteger)value key:(NSString *)key;
+ (NSInteger)intValueForKey:(NSString *)key;
+ (id)objForKey:(NSString *)key;
+ (void)removeObjForKey:(NSString *)key;

+ (void)saveSerializedObj:(id)obj key:(NSString *)key;
+ (id)getSerializedObjForKey:(NSString *)key;
+ (void)removeSerializedObjForKey:(NSString *)key;


@end

NS_ASSUME_NONNULL_END
