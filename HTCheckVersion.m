//
//  HTCheckVersion.m
//  chookr
//
//  Created by Chanxa-admin on 2017/6/23.
//  Copyright © 2017年 com.chanxa. All rights reserved.
//

#import "HTCheckVersion.h"
#import "AFNetworking.h"

static HTCheckVersion *instance;

@interface HTCheckVersion()<UIAlertViewDelegate>
/**
 appstore链接
 */
@property(nonatomic,copy)NSString *appUrl;

@end
@implementation HTCheckVersion
+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

+ (instancetype)shareInstance
{
    return [[self alloc]init];
}
- (void)checkUpdate
{
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    NSString *bundleId = [self getBundleID];
    NSString *encodingUrl=[[@"http://itunes.apple.com/lookup?bundleId=" stringByAppendingString:bundleId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [manager GET:encodingUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *resultDic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSArray *resultArray = resultDic[@"results"];
        if (resultArray.count == 0) {
            NSLog(@"Error:------未找到应用信息,请确认应用是否上架------");
            return ;
        }
        NSString * versionStr =[[[resultDic objectForKey:@"results"] objectAtIndex:0] valueForKey:@"version"];
        
        NSString *notes = [[[resultDic objectForKey:@"results"] objectAtIndex:0] valueForKey:@"releaseNotes"];
        self.appUrl = [[[resultDic objectForKey:@"results"] objectAtIndex:0] valueForKey:@"trackViewUrl"];
        NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
        NSString * currentVersion = [NSString stringWithFormat:@"%@",[infoDic valueForKey:@"CFBundleShortVersionString"]];
        NSArray *currentVersionArr = [currentVersion componentsSeparatedByString:@"."];
        NSArray *appstoreVersionArr = [versionStr componentsSeparatedByString:@"."];
        BOOL isNewVersion = [self compareWithVersion:currentVersionArr AndAppstoreVersion:appstoreVersionArr];
        
        if(isNewVersion == YES){
            
            [self showUpdateView:notes];
            
        }else{
            
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}
-(NSString*)getBundleID

{
    
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    
}
- (BOOL)compareWithVersion:(NSArray*)currentVersionArray AndAppstoreVersion:(NSArray*)appstoreVersionArray
{
    //比较版本号
    for (int i = 0; i<currentVersionArray.count; i++) {
        NSString *currentVersion = currentVersionArray[i];
        NSString *appstoreVersion = appstoreVersionArray[i];
        if ([currentVersion floatValue]<[appstoreVersion floatValue]) {
            return YES;
        }
        else {
            if (i == currentVersionArray.count-1) {
                return NO;
            }
        }
    }
    return NO;
}
- (void)showUpdateView:(NSString *)newVersion
{
    
    NSString *alertMsg=[[@"更新内容:" stringByAppendingString:[NSString stringWithFormat:@"%@",newVersion]] stringByAppendingString:@"\n赶快体验最新版本吧！"];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"发现新版本" message:alertMsg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"更新", nil];
    [alertView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.appUrl]];
    }
}
@end
