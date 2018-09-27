//
//  TableItem.m
//  JenkinsMonitor
//
//  Created by Andrii Tishchenko on 9/25/18.
//  Copyright © 2018 Andrii Tishchenko. All rights reserved.
//

#import "TableItem.h"
#import "CircleImage.h"

@interface TableItem ()
@end
@implementation TableItem
@synthesize timestamp = timestamp_;
@synthesize duration = duration_;
- (instancetype)init {
  self = [super init];

  self.buildID = nil;
  self.fullDisplayName = nil;
  self.url = nil;
  self.timestamp = @(0);
  self.duration = @(0);
  self.result = nil;
  return self;
}

- (NSString *)timestamp {
  NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp_ doubleValue] / 1000];

  NSDateFormatter *RFC3339DateFormatter = [[NSDateFormatter alloc] init];
  RFC3339DateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
  RFC3339DateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ssZZZZZ";
  RFC3339DateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
  return [RFC3339DateFormatter stringFromDate:date];
}

- (NSString *)duration {
  NSDate *date = [NSDate dateWithTimeIntervalSince1970:[duration_ doubleValue] / 1000];

  NSDateFormatter *RFC3339DateFormatter = [[NSDateFormatter alloc] init];
  RFC3339DateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
  RFC3339DateFormatter.dateFormat = @"HH:mm:ss";
  RFC3339DateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
  return [RFC3339DateFormatter stringFromDate:date];
}

- (const NSImage *)getIcon {
  NSColor *c;
  if ([self.result isEqual:[NSNull null]]) {
    c = [NSColor blueColor];
  } else if ([self.result isEqualToString:@"SUCCESS"]) {
    c = [NSColor greenColor];
  } else if ([self.result isEqualToString:@"ABORTED"]) {
    c = [NSColor grayColor];
  } else if ([self.result isEqualToString:@"FAILURE"]) {
    c = [NSColor redColor];
  } else
    c = [NSColor blueColor];

  const NSImage *icon = [[CircleImage alloc] initWithSize:CGSizeMake(20, 20) color:c];
  return icon;
}
@end
