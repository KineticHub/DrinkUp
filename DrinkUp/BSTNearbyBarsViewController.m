//
//  BSTNearbyBarsViewController.m
//  DrinkUp
//
//  Created by Kinetic on 3/7/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "BSTNearbyBarsViewController.h"
#import "BSTDrinkTypeViewController.h"
#import "DrinkSelectionsViewController.h"
#import "SelectBarSectionViewController.h"
#import "CollapsableDrinkViewController.h"
#import "FeedCell1.h"
#import "UIImageView+AFNetworking.h"

#import "UIColor+FlatUI.h"
#import "FUIAlertView.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"

@interface BSTNearbyBarsViewController ()
@property (nonatomic, strong) NSMutableArray *bars;
@property (nonatomic, strong) MKMapView *mapView;
@end

@implementation BSTNearbyBarsViewController

-(id)init {
    self = [super initWithUpperViewHieght:0.0];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[SharedDataHandler sharedInstance] initializeLocationTracking];
    
    self.bars = [[NSMutableArray alloc] init];
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.upperView.frame];
    [self.mapView setShowsUserLocation:YES];
    [self.upperView addSubview:self.mapView];
    
    [self.tableView setRowHeight:90.0];
    [self.tableView setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setRowHeight:320.0];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"View will appear");
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Bars...";
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SharedDataHandler sharedInstance] loadUserLocation];
        [[SharedDataHandler sharedInstance] loadBarsWithLocation:^(NSMutableArray *objects)
         {
             NSLog(@"Bars loaded with location");
             if ([objects count] == 0)
             {
                 [[SharedDataHandler sharedInstance] loadBars:^(NSMutableArray *objects)
                  {
                      NSLog(@"No location bars found, loading all bars");
                      
                      FUIAlertView *noBarsAlert = [[FUIAlertView alloc] initWithTitle:@"No Nearby Bars" message:@"No DrinkUp bars were found near you. Showing all participating bars." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                      noBarsAlert.titleLabel.textColor = [UIColor cloudsColor];
                      noBarsAlert.titleLabel.font = [UIFont boldFlatFontOfSize:16];
                      noBarsAlert.messageLabel.textColor = [UIColor cloudsColor];
                      noBarsAlert.messageLabel.font = [UIFont flatFontOfSize:14];
                      noBarsAlert.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
                      noBarsAlert.alertContainer.backgroundColor = [UIColor midnightBlueColor];
                      noBarsAlert.defaultButtonColor = [UIColor cloudsColor];
                      noBarsAlert.defaultButtonShadowColor = [UIColor asbestosColor];
                      noBarsAlert.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
                      noBarsAlert.defaultButtonTitleColor = [UIColor asbestosColor];
                      [noBarsAlert show];
                      
                      self.bars = [NSMutableArray arrayWithArray:objects];
                      [self.tableView reloadData];
                      [self setupMap];
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                      });
                  }];
             } else {
                 self.bars = [NSMutableArray arrayWithArray:objects];
                 [self.tableView reloadData];
                 [self setupMap];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                 });
             }
             
             
         }];
    });
}

#pragma mark - TableView DataSource Methods

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 25.0;
    }
    
    return 0.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *nearbyView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 25.0)];
    [nearbyView setBackgroundColor:[UIColor peterRiverColor]];
    [nearbyView setAlpha:0.8];
    
    UILabel *nearbyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 15.0)];
    [nearbyLabel setCenter:CGPointMake(nearbyLabel.center.x, nearbyView.center.y)];
    [nearbyLabel setFont:[UIFont systemFontOfSize:14.0]];
    [nearbyLabel setBackgroundColor:[UIColor clearColor]];
    [nearbyLabel setTextAlignment:NSTextAlignmentCenter];
    [nearbyLabel setTextColor:[UIColor whiteColor]];
    [nearbyLabel setText:[SharedDataHandler sharedInstance].user_location];
    [nearbyView addSubview:nearbyLabel];
    
    return nearbyView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.bars count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FeedCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"BarCell"];
    
	if (cell == nil) {
		cell = [[FeedCell1 alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BarCell"];
	}
    
    NSDictionary *bar = [self.bars objectAtIndex:[indexPath section]];
    
//    cell.textLabel.text = [bar objectForKey:@"name"];
//    NSString *address = [NSString stringWithFormat:@"%@", [bar objectForKey:@"street_address"]];
//    cell.detailTextLabel.text = address;
//    [cell.detailTextLabel setNumberOfLines:2];
//    [cell setCellImage:[NSURLRequest requestWithURL:[NSURL URLWithString:[bar objectForKey:@"icon"]]]];
    
    cell.nameLabel.text = [bar objectForKey:@"name"];
    cell.updateLabel.text = [NSString stringWithFormat:@"%@", [bar objectForKey:@"street_address"]];
    cell.dateLabel.text = @"0.5 mi";
    cell.likeCountLabel.text = @"";
    cell.commentCountLabel.text = @"";
    [cell.picImageView setImageWithURL:[NSURL URLWithString:[bar objectForKey:@"icon"]]];
    
    return cell;
}

#pragma mark - TableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    NSDictionary *selectedBar = [self.bars objectAtIndex:[indexPath section]];
    [SharedDataHandler sharedInstance].currentBar = selectedBar;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SharedDataHandler sharedInstance] loadBarSectionsForBar:[[selectedBar objectForKey:@"id"] intValue] onCompletion:^(NSMutableArray *objects) {
            
            if ([objects count] == 1) {
                NSDictionary *barSection = [objects objectAtIndex:0];
                [SharedDataHandler sharedInstance].current_section = [[barSection objectForKey:@"id"] intValue];
                [SharedDataHandler sharedInstance].currentBar = [NSDictionary dictionaryWithDictionary:barSection];
                
                
//                BSTDrinkTypeViewController *selectionView = [[BSTDrinkTypeViewController alloc] initWithBarSection:[[barSection objectForKey:@"id"] intValue]];
//                [self.navigationController pushViewController:selectionView animated:YES];
                
                CollapsableDrinkViewController *test = [[CollapsableDrinkViewController alloc] initWithBarSection:[[barSection objectForKey:@"id"] intValue]];
                [self.navigationController pushViewController:test animated:YES];
                
//                if ([indexPath section] == 1) {
//                    BSTDrinkTypeViewController *selectionView = [[BSTDrinkTypeViewController alloc] initWithBarSection:[[barSection objectForKey:@"id"] intValue]];
//                    [self.navigationController pushViewController:selectionView animated:YES];
//                } else {
//                    DrinkSelectionsViewController *selectionView = [[DrinkSelectionsViewController alloc] initWithBarSection:[[barSection objectForKey:@"id"] intValue]];
//                    [self.navigationController pushViewController:selectionView animated:YES];
//                }
                
            } else {
                //OTHERWISE GO TO BAR SELECTION SCREEN
                SelectBarSectionViewController *selectSection = [[SelectBarSectionViewController alloc] initWithBarSections:objects];
                [self.navigationController pushViewController:selectSection animated:YES];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
    });
}

#pragma mark - MapView Delegate Methods

-(void)setupMap {
    
    NSMutableArray *barAnnotations = [[NSMutableArray alloc] init];
    
    for (NSDictionary *bar in self.bars) {
        MKPointAnnotation *barAnnotation = [[MKPointAnnotation alloc] init];
        barAnnotation.title = [bar objectForKey:@"name"];
        barAnnotation.subtitle = [NSString stringWithFormat:@"Happy Hour: 4:00 to 9:00"];
        
        CLLocationCoordinate2D barLocation = CLLocationCoordinate2DMake([[bar objectForKey:@"latitude"] floatValue], [[bar objectForKey:@"longitude"] floatValue]);
        barAnnotation.coordinate = barLocation;
        
        [barAnnotations addObject:barAnnotation];
    }
    
    [self.mapView addAnnotations:barAnnotations];
    
    // CHOOSE FROM BELOW WHAT TO ZOOM TO
    
    //    MKMapRect flyTo = MKMapRectNull;
    //
    //    for (id <MKAnnotation> annotation in self.mapView.annotations) {
    //        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
    //        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
    //        if (MKMapRectIsNull(flyTo)) {
    //            flyTo = pointRect;
    //        } else {
    //            flyTo = MKMapRectUnion(flyTo, pointRect);
    //        }
    //    }
    //
    //    // Position the map so that all overlays and annotations are visible on screen.
    //    self.mapView.visibleMapRect = flyTo;
    
    MKCoordinateRegion mapRegion;
    //    mapRegion.center.latitude = self.mapView.userLocation.coordinate.latitude;
    //    mapRegion.center.longitude = self.mapView.userLocation.coordinate.longitude;
    mapRegion.center = self.mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.01;
    mapRegion.span.longitudeDelta = 0.01;
    [self.mapView setRegion:mapRegion animated: YES];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
}

@end
