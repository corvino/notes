- layoutViewsWhenReadyWithStory:(Story *)stry
{
    self.story = stry;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
//    CGPathAddRect(path, NULL, CGRectMake(0., 0., 600., 400.));
//    CGPathAddRect(path, NULL, CGRectMake(200., 401., 400., 200.));
    
    CGPathAddEllipseInRect(path, NULL, CGRectMake(0., 0., 600., 295.));
    CGPathAddEllipseInRect(path, NULL, CGRectMake(0., 305., 600., 295.));
    
    UIFont *font = [UIFont fontWithName:@"Georgia" size:12.];
    ArticleTextView *articleView = [[ArticleTextView alloc] initWithFrame:CGRectMake(10., 10., 600., 600.)];
    articleView.text = story.body;
    articleView.path = path;
    articleView.font = font;
    articleView.startIndex = 3;
    articleView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:articleView];
    
    NSLog(@"Num lines: %ld; font height: %f; text height: %f; next index: %ld", articleView.numLines, font.lineHeight, articleView.textHeight, articleView.nextIndex);
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0., articleView.textHeight + 10., 600., 1.)];
    lineView.backgroundColor = [UIColor redColor];
    [self.view addSubview:lineView];
    [lineView release];
    
    [articleView release];
    CFRelease(path);
    
    return self;
}


- (void)drawRect:(CGRect)rect
{
//    NSLog(@"Drawing text: %@", self.text);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0f, rect.size.height); //seems to work better by translating, then scaling
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
//    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.text];
//    CFMutableAttributedStringRef mAttrString = CFAttributedStringCreateMutableCopy(kCFAllocatorDefault, 0, (CFAttributedStringRef)attributedString);
    
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef) @"Georgia", 12., NULL);
    CFMutableAttributedStringRef mAttrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString (mAttrString, CFRangeMake(0, 0), (CFStringRef) self.text);
    CFAttributedStringSetAttribute(mAttrString, CFRangeMake(0, CFAttributedStringGetLength(mAttrString)), kCTFontAttributeName, font);
    CFRelease(ctFont);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) mAttrString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), self.path, NULL);
    CTFrameDraw(frame, context);
    CFRange frameRange = CTFrameGetVisibleStringRange(frame);
    
    int  nextIndex = frameRange.length;
    
    CFArrayRef lines = CTFrameGetLines(frame);
    CFIndex numLines = CFArrayGetCount(lines);
    
    NSLog(@"number linesL %ld", numLines);
    NSLog(@"nextIndex: %d", nextIndex);
//    NSLog(@"Remaining Text: %@", [self.text substringFromIndex:nextIndex]);
    
    CFRelease(frame);
}




- (CGFloat)getLineHeightForFont
{
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef) font.fontName, font.pointSize, NULL);
    CGFloat lineHeight = 0.0;
    
    lineHeight += CTFontGetAscent(ctFont);
    lineHeight += CTFontGetDescent(ctFont);
    lineHeight += CTFontGetLeading(ctFont);
    
    return lineHeight;
}

- (CGSize)measureFrame:(CTFrameRef)frame
{
	CGPathRef framePath = CTFrameGetPath(frame);
	CGRect frameRect = CGPathGetBoundingBox(framePath);
    
	CFArrayRef lines = CTFrameGetLines(frame);
	CFIndex numLines = CFArrayGetCount(lines);
    
	CGFloat maxWidth = 0;
	CGFloat textHeight = 0;
    
	// Now run through each line determining the maximum width of all the lines.
	// We special case the last line of text. While we've got it's descent handy,
	// we'll use it to calculate the typographic height of the text as well.
	CFIndex lastLineIndex = numLines - 1;
	for(CFIndex index = 0; index < numLines; index++)
	{
		CGFloat ascent, descent, leading, width;
		CTLineRef line = (CTLineRef) CFArrayGetValueAtIndex(lines, index);
		width = CTLineGetTypographicBounds(line, &ascent,  &descent, &leading);
        
		if(width > maxWidth)
		{
			maxWidth = width;
		}
        
		if(index == lastLineIndex)
		{
			// Get the origin of the last line. We add the descent to this
			// (below) to get the bottom edge of the last line of text.
			CGPoint lastLineOrigin;
			CTFrameGetLineOrigins(frame, CFRangeMake(lastLineIndex, 1), &lastLineOrigin);
            
			// The height needed to draw the text is from the bottom of the last line
			// to the top of the frame.
			textHeight =  CGRectGetMaxY(frameRect) - lastLineOrigin.y + descent;
		}
	}
    
	// For some text the exact typographic bounds is a fraction of a point too
	// small to fit the text when it is put into a context. We go ahead and round
	// the returned drawing area up to the nearest point.  This takes care of the
	// discrepencies.
	return CGSizeMake(ceil(maxWidth), ceil(textHeight));
}

- (CGFloat)textHeight2
{
    [self layoutText];

    return [self measureFrame:textFrame].height;
//    CFArrayRef lines = CTFrameGetLines(textFrame);
//    int numLines = CFArrayGetCount(lines);
//    CGPoint origins[numLines];
//    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
//    return origins[0].y;
//    
//    return CFArrayGetValueAtIndex(lines, CFArrayGetCount(lines) - 1);
//    return CTLineGetOffsetForStringIndex(CFArrayGetValueAtIndex(lines, CFArrayGetCount(lines) - 1), 0, 0);
}
