//
//  DHMagicPaintView.h
//  MagicPainter
//
//  Created by Mac on 2016/11/21.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHPaintView.h"

@interface DHMagicPaintView : DHPaintView

// default is 8
@property (nonatomic, assign) NSInteger numberOfParts;

- (void)saveToAlbumWithCompletionBlock:(void(^)(BOOL success))completion;

@end
