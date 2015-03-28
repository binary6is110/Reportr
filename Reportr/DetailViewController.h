//
//  DetailViewController.h
//  Reportr
//
//  Created by Kim Adams on 3/27/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface DetailViewController : UIViewController<GMSMapViewDelegate>

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

