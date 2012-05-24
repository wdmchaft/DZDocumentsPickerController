
//
//  DZDocument.h
//  DZDocumentsPickerController
//
//  Created Ignacio Romero Zurbuchen on 4/18/12.
//  Copyright (c) 2011 DZen Interaktiv.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>

enum DocumentsType {DocumentTypeAll = -1, DocumentTypeUnknown = 0, DocumentTypeImages = 1, DocumentTypePDF = 2, DocumentTypeMSOffice = 3, DocumentTypeZip = 4, DocumentTypeVideo = 5};
typedef enum DocumentsType DocumentType;

@interface DZDocument : NSObject
{
    
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *size;
@property BOOL isDirectory;

+ (DocumentType)getDocumentsTypeOfFile:(NSString *)filename;
+ (UIImage *)getIconDocumentsTypeOfFile:(NSString *)filename;
+ (NSString *)getUTIofFile:(NSString *)filename;
+ (NSString *)getMimeTypeOfFile:(NSString *)filename;

@end
