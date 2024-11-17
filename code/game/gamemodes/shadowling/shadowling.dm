#define LIGHT_DAM_THRESHOLD 4
#define LIGHT_HEAL_THRESHOLD 2
#define LIGHT_DAMAGE_TAKEN 6

/*

SHADOWLING: A gamemode based on previously-run events

Aliens called shadowlings are on the station.
These shadowlings can 'enthrall' crew members and enslave them.
They also burn in the light but heal rapidly whilst in the dark.
The game will end under two conditions:
	1. The shadowlings die
	2. The emergency shuttle docks at CentCom

Shadowling strengths:
	- The dark
	- Hard vacuum (They are not affected by it)
	- Their thralls who are not harmed by the light
	- Stealth

Shadowling weaknesses:
	- The light
	- Fire
	- Enemy numbers
	- Lasers (Lasers are concentrated light and do more damage)
	- Flashbangs (High stun and high burn damage; if the light stuns humans, you bet your ass it'll hurt the shadowling very much!)

Shadowlings start off disguised as normal crew members, and they only have two abilities: Hatch and Enthrall.
They can still enthrall and perhaps complete their objectives in this form.
Hatch will, after a short time, cast off the human disguise and assume the shadowling's true identity.
They will then assume the normal shadowling form and gain their abilities.

The shadowling will seem OP, and that's because it kinda is. Being restricted to the dark while being alone most of the time is extremely difficult and as such the shadowling needs powerful abilities.
Made by Xhuis

*/



/*
	GAMEMODE
*/


/datum/game_mode
	var/list/datum/mind/shadows = list()
	var/list/datum/mind/shadowling_thralls = list()
	var/list/shadow_objectives = list()
	var/required_thralls = 15 //How many thralls are needed (hardcoded for now)
	var/shadowling_ascended = 0 //If at least one shadowling has ascended
	var/shadowling_dead = 0 //is shadowling kill
	var/objective_explanation
	var/warning_threshold
	var/victory_warning_announced = FALSE
	var/thrall_ratio = 1

/proc/is_thrall(var/mob/living/M)
	return istype(M) && M.mind && SSticker && SSticker.mode && (M.mind in SSticker.mode.shadowling_thralls)


/proc/is_shadow_or_thrall(var/mob/living/M)
	return istype(M) && M.mind && SSticker && SSticker.mode && ((M.mind in SSticker.mode.shadowling_thralls) || (M.mind in SSticker.mode.shadows))


/proc/is_shadow(var/mob/living/M)
	return istype(M) && M.mind && SSticker && SSticker.mode && (M.mind in SSticker.mode.shadows)


/datum/game_mode/shadowling
	name = "shadowling"
	config_tag = "shadowling"
	required_players = 30
	required_enemies = 2
	recommended_enemies = 2
	restricted_jobs = list(JOB_TITLE_AI, JOB_TITLE_CYBORG)
	protected_jobs = list(JOB_TITLE_OFFICER, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_HOS, JOB_TITLE_HOP, JOB_TITLE_CAPTAIN, JOB_TITLE_BLUESHIELD, JOB_TITLE_REPRESENTATIVE, JOB_TITLE_PILOT, JOB_TITLE_JUDGE, JOB_TITLE_BRIGDOC, JOB_TITLE_LAWYER, JOB_TITLE_CCOFFICER, JOB_TITLE_CCFIELD, JOB_TITLE_CCSPECOPS, JOB_TITLE_CCSUPREME, JOB_TITLE_SYNDICATE)

/datum/game_mode/shadowling/announce()
	to_chat(world, "<b>Текущий режим игры - Тенелинги!</b>")
	to_chat(world, "<b>На станции находятся инопланетные <span class='deadsay'>порождения тьмы.</span>. Экипаж: Убейте порождений тьмы, прежде чем они смогут съесть экипаж или захватить станцию. Порождения тьмы: захватите станцию, оставаясь не обнаруженными.</b>")

/datum/game_mode/shadowling/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_shadowlings = get_players_for_role(ROLE_SHADOWLING)

	if(!possible_shadowlings.len)
		return 0

	var/shadowlings = max(3, round(num_players()/14))

	while(shadowlings)
		var/datum/mind/shadow = pick(possible_shadowlings)
		shadows += shadow
		possible_shadowlings -= shadow
		shadow.special_role = SPECIAL_ROLE_SHADOWLING
		shadow.restricted_roles = restricted_jobs
		shadowlings--

	recount_required_thralls()

	..()
	return 1


/datum/game_mode/shadowling/post_setup()
	for(var/datum/mind/shadow in shadows)
		add_game_logs("был выбран в качестве Тенелинга.", shadow.current)

		var/list/messages = list()
		spawn(rand(10,100))
			messages.Add("<br>")
			messages.Add("<span class='deadsay'><b><font size=3>Ты - порождение тьмы!</font></b></span>")
			messages.Add(greet_shadow(shadow))
			messages.Add(process_shadow_objectives(shadow))
			finalize_shadowling(shadow)
			to_chat(shadow.current, chat_box_red(messages.Join("<br>")))
		//give_shadowling_abilities(shadow)
	..()

/datum/game_mode/proc/greet_shadow(var/datum/mind/shadow)
	var/list/messages = list()
	messages.Add("<b>В настоящее время вы замаскированы под сотрудника на борту [station_name()].</b>")
	messages.Add("<b>В вашем ограниченном состоянии у вас есть две способности: Воплощение и коллективный разум '[get_language_prefix(LANGUAGE_HIVE_SHADOWLING)]'.</b>")
	messages.Add("<b>Все остальные порождения тьмы - ваши союзники. Вы должны помогать им так же, как они будут помогать вам.</b>")
	messages.Add("<b>С полной информацией вы можете ознакомиться на вики: <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Shadowling\">Тенеморф</a></b><br>")
	return messages


/datum/game_mode/proc/process_shadow_objectives(var/datum/mind/shadow_mind)
	var/objective = "enthrall" //may be devour later, but for now it seems murderbone-y

	if(objective == "enthrall")
		objective_explanation = "Примите свой истинный облик, используя способность Восхождение. Это может быть использовано только если у вас достаточно рабов [required_thralls] ,когда их будет достаточно - разблокируется способностью Коллективный разум."
		shadow_objectives += "enthrall"
		shadow_mind.memory += "<b>Objective #1</b>: [objective_explanation]"
		return "<b>Objective #1</b>: [objective_explanation]<br>"


/datum/game_mode/proc/finalize_shadowling(var/datum/mind/shadow_mind)
	var/mob/living/carbon/human/S = shadow_mind.current
	shadow_mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_hatch(null))
	spawn(0)
		shadow_mind.current.add_language(LANGUAGE_HIVE_SHADOWLING)
		update_shadow_icons_added(shadow_mind)
		if(shadow_mind.assigned_role == JOB_TITLE_CLOWN)
			to_chat(S, "<span class='notice'>Твоя инопланетная натура позволила тебе преодолеть свою клоунаду.</span>")
			S.force_gene_block(GLOB.clumsyblock, FALSE)


/datum/game_mode/proc/add_thrall(datum/mind/new_thrall_mind)
	if(!istype(new_thrall_mind))
		return 0
	if(!(new_thrall_mind in shadowling_thralls))
		shadowling_thralls += new_thrall_mind
		new_thrall_mind.special_role = SPECIAL_ROLE_SHADOWLING_THRALL
		update_shadow_icons_added(new_thrall_mind)
		add_conversion_logs(new_thrall_mind.current, "Became a Shadow thrall")
		new_thrall_mind.current.add_language(LANGUAGE_HIVE_SHADOWLING)
		//If you add spells to thrall, be sure to remove them on dethrallize
		new_thrall_mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_guise(null))
		new_thrall_mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_vision/thrall(null))
		var/list/messages = list()
		messages.Add(span_shadowling("><b>Ты видишь правду. Реальность исчезла, и ты понимаешь, каким дураком ты был.</b>"))
		messages.Add(span_shadowling("<b>Порождения тьмы - ваши хозяева.</b> Служите им и следите за тем, чтобы они достигли своих целей."))
		messages.Add(span_shadowling("Вы не имеете права причинять вред другим рабам или порождениям тьмы. Однако вам не обязательно подчиняться другим рабам."))
		messages.Add(span_shadowling("Ваше тело необратимо изменилось. Внимательный человек может это заметить - вы можете скрыть это, надев маску."))
		messages.Add(span_shadowling("Хотя вы и не так могущественны, как ваши хозяева, вы обладаете некоторыми слабыми способностями. Их можно найти на вкладке Способности рабов."))
		messages.Add(span_shadowling("Вы можете общаться со своими союзниками, используя язык Разума улья Порождений Тьмы '[get_language_prefix(LANGUAGE_HIVE_SHADOWLING)]'."))
		to_chat(new_thrall_mind.current, chat_box_red(messages.Join("<br>")))
		if(jobban_isbanned(new_thrall_mind.current, ROLE_SHADOWLING) || jobban_isbanned(new_thrall_mind.current, ROLE_SYNDICATE))
			replace_jobbanned_player(new_thrall_mind.current, ROLE_SHADOWLING)
		if(!victory_warning_announced && (length(shadowling_thralls) >= warning_threshold))//are the slings very close to winning?
			victory_warning_announced = TRUE	//then let's give the station a warning
			GLOB.command_announcement.Announce("Сканерами дальнего действия обнаружена большая концентрация психической блюспейс-энергии. Событие вознесения тенеморфов неизбежно. Предотвратите его любой ценой!", "Отдел Центрального Командования по делам высших измерений.", 'sound/AI/spanomalies.ogg')
			log_game("Shadowling reveal. Powergame and validhunt allowed.")
		return 1

/datum/game_mode/proc/remove_thrall(datum/mind/thrall_mind, var/kill = 0)
	if(!istype(thrall_mind) || !(thrall_mind in shadowling_thralls) || !isliving(thrall_mind.current))
		return 0 //If there is no mind, the mind isn't a thrall, or the mind's mob isn't alive, return
	shadowling_thralls.Remove(thrall_mind)
	add_conversion_logs(thrall_mind.current, "De-shadow thralled")
	thrall_mind.special_role = null
	update_shadow_icons_removed(thrall_mind)
	//If you add spells to thrall, be sure to remove them on dethrallize
	thrall_mind.RemoveSpell(/obj/effect/proc_holder/spell/shadowling_guise)
	thrall_mind.RemoveSpell(/obj/effect/proc_holder/spell/shadowling_vision/thrall)
	thrall_mind.current.remove_language(LANGUAGE_HIVE_SHADOWLING)
	if(kill && ishuman(thrall_mind.current)) //If dethrallization surgery fails, kill the mob as well as dethralling them
		var/mob/living/carbon/human/H = thrall_mind.current
		H.visible_message("<span class='warning'>[H] резко дергается и замирает.</span>", \
							"<span class='userdanger'>Пронзительный белый свет заливает твой разум, изгоняя твои воспоминания о рабстве и--</span>")
		H.death()
		return 1
	var/mob/living/M = thrall_mind.current
	if(issilicon(M))
		M.audible_message("<span class='notice'>[M] выдаёт короткую вспышку.</span>")
		to_chat(M, "<span class='userdanger'>Тебя превратили в робота! Ты больше не раб! Как бы ты ни старался, ты ничего не можешь вспомнить о своем рабстве..</span>")
	else
		M.visible_message("<span class='big'>[M] похоже, [M.p_their()] снова владеет разумом.</span>", \
						"<span class='userdanger'>Пронзительный белый свет заливает твои глаза. Ты снова в своем уме! Как бы ты ни старался, ты ничего не можешь вспомнить ни о порождениях тьмы, ни о своем времени \
							под их командованием..</span>")
	return 1


/*
	GAME FINISH CHECKS
*/

/datum/game_mode/shadowling/check_finished()
	var/shadows_alive = 0 //and then shadowling was kill
	for(var/datum/mind/shadow in shadows) //but what if shadowling was not kill?
		if(!ishuman(shadow.current) && !istype(shadow.current,/mob/living/simple_animal/ascendant_shadowling))
			continue
		if(shadow.current.stat == DEAD)
			continue
		shadows_alive++
		if(shadow.special_role == SPECIAL_ROLE_SHADOWLING && CONFIG_GET(number/shadowling_max_age))
			if(ishuman(shadow.current))
				var/mob/living/carbon/human/H = shadow.current
				if(!isshadowling(H))
					for(var/obj/effect/proc_holder/spell/shadowling_hatch/hatch_ability in shadow.spell_list)
						hatch_ability.cycles_unused++
						if(prob(20) && hatch_ability.cycles_unused > CONFIG_GET(number/shadowling_max_age))
							var/shadow_nag_messages = list("Ты едва можешь удержаться в этой жалкой форме!", "Желание стать чем-то большим непреодолимо!", "Ты испытываешь жгучее желание вылупиться из этой скорлупы и стать божественным!")
							H.take_overall_damage(0, 3)
							to_chat(H, "<span class='userdanger'>[pick(shadow_nag_messages)]</span>")
							H << 'sound/weapons/sear.ogg'

	if(shadows_alive)
		return ..()
	else
		shadowling_dead = 1 //but shadowling was kill :(
		return 1

/datum/game_mode/proc/remove_shadowling(datum/mind/ling_mind)
	if(!istype(ling_mind) || !(ling_mind in shadows)) return 0
	update_shadow_icons_removed(ling_mind)
	shadows.Remove(ling_mind)
	add_conversion_logs(ling_mind.current, "Deshadowlinged")
	ling_mind.special_role = null
	for(var/obj/effect/proc_holder/spell/spell as anything in ling_mind.spell_list)
		ling_mind.RemoveSpell(spell)
	var/mob/living/M = ling_mind.current
	if(issilicon(M))
		M.audible_message("<span class='notice'>[M] выдаёт короткую вспышку.</span>")
		to_chat(M, "<span class='userdanger'>Тебя превратили в робота! Ты больше не порождение тьмы! Как бы ты ни старался, ты ничего не можешь вспомнить о том времени, когда был им..</span>")
	else
		M.visible_message("<span class='big'>[M] кричит и корчится!</span>", \
						  "<span class='userdanger'>СВЕТ - ТВОЙ РАЗУМ-- <i>ГОРИТ--</i></span>")
		spawn(30)
			if(!M || QDELETED(M))
				return
			M.visible_message("<span class='warning'>[M] внезапно раздувается и взрывается!</span>", \
							  "<span class='warning'><b>AAAAAAAAA<font size=3>AAAAAAAAAAAAA</font><font size=4>AAAAAAAAAAAA----</font></span>")
			playsound(M, 'sound/magic/disintegrate.ogg', 100, 1)
			M.gib()

/datum/game_mode/shadowling/proc/check_shadow_victory()
	var/success = 0 //Did they win?
	if(shadow_objectives.Find("enthrall"))
		success = shadowling_ascended
	return success


/datum/game_mode/shadowling/declare_completion()
	if(check_shadow_victory() && SSshuttle.emergency.mode >= SHUTTLE_ESCAPE) //Doesn't end instantly - this is hacky and I don't know of a better way ~X
		SSticker.mode_result = "shadowling win - shadowling ascension"
		to_chat(world, "<FONT size = 3><B>Победа Тенеморфов!</B></FONT>")
		to_chat(world, "<span class='greentext'><b>Порождения тьмы вознеслись и захватили станцию!</b></span>")
	else if(shadowling_dead && !check_shadow_victory()) //If the shadowlings have ascended, they can not lose the round
		SSticker.mode_result = "shadowling loss - shadowling killed"
		to_chat(world, "<FONT size = 3><B>Crew Major Victory</B></FONT>")
		to_chat(world, "<span class='redtext'><b>Порождения тьмы были убиты экипажем!</b></span>")
	else if(!check_shadow_victory() && SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		SSticker.mode_result = "shadowling loss - crew escaped"
		to_chat(world, "<FONT size = 3><B>Crew Minor Victory</B></FONT>")
		to_chat(world, "<span class='redtext'><b>Экипаж эвакуировался со станции до того, как порождения тьмы смогли вознестись!</b></span>")
	else
		SSticker.mode_result = "shadowling loss - generic failure"
		to_chat(world, "<FONT size = 3><B>Crew Major Victory</B></FONT>")
		to_chat(world, "<span class='redtext'><b>Порождения тьмы потерпели неудачу!</b></span>")
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_shadowling()
	var/text = ""
	if(shadows.len)
		text += "<br><span class='big'><b>Порождениями тьмы были:</b></span>"
		for(var/datum/mind/shadow in shadows)
			text += "<br>[shadow.get_display_key()] was [shadow.name] ("
			if(shadow.current)
				if(shadow.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(shadow.current.real_name != shadow.name)
					text += " as <b>[shadow.current.real_name]</b>"
			else
				text += "body destroyed"
			text += ")"
		text += "<br>"
		if(shadowling_thralls.len)
			text += "<br><span class='big'><b>The thralls were:</b></span>"
			for(var/datum/mind/thrall in shadowling_thralls)
				text += "<br>[thrall.get_display_key()] was [thrall.name] ("
				if(thrall.current)
					if(thrall.current.stat == DEAD)
						text += "died"
					else
						text += "survived"
					if(thrall.current.real_name != thrall.name)
						text += " as <b>[thrall.current.real_name]</b>"
				else
					text += "body destroyed"
				text += ")"
	text += "<br>"
	to_chat(world, text)


/*
	MISCELLANEOUS
*/

/datum/game_mode/proc/update_shadow_icons_added(datum/mind/shadow_mind)
	var/datum/atom_hud/antag/shadow_hud = GLOB.huds[ANTAG_HUD_SHADOW]
	shadow_hud.join_hud(shadow_mind.current)
	set_antag_hud(shadow_mind.current, ((shadow_mind in shadows) ? "hudshadowling" : "hudshadowlingthrall"))


/datum/game_mode/proc/update_shadow_icons_removed(datum/mind/shadow_mind) //This should never actually occur, but it's here anyway.
	var/datum/atom_hud/antag/shadow_hud = GLOB.huds[ANTAG_HUD_SHADOW]
	shadow_hud.leave_hud(shadow_mind.current)
	set_antag_hud(shadow_mind.current, null)


/datum/game_mode/proc/recount_required_thralls()
	var/thrall_scaling = round(num_players() / 3)
	required_thralls = clamp(thrall_scaling, 15, 25)
	thrall_ratio = required_thralls / 15
	warning_threshold = round(0.66 * required_thralls)
