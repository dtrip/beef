#
# Copyright (c) 2006-2021 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models
  #
  # Table stores the http requests and responses from the requester.
  #
  class Http < BeEF::Core::Model
  
    include DataMapper::Resource
    
    storage_names[:default] = 'extension_requester_http'
    
    property :id, Serial

    # The hooked browser id
    property :hooked_browser_id, Text, :lazy => false

    # The http request to perform. In clear text.
    property :request, Text, :lazy => true

    # Boolean value as string to say whether cross-domain requests are allowed
    property :allow_cross_domain, Text, :lazy => false, :default => "true"
  
    #
    # Removes a request/response from the data store
    #
    def self.delete(id)
      (print_error "Failed to remove response. Invalid response ID."; return) if id.to_s !~ /\A\d+\z/
      r = BeEF::Core::Models::Http.find(id.to_i)
      (print_error "Failed to remove response [id: #{id}]. Response does not exist."; return) if r.nil?
      r.destroy
    end
  end
end
end
end
