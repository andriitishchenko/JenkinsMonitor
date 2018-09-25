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
@property(strong,nonatomic) NSMutableDictionary* jobList;
+ (Manager*) sharedManager;
- (void) startService;
- (void) save;
- (void) load;

-(void)addURL:(NSString*)url;
@end
