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

@interface AddFoodViewController () <HSDatePickerViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) NSDate * expirationDate;


@end

@implementation AddFoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    self.expirationDate = date;

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
