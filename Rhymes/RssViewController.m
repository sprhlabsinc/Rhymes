//
//  RssViewController.m
//  Rhymes
//
//  Created by Akira on 5/21/17.
//  Copyright © 2017 mypc. All rights reserved.
//

#import "RssViewController.h"
#import "RssTableViewCell.h"
#import "AppDelegate.h"
#import <sqlite3.h>
#import "Reachability.h"

@interface RssFeed : NSObject

@property (strong, nonatomic) NSString *strTitle;
@property (strong, nonatomic) NSString *strDescription;
@property (strong, nonatomic) NSString *strLink;

@end

@implementation RssFeed
@end

@interface RssViewController () <UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate> {
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableString *title;
    NSMutableString *link;
    NSMutableString *description;
    NSString *element;
    
    RssFeed *feed;
}

@property (weak, nonatomic) IBOutlet UITableView *rssTableView;

- (IBAction)onCloseBut:(id)sender;

@end

@implementation RssViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    feeds = [[NSMutableArray alloc] init];
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {
        
        sqlite3 *rssDB;
        const char *dbpath = [[AppDelegate sharedAppDelegate].databasePath UTF8String];
        sqlite3_stmt *statement;
        
        if (sqlite3_open(dbpath, &rssDB) == SQLITE_OK) {
            const char *sql = "select TITLE, DESCRIPTION, LINK from rss_tb order by ID asc";
            if (sqlite3_prepare_v2(rssDB, sql, -1, &statement, NULL) == SQLITE_OK) {
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    RssFeed *f = [[RssFeed alloc] init];
                    f.strTitle = [NSString stringWithFormat:@"%s", (char *)sqlite3_column_text(statement, 0)];
                    f.strDescription = [NSString stringWithFormat:@"%s", (char *)sqlite3_column_text(statement, 1)];
                    f.strLink = [NSString stringWithFormat:@"%s", (char *)sqlite3_column_text(statement, 2)];
                    
                    [feeds addObject:f];
                }
                sqlite3_finalize(statement);
            }
            sqlite3_close(rssDB);
        }
    }
    else {
        NSURL *url = [NSURL URLWithString:@"http://waleek.com/news/category/news/feed/"];
        parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        
        parser.delegate = self;
        parser.shouldResolveExternalEntities = NO;
        [parser parse];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)onCloseBut:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableViewDelegate and  Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return feeds.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier= @"rssCell";
    RssTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[RssTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    RssFeed *selFeed = [feeds objectAtIndex:indexPath.row];
    cell.txtTitle.text = selFeed.strTitle;
    cell.txtPubDate.text = [selFeed.strDescription stringByReplacingOccurrencesOfString:@"&#160; " withString:@""];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RssFeed *selFeed = [feeds objectAtIndex:indexPath.row];
    
    NSString *string = selFeed.strLink;
    string = [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:string]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string] options:[NSDictionary dictionary] completionHandler:^(BOOL success) {
            
        }];
    }
}

#pragma mark - Parser Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
    
    if ([element isEqualToString:@"item"]) {
        
        feed = [[RssFeed alloc] init];
        title   = [[NSMutableString alloc] init];
        link    = [[NSMutableString alloc] init];
        description = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([element isEqualToString:@"title"]) {
        [title appendString:string];
    } else if ([element isEqualToString:@"link"]) {
        [link appendString:string];
    } else if ([element isEqualToString:@"description"]) {
        [description appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"]) {
        
        feed.strTitle = title;
        feed.strDescription = description;
        feed.strLink = link;
        [feeds addObject:feed];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    sqlite3 *rssDB;
    const char *dbpath = [[AppDelegate sharedAppDelegate].databasePath UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_open(dbpath, &rssDB) == SQLITE_OK) {
        
        const char *delete_stmt = "delete from rss_tb";
        sqlite3_prepare_v2(rssDB, delete_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            
        }
        sqlite3_finalize(statement);
        
        for (int i = 0; i < feeds.count; i ++) {
            
            RssFeed *f = [feeds objectAtIndex:i];
            NSString *insertsql = [NSString stringWithFormat:@"insert into rss_tb(TITLE, DESCRIPTION, LINK) values (\"%@\", \"%@\", \"%@\")", f.strTitle, f.strDescription, f.strLink];
            const char *insert_stmt = [insertsql UTF8String];
            
            sqlite3_prepare_v2(rssDB, insert_stmt, -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE) {
                
            }
            else {
                NSLog(@"error");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(rssDB);
    }
    [_rssTableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}

@end
