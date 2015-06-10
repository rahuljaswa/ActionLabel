//
//  RJViewController.m
//  ActionLabel
//
//  Created by Rahul Jaswa on 01/17/2015.
//  Copyright (c) 2014 Rahul Jaswa. All rights reserved.
//

#import "RJViewController.h"
#import <ActionLabel/ActionLabel.h>


@interface RJViewController () <ActionLabelDelegate>

@end


@implementation RJViewController

- (void)actionLabel:(ActionLabel *)label didSelectLinkWithURL:(NSURL *)url {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    ActionLabel *actionLabel = [[ActionLabel alloc] initWithFrame:CGRectMake(0.0f, 50.0f, CGRectGetWidth(self.view.bounds), 30.0f)];
    actionLabel.delegate = self;
    actionLabel.textCheckingTypes = NSTextCheckingTypeLink;
    actionLabel.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view addSubview:actionLabel];
    
    actionLabel.linkAttributes = @{ NSForegroundColorAttributeName : [UIColor blueColor] };
    actionLabel.activeLinkAttributes = @{ NSForegroundColorAttributeName : [UIColor purpleColor] };
    actionLabel.attributedText = [[NSAttributedString alloc] initWithString:@"This is http://www.espn.com"];
}

@end
