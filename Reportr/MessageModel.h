//
//  MessageModel.h
//  Reportr
//
//  Created by Kim Adams on 5/1/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject
+(MessageModel*) messageModel;
+(BOOL) testMode;
+(NSString*) firebaseURL;
@end
