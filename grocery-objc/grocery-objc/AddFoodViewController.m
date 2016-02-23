//
//  AddFoodViewController.m
//  grocery-objc
//
//  Created by Henna Ahmed on 2/18/16.
//  Copyright © 2016 Shena Yoshida. All rights reserved.
//

#import "AddFoodViewController.h"
#import <Firebase/Firebase.h>
#import <AFNetworking/AFNetworking.h>
#import "HSDatePickerViewController.h"
#import <RSBarcodes/RSBarcodes.h>
#import <SIAlertView/SIAlertView.h>

@interface AddFoodViewController () <
HSDatePickerViewControllerDelegate,
UITableViewDelegate,
UITableViewDataSource,
UISearchBarDelegate,
UISearchBarDelegate
>

@property (nonatomic) NSMutableArray *autoCompleteSearchResults;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic) AFHTTPSessionManager *manager;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDate * expirationDate;
@property (weak, nonatomic) IBOutlet UIButton *addDateButton;
@property (strong, nonatomic) IBOutlet UILabel *foodLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *expirationMessageLabel;
@property (nonatomic) BOOL foodSet;
@property (nonatomic) BOOL dateSet;


@end

@implementation AddFoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.autoCompleteSearchResults = [[NSMutableArray alloc] init];
    self.manager = [[AFHTTPSessionManager alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal; // remove border from search bar
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.hidden = YES;
    self.expirationMessageLabel.hidden = YES;
    self.foodSet = NO;
    self.dateSet = NO;
    
    [self.searchBar setShowsBookmarkButton:YES];
    
    
    [self.searchBar setImage:[UIImage imageNamed:@"barcode"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    [self.searchBar setImage:[UIImage imageNamed:@"barcode"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateSelected];
    
    UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:downSwipe];
    
    
    // Do any additional setup after loading the view.
    
}


- (void) handleSwipe: (UISwipeGestureRecognizer *) gesture {
    switch (gesture.direction) {
        case UISwipeGestureRecognizerDirectionDown:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SearchBar delegate methods

-(void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar{
    
    RSScannerViewController *scanner = [[RSScannerViewController alloc] initWithCornerView:YES
                                                                               controlView:YES
                                                                           barcodesHandler:^(NSArray *barcodeObjects) {
                                                                               AVMetadataMachineReadableCodeObject *something = [barcodeObjects firstObject];
                                                                               [self.presentingViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
                                                                               
                                                                               [self findProductWithBarcode:something.stringValue];
                                                                               
                                                                           }
                                                                   preferredCameraPosition:AVCaptureDevicePositionBack];
    [scanner setStopOnFirst:YES];
    [self presentViewController:scanner animated:YES completion:nil];
    
    
}

- (void) findProductWithBarcode: (NSString *) barcode{
    NSString *url = [NSString stringWithFormat:@"https://api.nutritionix.com/v1_1/item?upc=%@&appId=827182c3&appKey=d6e62d15fdeba605e144d350d5587dde", barcode];
    
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.foodLabel.text = [responseObject objectForKey:@"item_name"];
        self.foodSet = YES;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
    
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
    [self searchBar:searchBar textDidChange:searchBar.text];
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    self.tableView.hidden = YES;
    return YES;
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchBar.text.length > 0) {
        self.tableView.hidden = NO;
        
        //API Call
        
        NSString *url = [NSString stringWithFormat:@"https://apibeta.nutritionix.com/v2/autocomplete?appId=ebecb9f6&appKey=8779a49b103c3b99986cd0e27c37d6b9&q=%@", searchText];
        NSString *encodedString = [url stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
        [self.manager GET:encodedString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            self.autoCompleteSearchResults = responseObject;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error);
        }];
        
        
        
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self.tableView setHidden:YES];
}


#pragma mark - TableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.autoCompleteSearchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AutocompleteIdentifier" forIndexPath:indexPath];
    cell.textLabel.text = [self.autoCompleteSearchResults[indexPath.row] objectForKey:@"text"];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    
    self.foodLabel.text = [self.autoCompleteSearchResults[indexPath.row]objectForKey:@"text"];
    self.foodSet = YES;
}




- (IBAction)addButtonTapped:(UIButton *)sender {
    
    if (self.foodSet && self.dateSet) {
        NSString *foodName = [self.foodLabel.text lowercaseString];
        
        NSString *emojiURL = [NSString stringWithFormat:@"https://www.emojidex.com/api/v1/search/emoji/?code_sw=%@", foodName];
        NSString *encodedString = [emojiURL stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];

        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
        
        [manager GET:encodedString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSArray * emojiData = [responseObject objectForKey:@"emoji"];
            NSString *moji = @"";
            for (NSDictionary* emoji in emojiData) {
                
                NSString *temp = [emoji objectForKey:@"moji"];
                
                if ( [temp isEqualToString:@""]) {
                    
                }
                else{
                    moji = temp;
                    break;
                }
            }
            
            NSNumber *expires = [NSNumber numberWithDouble:[self.expirationDate timeIntervalSince1970]];
            Firebase *myRootRef = [[Firebase alloc] initWithUrl:@"https://scorching-heat-3082.firebaseio.com/Grocery-List"];
            [[myRootRef childByAppendingPath:foodName] setValue:@{ @"Expiration Date": expires, @"emoji":moji }];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error);
        }];
    }
    else{
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Oops" andMessage:@"Please make sure you have a date and name for your food."];
        
        [alertView addButtonWithTitle:@"Ok"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  
                              }];
        
        
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        
        [alertView show];
    }
    
    
}

- (IBAction)pickDateTapped:(UIButton *)sender {
    self.messageLabel.hidden = YES;
    
    HSDatePickerViewController *hsdpvc = [[HSDatePickerViewController alloc] init];
    hsdpvc.delegate = self;
    
    [self presentViewController:hsdpvc animated:YES completion:nil];
    
}
- (void)hsDatePickerPickedDate:(NSDate *)date {
    
    NSString *bestBeforeMessage = @"best before:";
    NSString *dateString = [NSDateFormatter localizedStringFromDate:date
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterNoStyle];
    NSString *message = [NSString stringWithFormat:@"%@\n%@", bestBeforeMessage, dateString];
    
    self.expirationMessageLabel.text = message;
    self.expirationMessageLabel.hidden = NO;
    self.expirationDate = date;
    [self.addDateButton setImage:nil forState:UIControlStateNormal];
    self.dateSet = YES;
    //    [self.addDateButton setTitle:message forState:UIControlStateNormal];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
