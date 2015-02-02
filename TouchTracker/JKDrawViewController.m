//
//  JKDrawViewController.m
//  TouchTracker
//
//  Created by Jonathan Kim on 2/2/15.
//  Copyright (c) 2015 Jonathan Kim. All rights reserved.
//

#import "JKDrawViewController.h"
#import "JKDrawView.h"

@implementation JKDrawViewController

-(void)loadView
{
    self.view = [[JKDrawView alloc] initWithFrame:CGRectZero];
}

@end
