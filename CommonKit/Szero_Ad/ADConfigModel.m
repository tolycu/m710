//
//  ADConfigModel.m
//  sportqr
//
//  Created by Hoho Wu on 2022/3/30.
//

#import "ADConfigModel.h"
#import "MJExtension.h"

@implementation ADDataModel


@end



@implementation ADConfigModel

+ (NSDictionary *)mj_objectClassInArray{
    return @{@"expert_adSource" : [ADDataModel class]};
}

+ (Class)objectClassInArray:(NSString *)propertyName{
    if ([propertyName isEqualToString:@"expert_adSource"]) {
        return [ADDataModel class];
    }
    return nil;
}

@end
