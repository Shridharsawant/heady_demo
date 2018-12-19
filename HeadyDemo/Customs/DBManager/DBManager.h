//
//  DBHelper.h
//  Demo Project
//
//  Created by Apple Developer on 12/11/16.
//  Copyright © 2016 Apple Developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject
{
    NSString *databasePath;
}

@property (nonatomic, strong) NSMutableArray *arrColumnNames;

@property (nonatomic) int affectedRows;

@property (nonatomic) long long lastInsertedRowID;
@property (nonatomic, strong) NSMutableArray *arrResults;

+(DBManager*)getSharedInstance;
-(BOOL)createDB;
-(void)removeDatabase;
-(BOOL)updateSchema;
-(BOOL)InsertUTSDriverCanMessages:(int)COLUMN_ID
                          Message:(NSString*)Message;
-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable;
-(NSArray *)loadDataFromDB:(NSString *)query;

-(BOOL)InsertUTSDriverBookZoneMessages:(int)COLUMN_ID
                                ZoneId:(NSString*)ZoneId
                                  Name:(NSString*)Name
                                   Lat:(NSString*)Lat
                                  Long:(NSString*)Long
                              ZoneType:(NSString*)ZoneType ;


- (NSArray *)getCanMessages ;

- (NSArray *)getServerCanMessages;


-(BOOL)InsertUTSDriverServerCanMessages:(int)COLUMN_ID
                                Message:(NSString*)Message
                                   Time:(NSString*)Time;

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
             SlotBooked:(NSString*)SlotBooked;

-(BOOL)insertGeopoints:(int)GeofenceId
              Latitude:(NSString*)Latitude
             Longitude:(NSString*)Longitude
                Radius:(NSString*)Radius;

- (NSArray *)getGeopoints:(NSString *)geofenceId;

-(BOOL)insertGeofence:(int)GeofenceId
               RideId:(NSString*)RideId
         GeofenceName:(NSString*)GeofenceName
           SequenceId:(NSString*)SequenceId
       AlreadyVisited:(NSString*)AlreadyVisited;

- (NSArray *)getGeofence:(NSString *)geofenceId;

-(void)executeGenericQuery:(NSString *)query;
- (NSArray *)getCurrentJobs;
- (NSArray *)getCurrentdJobs_;
- (NSArray *)getScheudleJobs;

-(BOOL)updateCurrentJob:(NSString *)COLUMN_NAME
              withValue:(NSString*)Value
              forRideID:(NSString *)rideID;

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
            isDriverRating:(NSString*)isDriverRating ;

-(void)checkColumnExists:(NSString *)tableName withColumn:(NSString *)columnName;

- (NSArray *)getCompletedJobs_:(NSString*)Username;


-(void)deleteRow:(NSString*)Message;
-(void)deleteRow_WhenUnassigned:(NSString *)jobid;


-(void)executeQuery;

-(BOOL)deletecompleteJobs:(NSString*)Message;

//- (NSArray *)getCompletedJobs_forDetail:(NSString*)Message;
- (NSArray *)getCompletedJobs_forDetail:(NSString*)Message Username:(NSString*)Username;


//Delete Canned Messages
-(BOOL)deleteCannedMessages;

//Update Data for rating
-(BOOL)updateDataforRating:(NSString*)Rating Message:(NSString*)Message Username:(NSString*)Username;

-(BOOL)insertScheduledJobs :(NSDictionary *)dict;
-(void)clearScheduleJob;
-(void)deleteScheduleJob:(NSString *)id;
-(void)setupAlarms :(NSString *)date withDict:(NSDictionary *)param;
-(void) clearnotifications;

-(BOOL)insertVariants:(int)productId
            variantId:(int)variantId
                color:(NSString*)color
                 size:(NSString*)size
                price:(NSString*)price;

- (NSArray *)getVariants:(NSString *)productId;

-(BOOL)insertTax:(int)productId
            name:(NSString*)name
           value:(NSString*)value;

- (NSArray *)getTax:(NSString *)productId;

-(BOOL)insertProducts:(int)categoryId
            productId:(int)productId
                 name:(NSString*)name
            dateAdded:(NSString*)dateAdded;

- (NSArray *)getProducts:(NSString *)categoryId;

-(BOOL)insertCategory:(int)categoryId
                 NAME:(NSString*)NAME
     CHILD_CATEGORIES:(NSString*)CHILD_CATEGORIES;

- (NSArray *)getCategories;


@end
