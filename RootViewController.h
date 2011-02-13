#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ChatController.h"
//@class ChatController;

@protocol RootDelegate <NSObject>
@optional
-(void)sendUpdate;
@end



@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
	NSFetchedResultsController *fetchedResultsController;
	ChatController *chatController;
	NSString *fromUser;
	id delegate;
}
-(void)updateChat;

@property (nonatomic, assign) id <RootDelegate> delegate;
@property (nonatomic, retain)NSString *fromUser;

@end
