//
//  NSTableView+ContextMenu.h
//  JenkinsMonitor
//
//  Created by Andrii Tishchenko on 9/26/18.
//  Copyright © 2018 Andrii Tishchenko. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol ContextMenuDelegate <NSObject>
- (NSMenu*)tableView:(NSTableView*)aTableView menuForRows:(NSIndexSet*)rows;
@end

@interface NSTableView (ContextMenu)

@end
