//
//  HTCheckVersion.h
//  chookr
//
//  Created by Chanxa-admin on 2017/6/23.
//  Copyright © 2017年 com.chanxa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTCheckVersion : NSObject
+ (instancetype)shareInstance;
/**
 检查更新
 */
- (void)checkUpdate;
@end
