//
//  AppDelegate.m
//  JenkinsMonitor
//
//  Created by Andrii Tishchenko on 9/20/18.
//  Copyright © 2018 Andrii Tishchenko. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Manager.h"

@interface AppDelegate ()<NSPopoverDelegate>
  @property (strong, nonatomic) NSStatusItem *statusItem;
  @property (weak) IBOutlet NSMenu *menu;
  @property (strong, nonatomic) IBOutlet NSPopover *popoverView;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
  self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  self.statusItem.title = @"JNk";
//  self.statusItem.menu = self.menu;
  self.statusItem.highlightMode = YES;
  _statusItem.toolTip = @"ctrl+click to QUIT";
  
  NSImage *icon = [NSImage imageNamed:@"icon_menu"];
  icon.template = YES;

  self.statusItem.button.image = icon;
//  _statusItem.toolTip = @"ctrl+click to QUIT";
  [self.statusItem setAction:@selector(itemClicked:)];
  
  [[Manager sharedManager] setJobID: @"AppID"];
  [[Manager sharedManager] startService];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(receiveNotification:)
                                               name:JobsUpdateNotification
                                             object:nil];
}

- (void) receiveNotification:(NSNotification *) notification {
  if ([[notification name] isEqualToString:JobsUpdateNotification]){
    
  }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  // Insert code here to tear down your application
}

- (void)itemClicked:(id)sender {
  
    //Look for control click, close app if so
  NSEvent *event = [NSApp currentEvent];
  if([event modifierFlags] & NSEventModifierFlagControl) {
    [[NSApplication sharedApplication] terminate:self];
    return;
  }
 
  if (!self.popoverView) {
    NSStoryboard *sb = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *vc = (ViewController *)[sb instantiateControllerWithIdentifier:@"popupContentController"];
    self.popoverView = [[NSPopover alloc] init];
    [self.popoverView setContentViewController:vc];
    self.popoverView.contentSize = vc.view.frame.size;
    self.popoverView.behavior = NSPopoverBehaviorTransient;
  }

  [self.popoverView showRelativeToRect: self.statusItem.button.bounds
                              ofView:  self.statusItem.button
                        preferredEdge:NSMaxYEdge];
}

@end
