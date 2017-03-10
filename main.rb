require 'net/http'
require 'uri'
require 'json'

uri = URI.parse('https://www.toggl.com/api/v8/workspaces')
request = Net::HTTP::Get.new(uri)
request.basic_auth(ENV['TOGGL_API_TOKEN'], "api_token")

req_options = {
  use_ssl: uri.scheme == 'https',
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end
json_work_datas = JSON.load(response.body.force_encoding('UTF-8'))
workspaces_id = json_work_datas.first['id']

now_date = Time.now.strftime('%F')

uri = URI.parse("https://toggl.com/reports/api/v2/details?workspace_id=#{workspaces_id}&since=#{now_date}&until=#{now_date}&user_agent=api_test")
request = Net::HTTP::Get.new(uri)
request.basic_auth(ENV['TOGGL_API_TOKEN'], "api_token")

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end
json_datas = JSON.load(response.body.force_encoding('UTF-8'))



datas={}

json_datas['data'].each do |json_data|
  title = json_data['description']
  if datas[title]
    datas[title] = datas[title] + json_data['dur']
  else
    datas[title] = json_data['dur']
  end
end

datas.each do |title, data|
  name = title

  time_sec = data / 1000.0
  time_min = time_sec / 60
  time = time_min / 60
  round_time = ((time / 0.5).round) * 0.5
  puts "#{name} #{round_time}h"
end
