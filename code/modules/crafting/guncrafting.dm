// This file is for projectile weapon crafting. All parts and construction paths will be contained here.
// The weapons themselves are children of other weapons and should be contained in their respective files.

// PARTS //

/obj/item/weaponcrafting/receiver
	name = "modular receiver"
	desc = "Прототип модульной ствольной коробки и спускового механизма для огнестрельного оружия."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "receiver"

/obj/item/weaponcrafting/stock
	name = "rifle stock"
	desc = "Классический приклад винтовки, который одновременно служит рукояткой, грубо вырезан из дерева."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "riflestock"

/obj/item/weaponcrafting/revolverbarrel
	name = "improvised revolver barrel"
	desc = "Грубо сделанный револьверный ствол."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "rev_barrel"
	w_class = WEIGHT_CLASS_SMALL
	var/new_fire_sound = 'sound/weapons/gunshots/1rev257.ogg'

/obj/item/weaponcrafting/revolverbarrel/steel
	name = "steel revolver barrel"
	desc = "Ствол пистолета из высококачественной тяжелой стали для повышения устойчивости."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "s_rev_barrel"
	new_fire_sound = 'sound/weapons/gunshots/1rev257S.ogg'


// CRAFTING //

/obj/item/weaponcrafting/receiver/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pipe))
		if(loc == user && !user.can_unEquip(src))
			return ..()
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		add_fingerprint(user)
		to_chat(user, "Вы прикрепляете ствол дробовика к ствольной коробке. Кажется, что штифты ослаблены.")
		var/obj/item/weaponcrafting/ishotgunconstruction/construct = new(drop_location())
		transfer_fingerprints_to(construct)
		I.transfer_fingerprints_to(construct)
		construct.add_fingerprint(user)
		if(loc == user)
			user.temporarily_remove_item_from_inventory(src)
		user.put_in_hands(construct, ignore_anim = FALSE)
		qdel(I)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

// SHOTGUN //

/obj/item/weaponcrafting/ishotgunconstruction
	name = "slightly conspicuous metal construction"
	desc = "Длинная труба, прикрепленная к ствольной коробке огнестрельного оружия. Кажется, что штифты расшатаны."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "ishotgunstep1"


/obj/item/weaponcrafting/ishotgunconstruction/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	var/obj/item/weaponcrafting/ishotgunconstruction2/construct = new(drop_location())
	transfer_fingerprints_to(construct)
	construct.add_fingerprint(user)
	user.temporarily_remove_item_from_inventory(src, force = TRUE)
	user.put_in_hands(construct, ignore_anim = FALSE)
	to_chat(user, span_notice("Вы вкручиваете штифты на место, закрепляя трубу на приемнике."))
	qdel(src)


/obj/item/weaponcrafting/ishotgunconstruction2
	name = "very conspicuous metal construction"
	desc = "Длинная труба, прикрепленная к спусковому механизму."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "ishotgunstep1"


/obj/item/weaponcrafting/ishotgunconstruction2/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weaponcrafting/stock))
		if(loc == user && !user.can_unEquip(src))
			return ..()
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You attach the stock to the receiver-barrel assembly."))
		var/obj/item/weaponcrafting/ishotgunconstruction3/construct = new(drop_location())
		transfer_fingerprints_to(construct)
		I.transfer_fingerprints_to(construct)
		construct.add_fingerprint(user)
		if(loc == user)
			user.temporarily_remove_item_from_inventory(src)
		user.put_in_hands(construct, ignore_anim = FALSE)
		qdel(I)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/weaponcrafting/ishotgunconstruction3
	name = "extremely conspicuous metal construction"
	desc = "Дробовик в сборе со ствольной коробкой и незакрепленным деревянным прикладом. Вы не сможете выстрелить из него без того, чтобы приклад не отвалился."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "ishotgunstep2"


/obj/item/weaponcrafting/ishotgunconstruction3/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/packageWrap))
		add_fingerprint(user)
		var/obj/item/stack/packageWrap/wrap = I
		if(loc == user && !user.can_unEquip(src))
			return ..()
		if(!wrap.use(5))
			to_chat(user, span_warning("Вам понадобится не менее пяти футов оберточной бумаги, чтобы закрепить заготовку."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("Вы обвязываете оберточной бумагой приклад и ствол, чтобы закрепить его."))
		var/obj/item/gun/projectile/revolver/doublebarrel/improvised/shotta = new(drop_location())
		transfer_fingerprints_to(shotta)
		shotta.add_fingerprint(user)
		investigate_log("[key_name_log(user)] crafted [shotta]", INVESTIGATE_CRAFTING)
		if(loc == user)
			user.temporarily_remove_item_from_inventory(src)
		user.put_in_hands(shotta, ignore_anim = FALSE)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

