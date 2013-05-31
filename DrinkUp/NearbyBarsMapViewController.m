//
//  NearbyBarsMapViewController.m
//  DrinkUp
//
//  Created by Kinetic on 3/17/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "NearbyBarsMapViewController.h"
#import "SharedDataHandler.h"
#import "MBProgressHUD.h"

@interface NearbyBarsMapViewController ()
@property (nonatomic, strong) NSMutableArray *bars;
@property (nonatomic, strong) MKMapView *mapView;
@end

@implementation NearbyBarsMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[SharedDataHandler sharedInstance] initializeLocationTracking];
    
    self.bars = [[NSMutableArray alloc] init];
    NSLog(@"nearby bars map view did load");
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SharedDataHandler sharedInstance] loadBarsWithLocation:^(NSMutableArray *objects) {
            
            self.bars = [NSMutableArray arrayWithArray:objects];
            [self setupMap];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
    });
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.mapView setShowsUserLocation:YES];
    [self.view addSubview:self.mapView];
}

-(void)viewWillAppear:(BOOL)animated
{
     NSLog(@"nearby bars map view will appear");
    [[SharedDataHandler sharedInstance] loadBarsWithLocation:^(NSMutableArray *objects)
    {
        self.bars = [NSMutableArray arrayWithArray:objects];
        [[SharedDataHandler sharedInstance] loadUserLocation];
        [self setupMap];
    }];
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
