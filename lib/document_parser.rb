# Sends a request to the boilerpipe server and returns the response
class DocumentParser
  def initialize
    @uri = 'https://document-parser.lateral.io'
    # @uri = 'http://0.0.0.0:8080'
    @auth = Base64.strict_encode64("lateral:#{ENV['DOCUMENT_PARSER_PW']}")
    @client = HTTPClient.new
  end

  def api(path, opts)
    @client.get "#{@uri}#{path}", opts, 'Authorization' => "Basic #{@auth}"
  end

  def sanitize(text)
    CGI.escapeHTML(ActionView::Base.full_sanitizer.sanitize(text))
  end

  def google(token, id)
    request = api '/extract-google/', id: id, token: token
    return false unless request.status == 200
    sanitize request.body
  end

  def dropbox(token, path)
    request = api '/extract-dropbox/', path: path, token: token
    return false unless request.status == 200
    sanitize request.body
  end

  def evernote(token, id)
    request = api '/extract-evernote/', id: id, token: token
    return false unless request.status == 200
    sanitize request.body
  end

  def pocket(url)
    request = api '/boilerpipe/', url: url
    return false unless request.status == 200
    sanitize request.body
  end

  def tika(url)
    request = api '/tika/', url: url
    return false unless request.status == 200
    sanitize request.body
  end
end
