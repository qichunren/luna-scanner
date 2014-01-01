require "sinatra/base"

module LunaScanner
  class Web < Sinatra::Base
    $scan_hosts = Array.new

    enable :inline_templates

    not_found do
      "Sir, I don't understand what you mean."
    end

    before do
      @local_ip ||= LunaScanner.local_ip
    end

    get '/' do
      @start_ip = Util.begin_ip @local_ip if params[:start_ip].to_s.length == 0
      @end_ip = Util.end_ip @local_ip if params[:end_ip].to_s.length == 0
      erb :index
    end

    post '/scan' do
      redirect "/" if !Util.ip_valid?(params[:start_ip]) || !Util.ip_valid?(params[:end_ip])

      @start_ip = params[:start_ip]
      @end_ip = params[:end_ip]

      @ip_range = Util.ip_range(params[:start_ip], params[:end_ip])

      scanner = LunaScanner::Scanner.new(100, params[:start_ip], params[:end_ip])


      100.times do

      end
      erb :index
    end

  end
end

__END__

@@ layout
<html>
<head>
<title>Luna scanner</title>
<style type='text/css'>
.table td {
border:1px solid #BDBDBD;
}
</style>
</head>
<body>
<h1>Luna scanner</h1>
Local IP: <%= @local_ip %>
<%= yield %>
<footer></footer>
</body>
</html>

@@ index
<div id='scan_form'>
<form action='/scan' method='POST'>
From <input type='text' name='start_ip' value="<%= @start_ip %>" /> to <input type='text' name='end_ip' value="<%= @end_ip %>" />
<input type='submit' class='btn'/>
</form>
</div>

<div id='scan_result'>
<% if @ip_range && @ip_range.size > 0 %>
<table class='table'>
<thead>
<tr>
  <th>Select</th>
  <th>Sequence</th>
  <th>IP</th>
  <th>Status</th>
  <th>Operation</th>
</tr>
</thead>
<tbody>
<% @ip_range.each_with_index do |ip, index| %>
<tr>
<td style='text-align:center'>
  <input type='checkbox' />
</td>
<td style='text-align:center'><%= index + 1 %></td>
<td><%= ip %></td>
<td></td>
<td></td>
</tr>
<% end %>
</tbody>
</table>
<% end %>
</div>