require "webrick"
require "webrick/httpproxy"

pch = Proc.new{|req, res|
  p [ req.request_line, res.status_line ]
}

def upstream_proxy
  if prx = ENV["http_proxy"]
    return URI.parse(prx)
  end
  return nil
end

httpd = WEBrick::HTTPProxyServer.new(
    :Port     => 10080,
    :ProxyContentHandler => pch,
    :ProxyURI => upstream_proxy
)

Signal.trap(:INT){ httpd.shutdown }
httpd.start