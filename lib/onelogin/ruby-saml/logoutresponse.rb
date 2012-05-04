module Onelogin
  module Saml
    class Logoutresponse

      def initialize(response)
        z = Zlib::Inflate.new(-Zlib::MAX_WBITS)
        @document = REXML::Document.new(z.inflate(Base64.decode64(response)))
      end

      def success?
        @success ||= begin
                       node = REXML::XPath.first(@document,
                                                 "/p:LogoutResponse/p:Status/p:StatusCode",
                                                 {"p" => "urn:oasis:names:tc:SAML:2.0:protocol"})
                       !node.nil? && node.attributes["Value"] == "urn:oasis:names:tc:SAML:2.0:status:Success"
                     end

      end
    end
  end
end
