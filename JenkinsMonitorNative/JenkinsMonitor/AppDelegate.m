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
  
  [self check_path];
  
  // Insert code here to initialize your application
  self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  self.statusItem.title = @"JNk";
//  self.statusItem.menu = self.menu;
  self.statusItem.highlightMode = YES;
  _statusItem.toolTip = @"ctrl+click to QUIT";
  
  NSImage *icon = [NSImage imageNamed:@"icon_menu"];
//  icon.template = YES;

  self.statusItem.button.image = icon;
  [self.statusItem setAction:@selector(itemClicked:)];
  
  [[Manager sharedManager] load];
  
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

-(void)check_path{
  
  BOOL shouldCopyToApps = YES;
  NSString*finalPathSearch = [NSString stringWithFormat:@"file:///Users/%@/Applications/JenkinsMonitor.app/",NSUserName()];
  
  
  NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
  CFStringRef cfBundleID = (__bridge CFStringRef)bundleID;
  CFErrorRef cfError;
  NSArray *array = CFBridgingRelease(LSCopyApplicationURLsForBundleIdentifier(
                                                                              cfBundleID, &cfError));
  if (array == nil) {
    NSError *nsError = (__bridge NSError *)cfError;
    fprintf(stderr, "error: %s\n", nsError.description.UTF8String);
  }
  else
  {
    //    NSLog(@"Found my app@: %@",array);
    if ([array indexOfObject: finalPathSearch] !=  NSNotFound) {
      shouldCopyToApps = NO;
    }
  }
  if (shouldCopyToApps) {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Where am I?"];
    [alert setInformativeText:@"Moving the app to user ~/Applications ?"];
    [alert addButtonWithTitle:@"YES"];
    [alert addButtonWithTitle:@"NO"];
    [alert setAlertStyle:NSAlertStyleWarning];
    
    if([alert runModal] == NSAlertFirstButtonReturn){
      [self copyAToUserApplications];
    }
  }
}

-(void)copyAToUserApplications{
  NSString*curPath = [[NSBundle mainBundle] bundlePath];
  NSString*destPath = [NSString stringWithFormat:@"/Users/%@/Applications/JenkinsMonitor.app",NSUserName()];
  [self runCommand: [NSString stringWithFormat:@"sudo cp -R %@ %@", curPath,destPath]];
  [self runCommand: [NSString stringWithFormat:@"/usr/bin/open %@", destPath]];
  [[NSApplication sharedApplication] terminate:self];
}

- (NSString *)runCommand:(NSString *)commandToRun
{
  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath:@"/bin/sh"];
  NSArray *arguments = [NSArray arrayWithObjects:
                        @"-c" ,
                        [NSString stringWithFormat:@"%@", commandToRun],
                        nil];
#ifdef DEBUG
  NSLog(@"#%@", commandToRun);
#endif
  [task setArguments:arguments];
  NSPipe *pipe = [NSPipe pipe];
  [task setStandardOutput:pipe];
  NSFileHandle *file = [pipe fileHandleForReading];
  [task launch];
  NSData *data = [file readDataToEndOfFile];
  NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  return output;
}
@end
