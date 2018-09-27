//
//  CircleImage.m
//  JenkinsMonitor
//
//  Created by Andrii Tishchenko on 9/25/18.
//  Copyright © 2018 Andrii Tishchenko. All rights reserved.
//

#import "CircleImage.h"

@interface CircleImage ()
@property(strong, nonatomic) NSColor *circleColor;
@end
@implementation CircleImage

- (instancetype)initWithSize:(NSSize)size color:(NSColor *)color {
  self = [super initWithSize:size];
  self.circleColor = color;
  [self drawInRect:NSInsetRect((CGRect){{0, 0}, size}, 2, 2)];
  return self;
}

- (void)drawInRect:(NSRect)rect {
  [self lockFocus];
  NSGraphicsContext *gc = [NSGraphicsContext currentContext];
  [gc saveGraphicsState];
  [[NSColor blackColor] setStroke];
  [self.circleColor setFill];
  NSBezierPath *circlePath = [NSBezierPath bezierPath];
  [circlePath appendBezierPathWithOvalInRect:rect];
  [circlePath stroke];
  [circlePath fill];
  [gc restoreGraphicsState];
  [self unlockFocus];
}
@end
