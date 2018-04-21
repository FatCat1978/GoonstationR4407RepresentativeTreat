/client/proc/authorize()
	set name = "Authorize"

	if (src.authenticating)
		return

	if (!config.enable_authentication)
		src.authenticated = 1
		return

	src.authenticating = 1

	spawn (rand(4, 18))

		src.verbs -= /client/proc/authorize
		var/account = key
		src.authenticated = account
		src << "Key authorized: Hello [html_encode(account)]!"
		src << "\blue[auth_motd]"
		src.authenticating = 0

/client/proc/beta_tester_auth()
	set name = "Tester?"
	/*if(istester(src))
		src << "\blue <B>Key accepted as beta tester</B>"
	else
		src << "\red<B>Key not accepted as beta tester. You may only observe the rounds. Please join #goonstation on irc.synirc.net and ask to be a tester if you'd like to help!</B>"
	*/
/client/proc/goonauth()
	set name = "Goon?"
	var/account = key

	src.authenticating = 1

	spawn (rand(4, 18))
		src.verbs -= /client/proc/goonauth
		src.goon = account
		src << "Key authorized: Hello [html_encode(account)]!"
		src << "\blue[auth_motd]"
		goon_key(src.ckey, account)
		src.authenticating = 0

var/goon_keylist[0]
var/list/beta_tester_keylist

/proc/beta_tester_loadfile()
	beta_tester_keylist = new/list()
	var/text = file2text("config/testers.txt")
	if (!text)
		diary << "Failed to load config/testers.txt\n"
	else
		var/list/lines = dd_text2list(text, "\n")
		for(var/line in lines)
			if (!line)
				continue

			var/tester_key = copytext(line, 1, 0)
			beta_tester_keylist.Add(tester_key)


/proc/goon_loadfile()
	var/savefile/S=new("data/goon.goon")
	S["key[0]"] >> goon_keylist
	log_admin("Loading goon_keylist")
	if (!length(goon_keylist))
		goon_keylist=list()
		log_admin("goon_keylist was empty")

/proc/goon_savefile()
	var/savefile/S=new("data/goon.goon")
	S["key[0]"] << goon_keylist

/proc/goon_key(key as text,account as text)
	var/ckey=ckey(key)
	if (!goon_keylist.Find(ckey))
		goon_keylist.Add(ckey)
	goon_keylist[ckey] = account
	goon_savefile()

/proc/isgoon(X)
	if (istype(X,/mob)) X=X:ckey
	if (istype(X,/client)) X=X:ckey
	if ((ckey(X) in goon_keylist)) return 1
	else return 0

/proc/istester(X)
	if (istype(X,/mob)) X=X:ckey
	if (istype(X,/client)) X=X:ckey
	if ((ckey(X) in beta_tester_keylist)) return 1
	else return 0

/proc/remove_goon(key as text)
	var/ckey=ckey(key)
	if (key && goon_keylist.Find(ckey))
		goon_keylist.Remove(ckey)
		goon_savefile()
		return 1
	return 0