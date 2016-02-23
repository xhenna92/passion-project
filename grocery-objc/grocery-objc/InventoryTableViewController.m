//
//  InventoryTableViewController.m
//  grocery-objc
//
//  Created by Shena Yoshida on 2/17/16.
//  Copyright © 2016 Shena Yoshida. All rights reserved.
//

#import "InventoryTableViewController.h"
#import "AddFoodViewController.h"
#import "NSDate+RelativeTime.h"
#import "InventoryTableViewCell.h"
#import <Firebase/Firebase.h>
#import "foodModel.h"


@interface InventoryTableViewController ()
@property (nonatomic) foodModel *sharedManager;
@end

@implementation InventoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //register notifications
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];

    
    
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.tabBarController.tabBar setTranslucent:NO];
    
    
    // set up custom cell
    UINib *nib = [UINib nibWithNibName:@"InventoryTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cellIdentifier"];
    
    // set height of cell to adjust to text
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"shopping"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(addFood:)];
    
    self.sharedManager = [foodModel sharedManager];
}

- (void) setUpNotificationsWithInterval:(NSTimeInterval)interval{

    if ([[UIApplication sharedApplication] scheduledLocalNotifications].count < 1){
        
        NSMutableArray *aboutToExpire = [[NSMutableArray alloc]init];
        
        NSDate *today = [NSDate date];
        NSDate *nextWeek  = [today dateByAddingTimeInterval: 1209600.0];
        
        //determine which ingredients are about to expire
        for (NSDictionary* food in self.sharedManager.foodData) {
            NSString *key = [[food allKeys] firstObject];
            NSTimeInterval interval = [[[food objectForKey:key] objectForKey: @"Expiration Date"] doubleValue];
            NSDate * foodDate = [NSDate dateWithTimeIntervalSince1970:interval];
            
            if([foodDate compare:nextWeek]<1 && [foodDate compare:[NSDate date]]>0){
                [aboutToExpire addObject:key];
            }
        }
        
        NSString * alertBody = [NSString stringWithFormat:@"Your %@ are about to expire!", [aboutToExpire componentsJoinedByString:@", "]];
        
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:interval];
        localNotification.alertBody = alertBody;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    }

    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self.sharedManager.foodData removeAllObjects];
    // read data
    Firebase *myRootRef = [[Firebase alloc] initWithUrl:@"https://scorching-heat-3082.firebaseio.com/Grocery-List"];
    [myRootRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.value != [NSNull null]) {
            
            NSDictionary * jsonFoods = snapshot.value;
            NSMutableArray *tempFoodArray = [[NSMutableArray alloc]init];
            
            for (NSDictionary* food in jsonFoods){
                
                NSDictionary *foodWithData = @{ food : [jsonFoods objectForKey:food] };
                
                [tempFoodArray addObject:foodWithData];
            }
            NSArray *sortedArray;
            sortedArray = [tempFoodArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                
                
                NSString *firstKey = [[(NSDictionary*)a allKeys]firstObject];
                NSTimeInterval first = [[[(NSDictionary*)a objectForKey:firstKey] objectForKey: @"Expiration Date"] doubleValue];
                NSDate * dateA = [NSDate dateWithTimeIntervalSince1970:first];
                NSString *secondKey = [[(NSDictionary*)b allKeys]firstObject];
                NSTimeInterval second = [[[(NSDictionary*)b objectForKey:secondKey] objectForKey: @"Expiration Date"] doubleValue];
                NSDate * dateB = [NSDate dateWithTimeIntervalSince1970:second];
                
                return [dateA compare:dateB];
            }];
            
            self.sharedManager.foodData = [sortedArray mutableCopy];
            [self setUpNotificationsWithInterval:60];
            [self.tableView reloadData];
        }
        
    }];
}

-(IBAction)addFood:(id)sender{
    AddFoodViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"addFoodVC"];
    [self presentViewController:vc animated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sharedManager.foodData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InventoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    NSDictionary *foodObject = self.sharedManager.foodData[indexPath.row];
    
    NSString *key = [[foodObject allKeys] firstObject];
    
    NSDictionary *foodDetails = [foodObject objectForKey:key];
    
    NSString *emoji = [foodDetails objectForKey:@"emoji"];
    NSString *displayName = [NSString stringWithFormat:@"%@ %@", key, emoji];
    NSTimeInterval interval = [[foodDetails objectForKey:@"Expiration Date"] doubleValue];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:interval];
    if ([date compare:[NSDate date]]<0) {
        cell.labelDate.text = @"expired";
        cell.labelDate.textColor = [UIColor redColor];
    }
    else{
        cell.labelDate.text = [date relativeTime];
        cell.labelDate.textColor = [UIColor blackColor];
    }
    
    cell.labelFood.text = displayName;
    
    
    
    return cell;
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    return YES;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *foodObject = self.sharedManager.foodData[indexPath.row];
    
    NSString *key = [[foodObject allKeys] firstObject];

    NSString *url = [NSString stringWithFormat:@"https://scorching-heat-3082.firebaseio.com/Grocery-List/%@",key];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // read data
        
        Firebase *mydeletionRef = [[Firebase alloc] initWithUrl:url];
        
        [mydeletionRef removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
            [self.sharedManager.foodData removeObjectAtIndex:indexPath.row];
            [self.tableView reloadData];
        }];
        
    }
}




/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */


/*
 #pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
