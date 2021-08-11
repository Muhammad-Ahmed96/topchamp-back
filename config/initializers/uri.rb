module URI
    def self.escape(arg)
        CGI.escape(arg)
    end
end