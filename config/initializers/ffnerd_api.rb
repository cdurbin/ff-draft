module Request

  def request_service(service, api_key, extras = [])
    # Bug in FFN API - if a '/' is missing it does not use the API key
    url = service_url(service, api_key, extras) << '/'
    JSON.parse(open(url).read)
  end

end
