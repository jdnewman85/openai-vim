local type CurlMethod = function(url: string, opts: table): table

local record Curl
  get: CurlMethod
  post: CurlMethod
  put: CurlMethod
  head: CurlMethod
  patch: CurlMethod
  delete: CurlMethod
  request: CurlMethod
end

return Curl
