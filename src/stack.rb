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
@stack_api = "https://stackrecord.com/api/v1/"

# PREDEFINED VARS
@def_user 		=	""						# Loaded user
@def_token 		=   ""						# Loaded token
@def_repo 		=	""						# Loaded repository
@def_version 	= 	""						# Loaded version of release

@def_dir 		=	"users/"				# User directory

@cur_info 		=	""						# Is:: (username/repository)


require 'yaml'
require 'fileutils'
require 'net/http'
require 'json'

# Don't bypass, it will break :(
def is_loged
	if @def_user == ""
		puts "ERROR: You have to login first."
		logged = "0"
		stack_main
	else
		logged = "1"
	end
	logged
end

# Is repository set
def is_repo
	if @def_repo == ""
		puts "ERROR: You have to set a repository first."
		repo = "0"
	else
		repo = "1"
	end
	repo
end

def is_version
	if @def_version == ""
		puts "ERROR: You have to set a version first."
		version = "0"
	else
		version = "1"
	end
	version
end

def stack_unset_vers
	puts "Version " + @def_version + "@" + @def_repo + " not in use anymore."
	puts "Use --version or --v to list and set version."
	@def_version = ""
	@cur_info = "(" + @def_user + "/" + @def_repo + ")"

	stack_main
end

def stack_set_vers(version)
	#puts "Loading version for repository " + @def_use + "@" + @def_repo + "/" + version
	@def_version = version
	@cur_info = "(" + @def_user + "/" + @def_repo + "/" + @def_version + ")"
	puts "Version loaded. Won't work if version is not available."
	stack_main 
end

def stack_set_repo(repo)
	puts "Loading repository ..."
	@def_repo = repo
	@cur_info = "(" + @def_user + "/" + @def_repo + ")"
	puts "Repository loaded. Won't work if repository is not available."

	stack_main
end

def stack_unset_repo
	puts "Repository " + @def_repo + " not in use anymore."
	puts "Use --list or --set to list and set a repository."
	@def_repo = ""
	@cur_info = "(" + @def_user + ")"

	stack_main
end

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
	puts @stack + " --ops 			| operation menu"
	puts @stack + " --login {user} 		| login to account"
	puts @stack + " --logout			| logout from session"
	puts @stack + " --create {user} {token} 	| create new user"
	puts @stack + " --exit			| exit stack-cli"
	puts "'" + @stack + "' not mandatory"
	stack_main
end

# Print operators menu
def stack_operators
	puts "# USE operators"
	puts @stack + " --use {repository}	| set repository in use (++use to unset)"
	puts @stack + " --v {version}		| set version in use (++v to unset)"
	puts "# REPOSITORY operators"
	puts @stack + " --list			| get repositories"
	puts @stack + " --new 			| create a new repository"
	puts @stack + " --deleterepo {repositroy} | to delete a repository"
	puts @stack + " --info 			| to get current repository info"
	puts "# VERSION operators"
	puts @stack + " --version 		| display all versions from repository"
	puts @stack + " --newversion 		| create a new version"
	puts @stack + " --deleteverion {version}  | delete a version from repository"
	puts "# CHANGELOG operators"
	puts @stack + " --changelist 		| display all changelog from a version"
	puts @stack + " --change 			| add a new change to a version"
	puts @stack + " --changeremove 		| *delete a change from a version"
	puts "'" + @stack + "' not mandatory"
	stack_main
end

##########################################################
# FUNCS: HELP
##########################################################
# Login
def stack_login(user) 
	if File.exist?(@def_dir + user + '/info.yaml')
		puts "Loading user ...."
		user_file = YAML.load_file(@def_dir + user + '/info.yaml')
	else
		puts "ERROR: Create an offline data first using --create"
		stack_main
		return
	end

	@def_user = user # Set this->user in use
	@def_token = user_file['token']
	@cur_info = "(" + @def_user + ")"

	puts "Current user: " + @def_user
	puts "User loaded."
	puts "Use --ops to get list of user functions"

	stack_main
end

# Logout
def stack_logout()
	@def_user = "" # Set user to none
	@cur_info = ""
	puts "User logout completed."
	stack_main
end

# Create a new user-file
def stack_create(user, token)
	puts "Creating user directory @ users/" + user
	FileUtils::mkdir_p 'users/' + user
	
	puts "Your data is:"
	create = { "name" => user, "token" => token }
	puts create

	puts "Writing data..."
	File.open("users/" + user + "/info.yaml", "w") {|f| f.write create.to_yaml }

	puts "User created. You may login with --login " + user + "."
	stack_main
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

	stack_main
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

	if hash.member?("error")
		puts "Total releases:   0"
	else
		puts "Total releases:   " + hash.count.to_s
	end
	puts "Available releases"
	puts "-"
	puts "Note: <v> is additional char and not displayed over API."

	if hash.member?("error")
		puts "Repository empty."
		stack_main
		return
	end

	hash.each do |child|
		puts "v" + child['commit_rel_version'] + " | " + child['commit_rel_name'] + " | " + child['commit_rel_created']
	end
	stack_main
	return
end

def stack_get_commits(repository, version) # API/change/get/{username}/{repository_name}/{version}
	call 	= @stack_api + "change/get/" + @def_user + "/" + repository + "/" + version

	result  = Net::HTTP.get(URI.parse(call))
	hash    = JSON.parse(result)

	stack_get_info(repository)
	puts "Getting changes for repository @ " + repository
	puts "---------------------------------"

		hash.each do |child|
				puts "v" + child['release']['version'].to_s
				puts child['release']['line']
		end
		stack_main
		return

	#end
end
##########################################################
# FUNCS: OPERATIONS END
##########################################################

##########################################################
# FUNCS: OPERATIONS (SET)
##########################################################
def stack_new_repository(repository) # API/repository/create/{username}/{repository_name}
	call	= @stack_api + "repository/create/" + @def_user + "/" + repository + "?apitoken=" + @def_token

	result  = Net::HTTP.get(URI.parse(call))
	hash 	= JSON.parse(result)

	#puts hash

	puts "Creating or rebuilding an old repository " + @def_user + "@" + repository
	puts "Repository available @ https://stackrecord.com/" + @def_user + "/" + repository
	puts "---------------------------------"

	stack_get_info(repository)
end

def stack_delete_repository(repository) # API/repository/delete/{username}/{repository_name}
	puts "Are you sure you want to delete repository " + repository + "? This will permanently delete the repository and versions from our database."
	print "(Y)es / (N)o "
	del_repository = STDIN.gets.chomp.downcase

	puts case del_repository
		when "y"
			if @def_repo == repository
				@def_repo = ""
				@cur_info = "(" + @def_user + ")"
			end

				# Deleting procedure
				call 	= @stack_api + "repository/delete/" + @def_user + "/" + repository + "?apitoken=" + @def_token
				result 	= Net::HTTP.get(URI.parse(call))
				hash 	= JSON.parse(result)

				if hash.member?("error") 
					puts "ERROR: " + hash['message']
					stack_main
				else
					puts "Repository " + @def_user + "@" + repository + " removed."
					stack_main
				end

		when "n"
			puts "Repository not removed."
			stack_main
		end
end

def stack_set_version(repository, version) # API/commit/new/{username}/{repository}/{version}
	call 	= @stack_api + "commit/new/" + @def_user + "/" + repository + "/" + version + "?apitoken=" + @def_token

	#puts call

	result  = Net::HTTP.get(URI.parse(call))
	hash    = JSON.parse(result)

	puts "Creating a new version or rebuilding an old one"
	puts @def_user + '@' + repository + "/" + version
	puts "---------------------------------"

	stack_get_versions(repository)
end

def stack_delete_version(repository, version) # API/commit/remove/{username}/{repository}/{version}
	call 	= @stack_api + "commit/remove/" + @def_user + "/" + repository + "/" + version + "?apitoken=" + @def_token

	result  = Net::HTTP.get(URI.parse(call))
	hash    = JSON.parse(result)

	puts "Deleting a version from repositry ..."
	puts @def_user + '@' + repository + "/" + version
	puts "---------------------------------"
	puts "Version / release deleted."

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
	#puts hash

	stack_get_commits(repository, version) 
end

def stack_main
puts
print ">" + @cur_info + ":"
@cl_operator = STDIN.gets.chomp.split(" ")

	puts case @cl_operator[0]
	# BASIC ARGS
	when "--help"
		stack_help
	when "--ops"
		stack_operators
	when "--login"
		stack_login(@cl_operator[1])
	when "--logout"
		stack_logout
	when "--create"
		stack_create(@cl_operator[1], @cl_operator[2])
	when "--exit"
		print "Come back again! Visit us @ stackrecord.com"
		abort


	# OPERATION ARGS
	when "--v" # Set version
		if is_loged == "1"
			if is_repo == "1"
				stack_set_vers(@cl_operator[1])
			end
		end
	when "++v" # Unset version
		stack_unset_vers

	when "--use" # Set repository
		if is_loged == "1"
			stack_set_repo(@cl_operator[1])
		end
	when "++use" # Unset repository
		stack_unset_repo

	# REPO ARGS
	# --list (to list repositories)
	# --new (to create a repository)
	# --deleterepo (to delete a repository)
	when "--list"
		if is_loged == "1"
			stack_get_list(@def_user)
		end
	when "--new"
		if is_loged == "1"
			stack_new_repository(@cl_operator[1])
		end
	when "--deleterepo"
		if is_loged == "1"
			stack_delete_repository(@cl_operator[1])
		end
	when "--info"
		if is_loged == "1"
			if is_repo == "1"
				stack_get_info(@def_repo)
			end
		end

	# VERSION ARGS
	# --version (to list versions)
	# --newversion (to create a version)
	# --deleteversion (to delete version)
	when "--version"
		if is_repo == "1"
			stack_get_versions(@def_repo)
		end
	when "--newversion"
		if is_loged == "1"
			if is_repo == "1"
				stack_set_version(@def_repo, @cl_operator[1]) # Create a new version
			end
		end
	when "--deleteversion"
		if is_loged == "1"
			if is_repo == "1"
				stack_delete_version(@def_repo, @cl_operator[1]) # Delete a version/release
			end
		end


	# CHANGES ARGS
	# --changelist (to list all changelog data for a version)
	# --change (to create a new change)
	# --changeremove (to remove a change from a version)
	when "--changelist"
		if is_loged == "1"
			if is_repo == "1"
				if is_version == "1"
					stack_get_commits(@def_repo, @def_version)
				end
			end
		end

	when "--change"
		if is_loged == "1"
			if is_repo == "1"
				if is_version == "1"
					stack_set_commit(@def_repo, @def_version)
				end
			end
		end
	else
		stack_main


	end
end

stack_header
stack_help

stack_main