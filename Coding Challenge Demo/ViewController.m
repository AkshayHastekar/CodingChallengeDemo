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
@property IBOutlet NSLayoutConstraint *tableContainerBottomConstraint;

@end

@implementation ViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Adding shadow for better look and feel
    {
        self.locationTextContainerView.layer.cornerRadius = 2.0;
        self.locationTextContainerView.layer.masksToBounds = NO;
        self.locationTextContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.locationTextContainerView.layer.shadowOffset = CGSizeZero;
        self.locationTextContainerView.layer.shadowOpacity = 0.3f;
        
        self.locationTableContainerView.layer.cornerRadius = 2.0;
        self.locationTableContainerView.layer.masksToBounds = NO;
        self.locationTableContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.locationTableContainerView.layer.shadowOffset = CGSizeZero;
        self.locationTableContainerView.layer.shadowOpacity = 0.3f;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]  removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]  removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Keyboard Notifications

-(void)keyboardWillShow:(NSNotification*)notification
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    NSDictionary *info = [notification userInfo];
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.25 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState | 7<<16) animations:^{
        
        weakSelf.tableContainerBottomConstraint.constant = keyboardRect.size.height+10;
        
        [weakSelf.view setNeedsLayout];
        [weakSelf.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.25 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState | 7<<16) animations:^{
        
        weakSelf.tableContainerBottomConstraint.constant = 20;
        
        [weakSelf.view setNeedsLayout];
        [weakSelf.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
    }];
}

@end
