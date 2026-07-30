//
//  YYCustomTabBar.m
//  homeworkFrame
//
//  Created by 汤冉阳 on 2020/5/20.
//  Copyright © 2020 汤冉阳. All rights reserved.
//

#import "YYCustomTabBar.h"

@implementation YYCustomTabBar

-(CGSize)sizeThatFits:(CGSize)size{
    CGSize sizeThatFits = [super sizeThatFits:size];
    sizeThatFits.height = sizeThatFits.height + 3;
    return sizeThatFits;
}

- (void)settingTabBar {
    
}


@end
