extends RichTextLabel

# Adds a line to the console text
func add_line(line: String):
	append_text("\n" + line)

func add_error_line(line: String):
	append_text("\n[color=red]%s[/color]" % line)
