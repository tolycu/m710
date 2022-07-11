//
//  Szero_GlobalConfigModel.m
//  sportqr
//
//  Created by Hoho Wu on 2022/3/6.
//

#import "Szero_GlobalConfigModel.h"

@implementation Szero_GlobalConfigModel

+ (NSDictionary *)mj_objectClassInArray{
    return @{@"adCfgs" : [ADConfigModel class]};
}

+ (Class)objectClassInArray:(NSString *)propertyName{
    if ([propertyName isEqualToString:@"adCfgs"]) {
        return [ADConfigModel class];
    }
    return nil;
}

@end
