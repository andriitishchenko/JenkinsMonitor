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

- (void)viewDidLoad {
  [super viewDidLoad];
}


- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];

  // Update the view, if already loaded.
}


@end
