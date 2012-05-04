require "base64"
require "uuid"
require "zlib"
require "cgi"
require "rexml/document"
require "rexml/xpath"

module Onelogin
  module Saml
  include REXML
    class Logoutrequest
      def create(settings, params = {} )
        uuid = "_" + UUID.new.generate
        time = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
        # Create LogoutRequest root element using REXML 
        request_doc = REXML::Document.new

        root = request_doc.add_element "samlp:LogoutRequest", { "xmlns:samlp" => "urn:oasis:names:tc:SAML:2.0:protocol" }
        root.attributes['ID'] = uuid
        root.attributes['IssueInstant'] = time
        root.attributes['Version'] = "2.0"
        
        if settings.issuer != nil
          issuer = root.add_element "saml:Issuer", { "xmlns:saml" => "urn:oasis:names:tc:SAML:2.0:assertion" }
          issuer.text = settings.issuer
        end
        
        name_id = root.add_element "saml:NameID", { "xmlns:saml" => "urn:oasis:names:tc:SAML:2.0:assertion" }
        name_id.text = params

        request = ""
        request_doc.write(request)

        Logging.debug "Created LogoutRequest: #{request}"

        deflated_request  = Zlib::Deflate.deflate(request, 9)[2..-5]
        base64_request    = Base64.encode64(deflated_request)
        encoded_request   = CGI.escape(base64_request)
        params_prefix     = (settings.idp_sso_target_url =~ /\?/) ? '&' : '?'
        request_params    = "#{params_prefix}SAMLRequest=#{encoded_request}"

        params.each_pair do |key, value|
          request_params << "&#{key}=#{CGI.escape(value.to_s)}"
        end

        settings.idp_slo_target_url + request_params
      end
      
    end
  end
end
