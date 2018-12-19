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

//-(BOOL)InsertCompletedJobs:(int)COLUMN_ID
//             CompletedJobs:(NSString*)CompletedJobs;
//
//- (NSArray *)getCompletedJobs;


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
            
            "create table if not exists PRODUCT(CATEGORY_ID integer, PRODUCT_ID integer primary key, NAME text,DATE_ADDED text);"
            
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

-(BOOL)updateCurrentJob:(NSString *)COLUMN_NAME
              withValue:(NSString*)Value
              forRideID:(NSString *)rideID
{
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *updateSQL = [NSString stringWithFormat:@"update UTSCurrentJobs Set '%@'='%@' where  RideId ='%@'",COLUMN_NAME,Value,rideID];
        
        const char *insert_stmt = [updateSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        {
            //sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL); //
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


-(BOOL)InsertUTSDriverCanMessages:(int)COLUMN_ID
                          Message:(NSString*)Message
{
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:
                               @"insert into UTSDriverCanMessages (COLUMN_ID,Message) values(\"%d\",\"%@\")",
                               COLUMN_ID,
                               Message];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        {
            //sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL); //
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



- (NSArray *)getCanMessages 
{
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
    NSString *query = [NSString stringWithFormat:@"SELECT Message FROM UTSDriverCanMessages"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            char *Message = (char *) sqlite3_column_text(statement, 0);
            
            NSString *Messages = [[NSString alloc] initWithUTF8String:Message];
            [retval addObject:Messages];
            
        }
    }
    else{
        
        // NSLog(@"sqlite3_errmsg retiving Legs Data ....  %s",sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    
    return retval;
}



-(BOOL)InsertUTSDriverBookZoneMessages:(int)COLUMN_ID
                                ZoneId:(NSString*)ZoneId
                                  Name:(NSString*)Name
                                   Lat:(NSString*)Lat
                                  Long:(NSString*)Long
                              ZoneType:(NSString*)ZoneType
{
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        //(COLUMN_ID integer primary key, ZoneID text,Name text,Lat text,Long text,ZoneType text)
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"insert into InsertUTSDriverBookZoneMessages (COLUMN_ID,ZoneID,Name,Lat,Long,ZoneType) values(\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",
                               COLUMN_ID,
                               ZoneId,
                               Name,
                               Lat,
                               Long,
                               ZoneType];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        {
            //sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL); //
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



-(BOOL)InsertUTSDriverServerCanMessages:(int)COLUMN_ID
                                Message:(NSString*)Message
                                   Time:(NSString*)Time
{
    const char *dbpath = [databasePath UTF8String];
    
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSArray*Count_ = [[NSArray alloc]init];
        
        Count_ = [self getLastItemID_];
        int databasecount = (int)Count_.count; //[self getLastItemID ];
        NSLog(@"databasecount.. %d",databasecount);
        
        
        long lastRowId = sqlite3_last_insert_rowid(database);
        NSLog(@"lastRowId %ld",lastRowId);
        
        COLUMN_ID = databasecount;
        //COLUMN_ID = (int)lastRowId;
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"insert into UTSDriverServerCanMessages(COLUMN_ID,Message,Time) values(\"%d\",\"%@\",\"%@\")",
                               COLUMN_ID,
                               Message,
                               Time];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        {
            //sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL); //
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
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

-(BOOL)InsertUTSDriverJobsMessages:(int)COLUMN_ID
                            RideID:(NSString*)RideID
                         Passenger:(NSString*)Passenger
                           Message:(NSString*)PickupAt
                              Time:(NSString*)DropoffAt
                           Message:(NSString*)PaxNo
                              Time:(NSString*)PickUpTime
                              Time:(NSString*)SpecialInstruction
{
    
    const char *dbpath = [databasePath UTF8String];
    
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        
        NSArray*Count_ = [[NSArray alloc]init];
        
        Count_ = [self getLastItemID_];
        int databasecount = (int)Count_.count; //[self getLastItemID ];
        NSLog(@"databasecount.. %d",databasecount);
        
        
        long lastRowId = sqlite3_last_insert_rowid(database);
        NSLog(@"lastRowId %ld",lastRowId);
        
        COLUMN_ID = databasecount;
        //COLUMN_ID = (int)lastRowId;
        
        
        //        "create table if not exists DriverJobsMessages (COLUMN_ID integer primary key, RideID text,Passenger text,PickupAt text,DropoffAt text,PaxNo text,PickUpTime text,SpecialInstruction text));"
        
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"insert into UTSDriverServerCanMessages(COLUMN_ID,RideID,Passenger,PickupAt,DropoffAt,PaxNo,PickUpTime,SpecialInstruction) values(\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",
                               COLUMN_ID,
                               RideID,
                               Passenger,
                               PickupAt,
                               DropoffAt,
                               PaxNo,
                               PickUpTime,
                               SpecialInstruction];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        {
            //sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL); //
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





- (NSArray *)getServerCanMessages
{
    
    
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
    NSString *query = [NSString stringWithFormat:@"SELECT Message,Time FROM UTSDriverServerCanMessages"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            char *Message = (char *) sqlite3_column_text(statement, 0);
            char *time = (char *) sqlite3_column_text(statement, 1);
            
            NSString *Messages = [[NSString alloc] initWithUTF8String:Message];
            NSString*Time =      [[NSString alloc] initWithUTF8String:time];
            /*
            MessagesBody *messages = [[MessagesBody alloc]init];
            
            messages.Message = Messages;
            messages.Time = Time;
            
            [retval addObject:messages];
            
            messages = nil;*/
        }
    }
    else{
        
        // NSLog(@"sqlite3_errmsg retiving Legs Data ....  %s",sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    
    return retval;
}







- (NSArray *)getLastItemID_
{
    
    //const char *utf8Dbpath = [databasePath UTF8String];
    
    
    
    //    if (sqlite3_open(utf8Dbpath, &database) == SQLITE_OK)
    //    {
    //        NSLog(@"Databse open Correctly");
    //    }
    //    else
    //    {
    //        NSLog(@"Databse not open Correctly");
    //    }
    
    NSMutableArray *retval = [[NSMutableArray alloc] init] ;
    NSString *query = [NSString stringWithFormat:@"SELECT Message FROM UTSDriverServerCanMessages"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            char *Message = (char *) sqlite3_column_text(statement, 0);
            
            NSString *Messages = [[NSString alloc] initWithUTF8String:Message];
            [retval addObject:Messages];
            
        }
    }
    else{
        
        NSLog(@"sqlite3_errmsg last Element of Server Messages Data ....  %s",sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    
    return retval;
}



- (int)getLastItemID
{
    
    //data base
    // const char *utf8Dbpath = [databasePath UTF8String];
    
    const char *query = "select MAX(COLUMN_ID) from UTSDriverServerCanMessages";
    sqlite3_stmt *sqlstatement = nil;
    if (sqlite3_prepare_v2(database, query, -1, &sqlstatement, NULL)==SQLITE_OK) {
        
        while (sqlite3_step(sqlstatement)==SQLITE_ROW) {
            
            int lastInsertedPrimaryKey = sqlite3_column_int(sqlstatement, 0);
            return lastInsertedPrimaryKey;
        }
        
        //sqlite3_close(dbreference);
        sqlite3_finalize(sqlstatement);
        
    }
    return 0;
}




-(BOOL)deletecompleteJobs:(NSString*)Message
{
    NSLog(@"Delete Completed Jobs");
    
    NSString * Msg = Message;
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        //(COLUMN_ID integer primary key, ZoneID text,Name text,Lat text,Long text,ZoneType text)
        
        
        // NSArray*Count_ = [[NSArray alloc]init];
        
        // Count_ = [self getLastCompletedJob_];
        // int databasecount = (int)Count_.count; //[self getLastItemID ];
        // NSLog(@"databasecount.. %d",databasecount);
        
        // COLUMN_ID = databasecount;
        
        NSString *deleteSQL = [NSString stringWithFormat: @"delete from UTSCompletedJob where Message ='%@'",Msg];
        
        
        const char *delete_stmt = [deleteSQL UTF8String];
        sqlite3_prepare_v2(database, delete_stmt,-1, &statement, NULL);
        {
            //sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL); //
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                sqlite3_finalize(statement);
                return YES;
            }
            else {
                
                NSLog(@"sqlite3 Delete Complete Jobs _errmsg....  %s",sqlite3_errmsg(database));
                sqlite3_finalize(statement);
                return NO;
            }
            
        }
    }
    return NO;
}



-(BOOL)deleteCannedMessages
{
    NSLog(@"Delete Canned Messages");
    
    //NSString * Msg = Message;
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        //(COLUMN_ID integer primary key, ZoneID text,Name text,Lat text,Long text,ZoneType text)
        
        
        // NSArray*Count_ = [[NSArray alloc]init];
        
        // Count_ = [self getLastCompletedJob_];
        // int databasecount = (int)Count_.count; //[self getLastItemID ];
        // NSLog(@"databasecount.. %d",databasecount);
        
        // COLUMN_ID = databasecount;
        
        
        
        //        sqlite3_stmt *statement;
        //        if(sqlite3_prepare_v2(db, sql,-1, &statement, NULL) == SQLITE_OK)
        //        {
        //            if(sqlite3_step(statement) == SQLITE_DONE){
        //                // executed
        //            }else{
        //                //NSLog(@"%s",sqlite3_errmsg(db))
        //            }
        //        }
        
        
        NSString *deleteSQL = [NSString stringWithFormat: @"delete from UTSDriverCanMessages"];
        
        const char *delete_stmt = [deleteSQL UTF8String];
        sqlite3_prepare_v2(database, delete_stmt,-1, &statement, NULL);
        {
            //sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL); //
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                sqlite3_finalize(statement);
                return YES;
            }
            else
            {
                NSLog(@"sqlite3 Delete Complete Jobs _errmsg....  %s",sqlite3_errmsg(database));
                sqlite3_finalize(statement);
                return NO;
            }
            
        }
    }
    return NO;
}






//NSString*onlocationTime;
//NSString*onBoardTime;
//NSString*unloadedAtTime;//Pax
//NSString*CompleteJobTime;
//NSString*CompleteJobStatus;


//-(BOOL)InsertCompletedJobs:(int)COLUMN_ID
//                   Message:(NSString*)Message
//            onlocationTime:(NSString*)onlocationTime
//               onBoardTime:(NSString*)onBoardTime
//            unloadedAtTime:(NSString*)unloadedAtTime
//           CompleteJobTime:(NSString*)CompleteJobTime
//         CompleteJobStatus:(NSString*)CompleteJobStatus
//                  Username:(NSString*)Username
//               ModifiedPax:(NSString*)ModifiedPax
//                   Command:(NSString*)Command

-(BOOL)InsertCompletedJobs:(int)COLUMN_ID
                   Message:(NSString*)Message
            onlocationTime:(NSString*)onlocationTime
               onBoardTime:(NSString*)onBoardTime
            unloadedAtTime:(NSString*)unloadedAtTime
           CompleteJobTime:(NSString*)CompleteJobTime
         CompleteJobStatus:(NSString*)CompleteJobStatus
                  Username:(NSString*)Username
               ModifiedPax:(NSString*)ModifiedPax
                   Command:(NSString*)Command
            isDriverRating:(NSString*)isDriverRating

{
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        //(COLUMN_ID integer primary key, ZoneID text,Name text,Lat text,Long text,ZoneType text)
        
        NSArray*Count_ = [[NSArray alloc]init];
        
        Count_ = [self getLastCompletedJob_];
        int databasecount = (int)Count_.count; //[self getLastItemID ];
        NSLog(@"databasecount.. %d",databasecount);
        
        COLUMN_ID = databasecount;
        
        //NSString*onlocationTime;
        //NSString*onBoardTime;
        //NSString*unloadedAtTime;//Pax
        //NSString*CompleteJobTime;
        //NSString*CompleteJobStatus;
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"insert into UTSCompletedJob(COLUMN_ID,Message,onlocationTime,onBoardTime,unloadedAtTime,CompleteJobTime,CompleteJobStatus,Username,ModifiedPax,Command,isDriverRating)values(\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",
                               COLUMN_ID,
                               Message,
                               onlocationTime,
                               onBoardTime,
                               unloadedAtTime,
                               CompleteJobTime,
                               CompleteJobStatus,
                               Username,
                               ModifiedPax,
                               Command,
                               isDriverRating];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        {
            //sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL); //
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

-(BOOL)insertScheduledJobs :(NSDictionary *)dict
{
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        //(COLUMN_ID integer primary key, ZoneID text,Name text,Lat text,Long text,ZoneType text)
        
        NSArray*Count_ = [[NSArray alloc]init];
        
        Count_ = [self getScheudleJobs];
        int databasecount = (int)Count_.count; //[self getLastItemID ];
        NSLog(@"databasecount.. %d",databasecount);
        
        int COLUMN_ID = databasecount;
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"insert into DriverScheduledJob(COLUMN_ID,ReservationId,RideId,PaxName,PickupAddress,DropoffAddress,AdultNo,PickupDateTime,SpecialInstruction,Accessible,PickupLatitude,PickupLongitude,DropffLatitude,DropoffLongitude,AirlineCode,AirlineNo,VehicleNo,PickupLocation,IsAllowPreAssignedCancel)values(\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%f\",\"%f\",\"%f\",\"%f\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",
                               COLUMN_ID,
                               [dict objectForKey:@"ReservationId"],
                               [dict objectForKey:@"RideId"],
                               [dict objectForKey:@"PaxName"],
                               [dict objectForKey:@"PickupAddress"],
                               [dict objectForKey:@"DropoffAddress"],
                               [dict objectForKey:@"AdultNo"],
                               [dict objectForKey:@"PickupDateTime"],
                               [dict objectForKey:@"SpecialInstruction"],
                               [dict objectForKey:@"Accessible"],
                               [[dict objectForKey:@"PickupLatitude"]doubleValue],
                               [[dict objectForKey:@"PickupLongitude"] doubleValue],
                               [[dict objectForKey:@"DropffLatitude"] doubleValue],
                               [[dict objectForKey:@"DropoffLongitude"]doubleValue],
                               [dict objectForKey:@"AirlineCode"],
                               [dict objectForKey:@"AirlineNo"],
                               [dict objectForKey:@"VehicleNo"],
                               [dict objectForKey:@"PickupLocation"],
                               [dict objectForKey:@"IsAllowPreAssignedCancel"]
                               ];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        {
            //sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL); //
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
- (NSArray *)getCompletedJobs_forDetail:(NSString*)Message Username:(NSString*)Username
{
    
    const char *utf8Dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(utf8Dbpath, &database) == SQLITE_OK)
    {
        NSLog(@"Databse open Correctly");
    }
    else
    {
        NSLog(@"Databse not open Correctly");
    }
    
    //    @property (nonatomic, strong) NSString  *Message;
    //    @property (nonatomic, strong) NSString  *onlocationTime;
    //
    //    @property (nonatomic, strong) NSString  *onBoardTime;
    //    @property (nonatomic, strong) NSString  *unloadedAtTime;
    //
    //    @property (nonatomic, strong) NSString  *CompleteJobTime;
    //    @property (nonatomic, strong) NSString  *CompleteJobStatus;
    
    
    NSMutableArray *retval = [[NSMutableArray alloc] init] ;
    //    NSString *query = [NSString stringWithFormat:@"SELECT Message,onlocationTime,onBoardTime,unloadedAtTime,CompleteJobTime,CompleteJobStatus FROM UTSCompletedJob where  Message ='%@'",Message];
    
    NSString *query = [NSString stringWithFormat:@"SELECT Message,onlocationTime,onBoardTime,unloadedAtTime,CompleteJobTime,CompleteJobStatus,ModifiedPax,Command FROM UTSCompletedJob where  Message ='%@' AND Username = '%@'",Message,Username];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            char *Message                   = (char *) sqlite3_column_text(statement, 0);
            char *onlocationTime            = (char *) sqlite3_column_text(statement, 1);
            char *onBoardTime               = (char *) sqlite3_column_text(statement, 2);
            char *unloadedAtTime            = (char *) sqlite3_column_text(statement, 3);
            char *CompleteJobTime           = (char *) sqlite3_column_text(statement, 4);
            char *CompleteJobStatus         = (char *) sqlite3_column_text(statement, 5);
            char *ModifiedPax               = (char *) sqlite3_column_text(statement, 6);
            char *Command                   = (char *) sqlite3_column_text(statement, 7);
            
            /*
            ClassCompletedJobs *cCompletedJobs = [[ClassCompletedJobs alloc]init];
            
            cCompletedJobs.Message = [[NSString alloc] initWithUTF8String:Message];
            cCompletedJobs.onlocationTime = [[NSString alloc] initWithUTF8String:onlocationTime];
            
            cCompletedJobs.onBoardTime = [[NSString alloc] initWithUTF8String:onBoardTime];
            cCompletedJobs.unloadedAtTime = [[NSString alloc] initWithUTF8String:unloadedAtTime];
            
            cCompletedJobs.CompleteJobTime = [[NSString alloc] initWithUTF8String:CompleteJobTime];
            cCompletedJobs.CompleteJobStatus = [[NSString alloc] initWithUTF8String:CompleteJobStatus];
            cCompletedJobs.ModifiedPax = [[NSString alloc] initWithUTF8String:ModifiedPax];
            cCompletedJobs.Command = [[NSString alloc] initWithUTF8String:Command];
            
            [retval addObject:cCompletedJobs];
            cCompletedJobs  =  nil;*/
            
        }
    }
    else{
        
        NSLog(@"sqlite3_errmsg Completed Jobs Data ....  %s",sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    
    return retval;
}



- (NSArray *)getScheudleJobs
{
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
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM DriverScheduledJob"];
    
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            char *ReservationId = (char *) sqlite3_column_text(statement, 1);
            char *RideId = (char *) sqlite3_column_text(statement, 2);
            char *PaxName = (char *) sqlite3_column_text(statement, 3);
            char *PickupAddress = (char *) sqlite3_column_text(statement, 4);
            char *DropoffAddress = (char *) sqlite3_column_text(statement,5);
            char *AdultNo = (char *) sqlite3_column_text(statement, 6);
            char *PickupDateTime = (char *) sqlite3_column_text(statement, 7);
            char *SpecialInstruction = (char *) sqlite3_column_text(statement, 8);
            char *Accessible = (char *) sqlite3_column_text(statement, 9);
            double PickupLatitude = (double ) sqlite3_column_double(statement, 10);
            double PickupLongitude = (double ) sqlite3_column_double(statement, 11);
            double DropffLatitude = (double ) sqlite3_column_double(statement, 12);
            double DropoffLongitude = (double ) sqlite3_column_double(statement, 13);
            char *AirlineCode = (char *) sqlite3_column_text(statement, 14);
            char *AirlineNo = (char *) sqlite3_column_text(statement, 15);
            char *VehicleNo = (char *) sqlite3_column_text(statement, 16);
            char *PickupLocation = (char *) sqlite3_column_text(statement, 17);
            char *IsAllowPreAssignedCancel = (char *) sqlite3_column_text(statement, 18);
            
            
            NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
            [ dict setObject:[[NSString alloc]initWithUTF8String:ReservationId] forKey:@"ReservationId"];
            [ dict setObject:[[NSString alloc]initWithUTF8String:RideId] forKey:@"RideId"];
            [ dict setObject:[[NSString alloc]initWithUTF8String:PaxName] forKey:@"PaxName"];
            [ dict setObject:[[NSString alloc]initWithUTF8String:PickupAddress] forKey:@"PickupAddress"];
            [ dict setObject:[[NSString alloc]initWithUTF8String:DropoffAddress] forKey:@"DropoffAddress"];
            [ dict setObject:[[NSString alloc]initWithUTF8String:AdultNo] forKey:@"AdultNo"];
            [ dict setObject:[[NSString alloc]initWithUTF8String:PickupDateTime] forKey:@"PickupDateTime"];
            [ dict setObject:[[NSString alloc]initWithUTF8String:SpecialInstruction] forKey:@"SpecialInstruction"];
            [ dict setObject:[[NSString alloc]initWithUTF8String:Accessible] forKey:@"Accessible"];
            [ dict setObject: [NSNumber numberWithDouble:PickupLatitude] forKey:@"PickupLatitude"];
            [ dict setObject: [NSNumber numberWithDouble:PickupLongitude] forKey:@"PickupLongitude"];
            [ dict setObject: [NSNumber numberWithDouble:DropffLatitude] forKey:@"DropffLatitude"];
            [ dict setObject: [NSNumber numberWithDouble:DropoffLongitude] forKey:@"DropoffLongitude"];
            [ dict setObject:[[NSString alloc]initWithUTF8String:AirlineCode] forKey:@"AirlineCode"];
            [ dict setObject:[[NSString alloc]initWithUTF8String:AirlineNo] forKey:@"AirlineNo"];
            [ dict setObject:[[NSString alloc]initWithUTF8String:VehicleNo] forKey:@"VehicleNo"];
            [ dict setObject:[[NSString alloc]initWithUTF8String:PickupLocation] forKey:@"PickupLocation"];
            [ dict setObject:[[NSString alloc]initWithUTF8String:(IsAllowPreAssignedCancel)?IsAllowPreAssignedCancel:""] forKey:@"IsAllowPreAssignedCancel"];
            //[retval addObject:Messages];
            [retval addObject:dict];
            
            
            
        }
    }
    else{
        NSLog(@"sqlite3_errmsg Completed Jobs Data ....  %s",sqlite3_errmsg(database));
    }
    sqlite3_finalize(statement);
    
    return retval;
    
}



- (NSArray *)getCompletedJobs_:(NSString*)Username
{
    
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
    NSString *query = [NSString stringWithFormat:@"SELECT Message,ModifiedPax,Command,isDriverRating FROM UTSCompletedJob where Username = '%@' ORDER BY COLUMN_ID DESC  LIMIT 10",Username];
    
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            char *Message = (char *) sqlite3_column_text(statement, 0);
            char *ModifiedPax = (char *) sqlite3_column_text(statement, 1);
            char *Command = (char *) sqlite3_column_text(statement, 2);
            char *isDriverRating = (char *) sqlite3_column_text(statement, 3);
            
            
            /*
            
            ClassCompletedJobs *cCompletedJobs = [[ClassCompletedJobs alloc]init];
            NSString *Messages = [[NSString alloc] initWithUTF8String:Message];
            NSString *ModifiedPax_ = [[NSString alloc] initWithUTF8String:ModifiedPax];
            NSString*Command_ = [[NSString alloc] initWithUTF8String:Command];
            NSString*isDriverRating_ = [[NSString alloc] initWithUTF8String:isDriverRating];
            
            
            cCompletedJobs.Message = Messages;
            cCompletedJobs.ModifiedPax = ModifiedPax_;
            cCompletedJobs.Command = Command_;
            cCompletedJobs.isDriverRating = isDriverRating_;
            
            
            
            //[retval addObject:Messages];
            [retval addObject:cCompletedJobs];
            
            cCompletedJobs = nil;*/
            
        }
    }
    else{
        
        NSLog(@"sqlite3_errmsg Completed Jobs Data ....  %s",sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    
    return retval;
}


- (NSArray *)getLastCompletedJob_
{
    
    //const char *utf8Dbpath = [databasePath UTF8String];
    
    //    if (sqlite3_open(utf8Dbpath, &database) == SQLITE_OK)
    //    {
    //        NSLog(@"Databse open Correctly");
    //    }
    //    else
    //    {
    //        NSLog(@"Databse not open Correctly");
    //    }
    
    NSMutableArray *retval = [[NSMutableArray alloc] init] ;
    NSString *query = [NSString stringWithFormat:@"SELECT Message FROM UTSCompletedJob"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            char *Message = (char *) sqlite3_column_text(statement, 0);
            
            NSString *Messages = [[NSString alloc] initWithUTF8String:Message];
            [retval addObject:Messages];
            
        }
    }
    else{
        
        // NSLog(@"sqlite3_errmsg retiving Legs Data ....  %s",sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    
    return retval;
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
    
    //"create table if not exists PRODUCT(CATEGORY_ID integer, PRODUCT_ID integer primary key, NAME text,DATE_ADDED text);"
    NSMutableArray *retval = [[NSMutableArray alloc] init] ;
    NSString *query = [NSString stringWithFormat:@"SELECT PRODUCT_ID, NAME,DATE_ADDED FROM PRODUCT where CATEGORY_ID=%@", categoryId];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *productId            = (char *) sqlite3_column_text(statement, 0);
            char *name           = (char *) sqlite3_column_text(statement, 1);
            char *date_added           = (char *) sqlite3_column_text(statement, 2);
            
            NSString *productIds = [[NSString alloc] initWithUTF8String:productId];
            NSString *names = [[NSString alloc] initWithUTF8String:name];
            NSString *date_addeds = [[NSString alloc] initWithUTF8String:date_added];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:names forKey:@"name"];
            [dict setObject:productIds forKey:@"productId"];
            [dict setObject:date_addeds forKey:@"date_added"];
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

// Save Current Jobs

-(BOOL)insertCurrentJob:(int)COLUMN_ID
                Message:(NSString*)Message
                  JobId:(NSString*)JobId
                Command:(NSString*)Command
                 RideId:(NSString*)RideId
           IsOnlocation:(NSString*)IsOnlocation
              ISOnBoard:(NSString*)ISOnBoard
               ISNoShow:(NSString*)ISNoShow
         onlocationTime:(NSString*)onlocationTime
            onBoardTime:(NSString*)onBoardTime
         unloadedAtTime:(NSString*)unloadedAtTime
        CompleteJobTime:(NSString*)CompleteJobTime
   IsAssignedFromServer:(NSString*)IsAssignedFromServer
             FlightInfo:(NSString*)FlightInfo
            AccountType:(NSString*)AccountType
         FlightTerminal:(NSString*)FlightTerminal
             FlightGate:(NSString*)FlightGate
       AllowExtraStatus:(NSString*)AllowExtraStatus
       AllowAllGeofence:(NSString*)AllowAllGeofence
            AirportCode:(NSString*)AirportCode
             TerminalNo:(NSString*)TerminalNo
             SlotBooked:(NSString*)SlotBooked
{
    const char *dbpath = [databasePath UTF8String];
    
    NSArray*Count_ = [[NSArray alloc]init];
    
    Count_ = [self getCurrentdJobs_];
    int databasecount = (int)Count_.count; //[self getLastItemID ];
    NSLog(@"databasecount.. %d",databasecount);
    
    COLUMN_ID = databasecount;
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:
                               @"insert into UTSCurrentJobs(COLUMN_ID,Message,JobId,Command,RideId,IsOnlocation,ISOnBoard,ISNoShow,onlocationTime,onBoardTime,unloadedAtTime,CompleteJobTime,IsAssignedFromServer,FlightInfo, AccountType, FlightTerminal, FlightGate, AllowExtraStatus, AllowAllGeofence, AirportCode, TerminalNo, SlotBooked) values(\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",
                               COLUMN_ID,
                               Message,
                               JobId,
                               Command, RideId, IsOnlocation, ISOnBoard, ISNoShow, onlocationTime, onBoardTime,unloadedAtTime,CompleteJobTime,IsAssignedFromServer,FlightInfo,AccountType, FlightTerminal, FlightGate, AllowExtraStatus, AllowAllGeofence, AirportCode, TerminalNo, SlotBooked];
        
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

- (NSArray *)getCurrentJobs
{
    
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
    NSString *query = [NSString stringWithFormat:@"SELECT Message,Command,RideId,IsOnlocation,ISOnBoard,ISNoShow,onlocationTime,onBoardTime,unloadedAtTime,CompleteJobTime,IsAssignedFromServer,JobId,FlightInfo,AccountType,FlightTerminal,FlightGate,AllowExtraStatus,AllowAllGeofence,AirportCode,TerminalNo,SlotBooked FROM UTSCurrentJobs"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *Message           = (char *) sqlite3_column_text(statement, 0);
            char *Command           = (char *) sqlite3_column_text(statement, 1);
            char *RideId            = (char *) sqlite3_column_text(statement, 2);
            char *IsOnlocation      = (char *) sqlite3_column_text(statement, 3);
            char *ISOnBoard         = (char *) sqlite3_column_text(statement, 4);
            char *ISNoShow          = (char *) sqlite3_column_text(statement, 5);
            char *onlocationTime    = (char *) sqlite3_column_text(statement, 6);
            char *onBoardTime       = (char *) sqlite3_column_text(statement, 7);
            char *unloadedAtTime    = (char *) sqlite3_column_text(statement, 8);
            char *CompleteJobTime   = (char *) sqlite3_column_text(statement, 9);
            char *IsAssignedFromServer = (char *) sqlite3_column_text(statement, 10);
            char *JobId             = (char *) sqlite3_column_text(statement, 11);
            char *FlightInfo        = (char *) sqlite3_column_text(statement, 12);
            char *AccountType       = (char *) sqlite3_column_text(statement, 13);
            char *FlightTerminal    = (char *) sqlite3_column_text(statement, 14);
            char *FlightGate        = (char *) sqlite3_column_text(statement, 15);
            char *AllowExtraStatus  = (char *) sqlite3_column_text(statement, 16);
            char *AllowAllGeofence  = (char *) sqlite3_column_text(statement, 17);
            char *AirportCode       = (char *) sqlite3_column_text(statement, 18);
            char *TerminalNo        = (char *) sqlite3_column_text(statement, 19);
            char *SlotBooked        = (char *) sqlite3_column_text(statement, 20);
            
            NSString *Messages = [[NSString alloc] initWithUTF8String:Message];
            NSString *Commands = [[NSString alloc] initWithUTF8String:Command];
            NSString *RideIds = [[NSString alloc] initWithUTF8String:(RideId)?RideId:""];
            NSString *IsOnlocations = [[NSString alloc] initWithUTF8String:IsOnlocation?IsOnlocation:"false"];
            NSString *ISOnBoards = [[NSString alloc] initWithUTF8String:ISOnBoard?ISOnBoard:"false"];
            NSString *ISNoShows = [[NSString alloc] initWithUTF8String:ISNoShow?ISNoShow:"false"];
            NSString *onlocationTimes = [[NSString alloc] initWithUTF8String:onlocationTime?onlocationTime:""];
            NSString *onBoardTimes = [[NSString alloc] initWithUTF8String:onBoardTime?onBoardTime:""];
            NSString *unloadedAtTimes = [[NSString alloc] initWithUTF8String:unloadedAtTime?unloadedAtTime:""];
            NSString *CompleteJobTimes = [[NSString alloc] initWithUTF8String:CompleteJobTime?CompleteJobTime:""];
            NSString *IsAssignedFromServers = [[NSString alloc] initWithUTF8String:IsAssignedFromServer?IsAssignedFromServer:""];
            NSString *JobIds = [[NSString alloc] initWithUTF8String:JobId?JobId:""];
            NSString *FlightInfos = [[NSString alloc] initWithUTF8String:FlightInfo?FlightInfo:""];
            NSString *AccountTypes = [[NSString alloc] initWithUTF8String:AccountType?AccountType:""];
            NSString *FlightTerminals = [[NSString alloc] initWithUTF8String:FlightTerminal?FlightTerminal:""];
            NSString *FlightGates = [[NSString alloc] initWithUTF8String:FlightGate?FlightGate:""];
            NSString *AllowExtraStatuss = [[NSString alloc] initWithUTF8String:AllowExtraStatus?AllowExtraStatus:""];
            NSString *AllowAllGeofences = [[NSString alloc] initWithUTF8String:AllowAllGeofence?AllowAllGeofence:""];
            NSString *AirportCodes = [[NSString alloc] initWithUTF8String:AirportCode?AirportCode:""];
            NSString *TerminalNos = [[NSString alloc] initWithUTF8String:TerminalNo?TerminalNo:""];
            NSString *SlotBookeds = [[NSString alloc] initWithUTF8String:SlotBooked?SlotBooked:""];
            
            /*
            CurrentJobsBody *CJ = [[CurrentJobsBody alloc]init];
            CJ.Message = Messages;
            CJ.Command = Commands;
            CJ.RideId = RideIds;
            CJ.IsOnlocation = [IsOnlocations boolValue];
            CJ.ISOnBoard = [ISOnBoards boolValue];
            CJ.ISNoShow = [ISNoShows boolValue];
            CJ.onlocationTime = onlocationTimes;
            CJ.onBoardTime = onBoardTimes;
            CJ.unloadedAtTime = unloadedAtTimes;
            CJ.CompleteJobTime = CompleteJobTimes;
            CJ.IsAssignedFromServer = IsAssignedFromServers;
            CJ.JobId = JobIds;
            CJ.FlightInfo = FlightInfos;
            CJ.AccountType = AccountTypes;
            CJ.FlightTerminal = FlightTerminals;
            CJ.FlightGate = FlightGates;
            CJ.AllowExtraStatus = AllowExtraStatuss;
            CJ.AllowAllGeofence = AllowAllGeofences;
            CJ.AirportCode = AirportCodes;
            CJ.TerminalNo = TerminalNos;
            CJ.SlotBooked = SlotBookeds;
            [retval addObject:CJ];
            
            CJ = nil; */
        }
    }
    else{
        
        NSLog(@"sqlite3_errmsg Completed Jobs Data ....  %s",sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    
    return retval;
    
    
}



- (NSArray *)getCurrentdJobs_
{
    
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
    NSString *query = [NSString stringWithFormat:@"SELECT Message FROM UTSCurrentJobs"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *Message = (char *) sqlite3_column_text(statement, 0);
            
            NSString *Messages = [[NSString alloc] initWithUTF8String:Message];
            
            [retval addObject:Messages];
        }
    }
    else{
        
        NSLog(@"sqlite3_errmsg Completed Jobs Data ....  %s",sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    
    return retval;
    
    
}



-(void)deleteRow:(NSString *)Message
{
    const char *utf8Dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(utf8Dbpath, &database) == SQLITE_OK) {
        
        NSString *sql = [NSString stringWithFormat:@"delete from UTSCurrentJobs where Message ='%@'",Message];
        
        const char *del_stmt = [sql UTF8String];
        sqlite3_stmt *statement;
        
        sqlite3_prepare_v2(database, del_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            
            NSLog(@"Data Deleted from Completed Jobs Successfully");
        } else {
            
            NSLog(@"Data Deleted from Completed Jobs Successfully");// Not getdeleted
            NSLog(@"sqlite3_errmsg current Jobs deleting  ....  %s",sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
}

-(void)deleteScheduleJob:(NSString *)id
{
    const char *utf8Dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(utf8Dbpath, &database) == SQLITE_OK) {
        
        NSString *sql = [NSString stringWithFormat:@"delete from DriverScheduledJob where RideId ='%@'",id];
        
        const char *del_stmt = [sql UTF8String];
        sqlite3_stmt *statement;
        
        sqlite3_prepare_v2(database, del_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            
            NSLog(@"Data Deleted from Completed Jobs Successfully");
        } else {
            
            NSLog(@"Data Deleted from Completed Jobs Successfully");// Not getdeleted
            NSLog(@"sqlite3_errmsg current Jobs deleting  ....  %s",sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
}



-(void)deleteRow_WhenUnassigned:(NSString *)jobid
{
    const char *utf8Dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(utf8Dbpath, &database) == SQLITE_OK) {
        
        NSString *sql = [NSString stringWithFormat:@"delete from UTSCurrentJobs where JobId ='%@'",jobid];
        
        const char *del_stmt = [sql UTF8String];
        sqlite3_stmt *statement;
        
        sqlite3_prepare_v2(database, del_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            
            NSLog(@"Data Deleted from Current Jobs Successfully");
        } else {
            
            NSLog(@"Data Deleted from Current Jobs Successfully");// Not getdeleted
            NSLog(@"sqlite3_errmsg current Jobs deleting  ....  %s",sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
}



-(void)clearScheduleJob
{
    NSString *query1 = [NSString stringWithFormat:@"DELETE from DriverScheduledJob"];
    
    NSString *_query = query1;
    
    const char *utf8Dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(utf8Dbpath, &database) == SQLITE_OK) {
        
        const char *sql = [_query cStringUsingEncoding:NSUTF8StringEncoding];
        sqlite3_stmt *statement = nil;
        
        if(sqlite3_prepare_v2(database,sql, -1, &statement, NULL)!= SQLITE_OK)
        {
            NSAssert1(0,@"error preparing statement",sqlite3_errmsg(database));
            NSLog(@"sqlite3_errmsg Current Jobs Data ....  %s",sqlite3_errmsg(database));
        }
        else
        {
            sqlite3_step(statement);
        }
        sqlite3_finalize(statement);
    }
    
}
-(void)executeQuery
{
    
    NSString *query1 = [NSString stringWithFormat:@"DELETE from UTSCurrentJobs"];
    
    NSString *_query = query1;
    
    const char *utf8Dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(utf8Dbpath, &database) == SQLITE_OK) {
        
        const char *sql = [_query cStringUsingEncoding:NSUTF8StringEncoding];
        sqlite3_stmt *statement = nil;
        
        if(sqlite3_prepare_v2(database,sql, -1, &statement, NULL)!= SQLITE_OK)
        {
            NSAssert1(0,@"error preparing statement",sqlite3_errmsg(database));
            NSLog(@"sqlite3_errmsg Current Jobs Data ....  %s",sqlite3_errmsg(database));
        }
        else
        {
            [self clearnotifications];
            sqlite3_step(statement);
        }
        sqlite3_finalize(statement);
    }
}


-(void)executeGenericQuery:(NSString *)query
{
    
    NSString *query1 = [NSString stringWithFormat:@"%@", query];
    
    NSString *_query = query1;
    
    const char *utf8Dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(utf8Dbpath, &database) == SQLITE_OK) {
        
        const char *sql = [_query cStringUsingEncoding:NSUTF8StringEncoding];
        sqlite3_stmt *statement = nil;
        
        if(sqlite3_prepare_v2(database,sql, -1, &statement, NULL)!= SQLITE_OK)
        {
            NSAssert1(0,@"error preparing statement",sqlite3_errmsg(database));
            NSLog(@"sqlite3_errmsg Current Jobs Data ....  %s",sqlite3_errmsg(database));
        }
        else
        {
            [self clearnotifications];
            sqlite3_step(statement);
        }
        sqlite3_finalize(statement);
    }
}

-(NSArray *)loadDataFromDB:(NSString *)query{
    // run the query and indicate that it is not executable
    // convert the string to a char* object
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    
    // return the loaded results
    return (NSArray *)self.arrResults;
}

-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable{
    // create a sqlite object
    //sqlite3 *sqlite3Database;
    
    // set the database file path
    //NSString *databasePath = [self.documentsDirectory stringByAppendingPathComponent: self.databaseFilename];
    
    // initialize the results array
    if (self.arrResults != nil){
        [self.arrResults removeAllObjects];
        self.arrResults = nil;
    }
    self.arrResults = [[NSMutableArray alloc] init];
    
    // initialize the column names array
    if (self.arrColumnNames != nil) {
        [self.arrColumnNames removeAllObjects];
        self.arrColumnNames = nil;
    }
    self.arrColumnNames = [[NSMutableArray alloc] init];
    
    // open the database
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &database);
    if(openDatabaseResult == SQLITE_OK){
        // Declare a sqlite3_stmt object which will store the query after it's been compiled into a SQLite statement
        sqlite3_stmt *compiledStatement;
        
        // load all data from database to memory
        int prepareStatementResult = sqlite3_prepare_v2(database, query, -1, &compiledStatement, NULL);
        if (prepareStatementResult == SQLITE_OK){
            // check if the query is non-executable
            if (!queryExecutable){
                // data must be loaded from the database
                
                // declare an array to keep the data for each fetched row
                NSMutableArray *arrDataRow;
                
                // loop through the results and add them to the results array row by row
                while (sqlite3_step(compiledStatement) == SQLITE_ROW){
                    // initialize the mutable array that will contain the data of the fetched row
                    arrDataRow = [[NSMutableArray alloc] init];
                    
                    // get the total number of columns
                    int totalColumns = sqlite3_column_count(compiledStatement);
                    
                    // go through all the columns and fetch the column data
                    for (int i=0; i<totalColumns; i++){
                        //convert the column data to text (characters)
                        char * dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                        
                        // if there are contents in the current column (field) then add them to the current row array
                        if (dbDataAsChars != NULL){
                            // convert the characters to a string
                            [arrDataRow addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                        
                        // keep current column name
                        if (self.arrColumnNames.count != totalColumns){
                            dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                            [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                    }
                    
                    // store each fetched row in the results array, but first check if there is actually data
                    if (arrDataRow.count > 0){
                        [self.arrResults addObject:arrDataRow];
                    }
                }
            }
            else{
                // this is the case of an executable query (insert, update,...)
                
                // execute the query
                int executeQueryResults = sqlite3_step(compiledStatement);
                if (executeQueryResults == SQLITE_DONE){
                    // keep the affected rows
                    self.affectedRows = sqlite3_changes(database);
                    
                    // keep the last inserted row ID
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(database);
                }
                else{
                    // if we could not execute the query show the error message on the debugger
                    NSLog(@"DB Error: %s", sqlite3_errmsg(database));
                }
            }
        }
        else{
            // if we could not open the database show the error message on the debugger
            NSLog(@"%s", sqlite3_errmsg(database));
        }
        
        // release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    
    // close the database
    sqlite3_close(database);
}
// Update Completed Job


//const char *sql_stmt = "create table if not exists UTSCompletedJob(COLUMN_ID integer primary key,Message text ,onlocationTime text,onBoardTime text,unloadedAtTime text,CompleteJobTime text,CompleteJobStatus text,Username text,ModifiedPax text,Command text,isDriverRating text);"


-(BOOL)updateDataforRating:(NSString*)Rating
                   Message:(NSString*)Message
                  Username:(NSString*)Username
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        
        NSString *updateSQL = [NSString stringWithFormat:@"update UTSCompletedJob Set isDriverRating='%@' where  Message ='%@' AND Username = '%@'",Rating,Message,Username ];
        
        const char *update_stmt = [updateSQL UTF8String];
        
        sqlite3_stmt *statement = nil;
        
        sqlite3_prepare_v2(database, update_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else
        {
            NSLog(@"sqlite3_errmsg  update Completed Jobs Data ....  %s",sqlite3_errmsg(database));
            return  NO;
            
        }
        
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return NO;
}

-(void)setupAlarms :(NSString *)date withDict:(NSDictionary *)param
{
    NSMutableDictionary *finalParam = [NSMutableDictionary dictionaryWithDictionary:param];
    [finalParam setObject:@"UPCOMING_JOB_REMINDER_NOTIFICATION" forKey:@"notifType"];
    
    [self clearnotifications];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
    NSDate *job_date = [dateFormatter dateFromString:date];
    NSDate* fireDate =[job_date dateByAddingTimeInterval:-(15*60)]; //30 minutes back from event date
    NSString *body=@"Click for more detail";
    NSString *title=@"Your next Job will start within 15 minutes";
    /*
    if(IS_OS_10_OR_LATER){
        UNMutableNotificationContent *objNotificationContent = [[UNMutableNotificationContent alloc] init];
        objNotificationContent.body = body;
        objNotificationContent.userInfo=finalParam;
        objNotificationContent.title = title;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitTimeZone fromDate:fireDate];
        UNCalendarNotificationTrigger* trigger =[UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"UPCOMING_JOB_REMINDER_NOTIFICATION" content:objNotificationContent trigger:trigger];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            NSLog(@"request passed %@",request);
        }];
        [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
            for (UNNotificationRequest *request in requests) {
                NSLog(@"%@", request);
            }
        }];
    }else{
     
        UILocalNotification* uiLocalNotification= [[UILocalNotification alloc] init];
        uiLocalNotification.fireDate = fireDate;
        uiLocalNotification.userInfo = finalParam ;
        uiLocalNotification.alertTitle=title;
        uiLocalNotification.alertBody =body;
        [[UIApplication sharedApplication] scheduleLocalNotification:uiLocalNotification];
    }*/
    
    /* NSMutableArray *schedule_jobs=[[self getScheudleJobs]mutableCopy];
     
     NSMutableArray *pending_job=[[NSMutableArray alloc]init];
     NSDate *today=[NSDate date];
     NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
     [formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
     NSDate *job_date;
     for(NSMutableDictionary *dict in schedule_jobs)
     {
     job_date = [formatter dateFromString:[dict objectForKey:@"PickupDateTime"]];
     if ([today earlierDate:job_date] == job_date)
     {
     // [delayed_job addObject:dict];
     }else
     [pending_job addObject:dict];
     }
     NSArray *final = [pending_job sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
     NSDate *d1 = [formatter dateFromString:obj1[@"PickupDateTime"]];
     NSDate *d2 = [formatter dateFromString:obj2[@"PickupDateTime"]];
     return [d1 compare:d2]; // ascending order
     //return [d2 compare:d1]; // descending order
     }];
     if(date!=nil&&final.count>0){
     // params=@"4300600031%P k - 1P 1F 1C%BOS Logan International Airport %Alexanderplatz 10178 Berlin %3%20171003052200%%N%42.362972%-71.006416%52.5219184%13.4132147%>";
     //  NSArray *response=[params componentsSeparatedByString:@"%"];
     NSMutableDictionary *param=[final objectAtIndex:0];
     [self clearnotifications];//for now there is only one type notification so i am cancelling all
     
     // NSString *dateString =[response objectAtIndex:5];
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
     NSDate *job_date = [dateFormatter dateFromString:[param objectForKey:@"PickupDateTime"]];
     
     
     NSString *body=@"Click for more detail";
     NSString *title=@"Reminder : Upcoming Job";
     NSDate* fireDate =[job_date dateByAddingTimeInterval:-(30*60)]; //30 minutes back from event date
     NSDate* endDate =  [job_date dateByAddingTimeInterval:+(5*60)];//5 minutes delay from event date
     [param setObject:endDate forKey:@"endDate"];
     [param setObject:@"ScheduleNotification" forKey:@"Type"];
     NSLog(@"\n========================\ncurrent : %@\n fire : %@\n end : %@\n========================",job_date,fireDate,endDate);
     
     NSUInteger interval;
     if(IS_OS_10_OR_LATER){
     interval=   NSCalendarUnitSecond;
     UNMutableNotificationContent *objNotificationContent = [[UNMutableNotificationContent alloc] init];
     objNotificationContent.body = body;
     objNotificationContent.userInfo=param;
     objNotificationContent.title = title;
     NSDateComponents *components = [[NSCalendar currentCalendar] components:interval fromDate:fireDate];
     UNCalendarNotificationTrigger* trigger =[UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
     UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"rover_alarm" content:objNotificationContent trigger:trigger];
     UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
     [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
     NSLog(@"request passed %@",request);
     }];
     }else{
     interval=   NSCalendarUnitMinute;
     UILocalNotification* uiLocalNotification= [[UILocalNotification alloc] init];
     //Set the repeat interval
     uiLocalNotification.repeatInterval =interval ;
     //Set the fire date
     uiLocalNotification.fireDate = fireDate;
     //Set the end date
     //5 minutes after  event date
     uiLocalNotification.userInfo =param ;
     uiLocalNotification.alertTitle=title;
     uiLocalNotification.alertBody =body;
     UIApplication* application = [UIApplication sharedApplication];
     [application scheduleLocalNotification:uiLocalNotification];
     }
     }*/
}
/*
-(void) clearnotifications
{
    if(IS_OS_10_OR_LATER){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //        [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
        //            NSLog(@"request cleared %@",requests);
        //        }];
        //[center removeAllPendingNotificationRequests];
        [center removeDeliveredNotificationsWithIdentifiers:[NSArray arrayWithObjects:@"UPCOMING_JOB_REMINDER_NOTIFICATION", nil]];
        [center removePendingNotificationRequestsWithIdentifiers:[NSArray arrayWithObjects:@"UPCOMING_JOB_REMINDER_NOTIFICATION", nil]];
    }else{
        NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for (UILocalNotification *not in notifications) {
            NSString *dateString=[not.userInfo valueForKey:@"EndDate"];
            if(dateString!=nil)
            {
                [[UIApplication sharedApplication] cancelLocalNotification:not];
            }
        }
    }
    
}*/


@end
