extends Node

class BodyPart:
	var is_intact: bool = true
	var is_not_broken: bool = true
	var is_vital: bool = false
	var wound_severity: int = 0
	var bp_name = "placeholder_name"
	var bp_health_current: int = 50
	var bp_health_max: int = 50
	var armor_amount: int = 0

	func _init(bodypart_name: String, vitality:bool = false):
		bp_name = bodypart_name
		is_vital = vitality
		log_stat()
	func take_damage(damage: int, bleed_severity):
		bp_health_current -= (damage - armor_amount)
		if bleed_severity: wound_severity = bleed_severity
		if bp_health_current <= 0:
			bp_health_current = 0
			if wound_severity:
				is_intact = false
				wound_severity = 4
				print("Bodypart %s is cut off, bleeding with %d severity." % [bp_name, wound_severity])
			else:
				is_not_broken = false
				print("Bodypart %s is broken, not bleeding" % [bp_name])
	func log_stat():
		print("BodyPart:%s:%d:%s:%s:%d" % [bp_name, bp_health_current, is_intact, is_not_broken, wound_severity])
	
class Body:
	# For later: mix health system with hemorrhage
	var sex
	var max_health: int
	var current_health: int = 1
	var total_blood: int = 5000
	var is_alive: bool = true
	var is_consious: bool = true
	var bodyparts_container = {
	# handle eyes, parts that are not intact affect stats + parser description
		"head": BodyPart.new("head", true),
		"torso": BodyPart.new("torso", true),
		"lefthand": BodyPart.new("lefthand"),
		"righthand": BodyPart.new("righthand"),
		"leftleg": BodyPart.new("leftleg"),
		"rightleg": BodyPart.new("rightleg")
	}
	func _init() -> void:
		update_max_health()
		update_current_health()
		
	func get_bodypart(bodypart_name: String):
		return bodyparts_container[bodypart_name]
		
	func kill():
		current_health = 0
		is_alive = false
		is_consious = false
		return
		
	func stun():
		current_health = 1
		is_consious = false
		return
	
	func get_bodypart_status(bodypart_name: String):
		return bodyparts_container[bodypart_name].bp_health_current
	
	func update_max_health():
		var total_hp = 0
		for part in bodyparts_container.values():
			total_hp += part.bp_health_max
		max_health = total_hp
		
	func get_max_health():
		return max_health
	
	func update_current_health():
		var total_hp = 0
		for part in bodyparts_container.values():
			total_hp += part.bp_health_current
		current_health = total_hp
		if !current_health: kill()
		
	func get_current_health():
		return current_health
		
	# rewrite logic, get stunned on low health
	func bodypart_get_hit(bodypart_name, damage_amount: int, bleed_severity: int = 0):
		var target_bp = bodyparts_container[bodypart_name]
		if target_bp.is_intact and target_bp.is_not_broken:
			target_bp.take_damage(damage_amount, bleed_severity)
			if target_bp.is_vital:
				if !target_bp.is_not_broken: stun()
				if !target_bp.is_intact: kill()
			update_current_health()
		else: print("Bodypart %s is already missing or broken." % bodypart_name)
		target_bp.log_stat()