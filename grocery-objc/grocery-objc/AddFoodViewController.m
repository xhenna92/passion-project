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
#import "BarCodeScannerViewController.h"

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
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) NSDate * expirationDate;
@property (weak, nonatomic) IBOutlet UIButton *addDateButton;

@end

@implementation AddFoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:213.0/255.0 blue:199.0/255.0 alpha:1];

    
    self.autoCompleteSearchResults = [[NSMutableArray alloc] init];
    self.manager = [[AFHTTPSessionManager alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal; // remove border from search bar
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.hidden = YES;
    
    [self.searchBar setShowsBookmarkButton:YES];
    
    
    [self.searchBar setImage:[UIImage imageNamed:@"barcode"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    [self.searchBar setImage:[UIImage imageNamed:@"barcode"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateSelected];


    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SearchBar delegate methods

-(void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar{
    BarCodeScannerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"barcodeScanner"];
    
    
    [self presentViewController:vc animated:YES completion:nil];
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
        
        NSString *url = [NSString stringWithFormat:@"https://apibeta.nutritionix.com/v2/autocomplete?appId=827182c3&appKey=d6e62d15fdeba605e144d350d5587dde&q=%@", searchText];
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
    
    self.nameTextField.text = [self.autoCompleteSearchResults[indexPath.row] objectForKey:@"text"];
    
}




- (IBAction)addButtonTapped:(UIButton *)sender {
    
    NSString *foodName = [self.nameTextField.text lowercaseString];
    NSString *emojiURL = [NSString stringWithFormat:@"https://www.emojidex.com/api/v1/search/emoji/?code_sw=%@", foodName];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    
    [manager GET:emojiURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

- (IBAction)pickDateTapped:(UIButton *)sender {
    HSDatePickerViewController *hsdpvc = [[HSDatePickerViewController alloc] init];
    hsdpvc.delegate = self;
    
    [self presentViewController:hsdpvc animated:YES completion:nil];

}
- (void)hsDatePickerPickedDate:(NSDate *)date {
    NSString *dateString = [NSDateFormatter localizedStringFromDate:date
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterNoStyle];
    
    
    self.expirationDate = date;
    [self.addDateButton setImage:nil forState:UIControlStateNormal];
    [self.addDateButton setTitle:dateString forState:UIControlStateNormal];
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
