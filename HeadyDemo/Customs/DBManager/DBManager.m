//
//  DBHelper.m
//  Demo Project
//
//  Created by Apple Developer on 12/11/16.
//  Copyright © 2016 Apple Developer. All rights reserved.
//

#import "DBManager.h"
#import "HeadyDemo-Swift.h"

@import UserNotifications;
static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;



@implementation DBManager


+(DBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

-(BOOL)createDB
{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"UTSDriver.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            
            const char *sql_stmt = "create table if not exists CATEGORY(CATEGORY_ID integer primary key, NAME text,CHILD_CATEGORIES text);"
            
            "create table if not exists PRODUCT(CATEGORY_ID integer, PRODUCT_ID integer primary key, NAME text,DATE_ADDED text, VIEW_COUNT text, ORDER_COUNT text, SHARES text);"
            
            "create table if not exists TAX(PRODUCT_ID integer, NAME text,VALUE integer);"
            
            "create table if not exists VARIANT(PRODUCT_ID integer, VARIANT_ID integer primary key, COLOR text, SIZE text, PRICE text);";
            
            NSLog(@"sql_stmt.. %s",sql_stmt);
            
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
    
}

-(void)checkColumnExists:(NSString *)tableName withColumn:(NSString *)columnName
{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent:@"UTSDriver.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:databasePath])
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            BOOL columnExists = NO;//HotelReservation text, LegId text
            
            sqlite3_stmt *selectStmt;
            
            NSString *queryString = [NSString stringWithFormat:@"select %@ from %@;", columnName, tableName];
            const char *sqlStatement = [queryString UTF8String];
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &selectStmt, NULL) == SQLITE_OK){
                columnExists = YES;
            }
            
            if(!columnExists){
                [self alterTables:tableName withColumn:columnName];
            }
        }
    }
}

- (BOOL)alterTables:(NSString *)tableName withColumn:(NSString *)columnName {
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"UTSDriver.db"]];
    
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:databasePath])
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            
            NSString *queryString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ TEXT;", tableName, columnName];
            const char *sql_stmt = [queryString UTF8String];
            
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                isSuccess = NO;
                //^^NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            
            database = nil; //Test Abhishek
            return  isSuccess;
            
        }
        else {
            isSuccess = NO;
            //^^NSLog(@"Failed to open/create database");
        }
    }
    else
    {
    }
    return isSuccess;
}

-(BOOL)updateSchema
{
    [self removeDatabase];
    return [self createDB];
}
// remove Database

-(void)removeDatabase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath =  [documentsDirectory stringByAppendingPathComponent:@"UTSDriver.db"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
}


-(BOOL)insertVariants:(int)productId
            variantId:(int)variantId
                color:(NSString*)color
                 size:(NSString*)size
                price:(NSString*)price {
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        //"create table if not exists VARIANT(PRODUCT_ID integer, VARIANT_ID integer primary key, COLOR text, SIZE text, PRICE text);"
        NSString *insertSQL = [NSString stringWithFormat:
                               @"insert into VARIANT(PRODUCT_ID, VARIANT_ID, COLOR, SIZE, PRICE) values(\"%d\",\"%d\",\"%@\",\"%@\",\"%@\")",
                               productId, variantId, color, size, price];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        {
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                sqlite3_finalize(statement);
                return YES;
                
            }
            else {
                
                NSLog(@"sqlite3_errmsg....  %s",sqlite3_errmsg(database));
                sqlite3_finalize(statement);
                return NO;
            }
            
        }
    }
    return NO;
}

- (NSArray *)getVariants:(NSString *)productId {
    const char *utf8Dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(utf8Dbpath, &database) == SQLITE_OK)
    {
        NSLog(@"Databse open Correctly");
    }
    else
    {
        NSLog(@"Databse not open Correctly");
    }
    
    NSMutableArray *retval = [[NSMutableArray alloc] init] ;
    NSString *query = [NSString stringWithFormat:@"SELECT VARIANT_ID, COLOR, SIZE, PRICE FROM VARIANT where PRODUCT_ID=%@", productId];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *variantId            = (char *) sqlite3_column_text(statement, 0);
            char *color              = (char *) sqlite3_column_text(statement, 1);
            char *size             = (char *) sqlite3_column_text(statement, 2);
            char *price                = (char *) sqlite3_column_text(statement, 3);
            
            NSString *variantIds = [[NSString alloc] initWithUTF8String:variantId];
            NSString *colors = [[NSString alloc] initWithUTF8String:color];
            NSString *sizes = [[NSString alloc] initWithUTF8String:size];
            NSString *prices = [[NSString alloc] initWithUTF8String:price];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:variantIds forKey:@"id"];
            [dict setObject:colors forKey:@"color"];
            [dict setObject:sizes forKey:@"size"];
            [dict setObject:prices forKey:@"price"];
            [retval addObject:dict];
            
            /*
             GeopointBody *gp = [[GeopointBody alloc]init];
             gp.GeofenceId = GeofenceIds;
             gp.Latitude = Latitudes;
             gp.Longitude = Longitudes;
             gp.Radius = Radiuss;
             [retval addObject:gp];*/
        }
    }
    else{
        
        NSLog(@"sqlite3_errmsg Completed Jobs Data ....  %s",sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    
    return retval;
}


-(BOOL)insertTax:(int)productId
            name:(NSString*)name
           value:(NSString*)value {
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {//"create table if not exists TAX(PRODUCT_ID integer, NAME text,VALUE integer);"
        NSString *insertSQL = [NSString stringWithFormat:
                               @"insert into TAX(PRODUCT_ID, NAME, VALUE) values(\"%d\",\"%@\",\"%@\")",
                               productId, name, value];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        {
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                sqlite3_finalize(statement);
                return YES;
                
            }
            else {
                
                NSLog(@"sqlite3_errmsg....  %s",sqlite3_errmsg(database));
                sqlite3_finalize(statement);
                return NO;
            }
            
        }
    }
    return NO;
}

- (NSArray *)getTax:(NSString *)productId {
    const char *utf8Dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(utf8Dbpath, &database) == SQLITE_OK)
    {
        NSLog(@"Databse open Correctly");
    }
    else
    {
        NSLog(@"Databse not open Correctly");
    }
    
    NSMutableArray *retval = [[NSMutableArray alloc] init] ;
    NSString *query = [NSString stringWithFormat:@"SELECT NAME, VALUE FROM TAX where PRODUCT_ID=%@", productId];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *name            = (char *) sqlite3_column_text(statement, 0);
            char *value           = (char *) sqlite3_column_text(statement, 1);
            
            NSString *names = [[NSString alloc] initWithUTF8String:name];
            NSString *values = [[NSString alloc] initWithUTF8String:value];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:names forKey:@"name"];
            [dict setObject:values forKey:@"value"];
            [retval addObject:dict];
        }
    }
    else{
        
        NSLog(@"sqlite3_errmsg Completed Jobs Data ....  %s",sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    
    return retval;
}


-(BOOL)insertProducts:(int)categoryId
            productId:(int)productId
                 name:(NSString*)name
            dateAdded:(NSString*)dateAdded {
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"insert into PRODUCT(CATEGORY_ID, PRODUCT_ID, NAME, DATE_ADDED) values(\"%d\",\"%d\",\"%@\",\"%@\")",
                               categoryId,productId, name, dateAdded];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        {
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                sqlite3_finalize(statement);
                return YES;
                
            }
            else {
                
                NSLog(@"sqlite3_errmsg....  %s",sqlite3_errmsg(database));
                sqlite3_finalize(statement);
                return NO;
            }
            
        }
    }
    return NO;
}

- (NSArray *)getProducts:(NSString *)categoryId {
    const char *utf8Dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(utf8Dbpath, &database) == SQLITE_OK)
    {
        NSLog(@"Databse open Correctly");
    }
    else
    {
        NSLog(@"Databse not open Correctly");
    }
    
    //create table if not exists PRODUCT(CATEGORY_ID integer, PRODUCT_ID integer primary key, NAME text,DATE_ADDED text, VIEW_COUNT text, ORDER_COUNT text, SHARES text);
    NSMutableArray *retval = [[NSMutableArray alloc] init] ;
    NSString *query = [NSString stringWithFormat:@"SELECT PRODUCT_ID, NAME, DATE_ADDED, VIEW_COUNT, ORDER_COUNT, SHARES FROM PRODUCT where CATEGORY_ID=%@", categoryId];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *productId      = (char *) sqlite3_column_text(statement, 0);
            char *name           = (char *) sqlite3_column_text(statement, 1);
            char *date_added     = (char *) sqlite3_column_text(statement, 2);
            char *view_count     = (char *) sqlite3_column_text(statement, 3);
            char *order_count    = (char *) sqlite3_column_text(statement, 4);
            char *share          = (char *) sqlite3_column_text(statement, 5);
            
            NSString *productIds = [[NSString alloc] initWithUTF8String:productId];
            NSString *names = [[NSString alloc] initWithUTF8String:name];
            NSString *date_addeds = [[NSString alloc] initWithUTF8String:date_added];
            NSString *view_counts = [[NSString alloc] initWithUTF8String:(view_count)?view_count:""];
            NSString *order_counts = [[NSString alloc] initWithUTF8String:(order_count)?order_count:""];
            NSString *shares = [[NSString alloc] initWithUTF8String:(share)?share:""];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:names forKey:@"name"];
            [dict setObject:productIds forKey:@"productId"];
            [dict setObject:date_addeds forKey:@"date_added"];
            [dict setObject:view_counts forKey:@"view_count"];
            [dict setObject:order_counts forKey:@"order_count"];
            [dict setObject:shares forKey:@"share"];
            [retval addObject:dict];
        }
    }
    else{
        
        NSLog(@"sqlite3_errmsg Completed Jobs Data ....  %s",sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    
    return retval;
}

-(BOOL)insertCategory:(int)categoryId
                 NAME:(NSString*)NAME
     CHILD_CATEGORIES:(NSString*)CHILD_CATEGORIES {
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:
                               @"insert into CATEGORY(CATEGORY_ID, NAME, CHILD_CATEGORIES) values(\"%d\",\"%@\",\"%@\")",
                               categoryId, NAME, CHILD_CATEGORIES];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        {
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                sqlite3_finalize(statement);
                return YES;
                
            }
            else {
                
                NSLog(@"sqlite3_errmsg....  %s",sqlite3_errmsg(database));
                sqlite3_finalize(statement);
                return NO;
            }
            
        }
    }
    return NO;
}

- (NSArray *)getCategories {
    const char *utf8Dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(utf8Dbpath, &database) == SQLITE_OK)
    {
        NSLog(@"Databse open Correctly");
    }
    else
    {
        NSLog(@"Databse not open Correctly");
    }
    
    NSMutableArray *retval = [[NSMutableArray alloc] init] ;
    //"create table if not exists CATEGORY(CATEGORY_ID integer primary key, NAME text,CHILD_CATEGORIES text);"
    NSString *query = [NSString stringWithFormat:@"SELECT CATEGORY_ID, NAME, CHILD_CATEGORIES FROM CATEGORY"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *categoryId            = (char *) sqlite3_column_text(statement, 0);
            char *name              = (char *) sqlite3_column_text(statement, 1);
            char *child_categories             = (char *) sqlite3_column_text(statement, 2);
            
            NSString *categoryIds = [[NSString alloc] initWithUTF8String:categoryId];
            NSString *names = [[NSString alloc] initWithUTF8String:name];
            NSString *child_categoriess = [[NSString alloc] initWithUTF8String:child_categories];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:categoryIds forKey:@"categoryId"];
            [dict setObject:names forKey:@"name"];
            [dict setObject:child_categoriess forKey:@"child_categories"];
            [retval addObject:dict];
        }
    }
    else{
        NSLog(@"sqlite3_errmsg Completed Jobs Data ....  %s",sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    
    return retval;
}

-(BOOL)updateRankforProduct:(int)productId
                    rankKey:(NSString*)rankKey
                      value:(NSString*)value
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        
        //create table if not exists PRODUCT(CATEGORY_ID integer, PRODUCT_ID integer primary key, NAME text,DATE_ADDED text, VIEW_COUNT text, ORDER_COUNT text, SHARES text);
        
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE PRODUCT Set %@='%@' where PRODUCT_ID ='%d'",rankKey,value,productId];
        
        if ([rankKey isEqualToString:@"shares"]) {
            NSLog(@"");
        }
        
        const char *update_stmt = [updateSQL UTF8String];
        
        sqlite3_stmt *statement = nil;
        
        sqlite3_prepare_v2(database, update_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else
        {
            NSLog(@"sqlite3_errmsg %s",sqlite3_errmsg(database));
            return  NO;
            
        }
        
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return NO;
}

@end
