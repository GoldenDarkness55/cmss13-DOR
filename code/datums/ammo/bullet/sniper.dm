/*
//======
					Sniper Ammo
//======
*/

/datum/ammo/bullet/sniper
	name = "sniper bullet"
	headshot_state = HEADSHOT_OVERLAY_HEAVY
	damage_falloff = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SNIPER|AMMO_IGNORE_COVER
	accurate_range_min = 4

	accuracy = HIT_ACCURACY_TIER_8
	accurate_range = 32
	max_range = 32
	scatter = 0
	damage = 70
	penetration= ARMOR_PENETRATION_TIER_10
	shell_speed = AMMO_SPEED_TIER_6
	damage_falloff = 0

/datum/ammo/bullet/sniper/on_hit_mob(mob/M,obj/projectile/P)
	if((P.projectile_flags & PROJECTILE_BULLSEYE) && M == P.original)
		var/mob/living/L = M
		L.apply_armoured_damage(damage*2, ARMOR_BULLET, BRUTE, null, penetration)
		to_chat(P.firer, SPAN_WARNING("Bullseye!"))

/datum/ammo/bullet/sniper/incendiary
	name = "incendiary sniper bullet"
	damage_type = BRUTE
	shrapnel_chance = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SNIPER|AMMO_IGNORE_COVER

	//Removed accuracy = 0, accuracy_var_high = Variance Tier 6, and scatter = 0. -Kaga
	damage = 60
	penetration = ARMOR_PENETRATION_TIER_4

/datum/ammo/bullet/sniper/incendiary/set_bullet_traits()
	. = ..()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_incendiary)
	))

/datum/ammo/bullet/sniper/incendiary/on_hit_mob(mob/M,obj/projectile/P)
	if((P.projectile_flags & PROJECTILE_BULLSEYE) && M == P.original)
		var/mob/living/L = M
		var/blind_duration = 5
		if(isxeno(M))
			var/mob/living/carbon/xenomorph/target = M
			if(target.mob_size >= MOB_SIZE_BIG)
				blind_duration = 2
		L.AdjustEyeBlur(blind_duration)
		L.adjust_fire_stacks(10)
		to_chat(P.firer, SPAN_WARNING("Bullseye!"))

/datum/ammo/bullet/sniper/flak
	name = "flak sniper bullet"
	damage_type = BRUTE
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SNIPER|AMMO_IGNORE_COVER

	accuracy = HIT_ACCURACY_TIER_8
	scatter = SCATTER_AMOUNT_TIER_8
	damage = 55
	damage_var_high = PROJECTILE_VARIANCE_TIER_8 //Documenting old code: This converts to a variance of 96-109% damage. -Kaga
	penetration = ARMOR_PENETRATION_TIER_4

/datum/ammo/bullet/sniper/flak/on_hit_mob(mob/M,obj/projectile/P)
	if((P.projectile_flags & PROJECTILE_BULLSEYE) && M == P.original)
		var/slow_duration = 3.5
		var/mob/living/L = M
		if(isxeno(M))
			var/mob/living/carbon/xenomorph/target = M
			if(target.mob_size >= MOB_SIZE_BIG)
				slow_duration = 2
		M.adjust_effect(slow_duration, SUPERSLOW)
		L.apply_armoured_damage(damage*1, ARMOR_BULLET, BRUTE, null, penetration)
		to_chat(P.firer, SPAN_WARNING("Bullseye!"))
	else
		burst(get_turf(M),P,damage_type, 2 , 2)
		burst(get_turf(M),P,damage_type, 1 , 2 , 0)

/datum/ammo/bullet/sniper/flak/on_near_target(turf/T, obj/projectile/P)
	burst(T,P,damage_type, 2 , 2)
	burst(T,P,damage_type, 1 , 2, 0)
	return 1

/datum/ammo/bullet/sniper/crude
	name = "crude sniper bullet"
	damage = 42
	penetration = ARMOR_PENETRATION_TIER_6

/datum/ammo/bullet/sniper/crude/on_hit_mob(mob/M, obj/projectile/P)
	. = ..()
	pushback(M, P, 3)

/datum/ammo/bullet/sniper/upp
	name = "armor-piercing sniper bullet"
	damage = 80
	penetration = ARMOR_PENETRATION_TIER_10

/datum/ammo/bullet/sniper/anti_materiel
	name = "anti-materiel sniper bullet"

	shrapnel_chance = 0 // This isn't leaving any shrapnel.
	accuracy = HIT_ACCURACY_TIER_8
	damage = 125
	shell_speed = AMMO_SPEED_TIER_6
	penetration = ARMOR_PENETRATION_TIER_10 + ARMOR_PENETRATION_TIER_5

/datum/ammo/bullet/sniper/anti_materiel/proc/stopping_power_knockback(mob/living/living_mob, obj/projectile/fired_projectile)
	var/stopping_power = min(CEILING((fired_projectile.damage/30), 1), 5) // This is from bullet damage, and does not take Aimed Shot into account.

	if(!living_mob || living_mob == fired_projectile.firer)
		return stopping_power

	if(stopping_power > 2)

		// Depending on target size and damage, may apply a mini-stun to interrupt channels. Support your allies!
		// For reference: Scout Impact stuns for up to 1s and slows for up to 10s, Shotgun stuns for 1.4s and slows for 4s
		if(living_mob.mob_size >= MOB_SIZE_BIG)
			// If above 90 damage, screenshake. This maxes out at (2,3), weaker than other impact rounds.
			if(stopping_power > 3)
				shake_camera(living_mob, (stopping_power - 3), (stopping_power - 2))
			if(HAS_TRAIT(living_mob, TRAIT_CHARGING) && isxeno(living_mob))
				to_chat(living_mob, SPAN_WARNING("A sudden massive impact strikes you, but your charge will not be stopped!"))
				return stopping_power
			if(stopping_power >= 4)
				to_chat(living_mob, SPAN_XENOHIGHDANGER("You are knocked off-balance by the sudden massive impact!"))
				if(living_mob.mob_size >= MOB_SIZE_IMMOBILE && !((fired_projectile.projectile_flags & PROJECTILE_BULLSEYE) && living_mob == fired_projectile.original)) // Queens and Crushers
					return stopping_power // For Crushers and Queens, must be aimed at them.
				living_mob.KnockDown(0.05) // Must deal more than 90 damage to mini-stun big mobs for 0.1s
				// Can't interrupt a big mob unless it's completely alone with nothing blocking the shot.
			else
				to_chat(living_mob, SPAN_XENODANGER("You are shaken by the sudden heavy impact!"))
		else
			// If above 60 damage, screenshake. This maxes out at (3,4) like buckshot and heavy rounds. (1,2) (2,3) or (3,4)
			shake_camera(living_mob, (stopping_power - 2), (stopping_power - 1))
			if(living_mob.body_position != LYING_DOWN)
				to_chat(living_mob, SPAN_XENOHIGHDANGER("You are thrown back by the sudden massive force!"))
				slam_back(living_mob, fired_projectile)
			else
				to_chat(living_mob, SPAN_XENODANGER("You are shaken by the sudden heavy impact!"))

			if(isxeno(living_mob))
				living_mob.KnockDown((stopping_power - 2)*0.05) // Up to 0.3s on a solo target.
			else
				if(living_mob.stamina)
					living_mob.apply_stamina_damage(fired_projectile.ammo.damage, fired_projectile.def_zone, ARMOR_BULLET)
					// Not sure what this comes out to exactly, but follows the example of other heavy ammo like slugs of applying full base damage as stamina damage.
				else
					living_mob.KnockDown((stopping_power - 2)*0.3) // Rare exception of up to 1.8s on non-xenos without stamina.

	return stopping_power

/datum/ammo/bullet/sniper/anti_materiel/on_hit_mob(mob/target_mob,obj/projectile/aimed_projectile)

	var/mob/living/living_target = target_mob

	var/stopping_power = stopping_power_knockback(living_target, aimed_projectile)

	if((aimed_projectile.projectile_flags & PROJECTILE_BULLSEYE) && target_mob == aimed_projectile.original)

		var/size_damage_mod = 0.6 // 1.6x vs Non-Xenos (200)
		var/size_current_health_damage = 0 // % Current Health calculation, only used for Xeno calculations at the moment.
		var/slow_duration = stopping_power // Based on damage dealt.

		if(slow_duration <= 2) // Must be over 60 base damage.
			slow_duration = 0

		if(isxeno(target_mob))
			var/mob/living/carbon/xenomorph/target = target_mob
			size_damage_mod -= 0.3 // Down to 1.3x damage, 162.
			size_current_health_damage = 0.1 // 1.3x Damage + 10% current health (162 + 10%, 185 vs Runners)

			if(target.mob_size >= MOB_SIZE_XENO)
				size_current_health_damage += 0 // 1.3x Damage + 10% current health
				slow_duration = max(slow_duration-1, 0)

			if(target.mob_size >= MOB_SIZE_BIG)
				size_damage_mod -= 0.2 // Down to 1.1x Damage.
				size_current_health_damage += 0.1 // 1x Damage + 20% current health.
				slow_duration = max(slow_duration-1, 0)
				// Most T3s have around 650 to 700 HP, meaning the health modifier grants a MAXIMUM of around 130-140 damage for a total max of 267-277. This is at max HP.
				// Queen takes around 340 at max health.
				// At low health, does little more than a normal shot. Does WORSE than a normal shot if unfocused and hitting through blockers, all of which stack to reduce it.

			var/final_xeno_damage = ((damage * size_damage_mod) + ((target.health + damage) * size_current_health_damage))

			living_target.apply_armoured_damage((final_xeno_damage), ARMOR_BULLET, BRUTE, null, penetration)

		else
			living_target.apply_armoured_damage((damage*size_damage_mod), ARMOR_BULLET, BRUTE, null, penetration)

		if(slow_duration && (living_target.mob_size != MOB_SIZE_XENO_SMALL) && !(HAS_TRAIT(living_target, TRAIT_CHARGING))) // Runners and Charging Crushers are not slowed.
			living_target.Slow((slow_duration / 2))
			if(slow_duration >= 2)
				living_target.Superslow((slow_duration / 4))
		if(stopping_power > 3)
			living_target.Daze(0.1) // Visual cue that you got hit by something HARD.

		// Base 1.6x damage to non-xeno targets (200), 1.3x + 10% current against Runners (185), 1.3x + 10% current health against most non-Runner xenos, and 1.1x + 20% current health against Big xenos. -Kaga
		// This applies after pen reductions. After hitting 1 other thing, it deals 80% damage, or 40% after hitting a dense wall or big xeno.

		if(isxeno(target_mob) && !(target_mob.is_dead()))
			to_chat(aimed_projectile.firer, SPAN_WARNING("Bullseye!"))

/datum/ammo/bullet/sniper/anti_materiel/set_bullet_traits()
	. = ..()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_penetrating/weak)
	))

/datum/ammo/bullet/sniper/anti_materiel/vulture
	damage = 400 // Fully intended to vaporize anything smaller than a mini cooper
	accurate_range_min = 10
	handful_state = "vulture_bullet"
	sound_hit = 'sound/bullets/bullet_vulture_impact.ogg'
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SNIPER|AMMO_IGNORE_COVER|AMMO_ANTIVEHICLE

/datum/ammo/bullet/sniper/anti_materiel/vulture/on_hit_mob(mob/hit_mob, obj/projectile/bullet)
	. = ..()
	knockback(hit_mob, bullet, 30)
	hit_mob.apply_effect(3, SLOW)

/datum/ammo/bullet/sniper/anti_materiel/vulture/set_bullet_traits()
	. = ..()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_penetrating/heavy)
	))

/datum/ammo/bullet/sniper/anti_materiel/vulture/holo_target
	name = "holo-targeting anti-materiel sniper bullet"
	damage = 60 // it's a big bullet but its purpose is to support marines, not to kill enemies by itself
	/// inflicts this many holo stacks per bullet hit
	var/holo_stacks = 333
	/// modifies the default cap limit of 100 by this amount
	var/bonus_damage_cap_increase = 233
	/// multiplies the default drain of 5 holo stacks per second by this amount
	var/stack_loss_multiplier = 2

/datum/ammo/bullet/sniper/anti_materiel/vulture/holo_target/on_hit_mob(mob/hit_mob, obj/projectile/bullet)
	hit_mob.AddComponent(/datum/component/bonus_damage_stack, holo_stacks, world.time, bonus_damage_cap_increase, stack_loss_multiplier)
	playsound(hit_mob, 'sound/weapons/gun_vulture_mark.ogg', 40)
	to_chat(hit_mob, isxeno(hit_mob) ? SPAN_XENOHIGHDANGER("It feels as if we were MARKED FOR DEATH!") : SPAN_HIGHDANGER("It feels as if you were MARKED FOR DEATH!"))
	hit_mob.balloon_alert_to_viewers("marked for death!")

// the effect should be limited to one target, with IFF to compensate how hard it will be to hit these shots
/datum/ammo/bullet/sniper/anti_materiel/vulture/holo_target/set_bullet_traits()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_iff)
	))

/datum/ammo/bullet/sniper/elite
	name = "supersonic sniper bullet"

	shrapnel_chance = 0 // This isn't leaving any shrapnel.
	accuracy = HIT_ACCURACY_TIER_8
	damage = 150
	shell_speed = AMMO_SPEED_TIER_6 + AMMO_SPEED_TIER_2
	penetration = ARMOR_PENETRATION_TIER_10 + ARMOR_PENETRATION_TIER_5

/datum/ammo/bullet/sniper/elite/set_bullet_traits()
	. = ..()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_penetrating)
	))

/datum/ammo/bullet/sniper/elite/on_hit_mob(mob/M,obj/projectile/P)
	if((P.projectile_flags & PROJECTILE_BULLSEYE) && M == P.original)
		var/mob/living/L = M
		var/size_damage_mod = 0.5
		if(isxeno(M))
			var/mob/living/carbon/xenomorph/target = M
			if(target.mob_size >= MOB_SIZE_XENO)
				size_damage_mod += 0.5
			if(target.mob_size >= MOB_SIZE_BIG)
				size_damage_mod += 1
			L.apply_armoured_damage(damage*size_damage_mod, ARMOR_BULLET, BRUTE, null, penetration)
		else
			L.apply_armoured_damage(damage, ARMOR_BULLET, BRUTE, null, penetration)
		// 150% damage to runners (225), 300% against Big xenos (450), and 200% against all others (300). -Kaga
		to_chat(P.firer, SPAN_WARNING("Bullseye!"))
