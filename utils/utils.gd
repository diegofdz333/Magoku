"""
Parses a command-line string into an array of arguments, preserving quoted strings as single arguments.
"""
func parse_arguments(command: String) -> Array[String]:
	var args: Array[String] = []
	var regex = RegEx.new()
	# Matches quotations as one argument, otherwise separate by sapce
	regex.compile("(?!\\\\)(\\\".*?[^\\\\]\\\")|(?!\\\\)('.*?[^\\\\]')|\\S+")
	var matches = regex.search_all(command)
	
	for match in matches:
		var arg = match.get_string()
		if (arg.begins_with("\"") and arg.ends_with("\"")) or (arg.begins_with("'") and arg.ends_with("'")):
			arg = arg.substr(1, arg.length() - 2) # Remove surrounding quotes
		arg = arg.replace("\\\"", "\"")
		args.append(arg)
		print(arg)
	
	return args
