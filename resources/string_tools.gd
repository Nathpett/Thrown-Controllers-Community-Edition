class_name StringTools
extends Node



static func rjust(value, filler: String, length: int) -> String:
	value = str(value)
	var filled_string = ""
	for i in range(length):
		filled_string += filler
	return filled_string.right(length - len(str(value))) + str(value)


static func stringify_date(date: Dictionary) -> String:
	return "%s-%s-%s_%s-%s-%s" % [date["year"], rjust(date["month"], "0", 2), rjust(date["day"], "0", 2), \
								rjust(date["hour"], "0", 2), rjust(date["minute"], "0", 2), rjust(date["second"], "0", 2)]


static func get_handsom_date(time_string: String) -> String:
	# auto_save_2023-06-17_11-32-43.json -> Jun 17th 2023 11:32:43
#	var string_date = file.get_basename().right(19)
	time_string = time_string.replace("_", "-")
	var date_array = time_string.split("-")
	
	var year = date_array[0]
	var month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"][int(date_array[1]) - 1]
	var day = get_ord(date_array[2])
	
	var time = "%s:%s:%s" % [date_array[3], date_array[3], date_array[5]]
	
	return "%s %s %s %s" % [month, day, year, time]


static func get_ord(idx) -> String:
	var num = str(idx)
	var last_two = int(num.right(2))
	
	if last_two >= 11 and last_two <= 13:
		return num + "th"
	
	var last_one = int(num.right(1))
	if last_one == 1:
		return num + "st"
	if last_one == 2:
		return num + "nd"
	if last_one == 3:
		return num + "rd"
	
	return num + "th"
