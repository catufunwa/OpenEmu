/*
 Copyright (c) 2011, OpenEmu Team
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
     * Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
     * Neither the name of the OpenEmu Team nor the
       names of its contributors may be used to endorse or promote products
       derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY OpenEmu Team ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL OpenEmu Team BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "OETableHeaderCell.h"

#import "OEUIDrawingUtils.h"
#import "NSImage+OEDrawingAdditions.h"

#pragma mark - Private variables

static const NSSize  _OESortIndicatorSize   = {15, 14};
static const CGFloat _OESortIndicatorMargin = 5;

#pragma mark -

@implementation OETableHeaderCell
@synthesize clickable;

+ (void)initialize
{
    if(self != [OETableHeaderCell class])
        return;
    
    NSImage *sourceImage = [NSImage imageNamed:@"table_header"];
    [sourceImage setName:@"table_header_background_active"  forSubimageInRect:NSMakeRect(0, 17, 16, 17)];
    [sourceImage setName:@"table_header_background_pressed" forSubimageInRect:NSMakeRect(0,  0, 16, 17)];
    
    sourceImage = [NSImage imageNamed:@"sort_arrow"];
    [sourceImage setName:@"sort_arrow_inactive" forSubimageInRect:(NSRect){{_OESortIndicatorSize.width * 0, 0}, _OESortIndicatorSize}];
    [sourceImage setName:@"sort_arrow_pressed"  forSubimageInRect:(NSRect){{_OESortIndicatorSize.width * 1, 0}, _OESortIndicatorSize}];
    [sourceImage setName:@"sort_arrow_rollover" forSubimageInRect:(NSRect){{_OESortIndicatorSize.width * 2, 0}, _OESortIndicatorSize}];
}

#pragma mark -

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSTableView *tableView = [(NSTableHeaderView *)controlView tableView];

	BOOL isPressed = [self state] && [self isClickable];
	BOOL isFirst = [(NSTableHeaderView *)controlView columnAtPoint:cellFrame.origin] == 0;

	BOOL hideDarkBorderOnRight = !isFirst && ([(NSTableHeaderView *)controlView columnAtPoint:cellFrame.origin] >= [[tableView tableColumns] count]-1);
	BOOL hideHighlight = hideDarkBorderOnRight && ([(NSTableHeaderView *)controlView columnAtPoint:cellFrame.origin] >= [[tableView tableColumns] count]);
	
	NSRect sourceRect = NSZeroRect;
	NSImage *backgroundImage = [NSImage imageNamed:@"table_header_background_active"];
	if(hideDarkBorderOnRight) sourceRect = NSMakeRect(0, 0, backgroundImage.size.width-1, backgroundImage.size.height);
	
	if(isPressed)
    {
		backgroundImage = [NSImage imageNamed:@"table_header_background_pressed"];
		[backgroundImage drawInRect:cellFrame fromRect:sourceRect operation:NSCompositeCopy fraction:1.0 respectFlipped:YES hints:nil leftBorder:7 rightBorder:hideDarkBorderOnRight?7:8 topBorder:0 bottomBorder:0];
	}
    else
    {
		[backgroundImage drawInRect:cellFrame fromRect:sourceRect operation:NSCompositeCopy fraction:1.0 respectFlipped:YES hints:nil leftBorder:7 rightBorder:hideDarkBorderOnRight?7:8 topBorder:0 bottomBorder:0];
		
		// draw highlight on left edge
		if(!isFirst && !hideHighlight)
        {
			NSRect leftHighlightRect = cellFrame;
			leftHighlightRect.size.width = 1;
			
			[[NSColor colorWithDeviceWhite:1.0 alpha:0.04] setFill];
			NSRectFillUsingOperation(leftHighlightRect, NSCompositeSourceOver);
		}
	}
	
	/*
	 *	Highlight stuff (included in image)
	 *
	 
	// Draw Dark border on right
	NSRect rightBorderRect = cellFrame;
	rightBorderRect.origin.x += rightBorderRect.size.width-1;
	rightBorderRect.size.width = 1;
	
	[[NSColor colorWithDeviceWhite:0.08 alpha:1.0] setFill];
	NSRectFill(rightBorderRect);
	
	// Draw dark dot in lower right corner
	NSRect lowerRightBorderRect = cellFrame;
	lowerRightBorderRect.origin.x += lowerRightBorderRect.size.width-1;
	lowerRightBorderRect.size.width = 1;
	lowerRightBorderRect.origin.y += lowerRightBorderRect.size.height-1;
	lowerRightBorderRect.size.height = 1;
	
	[[NSColor colorWithDeviceWhite:0.06 alpha:1.0] setFill];
	NSRectFill(lowerRightBorderRect);
	
	// Draw Black Border on bottom
	NSRect borderLineRect = cellFrame;
	borderLineRect.origin.y += borderLineRect.size.height-1;
	borderLineRect.size.height = 1;
	
	[[NSColor blackColor] setFill];
	NSRectFill(borderLineRect); 
	 */
	
	NSFont *titleFont = [[NSFontManager sharedFontManager] fontWithFamily:@"Lucida Grande" traits:0 weight:4 size:11];
	NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [paraStyle setAlignment:[self alignment]];
	
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor:[NSColor blackColor]];
	[shadow setShadowOffset:NSMakeSize(0, -1)];
	[shadow setShadowBlurRadius:0];
		
	NSDictionary *attributes;
	NSAttributedString *header;
	NSRect headerRect;

	NSColor *textColor = [NSColor colorWithDeviceWhite:.85 alpha:1];
	
    headerRect = NSInsetRect(cellFrame, 8, 0);
    headerRect.origin.y   += 1;
    headerRect.size.width -= _OESortIndicatorSize.width;

	// Draw glow if header is pressed
	if(isPressed)
    {
		textColor = [NSColor whiteColor];

		NSShadow *glow = [[NSShadow alloc] init];
		
		[glow setShadowColor:[NSColor whiteColor]];
		[glow setShadowOffset:NSMakeSize(0, 0)];
		[glow setShadowBlurRadius:5];
		
		attributes = [NSDictionary dictionaryWithObjectsAndKeys:
					  textColor, NSForegroundColorAttributeName,
					  titleFont, NSFontAttributeName,
					  glow, NSShadowAttributeName,
					  paraStyle, NSParagraphStyleAttributeName,
					  nil];
		
		header = [[NSAttributedString alloc] initWithString:[self title] attributes:attributes];
		[header drawInRect:headerRect];
	}
	
	attributes = [NSDictionary dictionaryWithObjectsAndKeys:
				  textColor, NSForegroundColorAttributeName,
				  titleFont, NSFontAttributeName,
				  shadow, NSShadowAttributeName,
				  paraStyle, NSParagraphStyleAttributeName,
				  nil];
	
	
	header = [[NSAttributedString alloc] initWithString:[self title] attributes:attributes];
	[header drawInRect:headerRect];
		
	int columnIndex = [(NSTableHeaderView *)controlView columnAtPoint:cellFrame.origin];
	if(columnIndex < 0) return;
	
	NSTableColumn *column = [[tableView tableColumns] objectAtIndex:columnIndex];
	
	if([[tableView sortDescriptors] count] == 0) return;
    
	NSSortDescriptor *sortDesc = [[tableView sortDescriptors] objectAtIndex:0];
	
    NSInteger priority = [[sortDesc key] isEqualToString:[[column sortDescriptorPrototype] key]];
	BOOL ascending = [sortDesc ascending];
	
    const NSRect sortIndicatorRect =
    {
        .origin.x = cellFrame.origin.x + cellFrame.size.width - _OESortIndicatorMargin - _OESortIndicatorSize.width,
        .origin.y = roundf(cellFrame.origin.y + (cellFrame.size.height - _OESortIndicatorSize.height) / 2) - 1,
        _OESortIndicatorSize
    };
	[self drawSortIndicatorWithFrame:sortIndicatorRect inView:controlView ascending:ascending priority:priority];
}

- (void)drawSortIndicatorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView ascending:(BOOL)ascending priority:(NSInteger)priority
{
	if(priority != 1) return;
	
	NSImage *sortindicatorImage = [NSImage imageNamed:[self state] ? @"sort_arrow_pressed" : @"sort_arrow_inactive"];
	
	[sortindicatorImage drawInRect:cellFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:!ascending hints:nil];
}

@end