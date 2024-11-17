//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki()
	set name = "wiki"
	set desc = "Введите то, о чем вы хотите знать. После этого в вашем веб-браузере откроется вики-страница."
	set hidden = 1
	if(CONFIG_GET(string/wikiurl))
		var/query = tgui_input_text(src, "Введите запрос:", "Поиск по вики-сайту", "Заглавная страница")
		if(query == "Заглавная страница")
			src << link(CONFIG_GET(string/wikiurl))
		else if(query)
			var/output = CONFIG_GET(string/wikiurl) + "/index.php?title=Special%3ASearch&profile=default&search=" + query
			src << link(output)
	else
		to_chat(src, "<span class='danger'>URL-адрес wiki не задан в конфигурации сервера.</span>")
	return

/client/verb/forum()
	set name = "forum"
	set desc = "Посетите форум."
	set hidden = 1
	if(CONFIG_GET(string/forumurl))
		if(tgui_alert(src, "Откройте форум в своем браузере?", "Forum", list("Да", "Нет")) != "Да")
			return
		if(CONFIG_GET(string/forum_link_url) && prefs && !prefs.fuid)
			link_forum_account()
		src << link(CONFIG_GET(string/forumurl))
	else
		to_chat(src, "<span class='danger'>URL-адрес форума не задан в конфигурации сервера.</span>")

/client/verb/rules()
	set name = "Правила"
	set desc = "Просмотрите правила сервера."
	set hidden = 1
	if(CONFIG_GET(string/rulesurl))
		if(tgui_alert(src, "После этого в вашем браузере откроются правила. Вы уверены?", "Правила", list("Да", "Нет")) != "Да")
			return
		src << link(CONFIG_GET(string/rulesurl))
	else
		to_chat(src, "<span class='danger'>URL-адрес правил не задан в конфигурации сервера.</span>")

/client/verb/github()
	set name = "GitHub"
	set desc = "Посетите страницу на GitHub."
	set hidden = 1
	if(CONFIG_GET(string/githuburl))
		if(tgui_alert(src, "Это откроет наш репозиторий на GitHub в вашем браузере. Вы уверены?", "GitHub", list("Да", "Нет")) != "Да")
			return
		src << link(CONFIG_GET(string/githuburl))
	else
		to_chat(src, "<span class='danger'>URL-адрес GitHub не задан в конфигурации сервера.</span>")

/client/verb/discord()
	set name = "Discord"
	set desc = "Присоединяйтесь к нашему серверу Discord."
	set hidden = 1

	var/durl = CONFIG_GET(string/discordurl)
	if(CONFIG_GET(string/forum_link_url) && prefs && prefs.fuid && CONFIG_GET(string/discordforumurl))
		durl = CONFIG_GET(string/discordforumurl)
	if(!durl)
		to_chat(src, "<span class='danger'>URL-адрес Discord не задан в конфигурации сервера.</span>")
		return
	if(tgui_alert(src, "Это пригласит вас на наш сервер Discord. Вы уверены?", "Discord", list("Да", "Нет")) != "Да")
		return
	src << link(durl)

/client/verb/donate()
	set name = "Donate"
	set desc = "Сделайте пожертвование, чтобы покрыть расходы на хостинг."
	set hidden = 1
	if(CONFIG_GET(string/donationsurl))
		if(tgui_alert(src, "После этого в вашем браузере откроется страница пожертвований. Вы уверены?", "Donate", list("Да", "Нет")) != "Да")
			return
		src << link(CONFIG_GET(string/donationsurl))
	else
		to_chat(src, "<span class='danger'>URL-адрес донатов не задан в конфигурации сервера.</span>")
