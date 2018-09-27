//
//  TableItem.h
//  JenkinsMonitor
//
//  Created by Andrii Tishchenko on 9/25/18.
//  Copyright © 2018 Andrii Tishchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableItem : NSObject
@property(copy,nonatomic) NSString*result;
@property(copy,nonatomic) NSNumber*buildID;
@property(copy,nonatomic) NSString*fullDisplayName;
@property(copy,nonatomic) NSNumber*duration;
@property(copy,nonatomic) NSNumber*timestamp;
@property(copy,nonatomic) NSString*url;
- (const NSImage*) getIcon;

@end
