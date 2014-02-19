#import <OpenGL/CGLMacro.h>

#import "MMD_Render_DMPlugIn.h"

#define	kQCPlugIn_Name				@"MMDRender"
#define	kQCPlugIn_Description		@"PMD Render b124 / VMD Player using Quartz Composer"

@implementation MMD_Render_DMPlugIn

@synthesize pmdFilepath, vmdFilepath;
@synthesize pmdFilepath_curr, vmdFilepath_curr;
@dynamic inputIsFace;
@synthesize inputFace, faceBySetting, facesArray;
@dynamic inputLookAtZ, inputLookAtY, inputLookAtX;
@dynamic inputIsLookAt;
@dynamic inputIsPhysics;
@dynamic inputIsPlay;

+ (NSDictionary*) attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			kQCPlugIn_Name, QCPlugInAttributeNameKey,
			kQCPlugIn_Description, QCPlugInAttributeDescriptionKey,
			nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	if([key isEqualToString:@"inputIsPlay"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				QCPortTypeBoolean, QCPortAttributeTypeKey,
				@"VMD Play", QCPortAttributeNameKey,
				[NSNumber numberWithBool:YES] , QCPortAttributeDefaultValueKey,
				nil];
    if([key isEqualToString:@"inputIsPhysics"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				QCPortTypeBoolean, QCPortAttributeTypeKey,
				@"Enabled Physics", QCPortAttributeNameKey,
				[NSNumber numberWithBool:NO] , QCPortAttributeDefaultValueKey,
				nil];
	if([key isEqualToString:@"inputIsLookAt"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				QCPortTypeBoolean, QCPortAttributeTypeKey,
				@"Enabled LookAt", QCPortAttributeNameKey,
				[NSNumber numberWithBool:NO] , QCPortAttributeDefaultValueKey,
				nil];
	if([key isEqualToString:@"inputLookAtX"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				QCPortTypeNumber, QCPortAttributeTypeKey,
				@"LookAt X", QCPortAttributeNameKey,
				[NSNumber numberWithDouble:0.0] , QCPortAttributeDefaultValueKey,
				nil];
	if([key isEqualToString:@"inputLookAtY"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				QCPortTypeNumber, QCPortAttributeTypeKey,
				@"LookAt Y", QCPortAttributeNameKey,
				[NSNumber numberWithDouble:0.0] , QCPortAttributeDefaultValueKey,
				nil];
	if([key isEqualToString:@"inputLookAtZ"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				QCPortTypeNumber, QCPortAttributeTypeKey,
				@"LookAt Z", QCPortAttributeNameKey,
				[NSNumber numberWithDouble:0.0] , QCPortAttributeDefaultValueKey,
				nil];
	if([key isEqualToString:@"inputIsFace"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				QCPortTypeIndex, QCPortAttributeTypeKey,
				@"Enabled Face", QCPortAttributeNameKey,
				[NSNumber numberWithUnsignedInt:0] , QCPortAttributeDefaultValueKey,
				nil];
	if([key isEqualToString:@"inputFace"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				QCPortTypeIndex, QCPortAttributeTypeKey,
				@"Face", QCPortAttributeNameKey,
				[NSNumber numberWithUnsignedInt:0] , QCPortAttributeDefaultValueKey,
				nil];
	return nil;
}

+ (QCPlugInExecutionMode) executionMode
{
	return kQCPlugInExecutionModeConsumer;
}

+ (QCPlugInTimeMode) timeMode
{
	return kQCPlugInTimeModeTimeBase;
}

- (id) init
{
	if(self = [super init]) {
		self.pmdFilepath= @"";
		self.vmdFilepath= @"";
		self.pmdFilepath_curr= nil;
		self.vmdFilepath_curr= nil;
		loadedFlag= NO;
		prevFace= 0;
		facesArray= [NSMutableArray array];
		if (g_clBulletPhysics.isInitialized()==false) {		
			g_clBulletPhysics.initialize();
		}
        g_clPMDModel.setBulletPhysics(&g_clBulletPhysics);
        
	}
	
	return self;
}


- (void) dealloc
{
	g_clBulletPhysics.release();
	g_clPMDModel.release();
	g_clVMDMotion.release();
}

+ (NSArray*) plugInKeys
{
	return [NSArray arrayWithObjects:@"pmdFilepath", @"vmdFilepath", nil];
}

- (id) serializedValueForKey:(NSString*)key;
{
	if([key isEqualToString:@"pmdFilepath"])
        return self.pmdFilepath;
	if([key isEqualToString:@"vmdFilepath"])
        return self.vmdFilepath;
	return [super serializedValueForKey:key];
}

- (void) setSerializedValue:(id)serializedValue forKey:(NSString*)key
{
	if([key isEqualToString:@"pmdFilepath"])
        self.pmdFilepath= serializedValue;
	else if([key isEqualToString:@"vmdFilepath"])
        self.vmdFilepath= serializedValue;
    else
        [super setSerializedValue:serializedValue forKey:key];
}

- (QCPlugInViewController*)createViewController
{	
	return [[QCPlugInViewController alloc] initWithPlugIn:self viewNibName:@"Settings"];
}
@end

@implementation MMD_Render_DMPlugIn (Execution)
#pragma mark ---
- (IBAction)actionPMD
{
	NSOpenPanel *opanel = [NSOpenPanel openPanel];
	[opanel setCanChooseDirectories:NO];
	NSArray *fileTypes = [NSArray arrayWithObjects:@"pmd",nil];
	int state= NSCancelButton;
	NSFileManager *mgr = [NSFileManager defaultManager];
	if ([mgr fileExistsAtPath:self.pmdFilepath_curr]) {
        /*
         * Removed by: r1cebank
         * Updated by: r1cebank
         * Reason: deprecated method in 10.6
        */
		//state= [opanel runModalForDirectory:[self.pmdFilepath_curr stringByDeletingLastPathComponent] file:[self.pmdFilepath_curr lastPathComponent]types:fileTypes];
        [opanel setDirectoryURL:[NSURL URLWithString: [self.pmdFilepath_curr stringByDeletingLastPathComponent]]];
        [opanel setAllowedFileTypes:fileTypes];
        state = [opanel runModal];
	}
	else {
        /*
         * Removed by: r1cebank
         * Updated by: r1cebank
         * Reason: deprecated method in 10.6
         */
        //state= [opanel runModalForTypes: fileTypes];
        [opanel setAllowedFileTypes:fileTypes];
        state = [opanel runModal];
	}
    /*
     * Updated by: r1cebank
     * Reason: deprecated method in 10.6
     * Removed NSOKButton
     */
	if (state == NSFileHandlingPanelOKButton){
        /*
         * Removed by: r1cebank
         * Updated by: r1cebank
         * Reason: deprecated method in 10.6
         */
        //self.pmdFilepath= [opanel filename];
		self.pmdFilepath= [[opanel URL] path];
		loadedFlag= NO;
	}
}
- (IBAction)actionVMD
{
	NSOpenPanel *opanel = [NSOpenPanel openPanel];
	[opanel setCanChooseDirectories:NO];
	NSArray *fileTypes = [NSArray arrayWithObjects:@"vmd",nil];
	int state= NSCancelButton;
	NSFileManager *mgr = [NSFileManager defaultManager];
	if ([mgr fileExistsAtPath:self.vmdFilepath_curr]) {
        /*
         * Removed by: r1cebank
         * Updated by: r1cebank
         * Reason: deprecated method in 10.6
         */
		//state= [opanel runModalForDirectory:[self.vmdFilepath_curr stringByDeletingLastPathComponent] file:[self.vmdFilepath_curr lastPathComponent] types:fileTypes];
        [opanel setDirectoryURL:[NSURL URLWithString: [self.vmdFilepath_curr stringByDeletingLastPathComponent]]];
        [opanel setAllowedFileTypes:fileTypes];
        state = [opanel runModal];
	}
	else {
        /*
         * Removed by: r1cebank
         * Updated by: r1cebank
         * Reason: deprecated method in 10.6
         */
        //state= [opanel runModalForTypes: fileTypes];
		[opanel setAllowedFileTypes:fileTypes];
        state = [opanel runModal];
	}
    /*
     * Updated by: r1cebank
     * Reason: deprecated method in 10.6
     * Removed NSOKButton
     */
	if (state == NSFileHandlingPanelOKButton){
        /*
         * Removed by: r1cebank
         * Updated by: r1cebank
         * Reason: deprecated method in 10.6, messy code
         */
		//self.vmdFilepath= [opanel filename];
        self.vmdFilepath= [[opanel URL] path];
		loadedFlag= NO;
	}
}
#pragma mark ---
- (BOOL) _loadDataWithContext:(id<QCPlugInContext>)context
						  pmd:(NSString *)pmdfilepath
						  vmd:(NSString *)vmdfilepath
						 loop:(NSNumber *)loopFlag
{
	CGLContextObj cgl_ctx = [context CGLContextObj]; 
	if(cgl_ctx == NULL) 
		return NO; 
	{	
		loadedFlag= NO;
		if ([pmdfilepath isAbsolutePath]==NO
			|| [[NSFileManager defaultManager] fileExistsAtPath:pmdfilepath]==NO)
			return NO;
		if ([vmdfilepath isAbsolutePath]==NO
			|| [[NSFileManager defaultManager] fileExistsAtPath:vmdfilepath]==NO) {
			vmdfilepath= nil;
		}
		
		self.pmdFilepath_curr= pmdfilepath;
        self.vmdFilepath_curr= vmdfilepath;
		
		g_clPMDModel.setQCPlugInContext( context );
		g_clPMDModel.load( [pmdfilepath cStringUsingEncoding:NSUTF8StringEncoding] );
        /*
         * Commented by: r1cebank
         * Reason: messy code, branched motion to another method
         */
		if (vmdfilepath != nil) {
            [self loadMotion:vmdfilepath loop:YES];
//			g_clVMDMotion.load( [vmdfilepath cStringUsingEncoding:NSUTF8StringEncoding] );
//			g_clPMDModel.setMotion( &g_clVMDMotion, [loopFlag boolValue]?true:false );
		}
		
		loadedFlag= YES;
	}
	GLenum error;
    /*
     * Updated by: r1cebank
     * Reason: assignment without a (
     * if(error = glGetError())
     */
	if((error = glGetError()))
		[context logMessage:@"OpenGL error %04X", error];
	
	return (error ? NO : YES);
}
- (void) loadMotion: (NSString*)vmdfilepath loop:(BOOL)loopFlag
{
    if (vmdfilepath != nil) {
        NSLog(@"Loading %@", vmdfilepath);
        g_clVMDMotion.load( [vmdfilepath cStringUsingEncoding:NSUTF8StringEncoding] );
        g_clPMDModel.setMotion( &g_clVMDMotion, loopFlag?true:false );
        self.vmdFilepath_curr= vmdfilepath;
    }
}
- (BOOL) loadDataWithContext:(id<QCPlugInContext>)context
{
	CGLContextObj cgl_ctx = [context CGLContextObj]; 
	if(cgl_ctx == NULL) 
		return NO; 
	
	BOOL b= [self _loadDataWithContext:context
								   pmd:self.pmdFilepath
								   vmd:self.vmdFilepath
								  loop:[NSNumber numberWithBool:YES]];
	if (b) {
        NSLog(@"=====Setting Faces on the model.=====");
		[facesArray removeAllObjects];
		NSUInteger i, ic= g_clPMDModel.getNumberOfFaces();
		for(i= 0; i<ic; i++) {
			const char *n= g_clPMDModel.getFaceName(i);
			NSString *name= [NSString stringWithCString:n encoding:NSShiftJISStringEncoding];
			[facesArray addObject:name];
            NSLog(@"=====%@ is added=====", name);
		}
		faceTime= 0.0;
	}
	
	return b;
}
- (NSNumber *)faceBySetting
{
	return faceBySetting;
}
- (void)setFaceBySetting:(NSNumber *)v
{
	faceBySetting= v;
	
	self.inputFace= [faceBySetting unsignedIntValue];
}
- (NSMutableArray *)facesArray
{
	return facesArray;
}
- (void)setFacesArray:(NSMutableArray *)array
{
	//nil;
}
- (BOOL)isNeedReloadWithPmd:(NSString *)pmdfilepath
						vmd:(NSString *)vmdfilepath
{
    NSLog(@"=====pmd: %@ vmd: %@======", pmdfilepath, vmdfilepath);
    NSLog(@"=====pmd_curr: %@ vmd_curr: %@======", self.pmdFilepath_curr, self.vmdFilepath_curr);
	if ([pmdfilepath isEqualToString:self.pmdFilepath_curr]==NO 
		|| [vmdfilepath isEqualToString:self.vmdFilepath_curr]==NO)
	{
        NSLog(@"=====Inside first if======");
		if ([pmdfilepath isAbsolutePath]==NO
			|| [[NSFileManager defaultManager] fileExistsAtPath:pmdfilepath]==NO) {
            NSLog(@"=====Inside second if======");
			self.pmdFilepath= self.pmdFilepath_curr;
			return NO;
		}
		if ([vmdfilepath isAbsolutePath]==NO 
			|| [[NSFileManager defaultManager] fileExistsAtPath:vmdfilepath]==NO) {
            NSLog(@"=====Inside third if======");
			self.vmdFilepath= self.vmdFilepath_curr;
		}
		return YES;
	}
	return NO;
}
#pragma mark ---
- (BOOL) startExecution:(id<QCPlugInContext>)context
{
    /*
     * Updated by: r1cebank
     * Reason: data initialization
     */
	CGLContextObj cgl_ctx = [context CGLContextObj]; 
	if(cgl_ctx == NULL) 
		return NO; 
	{
	}
	GLenum error;
    /*
     * Updated by: r1cebank
     * Reason: assignment without a (
     * if(error = glGetError())
     */
	if((error = glGetError()))
        [context logMessage:@"OpenGL error %04X", error];
	return (error ? NO : YES);
}
- (void) enableExecution:(id<QCPlugInContext>)context
{
	CGLContextObj cgl_ctx = [context CGLContextObj]; 
	if(cgl_ctx == NULL) 
		return; 
	{
	}
}
- (BOOL) execute:(id<QCPlugInContext>)context 
		  atTime:(NSTimeInterval)time
   withArguments:(NSDictionary*)arguments
{
	CGLContextObj cgl_ctx = [context CGLContextObj]; 
	if(cgl_ctx == NULL) 
		return NO; 
	
	BOOL noPhysicsFlag= NO;
    /*
     * Updated by: r1cebank
     * Reason: Poor and messy code
     */
//	if ([self isNeedReloadWithPmd:self.pmdFilepath
//							  vmd:self.vmdFilepath]==YES) 
//	{
//        NSLog(@"=====Reload with PMD=====");
//		[self loadDataWithContext:context];
//		g_clPMDModel.clearCurrentFrame();
//        g_clPMDModel.enablePhysics(false);
//        g_clPMDModel.resetRigidBodyPos();
//        g_clPMDModel.updateMotion( 0.0f );
//        g_clPMDModel.updateSkinning();
//		noPhysicsFlag= YES;
//	}
    if([self.pmdFilepath_curr isEqualToString:self.pmdFilepath] == NO)
    {
        if((self.vmdFilepath != nil) || [self.vmdFilepath length]>0)
        {
            NSLog(@"=====Loading new resources=====");
            NSLog(@"=====pmd: %@ vmd: %@======", self.pmdFilepath, self.vmdFilepath);
            NSLog(@"=====pmd_curr: %@ vmd_curr: %@======", self.pmdFilepath_curr, self.vmdFilepath_curr);
            [self loadDataWithContext:context];
            g_clPMDModel.clearCurrentFrame();
            g_clPMDModel.enablePhysics(false);
            g_clPMDModel.resetRigidBodyPos();
            g_clPMDModel.updateMotion( 0.0f );
            g_clPMDModel.updateSkinning();
            noPhysicsFlag= YES;
        }
    }
    if([self.vmdFilepath_curr isEqualToString:self.vmdFilepath] == NO)
    {
        if([self.vmdFilepath isEqualToString:@""] != YES)
        {
            NSLog(@"=====Loading new motion=====");
            [self loadDataWithContext:context];
            //[self loadMotion:self.vmdFilepath loop:YES];
            g_clPMDModel.clearCurrentFrame();
            g_clPMDModel.enablePhysics(false);
            g_clPMDModel.resetRigidBodyPos();
            g_clPMDModel.updateMotion( 0.0f );
            g_clPMDModel.updateSkinning();
            noPhysicsFlag= YES;
        }
    }
    
	if(loadedFlag)
	{
        //NSLog(@"=====Loaded=====");
		g_clPMDModel.setQCPlugInContext( context );
		GLint saveMode;	
		glGetIntegerv(GL_MATRIX_MODE, &saveMode);
		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
		{
			glPushAttrib(GL_ENABLE_BIT);
			{
				if (self.vmdFilepath!=nil 
					&& [self.vmdFilepath length]>0
					&& self.inputIsPlay) {

                    float targetFrame= (float)time * 30.0f;
                    float fDiffFrame= targetFrame - g_clPMDModel.getCurrentFrame();
                    if (fDiffFrame > 30.0f || fDiffFrame<0.0) {
                        noPhysicsFlag= YES;
                    }

                    if (targetFrame<g_clVMDMotion.getMaxFrame()) {
                        g_clPMDModel.updateMotion( fDiffFrame );
                    }
                    if (noPhysicsFlag==YES || self.inputIsPhysics==NO) {
                        g_clPMDModel.resetRigidBodyPos();
                        g_clPMDModel.enablePhysics(false);
                    }
                    else {
                        g_clBulletPhysics.update( fDiffFrame );
                        g_clPMDModel.enablePhysics(true);
                    }
					noPhysicsFlag= NO;
				}
				
				//if (self.inputIsFace==YES && prevFace!=self.inputFace) {
                if (self.inputIsFace==YES) {
					//faceTime+= 0.1;
					//g_clPMDModel.setFace(0);
					faceTime= 1.0;
                    g_clPMDModel.blendFace(self.inputFace, faceTime);
					if (faceTime>=1.0) {
						faceTime= 0.0;
						prevFace= self.inputFace;
					}
				}
				
				if (self.inputIsLookAt) {
					g_clPMDModel.setLookAtFlag(true);
					Vector3		vecCamPos = { (float)self.inputLookAtX, (float)self.inputLookAtY, (float)self.inputLookAtZ };
					g_clPMDModel.updateNeckBone( &vecCamPos );
				}
				else {
					g_clPMDModel.setLookAtFlag(false);
				}
				
				g_clPMDModel.updateSkinning();
				
				//
				glEnable( GL_DEPTH_TEST );
				
				glEnable( GL_TEXTURE_2D );
				glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
				
				glEnable( GL_CULL_FACE );
				glCullFace( GL_FRONT );
				
				glEnable( GL_BLEND );
				glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
				
				glEnable( GL_ALPHA_TEST );
				glAlphaFunc( GL_GEQUAL, 0.05f );
				
				glEnable( GL_LIGHT0 );
				
				glEnable( GL_LIGHTING );
													
				glEnable( GL_CULL_FACE );
				glEnable( GL_ALPHA_TEST );
				glEnable( GL_BLEND );
				
				//
				glScalef( 1.0f, 1.0f, -1.0f );
				g_clPMDModel.render();
			}
			glPopAttrib();
		}
		glMatrixMode(GL_MODELVIEW);
		glPopMatrix();
		glMatrixMode(saveMode);
	}
	GLenum error;
    /*
     * Updated by: r1cebank
     * Reason: assignment without a (
     * if(error = glGetError())
     */
	if((error = glGetError()))
		[context logMessage:@"OpenGL error %04X", error];
	
	return (error ? NO : YES);
}

- (void) disableExecution:(id<QCPlugInContext>)context
{
}

- (void) stopExecution:(id<QCPlugInContext>)context
{
}
@end
