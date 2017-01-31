//
//  DetailViewController.m
//  Coding Challenge Demo
//
//  Created by Iftekhar on 30/01/17.
//  Copyright © 2017 Iftekhar. All rights reserved.
//

#import "DetailViewController.h"
#import <MapKit/MapKit.h>
#import "Config.h"
#import <SafariServices/SafariServices.h>

@interface DetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property NSDictionary *detailInfo;
@property NSArray<NSString*> *placeInfoList;
@property IBOutlet UITableView *detailsTableView;
@property IBOutlet MKMapView *mapView;

@property IBOutlet UIBarButtonItem *refreshBarItem;
@property UIBarButtonItem *activityBarItem;
@property UIActivityIndicatorView *activityIndicatorView;

@end

@implementation DetailViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.placeInfoList = @[@"Address",@"Ratings",@"Website",@"Phone"];
    self.navigationItem.title = self.resultInfo[@"description"];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicatorView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self getLocationDetailsWithPlaceID:self.resultInfo[@"place_id"]];
}

#pragma mark - API Handling

-(void)getLocationDetailsWithPlaceID:(NSString*)placeID
{
    NSString *urlPath = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?key=%@&placeid=%@",kGooglePlaceAPIKey,placeID];
    
    urlPath = [urlPath stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlPath];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject];
    
    [self.navigationItem setRightBarButtonItem:self.activityBarItem animated:YES];
    [self.activityIndicatorView startAnimating];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [weakSelf.navigationItem setRightBarButtonItem:self.refreshBarItem animated:YES];
            [weakSelf.activityIndicatorView stopAnimating];
            
            if (error)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else if (httpResponse.statusCode == 200)
            {
                NSDictionary *jsonDict= [NSJSONSerialization  JSONObjectWithData:data options:kNilOptions error:nil];
                
                weakSelf.detailInfo = jsonDict;
                [self updateUI];
            }
        }];
    }];
    
    [dataTask resume];
}

#pragma mark - Update UI

- (IBAction)refreshAction:(UIBarButtonItem *)sender
{
    [self getLocationDetailsWithPlaceID:self.resultInfo[@"place_id"]];
}


-(void)updateUI
{
    NSDictionary *locationDict = self.detailInfo[@"result"][@"geometry"][@"location"];
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake([locationDict[@"lat"] doubleValue], [locationDict[@"lng"] doubleValue]);
    MKCoordinateSpan span = MKCoordinateSpanMake(1, 1);

    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    
    [self.mapView setRegion:region animated:YES];
    
    if (self.mapView.annotations.count == 0)
    {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:center];
        annotation.title = self.detailInfo[@"result"][@"name"];
        annotation.subtitle = self.detailInfo[@"result"][@"formatted_address"];
        
        [self.mapView addAnnotation:annotation];
    }

    [self.detailsTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.placeInfoList.count)] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - TableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.placeInfoList.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.placeInfoList[section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    
    switch (indexPath.section)
    {
        case 0:
        {
            cell.textLabel.text = self.detailInfo[@"result"][@"name"]?:(self.resultInfo[@"description"]?:@"-");
            cell.detailTextLabel.text = self.detailInfo[@"result"][@"formatted_address"]?:@"-";
        }
            break;
        case 1:
        {
            NSNumber *rating = self.detailInfo[@"result"][@"rating"];
            cell.textLabel.text = rating?[rating stringValue]:@"-";
            cell.detailTextLabel.text = @"";
        }
            break;
        case 2:
        {
            cell.textLabel.text = self.detailInfo[@"result"][@"website"]?:@"-";
            cell.detailTextLabel.text = @"";
        }
            break;
        case 3:
        {
            cell.textLabel.text = self.detailInfo[@"result"][@"international_phone_number"]?:@"-";
            cell.detailTextLabel.text = @"";
        }
            break;
            
        default:
            cell.textLabel.text = @"-";
            cell.detailTextLabel.text = @"-";
            break;
    }
    
    return  cell;
}

@end
