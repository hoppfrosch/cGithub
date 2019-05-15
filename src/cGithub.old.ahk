#include JSON\JSON.ahk
#include log4ahk\log4ahk.ahk
#include log4ahk\callstack\callstack.ahk

; ===============================================================================================================================
; Title .........: github
; AHK Version ...: 1.1.22.06 x32 Unicode
; Win Version ...: Windows 7 Professional x64 SP1
; Description ...: Implementation of the Github Rest-API v3(https://developer.github.com/v3/)
; Version .......: v 0.0.1; 
; Modified ......: 2015.09.18
; Author(s) .....: hoppfrosch@gmx.de
; ===============================================================================================================================
class github {
; ******************************************************************************************************************************************
/*
	Class: github
		Implementation of the Github Rest-API v3 (https://developer.github.com/v3/)

	Author(s):
	<hoppfrosch at hoppfrosch@gmx.de>

	About: License
	This program is free software. It comes without any warranty, to the extent permitted by applicable law. You can redistribute 
	it and/or modify it under the terms of the Do What The Fuck You Want To Public License, Version 2, as published by Sam Hocevar. 
	See <WTFPL at http://www.wtfpl.net/> for more details.
*/
	_version := "0.0.4"
	static http:=[]
	
	__New( name := "", email := "", token := "", baseurl := "https://api.github.com"){
	
		logger := new log4ahk()
		logger.trace(">(name=(" name "), email=(" email "), token=(" token "), baseurl=(" baseurl ")) (version: " this._version ")")
			
		this.userdata := new this.userdata(name, email)
		this.access := new this.access(token, baseurl)
		this.issues := new this.issues(this.access)
		this.orgs := new this.orgs(this.access)
		this.orgs.members := new this.orgs.members(this.access)
		this.repos := new this.repos(this.access)
		this.users := new this.users(this.access)
		this.misc := new this.misc(this.access)
		
		logger.trace("<(name=(" name "), email=(" email "), token=(" token "), baseurl=(" baseurl "))")
		
		return this
	}

	version[] {
	/* ---------------------------------------------------------------------------------------
	Property: version [get]
	Get the version of the class (including versions of the subclasses as an object
	*/
		get {
			ret := Object()
			ret["github"] := this._version
			ret["github.access"] := this.access._version
			ret["github.misc"] := this.repos._version
			ret["github.userdata"] := this.userdata._version
			ret["github.issues"] := this.issues._version
			ret["github.orgs"] := this.orgs._version
			ret["github.orgs.members"] := this.orgs.members._version
			ret["github.repos"] := this.repos._version
			ret["github.users"] := this.users._version
			ret["github.misc"] := this.misc._version
			
			return ret
		}
	}

	class access {
; ********************************************************************************************************************************
/*
	Class: access
		Internal Helper class of github. Communication with https://api.github.com using WinHttpRequest COM Object

	Authentication on http://api.github.com is done via github acces token (https://help.github.com/articles/creating-an-access-token-for-command-line-use/)
*/
		_version := "0.1.0"

		/* ---------------------------------------------------------------------------------------
		Method: __New
			Constructor (*INTERNAL*)

		Parameters:
			token - github access token  (https://help.github.com/articles/creating-an-access-token-for-command-line-use/)
			baseurl - baseurl to github api (Optional - Default: "https://api.github.com")

		Returns:
			true or false, depending on current value
		*/  
		__New(token := "", baseurl := "https://api.github.com") {
			logger := new log4ahk()
			logger.trace(">(token=(" token "), baseurl=(" baseurl ")) (version: " this._version ")")
			this._token := token
			this._baseURL := baseurl
			this._http := ComObjCreate("WinHttp.WinHttpRequest.5.1")	
			logger.trace("<(token=(" token "), baseurl=(" baseurl "))")
			
			return this
		}
		
		baseurl[] {
		/* ---------------------------------------------------------------------------------------
		Property: baseurl [get]
		Get baseUrl to access Github-API
				
		Value:
		baseUrl - baseUrl to access Github-API
		*/
			get {
				return this._baseUrl
			}
		}
		http[] {
		/* ---------------------------------------------------------------------------------------
		Property: baseurl [get]
		Get HTTP-ComObj
				
		Value:
		http - HTTP-ComObj
		*/
			get {
				return this._http
			}
		}
		token[] {
		/* ---------------------------------------------------------------------------------------
		Property: token [get]
		Get accesstoken of the application
				
		Value:
		token - accesstoken of the application
		*/
			get {
				return this._token
			}
		}

		url[] {
		/* ---------------------------------------------------------------------------------------
		Property: url [get/set]
		Get/set url of the current query
						
		Value:
		url - url of the current query
		*/
			get {
				return this._url
			}
			set {
				this._url:=this.baseurl value "?access_token=" this._token
				return value
			}
		}


		send(verb,url,data:="",content_type:="application/json"){
			this.http.Open(verb,url)
			if !(data == "") {
				this.http.SetRequestHeader("Content-Typ",content_type)
			}
			this.http.send(data)
			return this.http.ResponseText
		}
	
		get() {
			logger := new log4ahk()
			logger.trace2(">(GET " this._url)
			json :=this.Send("GET",this._url)
			logger.trace2("< " json)
			return json
		}

		patch(data, content_type:="application/json") {
			json :=this.Send("PATCH",this._url, data, content_type)
			return json
		}

		post(data, content_type:="application/json") {
			json :=this.Send("POST",this._url, data, content_type)
			return json
		}
		
	}

	class userdata {
	; ********************************************************************************************************************************
	/*
		Class: access
			Internal Helper class of github. Storage of user relevant information
	*/
		_version := "0.1.0"
	
		__New(email := "", name := "") {
			logger := new log4ahk()
			logger.trace(">(email=(" email "), name=(" name ")) (version: " this._version ")")
			
			this.name  := name 
			this.email := email
			
			logger.trace("<[email=(" email "), name=(" name ")] ")
			
			return this
		}

		email[] {
		/* ---------------------------------------------------------------------------------------
		Property: email [get/set]
		Set/Get email of the user
				
		Value:
		email - email of the user
		*/
			get {
				return this._email
			}

			set {
				this._email := value
				return value
			}
		}
		name[] {
		/* ---------------------------------------------------------------------------------------
		Property: name [get/set]
		Set/Get name of the user
				
		Value:
		name - name of the user
		*/
			get {
				return this._name
			}

			set {
				this._name := value
				return value
			}
		}
	}

class issues {
	; ********************************************************************************************************************************
	/*
		Class: github.repos
			Subclass of github. Implementation of API-functionality from https://developer.github.com/v3/issues/
	*/
	/* Implementation state (https://developer.github.com/v3/issues/)
	VERB     | URL                                                  | Method
	---------+------------------------------------------------------+------------------------------------
	GET      | /issues                                              | obj.issues.getIssues()
	GET      | /user/issues                                         | _NOT_YET_IMPLEMENTED_
	GET      | /orgs/:org/issues                                    | _NOT_YET_IMPLEMENTED_
	GET      | /repos/:owner/:repo/issues                           | _NOT_YET_IMPLEMENTED_
	GET      | /repos/:owner/:repo/issues/:number                   | _NOT_YET_IMPLEMENTED_
	POST     | /repos/:owner/:repo/issues                           | _NOT_YET_IMPLEMENTED_
	PATCH    | /repos/:owner/:repo/issues/:number                   | _NOT_YET_IMPLEMENTED_
	*/
		_version := "0.1.0"
		
		__New(access) {
			
			logger := new log4ahk()
			logger.trace(">(access=(" access ")) (version: " this._version ")")
			this.access := access
			logger.trace(">")
			
			return this
		}

		getIssues() {
		/* ---------------------------------------------------------------------------------------
		Method: List repositories that are accessible to the authenticated user.
		*/
			logger := new log4ahk()
			logger.trace(">")
			this.access.url := "/issues"
			json := this.access.get()
			logger.trace("< ret: " json)
			return json
		}
	}
	
	class orgs {
	; ********************************************************************************************************************************
	/*
		Class: github.orgs
			Subclass of github. Implementation of API-functionality from https://developer.github.com/v3/orgs/
	*/
	/* Implementation state (https://developer.github.com/v3/orgs/)
	VERB     | URL                                                  | Method
	---------+------------------------------------------------------+------------------------------------
	GET      | /user/orgs                                           | obj.orgs.user_orgs()
	GET      | /organizations                                       | obj.orgs.organizations()
	GET      | /users/:username/orgs                                | _NOT_YET_IMPLEMENTED_
	GET      | /orgs/:org                                           | _NOT_YET_IMPLEMENTED_
	PATCH    | /orgs/:org                                           | _NOT_YET_IMPLEMENTED_
	*/
		_version := "0.1.0"
		
		__New(access) {
			
			logger := new log4ahk()
			logger.trace(">(access=(" access ")) (version: " this._version ")")
			this.access := access
			logger.trace("<")
			
			return this
		}

		user_orgs() {
		/* ---------------------------------------------------------------------------------------
		Method: List organizations for the authenticated user.
		*/
			logger := new log4ahk()
			logger.trace(">")
			this.access.url := "/user/orgs"
			json := this.access.get()
			logger.trace("<ret: " json)	
			return json
		}

		organizations() {
		/* ---------------------------------------------------------------------------------------
		Method: Lists all organizations, in the order that they were created on GitHub.
		*/
			logger := new log4ahk()
			logger.trace(">")
			this.access.url := "/organizations"
			json := this.access.get()
			logger.trace("<ret: " json)	
			return json
		}

		class members {
		; ********************************************************************************************************************************
		/*
			Class: github.orgs
				Subclass of github. Implementation of API-functionality from https://developer.github.com/v3/orgs/members
		*/
		/* Implementation state (https://developer.github.com/v3/orgs/members)
		VERB     | URL                                                  | Method
		---------+------------------------------------------------------+------------------------------------
		GET      | /orgs/:org/members                                   | obj.orgs.members.org_members(org)
		GET      | /orgs/:org/members/:username                         | _NOT_YET_IMPLEMENTED_
		DELETE   | /orgs/:org/members/:username                         | _NOT_YET_IMPLEMENTED_
		GET      | /orgs/:org/public_members                            | _NOT_YET_IMPLEMENTED_
		GET      | /orgs/:org/public_members/:username                  | _NOT_YET_IMPLEMENTED_
		PUT      | /orgs/:org/public_members/:username                  | _NOT_YET_IMPLEMENTED_
		DELETE   | /orgs/:org/public_members/:username                  | _NOT_YET_IMPLEMENTED_
		GET      | /orgs/:org/memberships/:username                     | _NOT_YET_IMPLEMENTED_
		PUT      | /orgs/:org/memberships/:username                     | _NOT_YET_IMPLEMENTED_
		DELETE   | /orgs/:org/memberships/:username                     | _NOT_YET_IMPLEMENTED_
		GET      | /user/memberships/orgs                               | _NOT_YET_IMPLEMENTED_
		GET      | /user/memberships/orgs/:org                          | _NOT_YET_IMPLEMENTED_
		PATCH    | /user/memberships/orgs/:org                          | _NOT_YET_IMPLEMENTED_
		*/
			_version := "0.1.0"
			
			__New(access) {
				
				logger := new log4ahk()
				logger.trace(">(access=(" access ")) (version: " this._version ")")
				this.access := access
				logger.trace("<(access=(" access "))")
				
				return this
			}
		
			org_members(org) {
			/* ---------------------------------------------------------------------------------------
			Method: List all users who are members of an organization.
			*/
				logger := new log4ahk()
				logger.trace(">(org: (" org "))")
				this.access.url := "/orgs/" org "/members"
				json := this.access.get()
				logger.trace("< ret: " json)
				return json
			}
		}
	}
	
	class repos {
	; ********************************************************************************************************************************
	/*
		Class: github.repos
			Subclass of github. Implementation of API-functionality from https://developer.github.com/v3/repos/
	*/
	/* Implementation state (https://developer.github.com/v3/repos/)
	VERB     | URL                                                  | Method
	---------+------------------------------------------------------+------------------------------------
	GET      | /user/repos                                          | obj.repos.user_repos()
	GET      | /users/:username/repos                               | _NOT_YET_IMPLEMENTED_
	GET      | /orgs/:org/repos                                     | _NOT_YET_IMPLEMENTED_
	GET      | /repositories                                        | _NOT_YET_IMPLEMENTED_
	POST     | /user/repos                                          | _NOT_YET_IMPLEMENTED_
	POST     | /orgs/:org/repos                                     | _NOT_YET_IMPLEMENTED_
	GET      | /repos/:owner/:repo                                  | _NOT_YET_IMPLEMENTED_
	PATCH    | /repos/:owner/:repo                                  | _NOT_YET_IMPLEMENTED_
	GET      | /repos/:owner/:repo/contributors                     | _NOT_YET_IMPLEMENTED_
	GET      | /repos/:owner/:repo/languages                        | _NOT_YET_IMPLEMENTED_
	GET      | /repos/:owner/:repo/tags                             | _NOT_YET_IMPLEMENTED_
	GET      | /repos/:owner/:repo/branches                         | _NOT_YET_IMPLEMENTED_
	GET      | /repos/:owner/:repo/branches/:branch                 | _NOT_YET_IMPLEMENTED_
	DELETE   | /repos/:owner/:repo                                  | _NOT_YET_IMPLEMENTED_
	*/
		_version := "0.1.0"
		
		__New(access) {
			logger := new log4ahk()
			logger.trace(">(access=(" access ")) (version: " this._version ")")
			this.access := access
			logger.trace("<")
			return this
		}

		user_repos() {
		/* ---------------------------------------------------------------------------------------
		Method: List repositories that are accessible to the authenticated user.
		*/
			logger := new log4ahk()
			logger.trace(">")
			this.access.url := "/user/repos"
			json := this.access.get()
			logger.trace("< ret: " json)
			return json
		}
	}

	class users {
	; ********************************************************************************************************************************
	/*
		Class: users
			Subclass of github. Implementation of API-functionality from https://developer.github.com/v3/users/
	*/
	/* Implementation state (https://developer.github.com/v3/users/)
	VERB     | URL                                                  | Method
	---------+------------------------------------------------------+------------------------------------
	GET      | /users/:username                                     | obj.users.getSingleUser(username)
	GET      | /user                                                | obj.users.getAuthenticatedUser()
	PATCH    | /user                                                | _NOT_YET_IMPLEMENTED_
	GET      | /users                                               | obj.users.all()
	*/
	    _version := "0.1.0"
	    
		__New(access) {
			
			logger := new log4ahk()
			logger.trace(">(access=(" access ")) (version: " this._version ")")
			
			this.access := access
			
			logger.trace("<")
			
			return this
		}

		all() {
		/* ---------------------------------------------------------------------------------------
		Method: get all Users
		*/
			logger := new log4ahk()
			logger.trace(">")
			this.access.url := "/users"
			json := this.access.get()
			logger.trace("< ret: " json)
			return json
		}

		getSingleUser(username) {
		/* ---------------------------------------------------------------------------------------
		Method: get a single user given by name
		*/
			logger := new log4ahk()
			logger.trace(">( username : " username )
			this.access.url := "/users/" username
			json := this.access.get()
			logger.trace("< ret: " json)
			return json
		}

		getAuthenticatedUser() {
		/* ---------------------------------------------------------------------------------------
		Method: get the authenticated user
		*/
			logger := new log4ahk()
			logger.trace(">")
			this.access.url := "/user"
			json := this.access.get()
			logger.trace("< ret: " json)
			return json
		}

		updateAuthenticatedUser() {
		/* ---------------------------------------------------------------------------------------
		Method: get a single user given by name
		*/
			MsgBox(A_ThisFunc  "is not yet implemented", "Not Yet Implemented",2)
			return 
			
			this.access.url := "/user"
			json := this.access.path()
			return json
		}
	}

	class misc {
	; ********************************************************************************************************************************
	/*
		Class: misc
			Subclass of github. Implementation of API-functionality from https://developer.github.com/v3/misc/
	*/
	/* Implementation state (https://developer.github.com/v3/misc/)
	VERB     | URL                                                  | Method
	---------+------------------------------------------------------+------------------------------------
	GET      | /emojis                                              | _NOT_YET_IMPLEMENTED_
	GET      | /gitignore/templates                                 | _NOT_YET_IMPLEMENTED_
	GET      | /gitignore/templates/:language                       | _NOT_YET_IMPLEMENTED_
	GET      | /licenses                                            | _NOT_YET_IMPLEMENTED_
	GET      | /licenses/:license                                   | _NOT_YET_IMPLEMENTED_
	GET      | /repos/:owner/:repo                                  | _NOT_YET_IMPLEMENTED_
	GET      | /repos/:owner/:repo/license                          | _NOT_YET_IMPLEMENTED_
	POST     | /markdown                                            | _NOT_YET_IMPLEMENTED_
	POST     | /markdown/raw                                        | obj.misc.markdown_raw(md)
	GET      | /meta                                                | _NOT_YET_IMPLEMENTED_
	GET      | /rate_limit                                          | obj.misc.rate_limit()
	*/
		_version := "0.1.0"
		
		__New(access) {
			
			logger := new log4ahk()
			logger.trace(">(access=(" access ")) (version: " this._version ")")
			
			this.access := access
			
			logger.trace("<(access=(" access "")
			
			return this
		}

		rate_limit() {
		/* ---------------------------------------------------------------------------------------
		Method: get the rate_limit (https://developer.github.com/v3/rate_limit/)
		*/
		logger := new log4ahk()
		logger.trace(">")
		this.access.url := "/rate_limit"
		json := this.access.get()
		logger.trace("<ret: " json)	
		return json
		}

		markdown_raw(md)
		{

		logger := new log4ahk()
		logger.trace(">(md:(" md "))")	
		this.access.url := "/markdown/raw"
		json := this.access.post(md,"text/x-markdown" )
		logger.trace("<ret: " json)	
		
		return json
		}
	}

} 