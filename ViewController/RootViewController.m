//
//  RootViewController.m
//  DianZTC
//
//  Created by 杨力 on 23/7/2016.
//  Copyright © 2016 杨力. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

-(void)viewDidLoad{
    
    [super viewDidLoad];
}

#pragma mark -计算产品描述Label的高度
-(CGFloat)getDescriptionHeight:(NSString *)text{
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(10*S6, 0, Wscreen-50*S6, 10)];
    label.text = text;
    label.font = [UIFont systemFontOfSize:14*S6];
    label.numberOfLines = 0;
    [label sizeToFit];
    return label.height;
}


#pragma mark - 获取本地图片路径
-(NSString *)captureLocalImage:(NSString *)imageName withType:(NSString *)imageType{
    
    return [[NSBundle mainBundle]pathForResource:imageName ofType:imageType];
}

#pragma mark -将字典转化成json字符串
- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSString*)myArrayToJson:(NSMutableArray *)array{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(NSString *)arrayToJson:(NSMutableArray *)picArr{
    
    if (picArr && picArr.count > 0) {
        
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
        
        for (NSDictionary * dict in picArr) {
            
            NSString * jsonText = [self dictionaryToJson:dict];
            [arr addObject:jsonText];
        }
        
        return [self objArrayToJSON:arr];
    }
    
    return nil;
}

//把多个json字符串转为一个json字符串
- (NSString *)objArrayToJSON:(NSArray *)array {
    
    NSString *jsonStr = @"[";
    
    for (NSInteger i = 0; i < array.count; ++i) {
        if (i != 0) {
            jsonStr = [jsonStr stringByAppendingString:@","];
        }
        jsonStr = [jsonStr stringByAppendingString:array[i]];
    }
    jsonStr = [jsonStr stringByAppendingString:@"]"];
    
    return jsonStr;
}


-(void)showAlertViewWithTitle:(NSString *)title{
    UIAlertController * alertVc = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertVc animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertVc dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

-(YLProgressHUD *)ylHud{
    
    if(_ylHud == nil){
        _ylHud = [[YLProgressHUD alloc]initWithView:self.view];
    }
    return _ylHud;
}

-(MBProgressHUD *)hud{
    
    if(_hud == nil){
        
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.labelText = @"正在加载...";
        _hud.animationType = MBProgressHUDAnimationZoomOut;
    }
    
    return _hud;
}

@end