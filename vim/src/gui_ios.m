/* vi:set ts=8 sts=4 sw=4 ft=objc:
 *
 * VIM - Vi IMproved		by Bram Moolenaar
 *				   iOS port by Romain Goyet
 *
 * Do ":help uganda"  in Vim to read copying and usage conditions.
 * Do ":help credits" in Vim to see a list of people who contributed.
 * See README.txt for an overview of the Vim source code.
 */
/*
 * gui_ios.m
 *
 * Support for the iOS GUI. Most of the iOS code resides in this file.
 */

#import "vim.h"
#import "VimIOS-Swift.h"



int getCTRLKeyCode(NSString * s) {
    if([s isEqualToString:@"["])
        return ESC;
    if([s isEqualToString:@"]"])
        return Ctrl_RSB;
    if([s isEqualToString:@"A"]) 
        return Ctrl_A;
    if([s isEqualToString:@"B"])
	return Ctrl_B;
    if([s isEqualToString:@"C"])
	return Ctrl_C;
    if([s isEqualToString:@"D"])
	return Ctrl_D;
    if([s isEqualToString:@"E"])
	return Ctrl_E;
    if([s isEqualToString:@"F"])
	return Ctrl_F;
    if([s isEqualToString:@"G"])
	return Ctrl_G;
    if([s isEqualToString:@"H"])
	return Ctrl_H;
    if([s isEqualToString:@"I"])
	return Ctrl_I;
    if([s isEqualToString:@"J"])
	return Ctrl_J;
    if([s isEqualToString:@"K"])
	return Ctrl_K;
    if([s isEqualToString:@"L"])
	return Ctrl_L;
    if([s isEqualToString:@"M"])
	return Ctrl_M;
    if([s isEqualToString:@"N"])
	return Ctrl_N;
    if([s isEqualToString:@"O"])
	return Ctrl_O;
    if([s isEqualToString:@"P"])
	return Ctrl_P;
    if([s isEqualToString:@"Q"])
	return Ctrl_Q;
    if([s isEqualToString:@"R"])
	return Ctrl_R;
    if([s isEqualToString:@"S"])
	return Ctrl_S;
    if([s isEqualToString:@"T"])
	return Ctrl_T;
    if([s isEqualToString:@"U"])
	return Ctrl_U;
    if([s isEqualToString:@"V"])
	return Ctrl_V;
    if([s isEqualToString:@"W"])
	return Ctrl_W;
    if([s isEqualToString:@"X"])
	return Ctrl_X;
    if([s isEqualToString:@"Y"])
	return Ctrl_Y;
    if([s isEqualToString:@"Z"])    
	return Ctrl_Z;
    return 0;
    
}



NSInteger const keyCAR = CAR;
NSInteger const keyBS = BS;
NSInteger const keyESC = ESC;
NSInteger const keyTAB = TAB;
NSInteger const keyF1 = 0x7E;
NSInteger const keyUP = K_UP;
NSInteger const keyDOWN = K_DOWN;
NSInteger const keyLEFT = K_LEFT;
NSInteger const keyRIGHT = K_RIGHT;
NSInteger const mouseDRAG = MOUSE_DRAG;
NSInteger const mouseLEFT = MOUSE_LEFT;
NSInteger const mouseRELEASE = MOUSE_RELEASE;



NSString *lookupStringConstant(NSString *constantName) {
    void ** dataPtr = CFBundleGetDataPointerForName(CFBundleGetMainBundle(), (__bridge CFStringRef)constantName);
    return (__bridge NSString *)(dataPtr ? *dataPtr : nil);
}


#define RGB(r,g,b)	((r) << 16) + ((g) << 8) + (b)
#define ARRAY_LENGTH(a) (sizeof(a) / sizeof(a[0]))

static int hex_digit(int c) {
    if (VIM_ISDIGIT(c))
        return c - '0';
    c = TOLOWER_ASC(c);
    if (c >= 'a' && c <= 'f')
        return c - 'a' + 10;
    return -1000;
}

VimViewController * getViewController() {
    return (VimViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
}
VimView * getView() {
    return [getViewController() vimView];
}



CGColorRef CGColorCreateFromVimColor(guicolor_T color)  {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int red = (color & 0xFF0000) >> 16;
    int green = (color & 0x00FF00) >> 8;
    int blue = color & 0x0000FF;
    CGFloat rgb[4] = {(float)red/0xFF, (float)green/0xFF, (float)blue/0xFF, 1.0f};
    CGColorRef cgColor = CGColorCreate(colorSpace, rgb);
    CGColorSpaceRelease(colorSpace);
    return cgColor;
}


//void inputSpecialKey(specialKey key) {
//    char escapeString[] = {CAR,0};
//    NSString * text = [NSString stringWithUTF8String:escapeString];
//    int length = [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
//    add_to_input_buf( (char_u)*[text UTF8String], length);
//}

#pragma mark -
#pragma mark Vim C functions

/*
 * Parse the GUI related command-line arguments.  Any arguments used are
 * deleted from argv, and *argc is decremented accordingly.  This is called
 * when vim is started, whether or not the GUI has been started.
 * NOTE: This function will be called twice if the Vim process forks.
 */

void vimHelper(int argc, NSString *file)
{
    char * argv[2] = { "vim", nil};
    if(file != nil) {
        char* filename = [file UTF8String];
        argv[1] = filename;
        argc++;
    }

       // NSLog(@"%s", argv[1]);
    
    VimMain(argc,argv);
    
    
}
    void
gui_mch_prepare(int *argc, char **argv)
{
    NSLog(@"Prepare");
}


/*
 * Check if the GUI can be started.  Called before gvimrc is sourced.
 * Return OK or FAIL.
 */
    int
gui_mch_init_check(void)
{
//    printf("%s\n",__func__);  
    return OK;
}


/*
 * Initialise the GUI.  Create all the windows, set up all the call-backs etc.
 * Returns OK for success, FAIL when the GUI can't be started.
 */
    int
gui_mch_init(void)
{
//    printf("%s\n",__func__);
    set_option_value((char_u *)"termencoding", 0L, (char_u *)"utf-8", 0);
    
    gui_mch_def_colors();
    
    set_normal_colors();

    gui_check_colors();
    gui.def_norm_pixel = gui.norm_pixel;
    gui.def_back_pixel = gui.back_pixel;

//#ifdef FEAT_GUI_SCROLL_WHEEL_FORCE
   // gui.scroll_wheel_force = 1;
    //gui
//#endif

    return OK;
}



    void
gui_mch_exit(int rc)
{
//    printf("%s\n",__func__);  
}


/*
 * Open the GUI window which was created by a call to gui_mch_init().
 */
    int
gui_mch_open(void)
{
    
    [getView() resizeShell];
    
 //   [gui_ios.view_controller resizeShell];
//    [gui_ios.window makeKeyAndVisible];
    
//    printf("%s\n",__func__);  
    return OK;
}


// -- Updating --------------------------------------------------------------


/*
 * Catch up with any queued X events.  This may put keyboard input into the
 * input buffer, call resize call-backs, trigger timers etc.  If there is
 * nothing in the X event queue (& no timers pending), then we return
 * immediately.
 */
    void
gui_mch_update(void)
{
    // This function is called extremely often.  It is tempting to do nothing
    // here to avoid reduced frame-rates but then it would not be possible to
    // interrupt Vim by presssing Ctrl-C during lengthy operations (e.g. after
    // entering "10gs" it would not be possible to bring Vim out of the 10 s
    // sleep prematurely).  Furthermore, Vim sometimes goes into a loop waiting
    // for keyboard input (e.g. during a "more prompt") where not checking for
    // input could cause Vim to lock up indefinitely.
    //
    // As a compromise we check for new input only every now and then. Note
    // that Cmd-. sends SIGINT so it has higher success rate at interrupting
    // Vim than Ctrl-C.
    //    EventRecord theEvent;

//    printf("%s\n",__func__);  
}


/* Flush any output to the screen */
    void
gui_mch_flush(void)
{
    // This function is called way too often to be useful as a hint for
    // flushing.  If we were to flush every time it was called the screen would
    // flicker.
//    printf("%s\n",__func__);
//    CGContextFlush(CGLayerGetContext(gui_ios.layer));
//[gui_ios.view_controller flush];
    
    
   [getViewController() flush];
}


/*
 * GUI input routine called by gui_wait_for_chars().  Waits for a character
 * from the keyboardk.
 *  wtime == -1	    Wait forever.
 *  wtime == 0	    This should never happen.
 *  wtime > 0	    Wait wtime milliseconds for a character.
 * Returns OK if a character was found to be available within the given time,
 * or FAIL otherwise.
 */
//TODO: Move to VC
    int
gui_mch_wait_for_chars(int wtime)
{
    
    return [getViewController() waitForChars:wtime];
    //NSLog(@"Wait %i", wtime);
//    NSDate * now = [NSDate date];
//    double  passed =[now timeIntervalSinceDate:[getViewController() lastKeyPress]]*1000;
//    
//    if(passed <1000 )
//        wtime=10;
//        //wtime = gui_ios.wait;
//    if(wtime<0)
//        wtime = 4000;
//    
//   // NSLog(@"Wtime: %i", wtime);
//    //NSLog(@"Passed: %f", passed);
//    NSDate * expirationDate = wtime > 0 ? [NSDate dateWithTimeIntervalSinceNow:((NSTimeInterval)wtime)/1000.0] : [NSDate distantFuture];
//    [[NSRunLoop currentRunLoop] acceptInputForMode:NSDefaultRunLoopMode beforeDate:expirationDate];
//    //[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]]; // This is a workaround. Without this, you cannot split the UIKeyboard
//    double delay = [expirationDate timeIntervalSinceNow];
//
//    return delay < 0 ? FAIL : OK;
// //   return OK;
}


// -- Drawing ---------------------------------------------------------------


/*
 * Clear the whole text window.
 */
void
gui_mch_clear_all(void)
{
    
    [getView() clearAll];
//    printf("%s\n",__func__);
  //  CGContextRef context = CGLayerGetContext(gui_ios.layer);
  //  
  //  CGContextSetFillColorWithColor(context, gui_ios.bg_color);
  //  CGSize size = CGLayerGetSize(gui_ios.layer);
  //  CGContextFillRect(context, CGRectMake(0.0f, 0.0f, size.width, size.height));
  //  gui_ios.dirtyRect = gui_ios.view_controller.textView.bounds;
}


/*
 * Clear a rectangular region of the screen from text pos (row1, col1) to
 * (row2, col2) inclusive.
 */
    void
gui_mch_clear_block(int row1, int col1, int row2, int col2)
{
    
    CGRect rect = CGRectMake(FILL_X(col1),
                             FILL_Y(row1),
                             FILL_X(col2+1)-FILL_X(col1),
                             FILL_Y(row2+1)-FILL_Y(row1));
    [getView() fillRectWithColor:rect color:CGColorCreateFromVimColor(gui.back_pixel)];
   // CGContextRef context = CGLayerGetContext(gui_ios.layer);
   // gui_mch_set_bg_color(gui.back_pixel);
   // CGContextSetFillColorWithColor(context, gui_ios.bg_color);
   // CGRect rect = CGRectMake(FILL_X(col1),
   //                          FILL_Y(row1),
   //                          FILL_X(col2+1)-FILL_X(col1),
   //                          FILL_Y(row2+1)-FILL_Y(row1));
   // CGContextFillRect(context, rect);
   // gui_ios.dirtyRect = CGRectUnion(gui_ios.dirtyRect, rect);
}

CGFloat gui_fill_x(int col){
    return FILL_X(col);
}

CGFloat gui_fill_y(int col){
    return FILL_Y(col);
}

CGFloat gui_text_x(int col){
    return TEXT_X(col);
}

CGFloat gui_text_y(int row){
    return TEXT_Y(row);
}



void gui_mch_draw_string(int row, int col, char_u *s, int len, int flags) {
    if (s == NULL || len <= 0) {
        return;
    }

    //NSLog(@"Draw %s ", s);
    //CGRect rect = CGRectMake(FILL_X(col),
    //                         FILL_Y(row),
    //                        #ifdef FEAT_MBYTE
    //                        FILL_X(col+mb_string2cells(s,len))-FILL_X(col),
    //                        #else
    //                        FILL_X(col+len)-FILL_X(col),
    //                        #endif
    //                         FILL_Y(row+1)-FILL_Y(row));
    
    NSString * string = [[NSString alloc] initWithBytes:s length:len encoding:NSUTF8StringEncoding];
    if (string == nil) {
        return;
    }
    //NSDictionary * attributes = [[NSDictionary alloc] initWithObjectsAndKeys:(__bridge id)(gui.norm_font), (NSString *)kCTFontAttributeName,
    //                             [NSNumber numberWithBool:YES], kCTForegroundColorFromContextAttributeName,
    //                             nil];
    //NSAttributedString * attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    
    [getView() drawString:string font:gui.norm_font col:col row: row cells: mb_string2cells(s,len) p_antialias:true transparent: !(flags & DRAW_TRANSP) cursor: (flags & DRAW_CURSOR)];

    //CGContextRef context = CGLayerGetContext(gui_ios.layer);

    //CGContextSetShouldAntialias(context, p_antialias);
    //CGContextSetAllowsAntialiasing(context, p_antialias);
    //CGContextSetShouldSmoothFonts(context, p_antialias);

    //CGContextSetCharacterSpacing(context, 0.0f);
    //CGContextSetTextDrawingMode(context, kCGTextFill); 

    //if (!(flags & DRAW_TRANSP)) {
    //    CGContextSetFillColorWithColor(context, gui_ios.bg_color);
    //    CGContextFillRect(context, CGRectMake(FILL_X(col), FILL_Y(row), FILL_X(col+len)-FILL_X(col), FILL_Y(row+1)-FILL_Y(row)));
    //}

    //CGContextSetFillColorWithColor(context, gui_ios.fg_color);

   //NSString * string = [[NSString alloc] initWithBytes:s length:len encoding:NSUTF8StringEncoding];
    //if (string == nil) {
    //    return;
    //}
    //NSDictionary * attributes = [[NSDictionary alloc] initWithObjectsAndKeys:(id)gui.norm_font, (NSString *)kCTFontAttributeName,
             //                    [NSNumber numberWithBool:YES], kCTForegroundColorFromContextAttributeName,
              //                   nil];
    //NSAttributedString * attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    //[attributes release];
    //[string release];
    //CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attributedString);
    //// Set text position and draw the line into the graphics context
    //CGContextSetTextPosition(context, TEXT_X(col), TEXT_Y(row));
    //CTLineDraw(line, context);


    //if (flags & DRAW_CURSOR) {
    //    CGContextSaveGState(context);
    //    CGContextSetBlendMode(context, kCGBlendModeDifference);
    //    CGContextFillRect(context, CGRectMake(FILL_X(col), FILL_Y(row),
    //                                          FILL_X(col+len)-FILL_X(col),
    //                                          FILL_Y(row+1)-FILL_Y(row)));
    //    CGContextRestoreGState(context);
    //}
    //if (line != NULL) {
    //    CFRelease(line);
    //}
    //[attributedString release];
    //CGRect rect = CGRectMake(FILL_X(col),
    //                         FILL_Y(row),
    //                         FILL_X(col+len)-FILL_X(col),
    //                         FILL_Y(row+1)-FILL_Y(row));
    //gui_ios.dirtyRect = CGRectUnion(gui_ios.dirtyRect, rect);
}


/*
 * Delete the given number of lines from the given row, scrolling up any
 * text further down within the scroll region.
 */
    void
gui_mch_delete_lines(int row, int num_lines)
{
//    printf("%s\n",__func__);
   CGRect sourceRect = CGRectMake(FILL_X(gui.scroll_region_left),
                                   FILL_Y(row + num_lines),
                                   FILL_X(gui.scroll_region_right+1) - FILL_X(gui.scroll_region_left),
                                   FILL_Y(gui.scroll_region_bot+1) - FILL_Y(row + num_lines));

    CGRect targetRect = CGRectMake(FILL_X(gui.scroll_region_left),
                                   FILL_Y(row),
                                   FILL_X(gui.scroll_region_right+1) - FILL_X(gui.scroll_region_left),
                                   FILL_Y(gui.scroll_region_bot+1) - FILL_Y(row + num_lines));

    [getView() CGLayerCopyRectToRect:sourceRect targetRect:targetRect];
//
    gui_clear_block(gui.scroll_region_bot - num_lines + 1,
                    gui.scroll_region_left,
                    gui.scroll_region_bot, gui.scroll_region_right);
}


/*
 * Insert the given number of lines before the given row, scrolling down any
 * following text within the scroll region.
 */
    void
gui_mch_insert_lines(int row, int num_lines)
{
//    printf("%s\n",__func__);
   CGRect sourceRect = CGRectMake(FILL_X(gui.scroll_region_left),
                                  FILL_Y(row),
                                  FILL_X(gui.scroll_region_right+1) - FILL_X(gui.scroll_region_left),
                                  FILL_Y(gui.scroll_region_bot+1) - FILL_Y(row + num_lines));

   CGRect targetRect = CGRectMake(FILL_X(gui.scroll_region_left),
                                  FILL_Y(row + num_lines),
                                  FILL_X(gui.scroll_region_right+1) - FILL_X(gui.scroll_region_left),
                                  FILL_Y(gui.scroll_region_bot+1) - FILL_Y(row + num_lines));
   
    [getView() CGLayerCopyRectToRect:sourceRect targetRect:targetRect];
//
    gui_clear_block(row, gui.scroll_region_left,
                    row + num_lines - 1, gui.scroll_region_right);
}

/*
 * Set the current text foreground color.
 */
    void
gui_mch_set_fg_color(guicolor_T color)
{
 //   if (gui_ios.fg_color != NULL) {
 //       CGColorRelease(gui_ios.fg_color);
 //   }
   getView().fgcolor = CGColorCreateFromVimColor(color);
}


/*
 * Set the current text background color.
 */
    void
gui_mch_set_bg_color(guicolor_T color)
{
    getView().bgcolor = CGColorCreateFromVimColor(color);
    
    //  if (gui_ios.bg_color != NULL) {
  //      CGColorRelease(gui_ios.bg_color);
  //  }
  //  gui_ios.bg_color = CGColorCreateFromVimColor(color);
}

/*
 * Set the current text special color (used for underlines).
 */
    void
gui_mch_set_sp_color(guicolor_T color)
{
    
    getView().spcolor = CGColorCreateFromVimColor(color);
//    printf("%s\n",__func__);  
}


/*
 * Set default colors.
 */
void gui_mch_def_colors() {
    gui.norm_pixel = gui_mch_get_color((char_u *)"white");
    gui.back_pixel = gui_mch_get_color((char_u *)"black");
    gui.def_back_pixel = gui.back_pixel;
    gui.def_norm_pixel = gui.norm_pixel;
}


/*
 * Called when the foreground or background color has been changed.
 */
    void
gui_mch_new_colors(void)
{
//    printf("%s\n",__func__);  
    gui.def_back_pixel = gui.back_pixel;
    gui.def_norm_pixel = gui.norm_pixel;

}

/*
 * Invert a rectangle from row r, column c, for nr rows and nc columns.
 */
    void
gui_mch_invert_rectangle(int r, int c, int nr, int nc)
{
//    printf("%s\n",__func__);  
}

// -- Menu ------------------------------------------------------------------


/*
 * A menu descriptor represents the "address" of a menu as an array of strings.
 * E.g. the menu "File->Close" has descriptor { "File", "Close" }.
 */
   void
gui_mch_add_menu(vimmenu_T *menu, int idx)
{
//    printf("%s\n",__func__);  
}


/*
 * Add a menu item to a menu
 */
    void
gui_mch_add_menu_item(vimmenu_T *menu, int idx)
{
//    printf("%s\n",__func__);  
}


/*
 * Destroy the machine specific menu widget.
 */
    void
gui_mch_destroy_menu(vimmenu_T *menu)
{
//    printf("%s\n",__func__);  
}


/*
 * Make a menu either grey or not grey.
 */
    void
gui_mch_menu_grey(vimmenu_T *menu, int grey)
{
}


/*
 * Make menu item hidden or not hidden
 */
    void
gui_mch_menu_hidden(vimmenu_T *menu, int hidden)
{
//    printf("%s\n",__func__);  
}


/*
 * This is called when user right clicks.
 */
    void
gui_mch_show_popupmenu(vimmenu_T *menu)
{
//    printf("%s\n",__func__);  
}


/*
 * This is called when a :popup command is executed.
 */
    void
gui_make_popup(char_u *path_name, int mouse_pos)
{
//    printf("%s\n",__func__);  
}


/*
 * This is called after setting all the menus to grey/hidden or not.
 */
    void
gui_mch_draw_menubar(void)
{
}


    void
gui_mch_enable_menu(int flag)
{
}

    void
gui_mch_set_menu_pos(int x, int y, int w, int h)
{
//    printf("%s\n",__func__);  
    
    /*
     * The menu is always at the top of the screen.
     */
}

    void
gui_mch_show_toolbar(int showit)
{
//    printf("%s\n",__func__);  
}




// -- Fonts -----------------------------------------------------------------


/*
 * If a font is not going to be used, free its structure.
 */
    void
gui_mch_free_font(font)
    GuiFont	font;
{
//    printf("%s\n",__func__);  
}


    GuiFont
gui_mch_retain_font(GuiFont font)
{
//    printf("%s\n",__func__);  
    return font;
}


/*
 * Get a font structure for highlighting.
 */
    GuiFont
gui_mch_get_font(char_u *name, int giveErrorIfMissing)
{
//    printf("%s\n",__func__);  

    return NOFONT;
}


#if defined(FEAT_EVAL) || defined(PROTO)
/*
 * Return the name of font "font" in allocated memory.
 * TODO: use 'font' instead of 'name'?
 */
    char_u *
gui_mch_get_fontname(GuiFont font, char_u *name)
{
    return name ? vim_strsave(name) : NULL;
}
#endif


/*
 * Initialise vim to use the font with the given name.	Return FAIL if the font
 * could not be loaded, OK otherwise.
 */
    int
gui_mch_init_font(char_u *font_name, int fontset) {
    VimView * view = getView();
    gui.norm_font = [view initFont];
    gui.char_ascent = view.char_ascent;
    gui.char_width = view.char_width;
    gui.char_height = view.char_height;
    
//    printf("%s\n",__func__);

  //  NSString * normalizedFontName = @"Menlo-Regular";
  //  CGFloat normalizedFontSize = 14.0f;
  //  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
  //      normalizedFontSize = 12.0f;
  //  }
  //  if (font_name != NULL) {
  //      NSString * sourceFontName = [[NSString alloc] initWithUTF8String:(const char *)font_name];
  //      NSRange separatorRange = [sourceFontName rangeOfString:@":h"];
  //      if (separatorRange.location != NSNotFound) {
  //          normalizedFontName = [sourceFontName substringToIndex:separatorRange.location];
  //          normalizedFontSize = [[sourceFontName substringFromIndex:separatorRange.location+separatorRange.length] floatValue];
  //      }
  //      [sourceFontName release];
  //  }
  //  CTFontRef rawFont = CTFontCreateWithName((CFStringRef)normalizedFontName, normalizedFontSize, &CGAffineTransformIdentity);

  //  
  //  CGRect boundingRect = CGRectZero;
  //  CGGlyph glyph = CTFontGetGlyphWithName(rawFont, (CFStringRef)@"0");
  //  CTFontGetBoundingRectsForGlyphs(rawFont, kCTFontHorizontalOrientation, &glyph, &boundingRect, 1);

////    NSLog(@"Font bounding box for character 0 : %@", NSStringFromCGRect(boundingRect));
////    NSLog(@"Ascent = %.2f", CTFontGetAscent(rawFont));
////    NSLog(@"Computed height = %.2f", CTFontGetAscent(rawFont) + CTFontGetDescent(rawFont));
////    NSLog(@"Leading = %.2f", CTFontGetLeading(rawFont));
  //  
  //  CGSize advances = CGSizeZero;
  //  
  //  CTFontGetAdvancesForGlyphs(rawFont, kCTFontHorizontalOrientation, &glyph, &advances, 1);
////    NSLog(@"Advances = %@", NSStringFromCGSize(advances));

  //  gui.char_ascent = CTFontGetAscent(rawFont);
  //  gui.char_width = boundingRect.size.width;
  //  gui.char_height = boundingRect.size.height + 3.0f;
////    gui.char_height = CTFontGetAscent(rawFont) + CTFontGetDescent(rawFont);

  //  if (gui.norm_font != NULL) {
  //      CFRelease(gui.norm_font);
  //  }
  //  // Now let's rescale the font
  //  CGAffineTransform transform = CGAffineTransformMakeScale(boundingRect.size.width/advances.width, -1.0f);
  //  gui.norm_font = CTFontCreateCopyWithAttributes(rawFont,
  //                                                normalizedFontSize,
  //                                                &transform,
  //                                                NULL);
  //  CFRelease(rawFont);
  //  
    return OK;
}


/*
 * Set the current text font.
 */
    void
gui_mch_set_font(GuiFont font)
{
//    printf("%s\n",__func__);  
}


// -- Scrollbars ------------------------------------------------------------

// NOTE: Even though scrollbar identifiers are 'long' we tacitly assume that
// they only use 32 bits (in particular when compiling for 64 bit).  This is
// justified since identifiers are generated from a 32 bit counter in
// gui_create_scrollbar().  However if that code changes we may be in trouble
// (if ever that many scrollbars are allocated...).  The reason behind this is
// that we pass scrollbar identifers over process boundaries so the width of
// the variable needs to be fixed (and why fix at 64 bit when only 32 are
// really used?).

    void
gui_mch_create_scrollbar(
	scrollbar_T *sb,
	int orient)	/* SBAR_VERT or SBAR_HORIZ */
{
//    printf("%s\n",__func__);  
}


    void
gui_mch_destroy_scrollbar(scrollbar_T *sb)
{
//    printf("%s\n",__func__);  
}


    void
gui_mch_enable_scrollbar(
	scrollbar_T	*sb,
	int		flag)
{
//    printf("%s\n",__func__);  
}


    void
gui_mch_set_scrollbar_pos(
	scrollbar_T *sb,
	int x,
	int y,
	int w,
	int h)
{
//    printf("%s\n",__func__);  
}


    void
gui_mch_set_scrollbar_thumb(
	scrollbar_T *sb,
	long val,
	long size,
	long max)
{
//    printf("%s\n",__func__);  
}


// -- Cursor ----------------------------------------------------------------


/*
 * Draw a cursor without focus.
 */
    void
gui_mch_draw_hollow_cursor(guicolor_T color)
{
    CGColorRef cgColor = CGColorCreateFromVimColor(color);
    CGRect rect = CGRectMake(FILL_X(gui.col), FILL_Y(gui.row), gui.char_width, gui.char_height);
    [getView() fillRectWithColor:rect color:cgColor];
    
//    int w = 1;
//    
//#ifdef FEAT_MBYTE
//    if (mb_lefthalve(gui.row, gui.col))
//        w = 2;
//#endif
//    
//    CGContextRef context = CGLayerGetContext(gui_ios.layer);
//    CGColorRef cgColor = CGColorCreateFromVimColor(color);
//    CGContextSetStrokeColorWithColor(context, cgColor);
//    CGColorRelease(cgColor);
//    CGRect rect = CGRectMake(FILL_X(gui.col), FILL_Y(gui.row), w * gui.char_width, gui.char_height);
//    CGContextStrokeRect(context, rect);
//    gui_ios.dirtyRect = CGRectUnion(gui_ios.dirtyRect, rect);
//    [gui_ios.view_controller.view setNeedsDisplayInRect:gui_ios.dirtyRect];
}


/*
 * Draw part of a cursor, only w pixels wide, and h pixels high.
 */
    void
gui_mch_draw_part_cursor(int w, int h, guicolor_T color)
{
    
    gui_mch_set_fg_color(color);
    
    int    left;
    
#ifdef FEAT_RIGHTLEFT
    /* vertical line should be on the right of current point */
    if (CURSOR_BAR_RIGHT)
        left = FILL_X(gui.col + 1) - w;
    else
#endif
        left = FILL_X(gui.col);
    
    CGRect rect = CGRectMake(left, FILL_Y(gui.row), (CGFloat)w, (CGFloat)h);
    [getView() fillRectWithColor:rect color:CGColorCreateFromVimColor(color)];
//    CGContextRef context = CGLayerGetContext(gui_ios.layer);
//    gui_mch_set_fg_color(color);
//    
//    int    left;
//    
//#ifdef FEAT_RIGHTLEFT
//    /* vertical line should be on the right of current point */
//    if (CURSOR_BAR_RIGHT)
//        left = FILL_X(gui.col + 1) - w;
//    else
//#endif
//        left = FILL_X(gui.col);
//    
//    CGContextSetFillColorWithColor(context, gui_ios.fg_color);
//    CGRect rect = CGRectMake(left, FILL_Y(gui.row), (CGFloat)w, (CGFloat)h);
//    CGContextFillRect(context, rect);
//    gui_ios.dirtyRect = CGRectUnion(gui_ios.dirtyRect, rect);
//    [gui_ios.view_controller.view setNeedsDisplayInRect:gui_ios.dirtyRect];
//
}


/*
 * Cursor blink functions.
 *
 * This is a simple state machine:
 * BLINK_NONE	not blinking at all
 * BLINK_OFF	blinking, cursor is not shown
 * BLINK_ON blinking, cursor is shown
 */

    void
gui_mch_set_blinking(long wait, long on, long off)
{
//    printf("%s\n",__func__);
    VimViewController * vc = getViewController();
    vc.blink_wait = wait;
    vc.blink_on   = on;
    vc.blink_off  = off;
}


/*
 * Start the cursor blinking.  If it was already blinking, this restarts the
 * waiting time and shows the cursor.
 */
    void
gui_mch_start_blink(void)
{
    [getViewController() startBlink];
//    printf("%s\n",__func__);
 //   if (gui_ios.blink_timer != nil)
 //       [gui_ios.blink_timer invalidate];
 //   
 //   if (gui_ios.blink_wait && gui_ios.blink_on &&
 //       gui_ios.blink_off && gui.in_focus)
 //   {
 //       gui_ios.blink_timer = [NSTimer scheduledTimerWithTimeInterval: gui_ios.blink_wait / 1000.0
 //                                                              target: gui_ios.view_controller
 //                                                            selector: @selector(blinkCursorTimer:)
 //                                                            userInfo: nil
 //                                                             repeats: NO];
 //       gui_ios.blink_state = BLINK_ON;
 //       gui_update_cursor(TRUE, FALSE);
 //   }
}


/*
 * Stop the cursor blinking.  Show the cursor if it wasn't shown.
 */
    void
gui_mch_stop_blink(void)
{
    [getViewController() stopBlink];
//    printf("%s\n",__func__);  
//    [gui_ios.blink_timer invalidate];
//    
////    if (gui_ios.blink_state == BLINK_OFF)
////        gui_update_cursor(TRUE, FALSE);
//    
//    gui_ios.blink_state = BLINK_NONE;
//    gui_ios.blink_timer = nil;
}


// -- Mouse -----------------------------------------------------------------


/*
 * Get current mouse coordinates in text window.
 */
    void
gui_mch_getmouse(int *x, int *y)
{
//    printf("%s\n",__func__);  
}


    void
gui_mch_setmouse(int x, int y)
{
//    printf("%s\n",__func__);  
}


    void
mch_set_mouse_shape(int shape)
{
//    printf("%s\n",__func__);  
}

     void
gui_mch_mousehide(int hide)
{
//    printf("%s\n",__func__);  
}


// -- Clip ----
//
    void
clip_mch_request_selection(VimClipboard *cbd)
{
	int type = MAUTO;
    NSString *string = [getViewController() get_pasteboard_text: nil];
    if(string){
        char_u *str = (char_u*)[string UTF8String];
        int len = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        if (str)
        {
            clip_yank_selection(type, str, len, cbd);
        }
    }
//    printf("%s\n",__func__);  
}

    void
clip_mch_set_selection(VimClipboard *cbd)
{

    NSLog(@"set");
    NSLog(@"%d",State);
    //printf("%s\n",__func__);  
    long	scrapSize;
    int		type;
    char_u	*str = NULL;
    if (!cbd->owned)
        return;
    clip_get_selection(cbd);

    /*
     * Once we set the clipboard, lose ownership.  If another application sets
     * the clipboard, we don't want to think that we still own it.
     */
    cbd->owned = FALSE;
    type = clip_convert_selection(&str, (long_u *)&scrapSize, cbd);
    if (type >= 0)
    {
        [getViewController() handle_select: [NSString stringWithUTF8String:str]];
    }
    vim_free(str);
}

   void
clip_mch_lose_selection(VimClipboard *cbd)
{
    NSLog(@"lose");
//    printf("%s\n",__func__);  
}

    int
clip_mch_own_selection(VimClipboard *cbd)
{
//    printf("%s\n",__func__);  
    return OK;
}


// -- Input Method ----------------------------------------------------------

#if defined(USE_IM_CONTROL)

    void
im_set_position(int row, int col)
{
//    printf("%s\n",__func__);  
}


    void
im_set_control(int enable)
{
//    printf("%s\n",__func__);  
}


    void
im_set_active(int active)
{
//    printf("%s\n",__func__);  
}


    int
im_get_status(void)
{
//    printf("%s\n",__func__);  
}

#endif // defined(USE_IM_CONTROL)





// -- Unsorted --------------------------------------------------------------



/*
 * Adjust gui.char_height (after 'linespace' was changed).
 */
    int
gui_mch_adjust_charheight(void)
{
//    printf("%s\n",__func__);  
    return OK;
}


    void
gui_mch_beep(void)
{
//    printf("%s\n",__func__);  
}



#ifdef FEAT_BROWSE
/*
 * Pop open a file browser and return the file selected, in allocated memory,
 * or NULL if Cancel is hit.
 *  saving  - TRUE if the file will be saved to, FALSE if it will be opened.
 *  title   - Title message for the file browser dialog.
 *  dflt    - Default name of file.
 *  ext     - Default extension to be added to files without extensions.
 *  initdir - directory in which to open the browser (NULL = current dir)
 *  filter  - Filter for matched files to choose from.
 *  Has a format like this:
 *  "C Files (*.c)\0*.c\0"
 *  "All Files\0*.*\0\0"
 *  If these two strings were concatenated, then a choice of two file
 *  filters will be selectable to the user.  Then only matching files will
 *  be shown in the browser.  If NULL, the default allows all files.
 *
 *  *NOTE* - the filter string must be terminated with TWO nulls.
 */
    char_u *
gui_mch_browse(
    int saving,
    char_u *title,
    char_u *dflt,
    char_u *ext,
    char_u *initdir,
    char_u *filter)
{
//    printf("%s\n",__func__);

    NSLog(@"title: %s", title);
    NSString *dir = [NSString stringWithFormat:@"%s", initdir];
    NSString *file = [NSString stringWithFormat:@"%s", dflt];
    NSString *path = [dir stringByAppendingString:file];

    NSLog(@"path: %@",path);
    NSURL *url = [NSURL fileURLWithPath:path];

    if (saving) [getViewController() showShareSheetForURL:url mode:@"Share"];
    else {
        [getViewController() showFileBrowser:url];
        // we return NULL here, and will open the file in VimViewController.swift
        // for user interface / asynchronous response reasons
    }
    return NULL;
}

/* When we close a buffer that was loaded from iOS, we need to
 release the file permissions and erase it from the list. */
void
gui_mch_close_buf(char_u *title)
{
    NSString* path = [NSString stringWithFormat:@"%s", title];
    NSURL *url = [NSURL fileURLWithPath:path];
    [getViewController() releaseFile:url];
}

#endif /* FEAT_BROWSE */



    int
gui_mch_dialog(
    int		type,
    char_u	*title,
    char_u	*message,
    char_u	*buttons,
    int		dfltbutton,
    char_u	*textfield,
    int         ex_cmd)     // UNUSED
{
//    printf("%s\n",__func__);
    
    NSString *bt = [NSString stringWithFormat:@"%s", buttons];

    if([bt isEqualToString:@"Activity"]) {
        NSString *path = [NSString stringWithFormat:@"%s", message];
        NSURL *url = [NSURL fileURLWithPath:path];
        
        [getViewController() showShareSheetForURL:url mode:@"Activity"];
    } else if([bt isEqualToString:@"Import"]) {
        
    }
    NSLog(@"Confirm title %s", title);
    NSLog(@"Confirm message %s", message);
    NSLog(@"Confirm buttons %s", buttons);
    NSLog(@"Confirm textfield %s", textfield);
    return 4;
}


    void
gui_mch_flash(int msec)
{
//    printf("%s\n",__func__);  
    
}


guicolor_T
gui_mch_get_color(char_u *name)
{
    int i;
    int r, g, b;
    
    
    typedef struct GuiColourTable
    {
        char	    *name;
        guicolor_T     colour;
    } GuiColourTable;
    
    static GuiColourTable table[] =
    {
        {"Black",       RGB(0x00, 0x00, 0x00)},
        {"DarkGray",    RGB(0xA9, 0xA9, 0xA9)},
        {"DarkGrey",    RGB(0xA9, 0xA9, 0xA9)},
        {"Gray",        RGB(0xC0, 0xC0, 0xC0)},
        {"Grey",        RGB(0xC0, 0xC0, 0xC0)},
        {"LightGray",   RGB(0xD3, 0xD3, 0xD3)},
        {"LightGrey",   RGB(0xD3, 0xD3, 0xD3)},
        {"Gray10",      RGB(0x1A, 0x1A, 0x1A)},
        {"Grey10",      RGB(0x1A, 0x1A, 0x1A)},
        {"Gray20",      RGB(0x33, 0x33, 0x33)},
        {"Grey20",      RGB(0x33, 0x33, 0x33)},
        {"Gray30",      RGB(0x4D, 0x4D, 0x4D)},
        {"Grey30",      RGB(0x4D, 0x4D, 0x4D)},
        {"Gray40",      RGB(0x66, 0x66, 0x66)},
        {"Grey40",      RGB(0x66, 0x66, 0x66)},
        {"Gray50",      RGB(0x7F, 0x7F, 0x7F)},
        {"Grey50",      RGB(0x7F, 0x7F, 0x7F)},
        {"Gray60",      RGB(0x99, 0x99, 0x99)},
        {"Grey60",      RGB(0x99, 0x99, 0x99)},
        {"Gray70",      RGB(0xB3, 0xB3, 0xB3)},
        {"Grey70",      RGB(0xB3, 0xB3, 0xB3)},
        {"Gray80",      RGB(0xCC, 0xCC, 0xCC)},
        {"Grey80",      RGB(0xCC, 0xCC, 0xCC)},
        {"Gray90",      RGB(0xE5, 0xE5, 0xE5)},
        {"Grey90",      RGB(0xE5, 0xE5, 0xE5)},
        {"White",       RGB(0xFF, 0xFF, 0xFF)},
        {"DarkRed",     RGB(0x80, 0x00, 0x00)},
        {"Red",         RGB(0xFF, 0x00, 0x00)},
        {"LightRed",    RGB(0xFF, 0xA0, 0xA0)},
        {"DarkBlue",    RGB(0x00, 0x00, 0x80)},
        {"Blue",        RGB(0x00, 0x00, 0xFF)},
        {"LightBlue",   RGB(0xAD, 0xD8, 0xE6)},
        {"DarkGreen",   RGB(0x00, 0x80, 0x00)},
        {"Green",       RGB(0x00, 0xFF, 0x00)},
        {"LightGreen",  RGB(0x90, 0xEE, 0x90)},
        {"DarkCyan",    RGB(0x00, 0x80, 0x80)},
        {"Cyan",        RGB(0x00, 0xFF, 0xFF)},
        {"LightCyan",   RGB(0xE0, 0xFF, 0xFF)},
        {"DarkMagenta", RGB(0x80, 0x00, 0x80)},
        {"Magenta",	    RGB(0xFF, 0x00, 0xFF)},
        {"LightMagenta",RGB(0xFF, 0xA0, 0xFF)},
        {"Brown",       RGB(0x80, 0x40, 0x40)},
        {"Yellow",      RGB(0xFF, 0xFF, 0x00)},
        {"LightYellow", RGB(0xFF, 0xFF, 0xE0)},
        {"SeaGreen",    RGB(0x2E, 0x8B, 0x57)},
        {"Orange",      RGB(0xFF, 0xA5, 0x00)},
        {"Purple",      RGB(0xA0, 0x20, 0xF0)},
        {"SlateBlue",   RGB(0x6A, 0x5A, 0xCD)},
        {"Violet",      RGB(0xEE, 0x82, 0xEE)},
    };
    
    /* is name #rrggbb format? */
    if (name[0] == '#' && STRLEN(name) == 7)
    {
        r = hex_digit(name[1]) * 16 + hex_digit(name[2]);
        g = hex_digit(name[3]) * 16 + hex_digit(name[4]);
        b = hex_digit(name[5]) * 16 + hex_digit(name[6]);
        if (r < 0 || g < 0 || b < 0)
            return INVALCOLOR;
        return RGB(r, g, b);
    }
    
    for (i = 0; i < ARRAY_LENGTH(table); i++)
    {
        if (STRICMP(name, table[i].name) == 0)
            return table[i].colour;
    }
    
    /*
     * Last attempt. Look in the file "$VIMRUNTIME/rgb.txt".
     */
    {
#define LINE_LEN 100
        FILE	*fd;
        char	line[LINE_LEN];
        char_u	*fname;
        
        fname = expand_env_save((char_u *)"$VIMRUNTIME/rgb.txt");
        if (fname == NULL)
            return INVALCOLOR;
        
        fd = fopen((char *)fname, "rt");
        vim_free(fname);
        if (fd == NULL)
            return INVALCOLOR;
        
        while (!feof(fd))
        {
            int	    len;
            int	    pos;
            char    *color;
            
            fgets(line, LINE_LEN, fd);
            len = STRLEN(line);
            
            if (len <= 1 || line[len-1] != '\n')
                continue;
            
            line[len-1] = '\0';
            
            i = sscanf(line, "%d %d %d %n", &r, &g, &b, &pos);
            if (i != 3)
                continue;
            
            color = line + pos;
            
            if (STRICMP(color, name) == 0)
            {
                fclose(fd);
                return (guicolor_T)RGB(r, g, b);
            }
        }
        
        fclose(fd);
    }
    
    
    return INVALCOLOR;
}



/*
 * Return the RGB value of a pixel as long.
 */
    long_u
gui_mch_get_rgb(guicolor_T pixel)
{
//    printf("%s\n",__func__);  
    
    // This is only implemented so that vim can guess the correct value for
    // 'background' (which otherwise defaults to 'dark'); it is not used for
    // anything else (as far as I know).
    // The implementation is simple since colors are stored in an int as
    // "rrggbb".
    return pixel;
}


/*
 * Get the screen dimensions.
 * Understandably, Vim doesn't quite like it when the screen size changes
 * But on the iOS the screen is rotated quite often. So let's just pretend
 * that the screen is actually square, and large enough to contain the
 * actual screen in both portrait and landscape orientations.
 */
    void
gui_mch_get_screen_dimensions(int *screen_w, int *screen_h)
{
    CGSize size = [getView() bounds].size;
    
    
//    CGSize appSize = [[UIScreen mainScreen] applicationFrame].size;
    int largest_dimension = MAX((int)size.width, (int)size.height);
    *screen_w = largest_dimension;
    *screen_h = largest_dimension;
}


/*
 * Return OK if the key with the termcap name "name" is supported.
 */
    int
gui_mch_haskey(char_u *name)
{
//    printf("%s\n",__func__);  
    return OK;
}


/*
 * Iconify the GUI window.
 */
    void
gui_mch_iconify(void)
{
//    printf("%s\n",__func__);  
    
}


#if defined(FEAT_EVAL) || defined(PROTO)
/*
 * Bring the Vim window to the foreground.
 */
    void
gui_mch_set_foreground(void)
{
//    printf("%s\n",__func__);  
}
#endif



    void
gui_mch_set_shellsize(
    int		width,
    int		height,
    int		min_width,
    int		min_height,
    int		base_width,
    int		base_height,
    int		direction)
{
//    printf("%s\n",__func__);
//    CGSize layerSize = CGLayerGetSize(gui_ios.layer);
//    gui_resize_shell(layerSize.width, layerSize.height);
}


/*
 * Set the position of the top left corner of the window to the given
 * coordinates.
 */
    void
gui_mch_set_winpos(int x, int y)
{
//    printf("%s\n",__func__);  
}


/*
 * Get the position of the top left corner of the window.
 */
    int
gui_mch_get_winpos(int *x, int *y)
{
//    printf("%s\n",__func__);  
    return OK;
}


    void
gui_mch_set_text_area_pos(int x, int y, int w, int h)
{
//    printf("%s\n",__func__);  
}



#ifdef FEAT_TITLE
/*
 * Set the window title and icon.
 * (The icon is not taken care of).
 */
    void
gui_mch_settitle(char_u *title, char_u *icon)
{
//    int length = STRLEN(title);
//    NSLog(@"%s\n",__func__);
//    NSLog(@"Title %i", length);
}
#endif



    void
gui_mch_toggle_tearoffs(int enable)
{
//    printf("%s\n",__func__);  
}



    void
gui_mch_enter_fullscreen(int fuoptions_flags, guicolor_T bg)
{
//    printf("%s\n",__func__);  
}


    void
gui_mch_leave_fullscreen()
{
//    printf("%s\n",__func__);  
}


    void
gui_mch_fuopt_update()
{
//    printf("%s\n",__func__);  
}





#if defined(FEAT_SIGN_ICONS)
    void
gui_mch_drawsign(int row, int col, int typenr)
{
//    printf("%s\n",__func__);  
}

    void *
gui_mch_register_sign(char_u *signfile)
{
//    printf("%s\n",__func__);  
   return NULL;
}

    void
gui_mch_destroy_sign(void *sign)
{
//    printf("%s\n",__func__);  
}

#endif // FEAT_SIGN_ICONS



// -- Balloon Eval Support ---------------------------------------------------

#ifdef FEAT_BEVAL

    BalloonEval *
gui_mch_create_beval_area(target, mesg, mesgCB, clientData)
    void	*target;
    char_u	*mesg;
    void	(*mesgCB)__ARGS((BalloonEval *, int));
    void	*clientData;
{
//    printf("%s\n",__func__);  

    return NULL;
}

    void
gui_mch_enable_beval_area(beval)
    BalloonEval	*beval;
{
//    printf("%s\n",__func__);  
}

    void
gui_mch_disable_beval_area(beval)
    BalloonEval	*beval;
{
//    printf("%s\n",__func__);  
}

/*
 * Show a balloon with "mesg".
 */
    void
gui_mch_post_balloon(beval, mesg)
    BalloonEval	*beval;
    char_u	*mesg;
{
//    printf("%s\n",__func__);  
}

#endif // FEAT_BEVAL

