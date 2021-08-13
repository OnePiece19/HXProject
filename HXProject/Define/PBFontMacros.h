//
//  PBFontMacros.h
//  PartyBuild
//
//  Created by HX on 2019/6/25.
//  Copyright © 2019 非公党建. All rights reserved.
//

#ifndef PBFontMacros_h
#define PBFontMacros_h


#warning todo   字体的全局设置

#define BOLDSYSTEMFONT(FONTSIZE)    [UIFont boldSystemFontOfSize:FONTSIZE]
#define SYSTEMFONT(FONTSIZE)        [UIFont systemFontOfSize:FONTSIZE]
#define FONT(NAME, FONTSIZE)        [UIFont fontWithName:(NAME) size:(FONTSIZE)]
// 粗体
#define kPBWideFont(fontSize) [UIFont fontWithName:@"PingFangSC-Medium" size:fontSize]
// 普通字体
#define kPBNormalFont(fontSize) [UIFont fontWithName:@"PingFangSC-Regular" size:fontSize]

#endif /* PBFontMacros_h */
