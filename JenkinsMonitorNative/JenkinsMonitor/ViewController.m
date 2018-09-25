//
//  ViewController.m
//  JenkinsMonitor
//
//  Created by Andrii Tishchenko on 9/20/18.
//  Copyright © 2018 Andrii Tishchenko. All rights reserved.
//

#import "ViewController.h"
#import "Manager.h"
#import "TableItem.h"


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
    [[Manager sharedManager] addURL: self.tf_job_id.stringValue];
  
    self.tf_job_id.stringValue = @"";
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.datasource = [NSMutableArray new];
}


- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
  return [self.datasource count];
}


-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
  TableItem*item = self.datasource[row];
  NSString* key=[tableColumn identifier];
  if ([key isEqualToString:@"cell_status"]) {
    return [item getIcon];
  }
  else if ([key isEqualToString:@"cell_job"]) {
    return item.fullDisplayName;
  }
  else if ([key isEqualToString:@"cell_timestamp"]) {
    return item.timestamp;
  }
  else if ([key isEqualToString:@"cell_duration"]) {
    return item.duration;
  }
  else if ([key isEqualToString:@"cell_id"]) {
    return item.buildID;
  }
  
  return @"NaN";
}
@end
