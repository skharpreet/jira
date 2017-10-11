require 'rubygems'
require 'jira-ruby'
require 'io/console'
args = Hash[ ARGV.flat_map{|s| s.scan(/--?([^=\s]+)(?:=([a-zA-Z0-9_ ]*))?/) } ]

if(args.empty?)
  p "-cloud=https://xxx.atlassian.net -project=abc -title=title -desc=description -type=bug/task -assignee=Harpreet Singh -email=harpreet_singh@gmail.com -p"
end

if(args["p"].nil? || args["P"].nil?)
  print "Password:"
  password = STDIN.noecho(&:gets).chop
end

jira_cloud = args['cloud']
project_name = args['project']

puts "\nStarting ..."

options = {
  :username     => "#{args['email']}",
  :password     => "#{password}",
  :site         => "#{jira_cloud}:443",
  :context_path => '',
  :auth_type    => :basic
}

begin

  client = JIRA::Client.new(options)

  project = client.Project.find("#{project_name}")

  puts "\nCreating issue now on project #{project.name}"

  issue_types = {"bug" =>1, "task" => 3}
  issue_type = issue_types[args['type']]

  issue = client.Issue.build
  issue.save({"fields"=>{"summary"=>"#{args['title']}","project"=>{"id"=>"#{project.id}"},"issuetype"=>{"id"=>"#{issue_type}"}, "description"=> "#{args['desc']}", "assignee" => {"name": "#{args['assignee']}"}}})
  issue.fetch

  puts "\nOpening now..."
  system("open", "#{jira_cloud}/browse/#{issue.key}")
rescue Exception => e
  puts "\nProblem in the api options. #{e.message}"
ensure
  puts "\nThank You!"
end
