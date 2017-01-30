//
//  ViewController.m
//  Coding Challenge Demo
//
//  Created by Iftekhar on 30/01/17.
//  Copyright © 2017 Iftekhar. All rights reserved.
//

#import "ViewController.h"
#import "SearchTextField.h"
#import "Config.h"
#import "DetailViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,SearchTextFieldDelegate>

@property NSURLSessionDataTask *searchDataTask;
@property NSArray<NSDictionary*> *results;

@property IBOutlet UIView *locationTextContainerView;
@property IBOutlet UIActivityIndicatorView *searchActivityIndicatorView;
@property IBOutlet SearchTextField *searchTextField;

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

    [self updateUIWithResult:@[]];
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

#pragma mark - API Handling

- (void)getPlacesForSearchText:(NSString*)searchText
{
    if (self.searchDataTask != nil)
    {
        [self.searchDataTask cancel];
    }
    
    NSString *urlPath = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?key=%@&input=%@&language=en-EN",kGooglePlaceAPIKey,searchText];
    
    urlPath = [urlPath stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];

    NSURL *url = [NSURL URLWithString:urlPath];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject];
    
    [self.searchActivityIndicatorView startAnimating];
    
    __weak typeof(self) weakSelf = self;

    self.searchDataTask = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        weakSelf.searchDataTask = nil;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [weakSelf.searchActivityIndicatorView stopAnimating];
            
            if (error)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else if (httpResponse.statusCode == 200)
            {
                NSDictionary *jsonDict= [NSJSONSerialization  JSONObjectWithData:data options:kNilOptions error:nil];
                
                [self updateUIWithResult:jsonDict[@"predictions"]];
            }
        }];
    }];
    
    [self.searchDataTask resume];
}

#pragma mark - Update UI

-(void)updateUIWithResult:(NSArray*)searchResults
{
    __weak typeof(self) weakSelf = self;

    if (searchResults.count)
    {
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.locationTableContainerView.alpha = 1.0;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.locationTableContainerView.alpha = [weakSelf.searchTextField isFirstResponder]?1:0;
        }];
    }
    
    if ([self.results isEqualToArray:searchResults] == NO)
    {
        self.results = searchResults;
        [weakSelf.listTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
    }
}

#pragma mark - TableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.results.count == 0)
    {
        tableView.alpha = 1.0;
        CGRect rect = [tableView frame];
        rect.origin = CGPointMake(0, 0);
        rect.size.height = 100;
        UIView *view = [[UIView alloc] initWithFrame:rect];
        view.backgroundColor = [UIColor clearColor];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, view.frame.size.width-40, 30)];
        label1.font = [UIFont boldSystemFontOfSize:20.0];
        label1.numberOfLines = 0;
        label1.textAlignment = NSTextAlignmentCenter;
        label1.textColor = [UIColor darkGrayColor];
        label1.text = @"No Search results";
        [view addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(label1.frame), CGRectGetWidth(label1.frame), 40)];
        label2.font = [UIFont systemFontOfSize:15.0];
        label2.numberOfLines = 0;
        label2.textAlignment = NSTextAlignmentCenter;
        label2.textColor = [UIColor grayColor];
        label2.text = @"Please type to search location";
        [view addSubview:label2];
        
        tableView.tableHeaderView = view;
    }
    else
    {
        tableView.tableHeaderView = nil;
    }
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    
    cell.textLabel.text = self.results[indexPath.row][@"description"];
    NSArray *types = self.results[indexPath.row][@"types"];
    cell.detailTextLabel.text = [types componentsJoinedByString:@", "];
    return  cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([DetailViewController class])];
    
    controller.resultInfo = self.results[indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - TextField delegate

- (void)textFieldDidStartTyping:(nonnull SearchTextField *)textField
{

}

- (void)textFieldDidStopTyping:(nonnull SearchTextField *)textField
{
    NSString *searchText = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([searchText length] > 0)
    {
        [self getPlacesForSearchText:searchText];
    }
    else
    {
        [self updateUIWithResult:@[]];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self updateUIWithResult:self.results];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateUIWithResult:self.results];
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
