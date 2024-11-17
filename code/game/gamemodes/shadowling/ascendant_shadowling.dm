/mob/living/simple_animal/ascendant_shadowling
	name = "ascendant shadowling"
	ru_names = list(
		NOMINATIVE = "восходящий тенелинг",
		GENITIVE = "восходящего тенелинга",
		DATIVE = "восходящему тенелингу",
		ACCUSATIVE = "восходящий тенелинг",
		INSTRUMENTAL = "восходящим тенелингом",
		PREPOSITIONAL = "восходящем тенелинге"
	)
	desc = "Большой, парящий в воздухе жуткий монстр. У него пульсирующие отметины по всему телу и большие рога. Кажется, что он летит без какой-либо поддержки."
	icon = 'icons/mob/mob.dmi'
	icon_state = "shadowling_ascended"
	icon_living = "shadowling_ascended"
	speak = list("Azima'dox", "Mahz'kavek", "N'ildzak", "Kaz'vadosh")
	speak_emote = list("telepathically thunders", "telepathically booms")
	force_threshold = INFINITY //Can't die by normal means
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS
	health = 100000
	maxHealth = 100000
	speed = 0
	var/phasing = 0
	nightvision = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	universal_speak = 1

	response_help   = "пристально смотрит на"
	response_disarm = "цепляется за"
	response_harm   = "цепляется за"

	harm_intent_damage = 0
	melee_damage_lower = 60 //Was 35, buffed
	melee_damage_upper = 60
	attacktext = "кромсает"
	attack_sound = 'sound/weapons/slash.ogg'

	environment_smash = ENVIRONMENT_SMASH_RWALLS

	faction = list("faithless")


/mob/living/simple_animal/ascendant_shadowling/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/simple_flying)
	if(prob(35))
		icon_state = "NurnKal"
		icon_living = "NurnKal"
	update_icon(UPDATE_OVERLAYS)

/mob/living/simple_animal/ascendant_shadowling/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		maxbodytemp = INFINITY, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/ascendant_shadowling/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE //copypasta from carp code

/mob/living/simple_animal/ascendant_shadowling/ex_act(severity)
	return //You think an ascendant can be hurt by bombs? HA

/mob/living/simple_animal/ascendant_shadowling/singularity_act()
	return 0 //Well hi, fellow god! How are you today?


/mob/living/simple_animal/ascendant_shadowling/update_overlays()
	. = ..()
	. += "shadowling_ascended_ms"


/mob/living/simple_animal/ascendant_shadowling/proc/announce(text, size = 4, new_sound = null)
	var/message = "<font size=[size]><span class='shadowling'><b>\"[text]\"</font></span>"
	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M) && M.client)
			to_chat(M, message)
			if(new_sound)
				M << new_sound
