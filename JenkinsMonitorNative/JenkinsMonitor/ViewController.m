//
//  ViewController.m
//  JenkinsMonitor
//
//  Created by Andrii Tishchenko on 9/20/18.
//  Copyright © 2018 Andrii Tishchenko. All rights reserved.
//

#import "ViewController.h"
#import "Manager.h"

@interface ViewController()<NSTableViewDataSource,NSTableViewDataSource>
@property (weak) IBOutlet NSTextFieldCell *tf_job_id;
@property (weak) IBOutlet NSTableView *tb_stats;


@property (strong,nonatomic) NSMutableArray* datasource;
@end

@implementation ViewController

-(void)viewWillAppear{
  [super viewWillAppear];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(receiveNotification:)
                                               name:JobsUpdateNotification
                                             object:nil];
  
  [self resetValues];
}

-(void)resetValues{
  NSDictionary* list = [[[Manager sharedManager] jobList]  copy];
  
  [self.datasource removeAllObjects];
  [list enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
    [self.datasource addObject:value];
  }];
  
  [self.tb_stats reloadData];
}

-(void)viewWillDisappear{
  [super viewWillDisappear];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void) receiveNotification:(NSNotification *) notification {
  if ([[notification name] isEqualToString:JobsUpdateNotification]){
    [self resetValues];
  }
}

- (IBAction)click_add:(id)sender {
  
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.datasource = [NSMutableArray new];
//  for (NSInteger i=0; i<10; i++) {
//    NSDictionary*d = @{
//                       @"first":@"first",
//                       @"second":@"second",
//                       };
//
//    [self.datasource addObject:d];
//  }
}


- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];

  // Update the view, if already loaded.
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
  return [self.datasource count];
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
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
  NSString* key=[tableColumn identifier];
  return [self.datasource[row] objectForKey:@"fullDisplayName"];
}
@end
