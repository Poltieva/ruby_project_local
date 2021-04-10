class RequestParser
  def parse(request)
    method, path = request.lines[0].split
    true_path, params = get_params(path)
    {
      path: true_path,
      method: method,
      params: params,
      headers: parse_headers(request),
      body: parse_body(request)
    }
  end

  def get_params(path)
    params = {}
    true_path, elements = path.split("?")
    if elements
      if elements.include? "&"
        for pair in elements.split("&")
          key, value = pair.split("=")
          params[key.to_sym] = value
        end
      else
        key, value = elements.split("=")
        params[key.to_sym] = value
      end
    end
  if params.empty?
    return true_path, nil
  else
    return true_path, params
  end
end

  def parse_headers(request)
    headers = {}

    request.lines[1..-1].each do |line|
      return headers if line == "\r\n"

      header, value = line.split
      header = header.gsub(':', '').downcase.to_sym
      headers[header] = value
    end
  end

  def parse_body(request)
    body = {}
    body = JSON.parse(request[request.index('{')..-1]).transform_keys(&:to_sym) if request.include? '{'
    if body
      return body
    else
      return nil
    end
  end
end
