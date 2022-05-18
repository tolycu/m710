
#import "SOneVPUserDefaults.h"

@implementation SOneVPUserDefaults

+ (void)saveWithObj:(id)obj key:(NSString *)key {
    if(nil != obj && nil != key){
        [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)removeObjForKey:(NSString *)key {
    if(key){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)saveWithInt:(NSInteger)value key:(NSString *)key {
    if(nil != key){
        [[NSUserDefaults standardUserDefaults] setInteger:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSInteger)intValueForKey:(NSString *)key {
    if (nil != key) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:key];
    }
    return 0;
}

+ (id)objForKey:(NSString *)key {
    if (nil != key) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    }
    return nil;
}

+ (void)saveSerializedObj:(id)obj key:(NSString *)key {
    NSData *serialized = [NSKeyedArchiver archivedDataWithRootObject:obj];
    if(serialized){
        [[NSUserDefaults standardUserDefaults] setObject:serialized forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (id)getSerializedObjForKey:(NSString *)key {
    if (nil != key) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:key]];
    }
    return nil;
}

+ (void)removeSerializedObjForKey:(NSString *)key {
    if (nil != key) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
