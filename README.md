### Stackrecord
Stackrecord is Github based changelog repository API built for developers to keep changes of their project releases. We offer a free accounts for all solo developers and freelancers. You can read more about Stackrecord on our [official website](http://stackrecord.com).

### Stack-CLI
Stackrecord official repository for our [CLI](http://stackrecord.com/cli) (Command Line Interface) that connects directly to our [API](Stackrecord v1) made in Ruby. The tool is open-source and currently in beta. You can also use this tool to learn how our API work. The full documentation of our API is located [here](http://stackrecord.com/docs). Stack-CLI is based on our sister-project also made by Stackrecord for offline release note generation [Vicilog](https://github.com/dn5/vicilog).

### How it works
Our CLI is pretty simple yet fast (pure libraries). These are the steps to make your Stackrecord account works with the CLI and API back-end.  

* Register at [Stackrecord](http://stackrecord.com/signup) (or use API)
* Generate a new API token at [Stackrecord](http://stackrecord.com/login)
* Use `--create {username} {api_token}` to generate configuration file
* Use `--login {username}` to login

### Usage
The usage is divided in tree operations:

* **GET** (to get changelog data)
* **SET** (to set changelog data)
* **OTHER** (for other functions)

#### GET (Get changelog data from our API)
* `--list` (List all repositories for logged user)
* `--versions {repository}` (List relase versions for repository)
* `--commits {repository} {o:version}` (List changelog for repository; optional: version)

#### SET (Set changelog data over API)
* `--new {repository}` (Create a new repository)
* `--version {version}` (Create a new release version)
* `--commit {version}` (Create a new change in a version)

#### Other
* `--help` (Display help menu)
* `--login {username}` (Login to account) 
	* *Note: You must [register](http://stackrecord.com/signup) first*
* `--create {username} {token}` (Create a new offline login)
	* *Note: You must [register](http://stackrecord.com/signup) first*
* `--logout` (Logout from account / Use other account)

### Requirements
Stack-CLI is currently deployed over pure Ruby libraries. The `Ruby` version is `1.9.3`.

* `Ruby 1.9.3`
* `yaml`
* `fileutils`
* `net/http`
* `json` 

### Installation
You can either use this CLI as compiled stand-alone available for `Windows`, `Linux` or `Mac/OSX`, or compile this by yourself. Installation is easy, either download MASTER zip file from [GitHub repository](https://github.com/stackrecord/stack-cli) or manually clone the repository.  
  
```
cd ~
git clone https://github.com/stackrecord/stack-cli.git
chmod 777 -R stack-sli/

# Optionally, you may create a symbolic link in /usr/local/bin
```  

### Release notes

* GitHub: https://github.com/stackrecord/stack-cli/CHANGELOG.md
* Stackrecord: ~

### Support, bugs, requests, TODO
Please, if you have any critics, want to support the project, found a bug or just simply have a request, create an issue here on GitHub(https://github.com/stackrecord/stack-cli/issues)

### License
This tool is registered and distrubuted by Stackrecord[http://stackrecord.com]. It's released under the [GNU General Public v3 license](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html).