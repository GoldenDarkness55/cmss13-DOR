//Slowing spit
/datum/action/xeno_action/activable/slowing_spit
	name = "Slowing Spit"
	action_icon_state = "xeno_spit"
	ability_name = "slowing spit"
	macro_path = /datum/action/xeno_action/verb/verb_slowing_spit
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_1
	xeno_cooldown = 2 SECONDS
	plasma_cost = 20

// Scatterspit
/datum/action/xeno_action/activable/scattered_spit
	name = "Scattered Spit"
	action_icon_state = "acid_shotgun"
	ability_name = "scattered spit"
	macro_path = /datum/action/xeno_action/verb/verb_scattered_spit
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_2
	xeno_cooldown = 5 SECONDS
	plasma_cost = 30

// Paralyzing slash
/datum/action/xeno_action/onclick/paralyzing_slash
	name = "Paralyzing Slash"
	action_icon_state = "lurker_inject_neuro"
	ability_name = "paralyzing slash"
	macro_path = /datum/action/xeno_action/verb/verb_paralyzing_slash
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_3
	xeno_cooldown = 12 SECONDS
	plasma_cost = 50

	var/buff_duration = 50

/datum/action/xeno_action/activable/hibernate
	name = "hibernate"
	action_icon_state = "warden_heal"
	ability_name = "hibernate"
	macro_path = /datum/action/xeno_action/verb/verb_hibernate
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_4
	xeno_cooldown = 50 SECONDS
	plasma_cost = 150

	var/regeneration_amount_total = 500
	var/regeneration_ticks = 10
	var/plasma_amount = 400
	var/plasma_time = 10
	var/time_between_plasmas = 1
