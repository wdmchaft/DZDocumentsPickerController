
//
//  DZDocument.h
//  DZDocumentsPickerController
//
//  Created Ignacio Romero Zurbuchen on 4/18/12.
//  Copyright (c) 2011 DZen Interaktiv.
//  Licence: MIT-Licence
//

#import "DZDocument.h"

@implementation DZDocument
@synthesize name, path, size, isDirectory;

#pragma mark - UIDocumentsPickerController Utilities

+ (DocumentType)getDocumentsTypeOfFile:(NSString *)filename
{
    NSString *fileExtension = [[filename pathExtension] lowercaseString];
    NSLog(@"fileExtension = %@",fileExtension);
    
    if ([fileExtension isEqualToString:@"png"] || [fileExtension isEqualToString:@"gif"] ||
        [fileExtension isEqualToString:@"bmp"] || [fileExtension isEqualToString:@"jpg"] ||
        [fileExtension isEqualToString:@"jpeg"] || [fileExtension isEqualToString:@"tiff"])
    {
        return DocumentTypeImages;
    }
    else if ([fileExtension isEqualToString:@"doc"] || [fileExtension isEqualToString:@"docx"] ||
             [fileExtension isEqualToString:@"ppt"] || [fileExtension isEqualToString:@"pptx"] ||
             [fileExtension isEqualToString:@"xls"] || [fileExtension isEqualToString:@"xlsx"])
    {
        return DocumentTypeMSOffice;
    }
    else if ([fileExtension isEqualToString:@"pdf"])
    {
        return DocumentTypePDF;
    }
    else if ([fileExtension isEqualToString:@"zip"] || [fileExtension isEqualToString:@"rar"] ||
             [fileExtension isEqualToString:@"sitx"])
    {
        return DocumentTypeZip;
    }
    else
    {
        return DocumentTypeUnknown;
    }
}

+ (UIImage *)getIconDocumentsTypeOfFile:(NSString *)filename
{
    NSString *fileExtension = [[filename pathExtension] lowercaseString];
    UIImage *iconImg = [[UIImage alloc] init];
    
    if ([fileExtension isEqualToString:@""]) iconImg = [UIImage imageNamed:@"icon_folder.png"];
    else if ([fileExtension isEqualToString:@"png"]) iconImg = [UIImage imageNamed:@"icon_png.png"];
    else if ([fileExtension isEqualToString:@"gif"]) iconImg = [UIImage imageNamed:@"icon_gif.png"];
    else if ([fileExtension isEqualToString:@"bmp"]) iconImg = [UIImage imageNamed:@"icon_bmp.png"];
    else if ([fileExtension isEqualToString:@"jpg"]) iconImg = [UIImage imageNamed:@"icon_jpg.png"];
    else if ([fileExtension isEqualToString:@"jpeg"]) iconImg = [UIImage imageNamed:@"icon_jpeg.png"];
    else if ([fileExtension isEqualToString:@"tiff"]) iconImg = [UIImage imageNamed:@"icon_tif.png"];
    else if ([fileExtension isEqualToString:@"pdf"]) iconImg = [UIImage imageNamed:@"icon_pdf.png"];
    else if ([fileExtension isEqualToString:@"doc"] || [fileExtension isEqualToString:@"docx"]) return [UIImage imageNamed:@"icon_doc.png"];
    else if ([fileExtension isEqualToString:@"ppt"] || [fileExtension isEqualToString:@"pptx"]) return [UIImage imageNamed:@"icon_ppt.png"];
    else if ([fileExtension isEqualToString:@"xls"] || [fileExtension isEqualToString:@"xlsx"]) return [UIImage imageNamed:@"icon_xls.png"];
    else if ([fileExtension isEqualToString:@"zip"]) return [UIImage imageNamed:@"icon_zip.png"];
    else if ([fileExtension isEqualToString:@"rar"]) return [UIImage imageNamed:@"icon_rar.png"];
    else if ([fileExtension isEqualToString:@"sitx"]) return [UIImage imageNamed:@"icon_sitx.png"];
    else iconImg = [UIImage imageNamed:@"icon_unknown.png"];
    
    return iconImg;
}

+ (NSString *)getUTIofFile:(NSString *)filename
{
    NSString *fileExtension = [[filename pathExtension] lowercaseString];
    
    if ([fileExtension isEqualToString:@"pdf"]) return @"com.adobe.pdf";
    else if ([fileExtension isEqualToString:@"doc"] || [fileExtension isEqualToString:@"docx"]) return @"com.microsoft.word.doc";
    else if ([fileExtension isEqualToString:@"ppt"] || [fileExtension isEqualToString:@"pptx"]) return @"com.microsoft.powerpoint.ppt";
    else if ([fileExtension isEqualToString:@"xls"] || [fileExtension isEqualToString:@"xlsx"]) return @"com.microsoft.excel.xls";
    
    return nil;
}

+ (NSString *)getMimeTypeOfFile:(NSString *)filename
{
    NSString *fileExtension = [[filename pathExtension] lowercaseString];
    
    if ([fileExtension isEqualToString:@"pdf"]) return @"application/pdf";
    else if ([fileExtension isEqualToString:@"doc"] || [fileExtension isEqualToString:@"docx"]) return @"application/msword";
    else if ([fileExtension isEqualToString:@"ppt"] || [fileExtension isEqualToString:@"pptx"]) return @"application/vnd.ms-powerpoint";
    else if ([fileExtension isEqualToString:@"xls"] || [fileExtension isEqualToString:@"xlsx"]) return @"application/vnd.ms-excel";
    else if ([fileExtension isEqualToString:@"jpg"] || [fileExtension isEqualToString:@"jpeg"]) return @"image/jpeg";
    else if ([fileExtension isEqualToString:@"png"]) return @"image/png";
    return nil;
}


@end
