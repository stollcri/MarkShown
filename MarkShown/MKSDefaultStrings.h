//
//  MKSDefaultStrings.h
//  MarkShown
//
//  Created by Christopher Stoll on 12/30/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#ifndef MarkShown_MKSDefaultStrings_h
#define MarkShown_MKSDefaultStrings_h

#define DEFAULT_PRESENTATION_CONTENT @"# Slide Number 1\nContent\n\n\n##Presenter Notes 1\nContent\n\n\n\n# Slide Number 2\nContent\n\n\n##Presenter Notes 2\nContent\n\n\n\n# Slide Number 3\nContent\n\n\n##Presenter Notes 3\nContent"
#define DEFAULT_PRESENTATION_CSS @"body {\n\tmargin:1.6em;\n\tfont-size:1.6em;\n}"

#define TUTORIAL_PRESENTATION_CONTENT @"# MarkShown Tutorial\n\nPress 'play' in the upper right corner to start the presentation. Swipe from right to left to go to the next slide, and left to right to go to the previous slide. If you swipe from off the left side of the screen to the right you will be taken back to the edit screen.\n\n\n\n## Slides\nSlides will be shown on the external display, if one is available. AirPlay can be used, but mirroring must be turned on. When a slide has no presenter notes the slide text will also display on the iPhone screen for the presenter.\n\n\n\n## Slides\nSlides are separated by three blank lines, and presenter notes are separated from slides by two blank lines. This slide has presenter notes.\n\n(One blank line is just a blank line.)\n\n\n## Presenter Notes\nEach slide can have one presenter note, additional ones are currently ignored.\n\nNote: Make sure that blank lines are completely blank, spaces count.\n\n\n\n## Formatting\nMarkShown uses a modified version of Markdown, a text based markup language created by John Gruber. This app will eventually support the 'official' version of Markdown, which is more feature rich.\n\n\n\n### Headings\nHeadings are created by putting pound signs at the beginning of a line.\n\n#####Fifth Level Heading\nUse one pound (#) sign for a first level heading, and up to five pound signs for a fifth level heading.\n\n\n\n### Bullet Points\n* Bullet points can be created by beginning a line with an asterisk (*)\n- Bullet points can also be created by beginning a line with a dash (-)\n\n\n\n### Italics\nTo //italicize// text surround it with two slashes like \\/\\/this\\/\\/.\n\nIf you are reading this in the edit mode you will notice the backslashes which were used to make the slashes display on the presentation.\n\n\n\n### Bold\nTo make text **bold** surround it with two asterisks like \\**this\\**.\n\nIt is possible to **embolden entire phrases** instead of just words, this is true for italics and underlines as well.\n\n\n\n### Underline\nTo __underline__ text, surround it with two underscores like \\__this\\__.\n\n\n\n### Strikethrough\n--Strikethrough-- text is presently shown in red and is made by surrounding the text with dashes, like \\--this\\--.\n\n\n\n### Undo\n\nIn the edit screen changes can be undone by shaking the device, but once you leave the edit screen changes are saved."

#endif
