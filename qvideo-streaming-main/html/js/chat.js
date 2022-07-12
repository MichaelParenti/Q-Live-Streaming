Chat = {
	controlUrl : "/chat_handler",
	bldgUrl : "/bldg_handler",

	doChatStart : function() {
		Chat.doChatGet();
		Chat.doChatSetObservers();
	},
	
	doChatSetObservers : function() {
		Event.observe($('chat_button'), 'click', Chat.doChatSay, false);
		Event.observe($('chat_entry'), 'keyup', Chat.doKeyIntercept, false);
	},

	doChatAreaDown : function() {
		var objDiv = document.getElementById("chat_area");
		objDiv.scrollTop = objDiv.scrollHeight;
	},

	doChatSay : function() {
		var objDiv = document.getElementById("chat_area");
		objDiv.scrollTop = objDiv.scrollHeight;
		if ($('chat_entry').value != '') {
			msg = $('chat_entry').value;
			msg = escape(msg);
			cbldg = $('chat_bldgroom').value;
			cbldg = escape(cbldg);
			new Ajax.Request(Chat.controlUrl, { method: 'get', parameters: 'a=2&room=' + cbldg + '&msg=' + msg, onComplete: null });
			$('chat_entry').value = '';
			$('chat_entry').focus();
		}
	},

	doChatGet : function() {
		new Ajax.PeriodicalUpdater('chat_area', Chat.controlUrl, { method: 'get',  parameters: 'a=3' });
		new Ajax.PeriodicalUpdater('bldg_area', Chat.bldgUrl, { method: 'get', parameters: 'bldg=' + $('bldg').value });
//		var pe = new Ajax.PeriodicalExecuter(Chat.doChatAreaDown, 5);
	},

	doKeyIntercept : function(e) {
		if (e.which) {
			if (e.which == Event.KEY_RETURN)
				Chat.doChatSay();

			return;
		}
		if (window.event.keyCode) {
			//$('chat_entry').value = "jane";
			if (window.event.keyCode == Event.KEY_RETURN) {
				Chat.doChatSay();
			}
			return;
		}
	}
}

Event.observe(window, 'load', Chat.doChatStart, false);

