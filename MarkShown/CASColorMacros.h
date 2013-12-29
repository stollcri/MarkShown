//
//  CASColorMacros.h
//  MarkShown
//
//  Created by Christopher Stoll on 12/28/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#ifndef MarkShown_CASColorMacros_h
#define MarkShown_CASColorMacros_h

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//RGB color macro with alpha
#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#endif
