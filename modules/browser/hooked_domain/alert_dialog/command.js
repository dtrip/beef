//
// Copyright (c) 2006-2021 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	alert("<%= @text %>");
	beef.net.send("<%= @command_url %>", <%= @command_id %>, "text=<%= @text %>", beef.are.status_success());
});
