/obj/item/clothing/under/shadowling
	name = "blackened flesh"
	ru_names = list(
		NOMINATIVE = "почерневшая плоть",
		GENITIVE = "почерневшей плоти",
		DATIVE = "почерневшей плоти",
		ACCUSATIVE = "почерневшая плоть",
		INSTRUMENTAL = "почерневшей плотью",
		PREPOSITIONAL = "почерневшей плоти"
	)
	desc = "Черная хитиновая кожа с тонкими красными прожилками."
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_uniform"
	origin_tech = null
	item_flags = ABSTRACT|DROPDEL
	has_sensor = FALSE
	displays_id = FALSE
	onmob_sheets = list(
		ITEM_SLOT_CLOTH_INNER_STRING = NONE
	)
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF


/obj/item/clothing/under/shadowling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)


/obj/item/clothing/suit/space/shadowling
	name = "chitin shell"
	ru_names = list(
		NOMINATIVE = "хитиновый панцирь",
		GENITIVE = "хитинового панциря",
		DATIVE = "хитиновому панцирю",
		ACCUSATIVE = "хитиновый панцирь",
		INSTRUMENTAL = "хитиновым панцирем",
		PREPOSITIONAL = "хитиновом панцире"
	)
	desc = "Тёмная полупрозрачная оболочка. Защищает от вакуума, но не от света звёзд." //Still takes damage from spacewalking but is immune to space itself
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_suit"
	body_parts_covered = FULL_BODY //Shadowlings are immune to space
	cold_protection = FULL_BODY
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT
	onmob_sheets = list(
		ITEM_SLOT_CLOTH_OUTER_STRING = NONE
	)
	slowdown = 0
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	heat_protection = null //You didn't expect a light-sensitive creature to have heat resistance, did you?
	max_heat_protection_temperature = null
	armor = list(melee = 25, bullet = 25, laser = 0, energy = 10, bomb = 25, bio = 100, rad = 100, fire = 100, acid = 100)
	item_flags = ABSTRACT|DROPDEL
	species_restricted = null


/obj/item/clothing/suit/space/shadowling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)


/obj/item/clothing/shoes/shadowling
	name = "chitin feet"
	ru_names = list(
		NOMINATIVE = "хитиновые лапы",
		GENITIVE = "хитиновых лап",
		DATIVE = "хитиновым лапам",
		ACCUSATIVE = "хитиновые лапы",
		INSTRUMENTAL = "хитиновыми лапами",
		PREPOSITIONAL = "хитиновых лапах"
	)
	desc = "Лапы выглядят обугленными. У них есть маленькие крючки, которые цепляются за пол."
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_shoes"
	onmob_sheets = list(
		ITEM_SLOT_FEET_STRING = NONE
	)

	resistance_flags = LAVA_PROOF|FIRE_PROOF|ACID_PROOF
	item_flags = ABSTRACT|DROPDEL
	clothing_traits = list(TRAIT_NO_SLIP_ALL)


/obj/item/clothing/shoes/shadowling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)


/obj/item/clothing/mask/gas/shadowling
	name = "chitin mask"
	ru_names = list(
		NOMINATIVE = "хитиновая маска",
		GENITIVE = "хитиновой маски",
		DATIVE = "хитиновой маске",
		ACCUSATIVE = "хитиновая маска",
		INSTRUMENTAL = "хитиновыми масками",
		PREPOSITIONAL = "хитиновых масках"
	)
	desc = "Похожее на маску образование с прорезями для черт лица. Красная пленка покрывает глаза."
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_mask"
	onmob_sheets = list(
		ITEM_SLOT_MASK_STRING = NONE
	)
	origin_tech = null
	siemens_coefficient = 0
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	item_flags = ABSTRACT|DROPDEL
	flags_cover = MASKCOVERSEYES	//We don't need to cover mouth


/obj/item/clothing/mask/gas/shadowling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)


/obj/item/clothing/gloves/shadowling
	name = "chitin hands"
	ru_names = list(
		NOMINATIVE = "хитиновые перчатки",
		GENITIVE = "хитиновых перчатках",
		DATIVE = "хитиновым перчатками",
		ACCUSATIVE = "хитиновые перчатки",
		INSTRUMENTAL = "хитиновыми перчатками",
		PREPOSITIONAL = "хитиновых перчатках"
	)
	desc = "Электростойкое покрытие для рук."
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_gloves"
	onmob_sheets = list(
		ITEM_SLOT_GLOVES_STRING = NONE
	)
	origin_tech = null
	siemens_coefficient = 0
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	item_flags = ABSTRACT|DROPDEL


/obj/item/clothing/gloves/shadowling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)


/obj/item/clothing/head/shadowling
	name = "chitin helm"
	ru_names = list(
		NOMINATIVE = "хитиновый шлем",
		GENITIVE = "хитинового шлема",
		DATIVE = "хитиновым шлемам",
		ACCUSATIVE = "хитиновый шлем",
		INSTRUMENTAL = "хитиновыми шлемами",
		PREPOSITIONAL = "хитиновых шлемах"
	)
	desc = "Шлемообразное ограждение головы."
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_helmet"
	onmob_sheets = list(
		ITEM_SLOT_HEAD_STRING = NONE
	)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	origin_tech = null
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	clothing_flags = STOPSPRESSUREDMAGE
	item_flags = ABSTRACT|DROPDEL
	flags_cover = HEADCOVERSEYES	//We don't need to cover mouth


/obj/item/clothing/head/shadowling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)


/obj/item/clothing/glasses/shadowling
	name = "crimson eyes"
	ru_names = list(
		NOMINATIVE = "багровые очки",
		GENITIVE = "багровых очков",
		DATIVE = "багровым очкам",
		ACCUSATIVE = "багровые очки",
		INSTRUMENTAL = "багровыми очками",
		PREPOSITIONAL = "багровых очках"
	)
	desc = "Очки из глаз сумеречного существа. Очень чувствительны к свету и могут улавливать тепло тела сквозь стены."
	icon = 'icons/obj/clothing/species/shadowling/shadowling_clothes.dmi'
	icon_state = "shadowling_glasses"
	onmob_sheets = list(
		ITEM_SLOT_EYES_STRING = NONE
	)
	origin_tech = null
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flash_protect = FLASH_PROTECTION_SENSITIVE
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	item_flags = ABSTRACT|DROPDEL


/obj/item/clothing/glasses/shadowling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

