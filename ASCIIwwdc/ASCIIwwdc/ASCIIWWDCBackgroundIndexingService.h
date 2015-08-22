//
//  ASCIWWDCBackgroundIndexingService.h
//  ASCIIwwdc
//
//  Created by Guilherme Rambo on 04/06/15.
//  Copyright (c) 2015 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASCIIWWDCBackgroundIndexingService : NSObject

+ (void)runWithSessions:(NSArray /*<NSDictionary<NSString*, NSNumber*>*>*/ *)sessions;
+ (BOOL)hasIndex;

@end
