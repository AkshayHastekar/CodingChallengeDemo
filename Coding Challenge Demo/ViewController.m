//
//  ViewController.m
//  Coding Challenge Demo
//
//  Created by Iftekhar on 30/01/17.
//  Copyright © 2017 Iftekhar. All rights reserved.
//

#import "ViewController.h"
#import "SearchTextField.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,SearchTextFieldDelegate>

@property IBOutlet UIView *locationTextContainerView;
@property IBOutlet UIActivityIndicatorView *searchActivityIndicatorView;
@property IBOutlet SearchTextField *searchTextField;
@property IBOutlet NSLayoutConstraint *activityContainerWidth;

@property IBOutlet UIView *locationTableContainerView;
@property IBOutlet UITableView *listTableView;
@property IBOutlet NSLayoutConstraint *tableContaienrBottomConstraint;

@end

@implementation ViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - TableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UITableViewCell new];
}


#pragma mark - TextField delegate

- (void)textFieldDidStartTyping:(nonnull SearchTextField *)textField
{

}

- (void)textFieldDidStopTyping:(nonnull SearchTextField *)textField
{

}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

@end
