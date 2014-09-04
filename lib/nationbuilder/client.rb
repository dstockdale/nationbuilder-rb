class NationBuilder::Client

  def initialize(nation_name, api_key)
    @nation_name = nation_name
    @api_key = api_key
    @name_to_endpoint = {}
    parsed_endpoints.each do |endpoint|
      @name_to_endpoint[endpoint.name] = endpoint
    end
  end

  def parsed_endpoints
    NationBuilder::SpecParser
      .parse(File.join(File.dirname(__FILE__), 'api_spec.json'))
  end

  class InvalidEndpoint < ArgumentError; end

  def [](endpoint)
    e = @name_to_endpoint[endpoint]
    raise InvalidEndpoint.new(endpoint) if e.nil?
    e
  end

  def endpoints
    @name_to_endpoint.keys
  end

  def base_url
    @base_url ||=
      NationBuilder::URL_TEMPLATE.gsub(':nation_name', @nation_name)
  end

  def call(endpoint_name, method_name, args={})
    endpoint = self[endpoint_name]
    method = endpoint[method_name]
    nonmethod_args = method.nonmethod_args(args)
    method_args = method.method_args(args)
    method.validate_args(method_args)
    url = NationBuilder.generate_url(base_url, method.uri, method_args)

    request_args = {
      header: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      },
      query: {
        access_token: @api_key
      }
    }

    if method.http_method == :get
      request_args[:query] = nonmethod_args
    else
      request_args[:body] = JSON(nonmethod_args)
    end

    HTTPClient.send(method.http_method, url, request_args)
  end

  class ServerResponseError < StandardError; end

  def print_all_descriptions
    endpoints.each do |endpoint_name|
      self.print_description(endpoint_name)
      puts
    end
  end

  def print_description(endpoint_name)
    endpoint_name = endpoint_name.to_sym

    unless self.endpoints.include?(endpoint_name)
      puts "Invalid endpoint name: #{endpoint_name}"
      puts
      puts "Valid endpoint names:"
      self.endpoints.each do |endpoint|
        puts "  #{endpoint}"
      end
      return
    end

    endpoint_str = "Endpoint: #{endpoint_name}"
    puts "=" * endpoint_str.length
    puts endpoint_str
    puts "=" * endpoint_str.length

    self[endpoint_name].methods.each do |method_name|
      puts
      method = self[endpoint_name][method_name]
      puts "  Method: #{method_name}"
      puts "  Description: #{method.description}"
      required_params = method.parameters.map { |p| p }
      if required_params.any?
        puts "  Required parameters: #{required_params.join(', ')}"
      end
    end
  end

end
