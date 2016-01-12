# -
# Stackrecord CLI (API v1)
# -
# Author 		: Stackrecord
# Twitter		: @stackrecordcom
# Website 		: https://stackrecord.com
# - 
# 
# #!/usr/bin/env ruby
@stack_ver = "100"
@stack 	   = "stack"
@stack_api = "https://api.stackrecord/v1/"

# PREDEFINED VARS
@def_user 		=	"stackrecord"			# Loaded user
@def_token 		=   "secret"				# Loaded token
@def_dir 		=	"users/"				# User directory

require 'yaml'
require 'fileutils'
require 'net/http'
require 'json'

# Header
def stack_header
	puts "     _             _       "
	puts "    | |           | |   	 "
	puts " ___| |_ __ _  ___| | __   "
	puts "/ __| __/ _` |/ __| |/ /	 "
	puts "\\__ \\ || (_| | (__|   <  "
	puts "|___/\\__\\__,_|\\___|_|\\_\\"

	puts "Welcome to STACKRECORD official CLI."
	puts "Use --help argument to show help."
	puts "https://stackrecord.com" + " | Version: " + @stack_ver
	puts ""
end

# Print Help menu
def stack_help
	puts @stack + " --help 			| help menu"
	puts @stack + " --login {user} 		| login to account"
	puts @stack + " --logout			| logout from session"
	puts @stack + " --create {user} {token} 	| create new user"
end

# Print operators menu
def stack_operators
	puts "# GET operators #"
	puts @stack + " --list			| get repositories"
	puts @stack + " --versions {repository} 	| list repository versions"
	puts @stack + " --commits {repository} {version}	| list commits from version"
	puts "# SET operators #"
	puts @stack + " --new {repository} 	| new repository"
	puts @stack + " --version {version} 	| new version"
	puts @stack + " --commit {version} 	| new commit in a version"
end

##########################################################
# FUNCS: HELP
##########################################################
# Login
def stack_login(user) 
	@def_user = user # Set this->user in use
	puts "Current user: " + @def_user
	puts "User loaded."
end

# Logout
def stack_logout(user)
	@def_user = "" # Set user to none
	puts "User logout completed."
end

# Create a new user-file
def stack_create(user, token)
	FileUtils::mkdir_p 'users/' + user
	
	create = { "name" => user, "token" => token }
	File.open("users/" + user + "/info.yaml", "w") {|f| f.write create.to_yaml }

	puts create
end
##########################################################
# FUNCS: HELP END
##########################################################

##########################################################
# FUNCS: OPERATIONS (GET)
##########################################################
def stack_get_list(user) # API/repository/get/{username}
	call 	= @stack_api + "repository/get/" + user
	
	result 	= Net::HTTP.get(URI.parse(call))
	hash 	= JSON.parse(result)

	puts "Available user repositories @ " + user
	puts hash['repository_list']
end

def stack_get_info(repository) # API/repository/{username}/{repository_name}
	call 	= @stack_api + "repository/" + @def_user + "/" + repository

	result  = Net::HTTP.get(URI.parse(call))
	hash 	= JSON.parse(result)

	puts "Repository owner: " + @def_user
	puts "Repository name:  " + repository
	puts "Description: 	  " + hash['repository_description']
	puts "Type: 		  " + hash['repository_type']
	puts "Created: 	  " + hash['repository_created']
end

def stack_get_versions(repository) # API/commit/get/{username}/{repository_name}
	call	= @stack_api + "commit/get/" + @def_user + "/" + repository

	result 	= Net::HTTP.get(URI.parse(call))
	hash 	= JSON.parse(result)

	stack_get_info(repository)
	puts "Total releases:   " + hash.count.to_s
	puts "Available releases"
	puts "-"

	hash.each do |child|
		puts "v" + child['commit_rel_version']
	end
end

def stack_get_commits(repository, version) # API/change/get/{username}/{repository_name}/{version}
	call 	= @stack_api + "change/get/" + @def_user + "/" + repository + "/" + version

	result  = Net::HTTP.get(URI.parse(call))
	hash    = JSON.parse(result)

	stack_get_info(repository)
	puts "Getting changes for repository @ " + repository
	puts "---------------------------------"

	#if hash['release'].has_key?('line')
	hash.each do |child|
			puts "v" + child['release']['version'].to_s
			puts child['release']['line']
	end
	#end
end
##########################################################
# FUNCS: OPERATIONS END
##########################################################

##########################################################
# FUNCS: OPERATIONS (SET)
##########################################################
def stack_set_repository(repository) # API/repository/create/{username}/{repository_name}
	call	= @stack_api + "repository/create/" + @def_user + "/" + repository + "?apitoken=" + @def_token

	result  = Net::HTTP.get(URI.parse(call))
	hash 	= JSON.parse(result)

	#puts hash

	puts "Creating or rebuilding an old one @ " + repository
	puts "Repository available @ https://stackrecord.com/" + @def_user + "/" + repository
	puts "---------------------------------"

	stack_get_info(repository)
end

def stack_set_version(repository, version) # API/commit/new/{username}/{repository}/{version}
	call 	= @stack_api + "commit/new/" + @def_user + "/" + repository + "/" + version + "?apitoken=" + @def_token

	puts call

	result  = Net::HTTP.get(URI.parse(call))
	hash    = JSON.parse(result)

	puts "Creating a new version or rebuilding an old one"
	puts @def_user + ':' + repository + " @ " + version
	puts "---------------------------------"

	stack_get_versions(repository)
end

def stack_set_commit(repository, version) # API/change/new/{username}/{repository}/{version}
	print "Please enter arbitary tag: (A)dded, (C)hanged, (D)eprecated, (R)emoved, (F)ixed: "
	@tags   = { "a" => "Added", 
				"c" => "Changed",
				"d" => "Deprecated",
				"r" => "Removed",
				"f" => "Fixed" }

	@cl_tag = STDIN.gets.chomp.downcase # Set a tag_char to lower
	@final  = @tags[@cl_tag] # Full tag (for b-e)

	print "Please enter your changelog: "
	@cl_change = STDIN.gets.chomp

	puts "------------------------------------------------"
	puts @final + ': ' + @cl_change
	puts "------------------------------------------------"

	call	= @stack_api + "change/new/" + @def_user + "/" + repository + "/" + version + "?apitoken=" + @def_token + "&tag=" + @final + "&change=" + @cl_change

	result  = Net::HTTP.get(URI.parse(URI.escape(call)))
	hash    = JSON.parse(result)
	puts hash

	stack_get_commits(repository, "all") 
end

stack_header