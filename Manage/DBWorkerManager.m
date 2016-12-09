//
//  DBWorkerManager.m
//  DianZTC
//
//  Created by 杨力 on 4/9/2016.
//  Copyright © 2016 杨力. All rights reserved.
//

#import "DBWorkerManager.h"
#import "NetManager.h"

@interface DBWorkerManager(){
    FMDatabaseQueue * _dataBaseQueue;
    FMDatabaseQueue * _orderDataBaseQueue;
}

@property (nonatomic,copy) NSString * detailCachePath;
@property (nonatomic,copy) NSString * orderCachePath;

@end

static DBWorkerManager * manager = nil;
@implementation DBWorkerManager

+(instancetype)shareDBManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DBWorkerManager alloc]init];
    });
    return manager;
}

-(instancetype)init{
    
    if(self = [super init]){
        
        //读取本地的plist文件
        self.detailCachePath = [NSString stringWithFormat:@"%@detailCachePath.plist",LIBPATH];
        self.orderCachePath = [NSString stringWithFormat:@"%@orderCachePath",LIBPATH];
        [self createDB];
    }
    return self;
}

#pragma mark -创建数据库
-(void)createDB{
    
    NSArray * docArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //获取Document下面的目录地址
    NSString * docPath = [docArray lastObject];
    //    QFLog(@"docPath:%@",docPath);
    NSString * dbPath = [docPath stringByAppendingPathComponent:@"save.db"];
    NSString * dbPath1 = [docPath stringByAppendingPathComponent:@"order.db"];
    //    QFLog(@"dbPath:%@",dbPath);
    _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    _orderDataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath1];
    
    [self createTable];
}

-(void)createTable{
    
    NSString * sql = @"create table if not exists saveList(number text,img blob,name text)";
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        
        BOOL isSu = [db executeUpdate:sql];
        if(isSu){
            //QFLog(@"%@",@"执行建表语句成功");
        }else{
            //QFLog(@"%@",@"执行建表语句失败");
        }
    }];
    
    NSString * sql1 = @"create table if not exists orderList(number text,img blob,name text)";
    
    [_orderDataBaseQueue inDatabase:^(FMDatabase *db) {
        
        BOOL isSu = [db executeUpdate:sql1];
        if(isSu){
            //QFLog(@"%@",@"执行建表语句成功");
        }else{
            //QFLog(@"%@",@"执行建表语句失败");
        }
        
    }];
}

/*
 @property (nonatomic,copy) NSString * number;
 @property (nonatomic,copy) NSString * img;
 @property (nonatomic,copy) NSString * name;
 */
#pragma mark -向数据库插入数据
-(void)insertInfo:(DetailModel *)model withData:(id)imgData withNumber:(NSString *)number{
    
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        
        //        [db executeUpdate:@"delete from saveList"];
        
        NSString * selectSql = @"select * from saveList where number = ?";
        //查询sql语句
        FMResultSet * set = [db executeQuery:selectSql,number];
        BOOL isExist;
        isExist = NO;
        while([set next]){
            isExist = YES;
        }
        
        if(isExist == NO){
            NSString * insertSQL = @"insert into saveList(number,img,name) values (?,?,?)";
            //执行插入
            BOOL isSuccess = [db executeUpdate:insertSQL,number,imgData,model.name];
            if (isSuccess) {
                //                QFLog(@"%@",@"执行插入语句成功");
            }else{
                //                QFLog(@"%@",@"执行插入语句失败");
            }
        }
    }];
}

-(void)order_insertInfo:(DetailModel *)model withData:(id)imgData withNumber:(NSString *)number{
    
    [_orderDataBaseQueue inDatabase:^(FMDatabase *db) {
        
        NSString * selectSql = @"select * from orderList where number = ?";
        //查询sql语句
        FMResultSet * set = [db executeQuery:selectSql,number];
        BOOL isExist;
        isExist = NO;
        while([set next]){
            isExist = YES;
        }
        
        if(isExist == NO){
            NSString * insertSQL = @"insert into orderList(number,img,name) values (?,?,?)";
            //执行插入
            BOOL isSuccess = [db executeUpdate:insertSQL,number,imgData,model.name];
            if (isSuccess) {
                                QFLog(@"%@",@"执行插入语句成功");
            }else{
                                QFLog(@"%@",@"执行插入语句失败");
            }
        }
    }];
}

-(void)order_getAllObject:(DBSaveBlock)block{
    
    [_orderDataBaseQueue inDatabase:^(FMDatabase *db) {
        
        NSString * selectSql = @"select * from orderList";
        FMResultSet * rs = [db executeQuery:selectSql];
        NSMutableArray * array = [NSMutableArray array];
        while([rs next]){
            
            DBSaveModel * model = [[DBSaveModel alloc]init];
            model.number = [rs stringForColumn:@"number"];
            model.name = [rs stringForColumn:@"name"];
            model.img = [rs dataForColumn:@"img"];
            model.isSeleted = NO;
            [array addObject:model];
        }
        block(array);
    }];

}

-(void)getAllObject:(DBSaveBlock)block{
    
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        
        NSString * selectSql = @"select * from saveList";
        FMResultSet * rs = [db executeQuery:selectSql];
        NSMutableArray * array = [NSMutableArray array];
        while([rs next]){
            
            DBSaveModel * model = [[DBSaveModel alloc]init];
            model.number = [rs stringForColumn:@"number"];
            model.name = [rs stringForColumn:@"name"];
            model.img = [rs dataForColumn:@"img"];
            model.isSeleted = NO;
            [array addObject:model];
        }
        block(array);
    }];
}

-(void)cleanDBDataWithNumber:(NSString *)number{
    
    NSString * deleteSql = @"delete from saveList where number = ?";
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        
        BOOL isDelete = [db executeUpdate:deleteSql,number];
        if(isDelete){
            
            //            QFLog(@"%@",@"根据number移除数据成功");
        }else{
            //            QFLog(@"%@",@"根据number移除数据失败");
        }
    }];
}

-(void)order_cleanDBDataWithNumber:(NSString *)number{
    
    NSString * deleteSql = @"delete from orderList where number = ?";
    [_orderDataBaseQueue inDatabase:^(FMDatabase *db) {
        
        BOOL isDelete = [db executeUpdate:deleteSql,number];
        if(isDelete){
            
            //            QFLog(@"%@",@"根据number移除数据成功");
        }else{
            //            QFLog(@"%@",@"根据number移除数据失败");
        }
    }];
}


-(void)cleanAllDBData{
    
    NSString * deleteSql = @"delete from saveList";
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        
        BOOL isDelete = [db executeUpdate:deleteSql];
        if(isDelete){
            
            //            QFLog(@"%@",@"移除数据库所有数据成功");
        }else{
            //            QFLog(@"%@",@"根据number移除数据失败");
        }
    }];
}

-(void)order_cleanAllDBData{
    
    NSString * deleteSql = @"delete from orderList";
    [_orderDataBaseQueue inDatabase:^(FMDatabase *db) {
        
        BOOL isDelete = [db executeUpdate:deleteSql];
        if(isDelete){
            
            //            QFLog(@"%@",@"移除数据库所有数据成功");
        }else{
            //            QFLog(@"%@",@"根据number移除数据失败");
        }
    }];
}

-(void)saveDatailCache:(NSString *)number withData:(id)responseObject{
    
    NSMutableArray * CacheArray = [NSMutableArray arrayWithContentsOfFile:self.detailCachePath];
    if(CacheArray == nil){
        CacheArray = [NSMutableArray array];
    }
    NSDictionary * dict = @{number:responseObject};
    if(![CacheArray containsObject:dict]){
        [CacheArray addObject:dict];
        [CacheArray writeToFile:self.detailCachePath atomically:YES];
    }
}

-(void)order_saveDatailCache:(NSString *)number withData:(id)responseObject{
    
    NSMutableArray * CacheArray = [NSMutableArray arrayWithContentsOfFile:self.orderCachePath];
    if(CacheArray == nil){
        CacheArray = [NSMutableArray array];
    }
    NSDictionary * dict = @{number:responseObject};
    if(![CacheArray containsObject:dict]){
        [CacheArray addObject:dict];
       BOOL isOK = [CacheArray writeToFile:self.orderCachePath atomically:YES];
        if(isOK){
//            NSLog(@"保存订单缓存数据成功");
        }else{
//            NSLog(@"保存订单缓存数据成功");
        }
    }
}

-(void)getAllDetailCache:(NSString *)number completion:(DetailDataBlock)block{
    
    //从文件读取数据
    NSArray * fileArray = [[NSArray alloc]initWithContentsOfFile:self.detailCachePath];
    for(NSDictionary * dict in fileArray){
        if([[[dict allKeys]lastObject]isEqualToString:number]){
            block(dict[number]);
            break;
        }
    }
}
-(void)order_getAllDetailCache:(NSString *)number completion:(DetailDataBlock)block{
    
    //从文件读取数据
    NSArray * fileArray = [[NSArray alloc]initWithContentsOfFile:self.orderCachePath];
    for(NSDictionary * dict in fileArray){
        if([[[dict allKeys]lastObject]isEqualToString:number]){
            block(dict[number]);
            break;
        }
    }
}
-(void)cleanAllSavedImageDiskAndCache{
    
    //从文件读取数据
    NSArray * fileArray = [[NSArray alloc]initWithContentsOfFile:self.detailCachePath];
    for(NSDictionary * dict in fileArray){
        NSString * key = [[dict allKeys]lastObject];
        NSData * data = [dict objectForKey:key];
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        //拼接ip和port
        NetManager * manager = [NetManager shareManager];
        NSString * URLstring = [NSString stringWithFormat:BANNERCONNET,[manager getIPAddress]];
        NSMutableArray * subArray = dict[@"imgs"];
        for(NSDictionary * subDict in subArray){
            NSString * urlAddress = [NSString stringWithFormat:@"%@%@",URLstring,subDict[@"img"]];
            [self bt_cleanUpDiskAndCacheWithUrl:urlAddress];
        }
    }
}

-(void)cleanDataCacheWithNumber:(NSString *)number{
    
    NSMutableArray * CacheArray = [NSMutableArray arrayWithContentsOfFile:self.detailCachePath];
    NSMutableArray * tempArray = [NSMutableArray array];
    for(int i=0;i<CacheArray.count;i++){
        
        NSDictionary * dict = CacheArray[i];
        if(![[[dict allKeys]lastObject]isEqualToString:number]){
            [tempArray addObject:dict];
        }
    }
    [self cleanAllCache];
    [tempArray writeToFile:self.detailCachePath atomically:YES];
}

-(void)order_cleanDataCacheWithNumber:(NSString *)number{
    
    NSMutableArray * CacheArray = [NSMutableArray arrayWithContentsOfFile:self.orderCachePath];
    NSMutableArray * tempArray = [NSMutableArray array];
    for(int i=0;i<CacheArray.count;i++){
        
        NSDictionary * dict = CacheArray[i];
        if(![[[dict allKeys]lastObject]isEqualToString:number]){
            [tempArray addObject:dict];
        }
    }
    [self cleanAllCache];
    [tempArray writeToFile:self.orderCachePath atomically:YES];
}

-(void)cleanAllCache{
    
    NSFileManager * fm = [NSFileManager defaultManager];
    BOOL isExist = [fm fileExistsAtPath:self.detailCachePath];
    if(isExist){
        NSError * error;
        [fm removeItemAtPath:self.detailCachePath error:&error];
    }
}

-(void)cleanUpImageInCache{
    
    [[SDImageCache sharedImageCache]clearMemory];
    [[SDImageCache sharedImageCache]cleanDisk];
}

-(void)cleanUpImageInDishes{
    
    [[SDImageCache sharedImageCache]clearDisk];
}

-(NSInteger)bt_getCacheSize{
    
    return [[SDImageCache sharedImageCache]getSize];
}

-(void)bt_cleanUpDiskAndCacheWithUrl:(NSString *)urlAddress{
    
    [[SDImageCache sharedImageCache]removeImageForKey:urlAddress fromDisk:YES];
    [[SDImageCache sharedImageCache]removeImageForKey:urlAddress];
}

-(BOOL)bt_productIsBeenSaveWithNumberID:(NSString *)number{
    
    __block BOOL isSaved = NO;
    [self getAllObject:^(NSMutableArray *dataArray) {
        
        for(DBSaveModel * model in dataArray){
            
//            NSLog(@"bbbb:%@",model.number);
            
            if([model.number isEqualToString:number]){
                isSaved = YES;
                break;
            }else{
                isSaved = NO;
            }
        }
    }];
    return isSaved;
}

-(BOOL)judgeSaveFileExists{
    
    NSMutableArray * array = [NSMutableArray array];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        
        NSString * selectSql = @"select * from saveList";
        FMResultSet * rs = [db executeQuery:selectSql];
        
        while([rs next]){
            
            DBSaveModel * model = [[DBSaveModel alloc]init];
            model.number = [rs stringForColumn:@"number"];
            model.name = [rs stringForColumn:@"name"];
            model.img = [rs dataForColumn:@"img"];
            model.isSeleted = NO;
            [array addObject:model];
        }
    }];
    return array.count>0?YES:NO;
}

@end