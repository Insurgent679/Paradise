#define EMPOWERED_THRALL_LIMIT 5


/obj/effect/proc_holder/spell/proc/shadowling_check(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE

	if(isshadowling(user) && is_shadow(user))
		return TRUE

	if(isshadowlinglesser(user) && is_thrall(user))
		return TRUE

	if(!is_shadow_or_thrall(user))
		to_chat(user, "<span class='warning'>Вы не можете себе представить, как это сделать.</span>")
		balloon_alert(user, "не вышло")

	else if(is_thrall(user))
		to_chat(user, "<span class='warning'>Ты недостаточно силен, чтобы сделать это.</span>")
		balloon_alert(user, "не вышло")

	else if(is_shadow(user))
		to_chat(user, "<span class='warning'>Ваши телепатические способности подавлены. Сначала используйте быстрое повторное воплощение.</span>")
		balloon_alert(user, "не вышло")

	return FALSE


/**
 * Stuns and mutes a human target, depending on the distance relative to the shadowling.
 */
/obj/effect/proc_holder/spell/shadowling_glare
	name = "Вспышка"
	desc = "Оглушает и отключает звук на достаточное время. Время действия зависит от близости к цели."
	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	need_active_overlay = TRUE

	action_icon_state = "glare"

	selection_activated_message		= "<span class='notice'>Приготовьтесь к ошеломляющему блеску в глазах! <B> Щелкните левой кнопкой мыши, чтобы применить на цели цели!</B></span>"
	selection_deactivated_message 	= "<span class='notice'>Ваши глаза расслабляются.. пока что.</span>"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/shadowling_glare/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.random_target = TRUE
	T.target_priority = SPELL_TARGET_CLOSEST
	T.max_targets = 1
	T.range = 10
	return T


/obj/effect/proc_holder/spell/shadowling_glare/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/shadowling_glare/valid_target(mob/living/carbon/human/target, user)
	return !target.stat && !is_shadow_or_thrall(target)


/obj/effect/proc_holder/spell/shadowling_glare/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/target = targets[1]

	user.visible_message("<span class='warning'><b>[user]'s глаза вспыхивают ослепительным красным светом!</b></span>")
	var/distance = get_dist(target, user)
	if(distance <= 2)
		target.visible_message("<span class='danger'>[target] застывает на месте, [target.p_their()] вгляд выражает равнодушие..</span>", \
			"<span class='userdanger'>Твой взгляд насильно притягивается к глазам [user]'s, и ты загипнотизирован ими. [user.p_their()] небесная красота..</span>")

		target.Weaken(4 SECONDS)
		target.AdjustSilence(20 SECONDS)
		target.apply_damage(20, STAMINA)
		target.apply_status_effect(STATUS_EFFECT_STAMINADOT)

	else //Distant glare
		target.Stun(2 SECONDS)
		target.Slowed(10 SECONDS)
		target.AdjustSilence(10 SECONDS)
		to_chat(target, "<span class='userdanger'>Перед вашим взором вспыхивает красный свет, ваш разум пытается сопротивляться им. Но вы слишком измотаны.. Кажется вы потеряли дар речи..</span>")
		target.visible_message("<span class='danger'>[target] застывает на месте, [target.p_their()] взгляд выражает равнодушие..</span>")


/obj/effect/proc_holder/spell/aoe/shadowling_veil
	name = "Теневая вуаль"
	desc = "Гасит большинство близлежащих источников света."
	base_cooldown = 15 SECONDS //Short cooldown because people can just turn the lights back on
	clothes_req = FALSE
	var/blacklisted_lights = list(/obj/item/flashlight/flare, /obj/item/flashlight/slime)
	action_icon_state = "veil"
	aoe_range = 5


/obj/effect/proc_holder/spell/aoe/shadowling_veil/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = aoe_range
	return T


/obj/effect/proc_holder/spell/aoe/shadowling_veil/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/aoe/shadowling_veil/cast(list/targets, mob/user = usr)
	if(!shadowling_check(user))
		revert_cast(user)
		return

	to_chat(user, "<span class='shadowling'>Вы бесшумно отключаете все близлежащие источники света.</span>")
	for(var/turf/T in targets)
		T.extinguish_light()
		for(var/atom/A in T.contents)
			A.extinguish_light()


/obj/effect/proc_holder/spell/shadowling_shadow_walk
	name = "Шаг тьмы"
	desc = "На короткое время переносит вас в пространство между мирами, позволяя проходить сквозь стены и становиться невидимым."
	base_cooldown = 30 SECONDS //Used to be twice this, buffed
	clothes_req = FALSE
	phase_allowed = TRUE
	action_icon_state = "shadow_walk"


/obj/effect/proc_holder/spell/shadowling_shadow_walk/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/shadowling_shadow_walk/cast(list/targets, mob/living/user = usr)
	if(!shadowling_check(user))
		revert_cast(user)
		return

	playsound(user.loc, 'sound/effects/bamf.ogg', 50, 1)
	user.visible_message("<span class='warning'>[user] исчезает в чёрном тумане!</span>", "<span class='shadowling'>Вы входите в пространство между мирами.</span>")
	user.SetStunned(0)
	user.SetWeakened(0)
	user.SetKnockdown(0)
	user.incorporeal_move = INCORPOREAL_NORMAL
	user.alpha = 0
	user.ExtinguishMob()
	user.forceMove(get_turf(user)) //to properly move the mob out of a potential container
	user.pulledby?.stop_pulling()
	user.stop_pulling()

	sleep(4 SECONDS)
	if(QDELETED(user))
		return

	user.visible_message("<span class='warning'>[user] внезапно проявляется!</span>", "<span class='shadowling'>Давление становится слишком сильным, и вы отделяетесь от межпространственной тьмы.</span>")
	user.incorporeal_move = INCORPOREAL_NONE
	user.alpha = 255
	user.forceMove(get_turf(user))


/obj/effect/proc_holder/spell/shadowling_guise
	name = "Призрачный облик"
	desc = "Окутывает вашу фигуру тенью, из-за чего вас труднее разглядеть."
	base_cooldown = 120 SECONDS
	clothes_req = FALSE
	action_icon_state = "shadow_walk"
	var/conseal_time = 4 SECONDS


/obj/effect/proc_holder/spell/shadowling_guise/Destroy()
	if(action?.owner)
		reveal(action.owner)
	return ..()


/obj/effect/proc_holder/spell/shadowling_guise/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/shadowling_guise/cast(list/targets, mob/user = usr)
	user.visible_message("<span class='warning'>[user] внезапно исчезает!</span>", "<span class='shadowling'>Ты окутываешь себя тьмой, из-за чего тебя труднее разглядеть.</span>")
	user.alpha = 10
	addtimer(CALLBACK(src, PROC_REF(reveal), user), conseal_time)


/obj/effect/proc_holder/spell/shadowling_guise/proc/reveal(mob/user)
	if(QDELETED(user))
		return

	user.alpha = initial(user.alpha)
	user.visible_message("<span class='warning'>[user] появляется из ниоткуда!</span>", "<span class='shadowling'>Твой призрачный облик исчезает.</span>")


/obj/effect/proc_holder/spell/shadowling_vision
	name = "Взгляд тени"
	desc = "Обеспечивает ночное и тепловизионное зрение."
	base_cooldown = 0
	clothes_req = FALSE
	action_icon_state = "darksight"


/obj/effect/proc_holder/spell/shadowling_vision/Destroy()
	action?.owner?.set_vision_override(null)
	return ..()


/obj/effect/proc_holder/spell/shadowling_vision/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/shadowling_vision/cast(list/targets, mob/living/carbon/human/user = usr)
	if(!istype(user))
		return

	if(!user.vision_type)
		to_chat(user, "<span class='notice'>Вы воздействуете на нервные окончания в ваших глазах, что позволяет вам видеть в темноте.</span>")
		user.set_vision_override(/datum/vision_override/nightvision)
	else
		to_chat(user, "<span class='notice'>Вы возвращаете свое зрение в норму.</span>")
		user.set_vision_override(null)


/obj/effect/proc_holder/spell/shadowling_vision/thrall
	desc = "Взгляд раба тьмы"
	desc = "Дает вам ночное зрение."


/obj/effect/proc_holder/spell/aoe/shadowling_icy_veins
	name = "Ледяные вены"
	desc = "Мгновенно замораживает кровь находящихся поблизости людей, оглушая их и нанося урон ожогами."
	base_cooldown = 25 SECONDS
	clothes_req = FALSE
	action_icon_state = "icy_veins"
	aoe_range = 5


/obj/effect/proc_holder/spell/aoe/shadowling_icy_veins/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new()
	T.range = aoe_range
	T.allowed_type = /mob/living/carbon
	return T


/obj/effect/proc_holder/spell/aoe/shadowling_icy_veins/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/aoe/shadowling_icy_veins/cast(list/targets, mob/user = usr)
	if(!shadowling_check(user))
		revert_cast(user)
		return

	to_chat(user, "<span class='shadowling'>Вы замораживаете воздух поблизости.</span>")
	playsound(user.loc, 'sound/effects/ghost2.ogg', 50, TRUE)

	for(var/mob/living/carbon/target in targets)
		if(is_shadow_or_thrall(target))
			to_chat(target, "<span class='danger'>Вы чувствуете, как порыв парализующе холодного воздуха окутывает вас и проносится мимо, но на вас это никак не влияет!</span>")
			continue

		to_chat(target, "<span class='userdanger'>Вас окутывает волна холодного воздуха!</span>")
		target.Stun(2 SECONDS)
		target.apply_damage(10, BURN)
		target.adjust_bodytemperature(-200) //Extreme amount of initial cold
		if(target.reagents)
			target.reagents.add_reagent("frostoil", 15) //Half of a cryosting


/obj/effect/proc_holder/spell/shadowling_enthrall //Turns a target into the shadowling's slave. This overrides all previous loyalties
	name = "Порабощение"
	desc = "Позволяет вам подчинить своей воле человека, находящегося в сознании, но не лишенного разума и не находящегося в кататонии. Для этого требуется некоторое время."
	base_cooldown = 0
	clothes_req = FALSE
	action_icon_state = "enthrall"
	selection_activated_message		= "<span class='notice'>Ты готовишь свой разум к тому, чтобы заворожить смертного. <B>Щелкните левой кнопкой мыши, чтобы применить на цели цели!</B></span>"
	selection_deactivated_message	= "<span class='notice'>Ваш разум расслабляется.</span>"
	need_active_overlay = TRUE
	var/enthralling = FALSE


/obj/effect/proc_holder/spell/shadowling_enthrall/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.range = 1
	T.click_radius = -1
	return T


/obj/effect/proc_holder/spell/shadowling_enthrall/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(enthralling || user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/shadowling_enthrall/valid_target(mob/living/carbon/human/target, user)
	return target.key && target.mind && !target.stat && !is_shadow_or_thrall(target) && target.client


/obj/effect/proc_holder/spell/shadowling_enthrall/cast(list/targets, mob/user = usr)

	listclearnulls(SSticker.mode.shadowling_thralls)
	if(!is_shadow(user))
		return

	var/mob/living/carbon/human/target = targets[1]
	if(ismindshielded(target))
		to_chat(user, "<span class='danger'>У этой цели есть ментальный щит, блокирующий ваши силы! Вы не можете подчинить его себе!</span>")
		return

	enthralling = TRUE
	to_chat(user, "<span class='danger'>Эта цель подходит. Вы начинаете увлекательный процесс.</span>")
	to_chat(target, "<span class='userdanger'>[user] пристально смотрит на тебя. Ты чувствуешь, как у тебя начинает кружиться голова..</span>")

	for(var/progress = 0, progress <= 3, progress++)
		switch(progress)
			if(1)
				to_chat(user, "<span class='notice'>Вы кладете свои руки на голову [target]'s..</span>")
				user.visible_message("<span class='warning'>[user] помещает [user.p_their()] руки по бокам от головы [target]'s!</span>")
			if(2)
				to_chat(user, "<span class='notice'>Вы начинаете заполнять разум [target]'s как чистый лист..</span>")
				user.visible_message("<span class='warning'>[user]'s ладони вспыхивают ярко-красным на фоне висков [target]'s!</span>")
				to_chat(target, "<span class='danger'>Ужасный красный свет заливает ваш разум. Вы теряете сознание, когда все осознанные мысли исчезают.</span>")
				target.Weaken(24 SECONDS)
			if(3)
				to_chat(user, "<span class='notice'>Вы начинаете насаждать опухоль, которая будет контролировать нового раба...</span>")
				user.visible_message("<span class='warning'>Странная энергия переходит из рук [user]'s в голову [target]'s!</span>")
				to_chat(target, span_boldannounceic("Вы чувствуете, как ваши воспоминания искажаются, трансформируются. Чувство ужаса овладевает вашим сознанием."))
		if(!do_after(user, 7.7 SECONDS, target, NONE)) //around 23 seconds total for enthralling
			to_chat(user, "<span class='warning'>Действие порабощения прервано - разум вашей жертвы возвращается в прежнее состояние.</span>")
			to_chat(target, "<span class='userdanger'>Вы вырываетесь из рук [user]'s  и берёте себя в руки.</span>")
			enthralling = FALSE
			return

		if(QDELETED(target) || QDELETED(user))
			revert_cast(user)
			return

	enthralling = FALSE
	to_chat(user, "<span class='shadowling'>Вы успешно поработили <b>[target]</b>!</span>")
	target.visible_message("<span class='big'>[target] похоже, вы пережили порабощение!</span>", \
							"<span class='warning'>Фальшивые лица <b>все они ненастоящие, ненастоящие, ненастоящие!--</b></span>")
	target.setOxyLoss(0) //In case the shadowling was choking them out
	SSticker.mode.add_thrall(target.mind)
	target.mind.special_role = SPECIAL_ROLE_SHADOWLING_THRALL


/**
 * Resets a shadowling's species to normal, removes genetic defects, and re-equips their armor.
 */
/obj/effect/proc_holder/spell/shadowling_regen_armor
	name = "Быстрое повторное воплощение"
	desc = "Восстанавливает защитный хитин, который может быть утрачен во время клонирования или аналогичных процессов."
	base_cooldown = 60 SECONDS
	clothes_req = FALSE
	action_icon_state = "regen_armor"


/obj/effect/proc_holder/spell/shadowling_regen_armor/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/shadowling_regen_armor/cast(list/targets, mob/living/carbon/human/user = usr)
	if(!is_shadow(user))
		to_chat(user, "<span class='warning'>Ты, должен быть, порождением тьмы, чтобы сделать это!</span>")
		revert_cast(user)
		return

	if(!istype(user))
		return

	user.visible_message("<span class='warning'>кожа [user]'s внезапно пузырится и перемещается по телу [user.p_their()]!</span>", \
					 "<span class='shadowling'>Вы восстанавливаете свою защитную броню и излечиваете своё тело от дефектов.</span>")
	user.set_species(/datum/species/shadow/ling)
	user.adjustCloneLoss(-(user.getCloneLoss()))
	user.equip_to_slot_or_del(new /obj/item/clothing/under/shadowling(user), ITEM_SLOT_CLOTH_INNER)
	user.equip_to_slot_or_del(new /obj/item/clothing/shoes/shadowling(user), ITEM_SLOT_FEET)
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/space/shadowling(user), ITEM_SLOT_CLOTH_OUTER)
	user.equip_to_slot_or_del(new /obj/item/clothing/head/shadowling(user), ITEM_SLOT_HEAD)
	user.equip_to_slot_or_del(new /obj/item/clothing/gloves/shadowling(user), ITEM_SLOT_GLOVES)
	user.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/shadowling(user), ITEM_SLOT_MASK)
	user.equip_to_slot_or_del(new /obj/item/clothing/glasses/shadowling(user), ITEM_SLOT_EYES)


/**
 * Lets a shadowling bring together their thralls' strength, granting new abilities and a headcount.
 */
/obj/effect/proc_holder/spell/shadowling_collective_mind
	name = "Коллективный разум"
	desc = "Собирает силу всех ваших рабов и сравнивает её с той, что необходима для восхождения. Также даёт вам новые способности."
	base_cooldown = 30 SECONDS //30 second cooldown to prevent spam
	clothes_req = FALSE
	var/blind_smoke_acquired
	var/screech_acquired
	var/null_charge_acquired
	var/revive_thrall_acquired
	action_icon_state = "collective_mind"


/obj/effect/proc_holder/spell/shadowling_collective_mind/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/shadowling_collective_mind/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/shadowling_collective_mind/cast(list/targets, mob/user = usr)
	if(!shadowling_check(user))
		revert_cast(user)
		return

	to_chat(user, "<span class='shadowling'><b>Вы концентрируете свою телепатическую энергию в одной точке, используя и собирая воедино силу всех своих рабов.</b></span>")

	var/thralls = 0
	var/victory_threshold = SSticker.mode.required_thralls
	for(var/mob/living/target in GLOB.alive_mob_list)
		if(is_thrall(target))
			thralls++
			to_chat(target, "<span class='shadowling'>Вы чувствуете, как крючки впиваются в ваш разум и тянут за собой.</span>")

	if(!do_after(user, 3 SECONDS, user))
		to_chat(user, "<span class='warning'>Ваша концентрация нарушена. Ментальные ловушки, которые вы посылали, теперь втягиваются в ваш разум.</span>")
		return

	if(QDELETED(user))
		return

	if(thralls >= CEILING(3 * SSticker.mode.thrall_ratio, 1) && !screech_acquired)
		screech_acquired = TRUE
		to_chat(user, "<span class='shadowling'><i>Сила ваших рабов наделила вас способностью<b>Сверхзвуковой визг</b>. Эта способность разбивает ближайшие окна и оглушает врагов, а также оглушает все силиконовые формы жизни.</span>")
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/shadowling_screech(null))

	if(thralls >= CEILING(5 * SSticker.mode.thrall_ratio, 1) && !blind_smoke_acquired)
		blind_smoke_acquired = TRUE
		to_chat(user, "<span class='shadowling'><i>Сила ваших рабов наделила вас способностью <b>Ослепляющий дым</b>. \
			Эта способность создаст удушающее облако, которое ослепит любого, кто не порабощён и войдёт в него.</i></span>")
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_blindness_smoke(null))

	if(thralls >= CEILING(7 * SSticker.mode.thrall_ratio, 1) && !null_charge_acquired)
		null_charge_acquired = TRUE
		to_chat(user, "<span class='shadowling'><i>Сила ваших рабов наделила вас способностью <b>Разряжающий заряд</b>. Эта способность вытягивает всю энергию APC's в пустоту, от чего весь свет неподалёку вскоре погаснет. \
			Действует до тех пор, пока APC не починят.</i></span>")
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_null_charge(null))

	if(thralls >= CEILING(9 * SSticker.mode.thrall_ratio, 1) && !revive_thrall_acquired)
		revive_thrall_acquired = TRUE
		to_chat(user, "<span class='shadowling'><i>Сила ваших рабов наделила вас способностью <b>Теневое восстановление</b> ability. \
			Эта способность позволит через короткое время полностью вернуть мёртвого раба к жизни без каких-либо телесных повреждений.</i></span>")
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_revive_thrall(null))

	if(thralls < victory_threshold)
		to_chat(user, "<span class='shadowling'>У тебя нет силы вознестись. Вам нужно [victory_threshold] рабов, сейчас присутсвуют только [thralls] в живых.</span>")

	else if(thralls >= victory_threshold)
		to_chat(user, "<span class='shadowling'><b>Теперь вы достаточно сильны, чтобы вознестись. Используйте способность вознесения, когда будете готовы. <i>Это убьет всех твоих рабов.</i></span>")
		to_chat(user, "<span class='shadowling'><b>Вы можете найти способность Восхождения во вкладке: Эволюция тенелинга.</b></span>")

		for(var/mob/check in GLOB.alive_mob_list)
			if(!is_shadow(check))
				continue

			check.mind.RemoveSpell(/obj/effect/proc_holder/spell/shadowling_collective_mind)
			check.mind.RemoveSpell(/obj/effect/proc_holder/spell/shadowling_hatch)
			check.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_ascend(null))

			if(check == user)
				to_chat(check, "<span class='shadowling'><i>Ты распространяешь свою силу на остальных порождений тьмы.</i></span>")
			else
				to_chat(check, "<span class='shadowling'><b>[user.real_name] объединил силу всех своих рабов. Вы можете воспользоваться ей в любое время, чтобы вознестись. (Во вкладке: Эволюция тенелинга)</b></span>")//Tells all the other shadowlings


/obj/effect/proc_holder/spell/shadowling_blindness_smoke
	name = "Ослепляющий дым"
	desc = "Извергает облако дыма, которое ослепляет врагов."
	base_cooldown = 60 SECONDS
	clothes_req = FALSE
	action_icon_state = "black_smoke"


/obj/effect/proc_holder/spell/shadowling_blindness_smoke/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/shadowling_blindness_smoke/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/shadowling_blindness_smoke/cast(list/targets, mob/user = usr) //Extremely hacky
	if(!shadowling_check(user))
		revert_cast(user)
		return

	user.visible_message("<span class='warning'>[user] внезапно наклоняется и выплёвывает облако чёрного дыма, которое начинает быстро распространяться!</span>")
	to_chat(user, "<span class='deadsay'>Вы извергаете огромное облако ослепляющего дыма.</span>")
	playsound(user, 'sound/effects/bamf.ogg', 50, TRUE)
	var/datum/reagents/reagents_list = new (1000)
	reagents_list.add_reagent("blindness_smoke", 810)
	var/datum/effect_system/smoke_spread/chem/chem_smoke = new
	chem_smoke.set_up(reagents_list, user.loc, TRUE)
	chem_smoke.start(4)


/datum/reagent/shadowling_blindness_smoke //Blinds non-shadowlings, heals shadowlings/thralls
	name = "странная чёрная дымка"
	id = "blindness_smoke"
	description = "<::Ошибка::> НЕ УДАЕТСЯ ПРОАНАЛИЗИРОВАТЬ РЕАГЕНТ <::Ошибка::>"
	color = "#000000" //Complete black (RGB: 0, 0, 0)
	metabolization_rate = 250 * REAGENTS_METABOLISM //still lel


/datum/reagent/shadowling_blindness_smoke/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(!is_shadow_or_thrall(M))
		to_chat(M, "<span class='warning'><b>Чёрный дым, не даёт твоим глазам разглядеть хоть что-то!</b></span>")
		M.EyeBlind(10 SECONDS)
		if(prob(25))
			M.visible_message("<b>[M]</b> claws at [M.p_their()] eyes!")
			M.Stun(4 SECONDS)
	else
		to_chat(M, "<span class='notice'><b>Вы вдыхаете чёрный дым и чувствуете прилив сил!</b></span>")
		update_flags |= M.heal_organ_damage(10, 10, updating_health = FALSE)
		update_flags |= M.adjustOxyLoss(-10, FALSE)
		update_flags |= M.adjustToxLoss(-10, FALSE)
	return ..() | update_flags


/obj/effect/proc_holder/spell/aoe/shadowling_screech
	name = "Сверхзвуковой визг"
	desc = "Оглушает и приводит в замешательство людей, находящихся поблизости. Также разбивает окна."
	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	action_icon_state = "screech"
	aoe_range = 7


/obj/effect/proc_holder/spell/aoe/shadowling_screech/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = aoe_range
	return T


/obj/effect/proc_holder/spell/aoe/shadowling_screech/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/aoe/shadowling_screech/cast(list/targets, mob/user = usr)
	if(!shadowling_check(user))
		revert_cast(user)
		return

	user.audible_message("<span class='warning'><b>[user] издаёт ужасный крик!</b></span>")
	playsound(user.loc, 'sound/effects/screech.ogg', 100, TRUE)

	for(var/turf/turf in targets)
		for(var/mob/target in turf.contents)
			if(is_shadow_or_thrall(target))
				continue

			if(iscarbon(target))
				var/mob/living/carbon/c_mob = target
				to_chat(c_mob, "<span class='danger'><b>Острая боль пронзает вашу голову и путает ваши мысли!</b></span>")
				c_mob.AdjustConfused(20 SECONDS)
				c_mob.AdjustDeaf(6 SECONDS)

			else if(issilicon(target))
				var/mob/living/silicon/robot = target
				to_chat(robot, "<span class='warning'><b>ОШИБКА $!(@ ОШИБКА )#^! ПЕРЕГРУЗКА СЕНСОРНА \[$(!@#</b></span>")
				robot << 'sound/misc/interference.ogg'
				playsound(robot, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
				do_sparks(5, 1, robot)
				robot.Weaken(12 SECONDS)

		for(var/obj/structure/window/window in turf.contents)
			window.take_damage(rand(80, 100))


/obj/effect/proc_holder/spell/shadowling_null_charge
	name = "Разряжающий заряд"
	desc = "Разряжает APC, предотвращая его перезарядку до тех пор, пока он не будет починен."
	base_cooldown = 60 SECONDS
	clothes_req = FALSE
	action_icon_state = "null_charge"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/shadowling_null_charge/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.click_radius = 0
	T.range = 1
	T.allowed_type = /obj/machinery/power/apc
	return T


/obj/effect/proc_holder/spell/shadowling_null_charge/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/shadowling_null_charge/cast(list/targets, mob/living/carbon/human/user = usr)
	if(!shadowling_check(user))
		revert_cast(user)
		return

	var/obj/machinery/power/apc/target_apc = targets[1]
	if(!target_apc)
		to_chat(user, "<span class='warning'>Вы должны встать рядом с APC, чтобы слить воду!</span>")
		revert_cast(user)
		return

	if(target_apc.cell?.charge <= 0)
		to_chat(user, "<span class='warning'>APC должен иметь хоть какой-то запас энергии для слива!</span>")
		revert_cast(user)
		return

	target_apc.operating = FALSE
	target_apc.update()
	target_apc.update_icon()
	target_apc.visible_message("<span class='warning'>Индикатор [target_apc] мигает и начинает темнеть.</span>")

	to_chat(user, "<span class='shadowling'>Вы затемняете экран APC и осторожно начинаете перекачивать его энергию в пустоту.</span>")
	if(!do_after(user, 20 SECONDS, target_apc))
		//Whoops!  The APC's powers back on
		to_chat(user, "<span class='shadowling'>Ваша концентрация нарушается, и APC внезапно включается снова!</span>")
		target_apc.operating = TRUE
		target_apc.update()
		target_apc.update_icon()
		target_apc.visible_message("<span class='warning'>Объект [target_apc]  начинает ярко светиться!</span>")
	else
		//We did it!
		to_chat(user, "<span class='shadowling'>Вы направили энергию APC в пустоту, перегрузив все его микросхемы!</span>")
		target_apc.cell?.charge = 0	//Sent to the shadow realm
		target_apc.chargemode = FALSE //Won't recharge either until an someone hits the button
		target_apc.charging = APC_NOT_CHARGING
		target_apc.null_charge()
		target_apc.update_icon()


/obj/effect/proc_holder/spell/shadowling_revive_thrall
	name = "Теневое восстановление"
	desc = "Оживляет или наделяет силой раба."
	base_cooldown = 1 MINUTES
	clothes_req = FALSE
	action_icon_state = "revive_thrall"
	selection_activated_message		= "<span class='notice'>Вы начинаете сосредотачивать свои силы на залечивании ран союзников. <B>Щелкните левой кнопкой мыши, чтобы применить на цели!</B></span>"
	selection_deactivated_message	= "<span class='notice'>Ваш разум расслабляется.</span>"
	need_active_overlay = TRUE
	/// Whether the EMPOWERED_THRALL_LIMIT limit is ignored or not
	var/ignore_prer = FALSE


/obj/effect/proc_holder/spell/shadowling_revive_thrall/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.click_radius = -1
	T.range = 1
	return T


/obj/effect/proc_holder/spell/shadowling_revive_thrall/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/shadowling_revive_thrall/valid_target(mob/living/carbon/human/target, user)
	return is_thrall(target)


/obj/effect/proc_holder/spell/shadowling_revive_thrall/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/thrall = targets[1]
	if(thrall.stat == CONSCIOUS)
		if(isshadowlinglesser(thrall))
			to_chat(user, "<span class='warning'>[thrall] уже наделён вашей силой/излечен.</span>")
			revert_cast(user)
			return

		var/empowered_thralls = 0
		for(var/datum/mind/thrall_mind in SSticker.mode.shadowling_thralls)
			if(!ishuman(thrall_mind.current))
				continue

			var/mob/living/carbon/human/h_mob = thrall_mind.current
			if(isshadowlinglesser(h_mob))
				empowered_thralls++

		if(empowered_thralls >= EMPOWERED_THRALL_LIMIT && !ignore_prer)
			to_chat(user, "<span class='warning'>Вы не можете тратить так много энергии. Здесь слишком много могущественных рабов.</span>")
			revert_cast(user)
			return

		user.visible_message("<span class='danger'>[user] кладёт [user.p_their()]  руки на лицо [thrall]'s, из-под которых льется красный свет.</span>", \
							"<span class='shadowling'>Вы кладёте руки на лицо [thrall]'s и начинаете собирать энергию..</span>")
		to_chat(thrall, "<span class='userdanger'>[user] кладёт [user.p_their()] руки вам на лицо. Вы чувствуете, как внутри вас накапливается энергия. Замрите..</span>")
		if(!do_after(user, 8 SECONDS, thrall, NONE))
			to_chat(user, "<span class='warning'>Ваша концентрация ослабевает. Поток энергии ослабевает.</span>")
			revert_cast(user)
			return

		if(QDELETED(thrall) || QDELETED(user))
			revert_cast(user)
			return

		to_chat(user, "<span class='shadowling'><b><i>Вы высвобождаете мощный поток энергии в [thrall]!</b></i></span>")
		user.visible_message(span_boldannounceic("<i>Красная молния бьёт в лицо [thrall]'s!</i>"))
		playsound(thrall, 'sound/weapons/egloves.ogg', 50, TRUE)
		playsound(thrall, 'sound/machines/defib_zap.ogg', 50, TRUE)
		user.Beam(thrall, icon_state="red_lightning",icon='icons/effects/effects.dmi',time=1)
		thrall.Weaken(10 SECONDS)
		thrall.visible_message("<span class='warning'><b>[thrall]  падает, [thrall.p_their()] его кожа и лицо искажаются!</span>", \
										"<span class='userdanger'><i>AAAAAAAAAAAAAAAAAAAGH-</i></span>")

		sleep(2 SECONDS)
		if(QDELETED(thrall) || QDELETED(user))
			revert_cast(user)
			return

		thrall.visible_message("<span class='warning'>[thrall] медленно поднимается, в нём больше нельзя узнать человека.</span>", \
								"<span class='shadowling'><b>Вы чувствуете, как в вас вливается новая сила. Вы были одарены своими учителями. Теперь вы очень похожи на них. Вы сильны во тьме, но медленно увядаете на свету. В дополнение, \
								теперь у вас есть яркий свет и настоящая походка в тени.</b></span>")

		thrall.set_species(/datum/species/shadow/ling/lesser)
		thrall.mind.RemoveSpell(/obj/effect/proc_holder/spell/shadowling_guise)
		thrall.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_glare(null))
		thrall.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_shadow_walk(null))

	else if(thrall.stat == DEAD)
		user.visible_message("<span class='danger'>[user]  опускается на колени над [thrall], кладя  [user.p_their()] руки на [thrall.p_their()] грудь.</span>", \
							"<span class='shadowling'>Ты склоняешься над телом своего раба и начинаешь собирать энергию..</span>")
		thrall.notify_ghost_cloning("Ваши хозяева воскрешают вас! Войдите в свой труп, если хотите, чтобы вас вернули к жизни.", source = thrall)
		if(!do_after(user, 3 SECONDS, thrall, NONE))
			to_chat(user, "<span class='warning'>Ваша концентрация ослабевает. Поток энергии стихает.</span>")
			revert_cast(user)
			return

		if(QDELETED(thrall) || QDELETED(user))
			revert_cast(user)
			return

		to_chat(user, "<span class='shadowling'><b><i>Вы высвобождаете мощный поток энергии в [thrall]!</b></i></span>")
		user.visible_message(span_boldannounceic("<i>Красная молния вылетает из рук [user]'s в грудь [thrall]'s!</i>"))
		playsound(thrall, 'sound/weapons/egloves.ogg', 50, TRUE)
		playsound(thrall, 'sound/machines/defib_zap.ogg', 50, TRUE)
		user.Beam(thrall, icon_state="red_lightning",icon='icons/effects/effects.dmi',time=1)

		sleep(1 SECONDS)
		if(QDELETED(thrall) || QDELETED(user))
			revert_cast(user)
			return

		thrall.revive()
		thrall.update_revive()
		thrall.Weaken(8 SECONDS)
		thrall.emote("gasp")
		thrall.visible_message(span_boldannounceic("[thrall] тяжело дыша, тусклый красный свет сияет в [thrall.p_their()] глазах."), \
								"<span class='shadowling'><b><i>Ты вернулся. Один из твоих хозяев вывел тебя из тьмы потустороннего мира.</b></i></span>")
		playsound(thrall, "bodyfall", 50, TRUE)

	else
		to_chat(user, "<span class='warning'>Цель должна быть бодрствующей, чтобы получить силу, или мёртвой, чтобы возродиться.</span>")
		revert_cast(user)


/obj/effect/proc_holder/spell/shadowling_extend_shuttle
	name = "Уничтожение движков"
	desc = "Увеличивает время прибытия аварийного шаттла на десять минут, используя жизненную силу нашего врага. Шаттл нельзя будет отозвать. Это можно использовать только один раз."
	clothes_req = FALSE
	base_cooldown = 60 SECONDS
	selection_activated_message		= "<span class='notice'>Вы начинаете собирать разрушительные силы, чтобы задержать шаттл. <B>Щелкните левой кнопкой мыши, чтобы применить на цели!</B></span>"
	selection_deactivated_message	= "<span class='notice'>Ваш разум расслабляется.</span>"
	action_icon_state = "extend_shuttle"
	need_active_overlay = TRUE
	var/global/extend_limit_pressed = FALSE


/obj/effect/proc_holder/spell/shadowling_extend_shuttle/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.click_radius = -1
	T.range = 1
	return T


/obj/effect/proc_holder/spell/shadowling_extend_shuttle/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/shadowling_extend_shuttle/valid_target(mob/living/carbon/human/target, user)
	return !target.stat && !is_shadow_or_thrall(target)


/obj/effect/proc_holder/spell/shadowling_extend_shuttle/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/target = targets[1]

	if(!shadowling_check(user))
		return FALSE

	if(extend_limit_pressed)
		to_chat(user, "<span class='warning'>Шаттл уже был отложен.</span>")
		return FALSE

	if(SSshuttle.emergency.mode != SHUTTLE_CALL)
		to_chat(user, "<span class='warning'>Шаттл должен прибывать только на станцию.</span>")
		return FALSE

	user.visible_message("<span class='warning'>[user]'s глаза вспыхивают ярко-красным!</span>", \
						"<span class='notice'>Вы начинаете искривлять жизненную силу.[target]'s.</span>")
	target.visible_message("<span class='warning'>[target]'s лицо обмякает, [target.p_their()] челюсть слегка выпячена.</span>", \
						span_boldannounceic("Вы внезапно переноситесь.. далеко-далеко отсюда.."))
	extend_limit_pressed = TRUE

	if(!do_after(user, 15 SECONDS, target, max_interact_count = 1))
		extend_limit_pressed = FALSE
		to_chat(target, "<span class='warning'>Вы возвращаетесь к реальности, ваш туман рассеивается!</span>")
		to_chat(user, "<span class='warning'>Вас прервали. Попытка не состоялась.</span>")
		return

	if(QDELETED(target) || QDELETED(user))
		revert_cast(user)
		return

	to_chat(user, "<span class='notice'>Вы направляете жизненную силу [target]'s на приближающийся шаттл, продлевая время его прибытия!</span>")
	target.visible_message("<span class='warning'>[target]'s глаза внезапно вспыхивают красным. Они падают на пол, не дыша.</span>", \
						"<span class='warning'><b>..проносясь мимо.. ..красивое голубое свечение манит тебя.. ..прикоснись к нему.. ..теперь никакого свечения.. ..никакого света.. ..совсем ничего..</span>")
	target.death()
	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/timer = SSshuttle.emergency.timeLeft(1) + 10 MINUTES
		GLOB.event_announcement.Announce("Крупный системный сбой на борту эвакуационного шаттла. Это увеличит время прибытия примерно на 10 минут, шаттл не может быть отозван.", "Системный сбой.", 'sound/misc/notice1.ogg')
		SSshuttle.emergency.setTimer(timer)
		SSshuttle.emergency.canRecall = FALSE
	user.mind.RemoveSpell(src)	//Can only be used once!


// ASCENDANT ABILITIES BEYOND THIS POINT //

/obj/effect/proc_holder/spell/ascendant_annihilate
	name = "Поглощение"
	desc = "Убей кого-нибудь мгновенно."
	base_cooldown = 0
	clothes_req = FALSE
	human_req = FALSE
	action_icon_state = "annihilate"
	selection_activated_message		= "<span class='notice'>Вы начинаете думать о поглощение <B>Щелкните левой кнопкой мыши, чтобы применить на цели!</B></span>"
	selection_deactivated_message	= "<span class='notice'>Ваш разум расслабляется.</span>"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/ascendant_annihilate/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.click_radius = 1
	T.range = 7
	T.try_auto_target = FALSE
	return T


/obj/effect/proc_holder/spell/ascendant_annihilate/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/ascendant_shadowling/ascendant = user
	if(ascendant.phasing)
		to_chat(user, "<span class='warning'>Вы находитесь в разных плоскостях бытия. Сначала измените фазу.</span>")
		revert_cast(user)
		return

	var/mob/living/carbon/human/target = targets[1]

	playsound(user.loc, 'sound/magic/staff_chaos.ogg', 100, TRUE)

	if(is_shadow(target)) //Used to not work on thralls. Now it does so you can PUNISH THEM LIKE THE WRATHFUL GOD YOU ARE.
		to_chat(user, "<span class='warning'>Заставлять союзника взрываться кажется неразумным.</span>")
		revert_cast(user)
		return

	user.visible_message("<span class='danger'>[user]'s метки вспыхивают в виде жеста[user.p_they()] в [user.p_s()] в направлении [target]!</span>", \
						"<span class='shadowling'>Вы направляете копьё телекинетической энергии в [target].</span>")
	sleep(0.4 SECONDS)

	if(QDELETED(target) || QDELETED(user))
		return

	playsound(target, 'sound/magic/disintegrate.ogg', 100, TRUE)
	target.visible_message("<span class='userdanger'>[target] Взорвался!</span>")
	target.gib()


/obj/effect/proc_holder/spell/shadowling_revive_thrall/ascendant
	name = "Тёмная воля"
	desc = "Надели силой своего верного раба или возроди."
	base_cooldown = 0
	ignore_prer = TRUE
	human_req = FALSE

/obj/effect/proc_holder/spell/ascendant_hypnosis
	name = "Гипноз"
	desc = "Мгновенно завораживает человека."
	base_cooldown = 0
	clothes_req = FALSE
	human_req = FALSE
	action_icon_state = "enthrall"
	selection_activated_message		= "<span class='notice'>Вы начинаете готовиться к промыванию мозгов смертному разуму. <B>Щелкните левой кнопкой мыши, чтобы применить на цели!</B></span>"
	selection_deactivated_message	= "<span class='notice'>Ваш разум расслабляется.</span>"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/ascendant_hypnosis/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.click_radius = 0
	T.range = 7
	return T


/obj/effect/proc_holder/spell/ascendant_hypnosis/valid_target(mob/living/carbon/human/target, user)
	return !is_shadow_or_thrall(target) && target.ckey && target.mind && !target.stat


/obj/effect/proc_holder/spell/ascendant_hypnosis/cast(list/targets, mob/living/simple_animal/ascendant_shadowling/user = usr)
	if(user.phasing)
		to_chat(user, "<span class='warning'>Вы находитесь в разных плоскостях бытия. Сначала измените фазу.</span>")
		revert_cast(user)
		return

	var/mob/living/carbon/human/target = targets[1]

	target.vomit(0, VOMIT_BLOOD, distance = 2, message = FALSE)
	playsound(user.loc, 'sound/hallucinations/veryfar_noise.ogg', 50, TRUE)
	to_chat(user, "<span class='shadowling'>Вы мгновенно меняете порядок мыслей <b>[target]</b>'s, превращает [target.p_them()] в раба.</span>")
	to_chat(target, "<span class='userdanger'><font size=3>Мучительный всплеск боли пронзает твой разум, и--</font></span>")
	SSticker.mode.add_thrall(target.mind)
	target.mind.special_role = SPECIAL_ROLE_SHADOWLING_THRALL
	target.add_language(LANGUAGE_HIVE_SHADOWLING)



/obj/effect/proc_holder/spell/ascendant_phase_shift
	name = "Фазовый сдвиг"
	desc = "Перемещает вас в пространство между мирами по желанию, позволяя проходить сквозь стены и становиться невидимым."
	base_cooldown = 1.5 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	action_icon_state = "shadow_walk"


/obj/effect/proc_holder/spell/ascendant_phase_shift/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/ascendant_phase_shift/cast(list/targets, mob/living/simple_animal/ascendant_shadowling/user = usr)
	if(!istype(user))
		return

	user.phasing = !user.phasing

	if(user.phasing)
		user.visible_message("<span class='danger'>[user] внезапно исчезает!</span>", \
							"<span class='shadowling'>Вы начинаете постепенно перемещаться между фазами мироздания. Используйте эту способность снова, чтобы вернуться.</span>")
		user.incorporeal_move = INCORPOREAL_NORMAL
		user.alpha = 0
	else
		user.visible_message("<span class='danger'>[user] внезапно появляется из ниоткуда!</span>", \
							"<span class='shadowling'>Ты возвращаешься из пространства между мирами.</span>")
		user.incorporeal_move = INCORPOREAL_NONE
		user.alpha = 255


/obj/effect/proc_holder/spell/aoe/ascendant_storm
	name = "Грозовой разряд"
	desc = "Шокирует всех, кто находится поблизости."
	base_cooldown = 10 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	action_icon_state = "lightning_storm"
	aoe_range = 6


/obj/effect/proc_holder/spell/aoe/ascendant_storm/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new()
	T.range = aoe_range
	return T


/obj/effect/proc_holder/spell/aoe/ascendant_storm/cast(list/targets, mob/living/simple_animal/ascendant_shadowling/user = usr)
	if(!istype(user))
		return FALSE

	if(user.phasing)
		to_chat(user, "<span class='warning'>Вы находитесь в разных плоскостях бытия. Сначала измените фазу.</span>")
		revert_cast(user)
		return

	user.visible_message("<span class='warning'><b>Массивный шар молнии появляется в руках [user]'s и вспыхивает!</b></span>", \
						"<span class='shadowling'>Вы выпускаете шаровую молнию.</span>")
	playsound(user.loc, 'sound/magic/lightningbolt.ogg', 100, TRUE)

	for(var/mob/living/carbon/human/target in targets)
		if(is_shadow_or_thrall(target))
			continue

		to_chat(target, "<span class='userdanger'>В вас ударила молния!</span>")
		playsound(target, 'sound/magic/lightningshock.ogg', 50, 1)
		target.Weaken(16 SECONDS)
		target.take_organ_damage(0, 50)
		user.Beam(target,icon_state="red_lightning",icon='icons/effects/effects.dmi',time=1)


/obj/effect/proc_holder/spell/ascendant_transmit
	name = "Потусторонняя трансляция"
	desc = "Посылает сообщение всему миру."
	base_cooldown = 20 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	action_icon_state = "transmit"


/obj/effect/proc_holder/spell/ascendant_transmit/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/ascendant_transmit/cast(list/targets, mob/living/simple_animal/ascendant_shadowling/user = usr)
	var/text = stripped_input(user, "Что вы хотите сказать обо всем, что находится на [station_name()] и рядом с ней?.", "Передавать всему миру", "")

	if(!text)
		revert_cast(user)
		return

	user.announce(text)

