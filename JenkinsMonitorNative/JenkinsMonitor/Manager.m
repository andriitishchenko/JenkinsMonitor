//
//  Manager.m
//  JenkinsMonitor
//
//  Created by Andrii Tishchenko on 9/21/18.
//  Copyright © 2018 Andrii Tishchenko. All rights reserved.
//

#import "Manager.h"

NSString * const JobsUpdateNotification = @"JobsUpdateNotification";

@interface Manager()
@property(strong,nonatomic) NSMutableDictionary* jobList;
- (void)timerFire:(id)sender;
-(void)parceAndSave:(NSData*)data forKey:(NSString*)key;
@end


@implementation Manager
+ (Manager*)sharedManager{
  static Manager *sharedMyManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedMyManager = [[self alloc] init];
  });
  return sharedMyManager;
}

- (id)init {
  if (self = [super init]) {
    self.datasource = [NSMutableArray new];
  }
  return self;
}

-(void)addWorkerWithID:(NSString*)jobID{
  [self.jobList setObject:[NSDictionary dictionary] forKey:jobID];
}

-(void)startService {
  NSTimer * timer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
  [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
  [timer fire];
}


- (void)timerFire:(id)sender {
  NSDictionary* list = [self.jobList copy];
  
  if ([list count] == 0) {
    [self requestData:@"lastBuild"];
  }
  
  [list enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
    if ([[value allKeys] count] == 0) {
      [self requestData:key];
    }
    else{
      BOOL buildingStatus = [[value objectForKey :@"building"] boolValue];
      if (buildingStatus) {
          [self requestData:key];
      }
    }
  }];
}

-(void)requestData:(NSString*)key {
  if (!self.jobID) {
    return;
  }
  NSString* functionURL = [NSString stringWithFormat: @"%@/job/%@/%@/api/json",@"url", self.jobID, key];
  NSURL *url = [NSURL URLWithString:functionURL];
  NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
                                                           completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                             if (error) {
                                                               NSLog(@"Error: %@",error);
                                                             } else {
                                                               [self parceAndSave:data forKey:key];
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
 result : "SUCCESS"
 timestamp : 1537450518959
 url : "URL/job/App/455/"
 builtOn : "macbuild1"
 changeSet
 culprits
 
 */
-(void)parceAndSave:(NSData*)data forKey:(NSString*)key {
  NSError *e = nil;
  NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData: data
                                                             options: NSJSONReadingMutableContainers
                                                               error:&e];
  if (resultDict) {
    if ([key isEqualToString:@"lastBuild"]) {
      [self.jobList removeObjectForKey: key];
      NSNumber *buildID = [resultDict objectForKey:@"id"];
      [self.jobList setObject:resultDict forKey:buildID];
      NSInteger index = [buildID integerValue];
      for (NSInteger i=index; i>0 && i>index-5; i--) {
        [self addWorkerWithID: [@(i) stringValue]];
      }
    } else {
      [self.jobList setObject:resultDict forKey:key];
    }
    
    if ([[self.jobList allKeys] count] == 1 || [[self.jobList allKeys] indexOfObject: key]== 0) {
      [[NSNotificationCenter defaultCenter] postNotificationName:JobsUpdateNotification object:self];
    }
    
//    NSString *status = [resultDict objectForKey:@"result"];
//    BOOL buildingStatus = [[resultDict objectForKey :@"building"] boolValue];
//    NSNumber *buildID = [resultDict objectForKey:@"id"];
//    NSNumber *duration = [resultDict objectForKey:@"duration"];
//    NSNumber *timestamp = [resultDict objectForKey:@"timestamp"];
//    NSLog(@"STATUS: %@", status);
  }
}

- (void) dealloc {
  self.jobList = nil;
  self.datasource = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
