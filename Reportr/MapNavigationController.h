//
//  MapNavigationController.h
//  Reportr
//
//  Created by Kim Adams on 4/21/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface MapNavigationController : UINavigationController
-(void) passModel:(UserModel*)model;
@end
