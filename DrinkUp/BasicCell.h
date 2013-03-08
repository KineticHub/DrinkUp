//
//  BasicCell.h
//  DrinkUp
//
//  Created by Kinetic on 3/6/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEFAULT_CELL_TITLE_FONT [UIFont boldSystemFontOfSize:18.0]
#define DEFAULT_CELL_DESCRIPTION_FONT [UIFont boldSystemFontOfSize:16.0]

@interface BasicCell : UITableViewCell
-(void)setCellImage:(NSURLRequest *)imageURL;
@end
