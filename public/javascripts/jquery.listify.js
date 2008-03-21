/*
+-----------------------------------------------------------------------+
| Copyright (c) 2006-2007 Dylan Verheul                                 |
| All rights reserved.                                                  |  
|                                                                       |
| Redistribution and use in source and binary forms, with or without    |
| modification, are permitted provided that the following conditions    |
| are met:                                                              |
|                                                                       | 
| o Redistributions of source code must retain the above copyright      |
|   notice, this list of conditions and the following disclaimer.       |
| o Redistributions in binary form must reproduce the above copyright   |
|   notice, this list of conditions and the following disclaimer in the |
|   documentation and/or other materials provided with the distribution.|
|                                                                       |
| THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS   |
| "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT     |
| LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR |
| A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT  |
| OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, |
| SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT      |
| LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, |
| DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY |
| THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT   |
| (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE |
| OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  |
|                                                                       |
+-----------------------------------------------------------------------+
*/

/**
  * jQuery listify plugin (version 1.0)
  *
  * http://www.dyve.net/jquery/?listify
  *
  * @name  listify
  * @type  jQuery
  * @param Hash    settings             settings 
  * @param String  settings[selector]   selector to use
  * @param String  settings[hoverClass] class to apply to items that the mouse is over an item
  * @param String  settings[cursorType] cursor type to change to when the mouse is over an item
  * @param Bool    settings[hideLink]   whether or not to hide the link
  */
(function($) {
	$.fn.listify = function(settings) {
		settings = $.extend({
			hoverClass: "over",
			cursorType: "pointer",
			selector: "tbody tr",
			hideLink: false
		}, settings);
		$(settings.selector, this).each(function() {
			var anchor = $("a", this);
			if (anchor.length == 1) {
				anchor = $(anchor.get(0));
				var thickbox = anchor.is(".thickbox");
				var link = anchor.attr("href");
				if (link) {
					if (settings.hideLink) {
						var text = anchor.html();
						anchor.after(text).hide();	
					}
					$(this)
						.css("cursor", settings.cursorType)
						.hover(
							function() { $(this).addClass(settings.hoverClass) },
							function() { $(this).removeClass(settings.hoverClass) }
						)
						.click(function() {
							if (thickbox) {
								anchor.click();
							} else {
								window.location.href = link;
							}
						});
				}
			}
		});
		return this;
	}
})(jQuery)
