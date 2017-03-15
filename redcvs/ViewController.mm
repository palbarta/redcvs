//
//  ViewController.m
//  redcvs
//
//  Created by Barta Pál on 2017. 03. 12..
//  Copyright © 2017. Barta Pál. All rights reserved.
//

#include <fstream>
#include <sstream>
#include "R3DSDK.h"

#import "ViewController.h"

std::string RedSDKStatusMsg(R3DSDK::InitializeStatus status)
{
    using namespace R3DSDK;
    
    std::string statusMsg = "Red SDK could not have been initialized: ";
    switch(status) {
        case ISInitializeOK:
            statusMsg = "Red SDK initialized succesfully.";
            break;
        case ISLibraryNotLoaded:
            statusMsg += "library not loaded.";
            break;
        case ISR3DSDKLibraryNotFound:
            statusMsg += "R3D SDK library not found.";
            break;
        case ISRedCudaLibraryNotFound:
            statusMsg += "Red CUDA library not found.";
            break;
        case ISRedOpenCLLibraryNotFound:
            statusMsg += "Red OpenCL library not found.";
            break;
        case ISR3DDecoderLibraryNotFound:
            statusMsg += "R3D decoder library not found.";
            break;
        case ISLibraryVersionMismatch:
            statusMsg += "library version mismatch.";
            break;
        case ISInvalidR3DSDKLibrary:
            statusMsg += "invalid R3D SDK library.";
            break;
        case ISInvalidRedCudaLibrary:
            statusMsg += "invalid Red CUDA library.";
            break;
        case ISInvalidRedOpenCLLibrary:
            statusMsg += "invalid Red OpenCL library.";
            break;
        case ISInvalidR3DDecoderLibrary:
            statusMsg += "invalid R3D decoder library.";
            break;
        case ISRedCudaLibraryInitializeFailed:
            statusMsg += "Red CUDA library initialization failed.";
            break;
        case ISRedOpenCLLibraryInitializeFailed:
            statusMsg += "Red OpenCL library initialization failed.";
            break;
        case ISR3DDecoderLibraryInitializeFailed:
            statusMsg += "R3D decoder library initialization failed.";
            break;
        case ISR3DSDKLibraryInitializeFailed:
            statusMsg += "R3D SDK library initialization failed.";
            break;
        case ISInvalidPath:
            statusMsg += "invalid path.";
            break;
        case ISInternalError:
            statusMsg += "internal error.";
            break;
    }
    
    return statusMsg;
}

void writeRedFileMetaDataToStream(const std::string& filePath, std::ostream& os, const bool verbose = false)
{
    using namespace R3DSDK;
    std::stringstream log;
    
    // first form to load a clip, this will try to load the clip and set
    // the class status to indicate succes or failure. In this scenario
    // you don't really have to worry about cleaning up the resources since
    // the destructor will do it as soon as 'clip' below goes out of scope
    std::unique_ptr<Clip> clip(new Clip(filePath.c_str()));
    
    if (clip->Status() == LSClipLoaded) {
        if (verbose)
            os << static_cast<unsigned int>(clip->MetadataCount()) << "metadata items found" << std::endl;
        
        // display all available metadata
        for (size_t i = 0U; i < clip->MetadataCount(); i++) {
            const std::string prefix = (verbose || i == 0) ? "" : ",";
            os << prefix << clip->MetadataItemKey(i) << ":" << clip->MetadataItemAsString(i);
            if (verbose)
                os << std::endl;
        }
    }
    else {
        if (verbose)
            os << "Error loading " << filePath << std::endl;
    }
}

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    using namespace R3DSDK;
    
    // Do any additional setup after loading the view.
    InitializeStatus status = InitializeSdk(".", OPTION_RED_NONE);
    const std::string statusMsg = RedSDKStatusMsg(status) + '\n';
    NSString* nsStatusMsg = [NSString stringWithCString:statusMsg.c_str()
                            encoding:[NSString defaultCStringEncoding]];
    [_textView insertText:nsStatusMsg];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)browseButtonClicked:(NSButton *)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];

    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];

    NSInteger clicked = [openDlg runModal];

    if (clicked == NSFileHandlingPanelOKButton) {
        _targetFileOrDir.stringValue = openDlg.URL.path;
        std::stringstream log;
        writeRedFileMetaDataToStream(_targetFileOrDir.stringValue.UTF8String, log, true);
        NSString* nsStatusMsg = [NSString stringWithCString:log.str().c_str()
                                                   encoding:[NSString defaultCStringEncoding]];
        [_textView insertText:nsStatusMsg];
    }
}

- (IBAction)saveButtonClicked:(NSButton *)sender
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:@"red_metadata.csv"];
    
    // display the panel
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            // create a file namaner and grab the save panel's returned URL
            NSFileManager *manager = [NSFileManager defaultManager];
            NSURL *saveURL = [panel URL];
            std::ofstream os(saveURL.path.UTF8String);
            writeRedFileMetaDataToStream(_targetFileOrDir.stringValue.UTF8String, os);
        }
    }];
}


@end
