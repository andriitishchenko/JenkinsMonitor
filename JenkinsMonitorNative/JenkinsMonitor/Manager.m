//
//  Manager.m
//  JenkinsMonitor
//
//  Created by Andrii Tishchenko on 9/21/18.
//  Copyright © 2018 Andrii Tishchenko. All rights reserved.
//

#import "Manager.h"
#import "TableItem.h"

NSString *const FetchDataStartNotification = @"FetchDataStartNotification";
NSString *const FetchDataStopNotification = @"FetchDataStopNotification";

NSString *const JobsUpdateNotification = @"JobsUpdateNotification";
NSString *const userKey = @"jenkinsMonitorSave";

#ifdef DEBUG
NSTimeInterval const updateInterval = 10 * 3;
#else
NSTimeInterval const updateInterval = 60 * 3;
#endif

@interface Manager () <NSUserNotificationCenterDelegate>
- (void)timerFire:(id)sender;
- (void)parceAndSave:(NSData *)data forKey:(NSString *)key;
@end

@implementation Manager
+ (Manager *)sharedManager {
  static Manager *sharedMyManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedMyManager = [[self alloc] init];
  });
  return sharedMyManager;
}

- (id)init {
  if (self = [super init]) {
    self.jobList = [NSMutableDictionary new];
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    [self startService];
  }
  return self;
}

- (void)load {
  NSArray *list = [[NSUserDefaults standardUserDefaults] objectForKey:userKey];
  for (NSString *url in list) {
    [self addURL:url];
  }
}

- (void)addURL:(NSString *)url {
  if (url && [url length] > 0) {
    NSURL *testURL = [NSURL URLWithString:url];
    if (testURL) {
      NSString *validStr = [testURL absoluteString];
      if ([validStr hasSuffix:@"/"]) {
        validStr = [validStr substringToIndex:[validStr length] - 1];
      }

      TableItem *item = [TableItem new];
      item.url = validStr;
      [self.jobList setObject:item forKey:validStr];
      [self requestData:validStr onComplete:nil];
    }
  }
}
- (void)removeURLIndex:(NSInteger)index {
  NSString *keyURL = [[self.jobList allKeys] objectAtIndex:index];
  [self.jobList removeObjectForKey:keyURL];
  [self save];
}

- (void)startService {
  NSTimer *timer = [NSTimer timerWithTimeInterval:updateInterval
                                           target:self
                                         selector:@selector(timerFire:)
                                         userInfo:nil
                                          repeats:YES];
  [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
  [timer fire];
}

- (void)timerFire:(id)sender {
  NSDictionary *list = [self.jobList copy];

  if ([list count] == 0) {
    return;
  }

  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:FetchDataStartNotification
                                                        object:self];
  });
  __block NSInteger counter = [list count];
  [list enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
    [self requestData:key
           onComplete:^{
             counter--;
             if (counter == 0) {
               dispatch_async(dispatch_get_main_queue(), ^{
                 [[NSNotificationCenter defaultCenter]
                     postNotificationName:FetchDataStopNotification
                                   object:self];
               });
             }
           }];
  }];
}

- (void)requestData:(NSString *)job_url onComplete:(void (^)(void))onComplete {
  NSString *functionURL = [NSString stringWithFormat:@"%@/lastBuild/api/json", job_url];
  NSURL *url = [NSURL URLWithString:functionURL];
  NSURLSessionDataTask *task = [[NSURLSession sharedSession]
        dataTaskWithURL:url
      completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response,
                          NSError *_Nullable error) {
        if (error) {
          NSLog(@"Error: %@", error);
        } else {
          [self parceAndSave:data forKey:job_url];
        }
        if (onComplete) {
          onComplete();
        }
      }];
  [task resume];
}

/*
 JSON
 _class : "hudson.model.FreeStyleBuild"
 actions
 artifacts
 building : false
 description : null
 displayName : "#455"
 duration : 8364580
 estimatedDuration : 8369662
 executor : null
 fullDisplayName : "App #455"
 id : "455"
 keepLog : false
 number : 455
 queueId : 565
 result : "SUCCESS", "ABORTED", "FAILURE", null = Building
 timestamp : 1537450518959
 url : "URL/job/App/455/"
 builtOn : "macbuild1"
 changeSet
 culprits

 */
- (void)parceAndSave:(NSData *)data forKey:(NSString *)job_url {
  NSError *e = nil;
  NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:&e];
  if (resultDict) {
    TableItem *item = [TableItem new];
    item.url = job_url;
    item.buildID = [resultDict objectForKey:@"number"];
    item.result = [resultDict objectForKey:@"result"];
    item.duration = [resultDict objectForKey:@"duration"];
    item.timestamp = [resultDict objectForKey:@"timestamp"];
    item.fullDisplayName = [resultDict objectForKey:@"fullDisplayName"];

    TableItem *item_old = [self.jobList objectForKey:job_url];
    if (item_old.buildID) {
      if ([item.buildID isEqual:item_old.buildID]) {      // if NOT new build
        if (![item.result isEqual:[NSNull null]] &&       // if completed
            ![item.result isEqual:item_old.result] &&     // if changed
            ![item.result isEqualToString:@"SUCCESS"]) {  // if failed
          [self showNotification:[NSString stringWithFormat:@"Build #%@ is %@", item_old.buildID,
                                                            item.result]
                         message:@""];
        }
      }
    }
    [self.jobList setObject:item forKey:job_url];

    dispatch_async(dispatch_get_main_queue(), ^{
      [[NSNotificationCenter defaultCenter] postNotificationName:JobsUpdateNotification
                                                          object:self];
    });
  }
}

- (void)save {
  NSArray *list = [self.jobList allKeys];
  if ([list count] > 0) {
    [[NSUserDefaults standardUserDefaults] setObject:list forKey:userKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
}

- (void)dealloc {
  self.jobList = nil;
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification {
  return YES;
}

- (void)showNotification:(NSString *)title message:(NSString *)message {
  NSUserNotification *notification = [[NSUserNotification alloc] init];
  notification.title = title;
  notification.informativeText = message;
  notification.soundName = NSUserNotificationDefaultSoundName;
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
  });
}

@end
