class_name B extends A

func _ready():
	print("ready says myvar is:", self.myvar)
	self.myvar = "B"
	print("I changed it to:", self.myvar)
