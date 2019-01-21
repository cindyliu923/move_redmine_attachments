require 'net/https'
require 'uri'
require 'json'

@base_url = "https://redmine.your_redmine.com"
@api_token = "your_api_token"
@source_issue_id = your_source_issue_id
@target_issue_id = your_target_issue_id

def get_attachments

  url = "#{@base_url}/issues/#{@source_issue_id}.json?include=attachments"
  uri = URI.parse(url)
  req = Net::HTTP::Get.new(uri.request_uri)

  req['X-Redmine-API-Key'] = @api_token

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  response = http.request(req)
  body = response.body
  parsed_body = JSON.parse(body)
  @files = []

  parsed_body["issue"]["attachments"].each do |att|
    url = att["content_url"]
    content_type = att["content_type"]
    filename = att["filename"]

    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri.request_uri)

    req["Content-Type"] = content_type
    req['X-Redmine-API-Key'] = @api_token

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.request(req)

    # if you want to download attachments
    # open(filename, "wb") do |file|
    #   file.write(response.body)
    # end

    @files << {
      filename: filename,
      content_type: content_type,
      file: response.body
    }

  end
  puts "從#{@source_issue_id}取得檔案"

end

def get_upload_tokens

  @uploads = []

  @files.each do |f|
    url = "#{@base_url}/uploads.json"
    uri = URI.parse(url)
    req = Net::HTTP::Post.new(uri.request_uri)

    req["Content-Type"] = "application/octet-stream"
    req['X-Redmine-API-Key'] = @api_token
    req.body = f[:file]

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.request(req)
    body = response.body
    parsed_body = JSON.parse(body)
    token = parsed_body["upload"]["token"]

    @uploads << {
      "token": token, "filename": f[:filename], "content_type": f[:content_type]
    }
  end
  puts "取得tokens"

end

def upload_attachments

  payload = {
    issue: {
      "uploads": @uploads
    }
  }

  url = "#{@base_url}/issues/#{@target_issue_id}.json"
  uri = URI.parse(url)
  req = Net::HTTP::Put.new(uri.request_uri)

  req["Content-Type"] = "application/json"
  req['X-Redmine-API-Key'] = @api_token
  req.body = payload.to_json

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  response = http.request(req)

  puts "上傳檔案至#{@target_issue_id}"

end

get_attachments
get_upload_tokens
upload_attachments
