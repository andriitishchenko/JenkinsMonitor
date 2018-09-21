//
//  Manager.h
//  JenkinsMonitor
//
//  Created by Andrii Tishchenko on 9/21/18.
//  Copyright © 2018 Andrii Tishchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const JobsUpdateNotification;

@interface Manager : NSObject
@property(strong,nonatomic) NSString* jobID;
@property(strong,nonatomic) NSMutableArray* datasource;
+ (Manager*) sharedManager;
- (void) startService;
@end
