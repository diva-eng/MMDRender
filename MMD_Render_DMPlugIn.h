#import <Quartz/Quartz.h>
#import	"MMD/PMDModel.h"
#import	"MMD/VMDMotion.h"
#import "BulletPhysics/BulletPhysics.h"

@interface MMD_Render_DMPlugIn : QCPlugIn
{
	cPMDModel		g_clPMDModel;
	cVMDMotion		g_clVMDMotion;
    cBulletPhysics	g_clBulletPhysics;
	
	BOOL			loadedFlag;
	//
	NSString *pmdFilepath;
	NSString *pmdFilepath_curr;
	NSString *vmdFilepath;
	NSString *vmdFilepath_curr;
	//
	NSUInteger prevFace;

	NSUInteger inputFace;
	//
	NSMutableArray *facesArray;
	NSNumber	*faceBySetting;
	//
	float faceTime;
}

@property(strong) NSString *pmdFilepath;
@property(strong) NSString *pmdFilepath_curr;
@property(strong) NSString *vmdFilepath;
@property(strong) NSString *vmdFilepath_curr;

@property BOOL inputIsFace;
@property(strong) NSNumber *faceBySetting;
@property(strong) NSMutableArray *facesArray;
@property NSUInteger inputFace;

@property BOOL inputIsPlay;
@property BOOL inputIsPhysics;

@property BOOL inputIsLookAt;
@property double inputLookAtX;
@property double inputLookAtY;
@property double inputLookAtZ;

@end
@interface MMD_Render_DMPlugIn (Execution)
- (IBAction)actionPMD;
- (IBAction)actionVMD;
@end
