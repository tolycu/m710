//
//  M710_TextField.m
//  M710qr
//
//  Created by Hoho Wu on 2022/3/3.
//

#import "M710_TextField.h"

@implementation M710_TextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.font = [UIFont systemFontOfSize:16];
        self.textColor = [UIColor colorWithString:@"#1a1aa1a"];
        self.layer.cornerRadius = 14.f;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds{
    return CGRectMake(10, 0, bounds.size.width-20, bounds.size.height);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds{
    return CGRectMake(10, 0, bounds.size.width-20, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds{
    return CGRectMake(10, 0, bounds.size.width-20, bounds.size.height);
}

@end
