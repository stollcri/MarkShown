//
//  MarkShow.h
//  MarkShown
//
//  Created by Christopher Stoll on 12/30/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MarkShow : NSManagedObject

@property (nonatomic, retain) NSString * presentationContent;
@property (nonatomic, retain) NSString * presentationName;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * presentationCSS;

@end
