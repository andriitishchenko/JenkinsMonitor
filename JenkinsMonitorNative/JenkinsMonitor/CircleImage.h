//
//  CircleImage.h
//  JenkinsMonitor
//
//  Created by Andrii Tishchenko on 9/25/18.
//  Copyright © 2018 Andrii Tishchenko. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CircleImage : NSImage
-(instancetype)initWithSize:(NSSize)size color:(NSColor*)color;
@end
