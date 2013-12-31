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
#define DEFAULT_PRESENTATION_CSS @"body {\n\tmargin:2.4em;\n\tfont-size:2.4em;\n}"

#define TUTORIAL_PRESENTATION_CONTENT @"# MarkShown Tutorial\n\nPress 'play' in the upper right corner to start the tutorial presentation. Navigation works like Safari; swipe from right to left to go to the next slide, and left to right to go to the previous slide.\n\n\n\n## Slides\nSlides will be shown on an external display if one is available. AirPlay can be used, but mirroring must be turned on (we are working to improve this). When a slide has no presenter notes the slide text will also display on the iPhone screen for the presenter.\n\n\n\n## Slides\nSlides are separated by three blank lines, and presenter notes are separated from slides by two blank lines. This slide has presenter notes.\n\n(One blank line is just a blank line.)\n\n\n## Presenter Notes\nSlides are separated by three blank lines, and presenter notes are separated from slides by two blank lines. Each slide can have one presenter note, additional ones are currently ignored.\n\nNote: Make sure that blank lines are completely blank, spaces count.\n\n\n\n## Formatting\nMarkShown uses Markdown, a text based markup language created by [John Gruber](http://daringfireball.net/projects/markdown/). MarkShown also does [SmartyPants](http://daringfireball.net/projects/smartypants/) transformations. Basically, this app can do anything that David Loren Parsons' [Discount Markdown tool](http://www.pell.portland.or.us/~orc/Code/discount/) can do, since it uses his C code.\n\n\n\n### Headings\nHeadings are created by putting pound signs at the beginning of a line. \"Underlining\" sentences with equals signs will also create first level headings, and \"underlining\" sentences with dashes will create second level headings.\n\n#####Fifth Level Heading\nUse one pound (#) sign for a first level heading, and up to five pound signs for a fifth level heading.\n\n\n\n### Bullet Points or Lists\n* Bullet points can be created by beginning a line with an asterisk (*)\n- Bullet points can also be created by beginning a line with a dash or plus (- or +)\n+ Be sure to leave a space between paragraphs and lists\n\n#### Ordered lists\n1. Ordered lists can be made by\n2. Starting lines with numbers followed by periods\n\n\n\n### Emphasized Words\nWords can be emphasized by surrounding them with *asterisks* (*) or _underlines_ (_).\nTwo **asterisks** or __underscores__ will produce strong text\n\n\n\n### SmartyPants\nSmartyPants will generate proper characters given the ASCII shortcuts, for example:\n\n - \\(TM\\) will display as (TM)\n - \\(c\\) will display as (c)\n - \\-\\- becomes --\n - \\-\\-\\- becomes ---\n - x\\^y becomes x^y\n - 1\\/2 becomes 1/2\n\n\n\n### Discount Extensions\n - \\-\\> Centered <\\- will center text\n - `Code words` can be surrounded by single back-ticks (\\`)\n - GitHub style fenced code blocks with three back-ticks (\\`\\`\\`) can also be used, but no formating is available (yet)\n\n```\nfor (int i=0; i<length; ++i) {\n	//do something\n}\n```\n\n\n\n## Images\nImages can be loaded (presently only from the network) using the following syntax:\n\\!\\[Alt text\\]\\(http://site.tld/path/to/img.png\\)\n\n-> ![Alt text](http://christopherstoll.org/assets/blogger/2013-10-21.png) <-\n\n\n\n## Links\nLinks can be created directly in the text using a format similar to images, like [this](http://christopherstoll.org/): \\[this\\]\\(http://christopherstoll.org/\\)\n\nLinks can also be created in a like footnotes, like [this][cstoll]: \\[this\\]\\[note_name\\]\n\n\\[note_name\\]: http://christopherstoll.org\n[cstoll]: http://christopherstoll.org/\n\n\n\n### Notes About Links\nLinks can be touched on the presenter's device, but obviously not on the external display. A touched link will display on the external display and NOT on the presenter's device. Viewers of the presentation probably do not need to see web links, but it could be convenient for the presenter to be able to quickly navigate to a web page, so it is probably best to keep notes in the presenter notes; hence this design. There is a refresh button on the play screen to get the external display back to the slide.\n\n\n\n### Undo\n\nIn the edit screen changes can be undone by shaking the device, but once you leave the edit screen changes are saved.\n\n\n\n-> **The End** <-"

#endif
