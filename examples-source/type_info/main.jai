#import "../../modules/Print.jai"
#import "../../modules/Math.jai"

#run main()
main :: () {

	A := 19
	B :: #type *Allocator

	// print_type(type_info(A)) print("\n") // ERROR: type_info expects a Type, this will not work.
	print_type(type_info(type_of(A))) print("\n")
	print_type(type_info(B)) print("\n")
	print("\n")

	// The "standard" print procedure when passed a Type will print the type.
	print("A: %\n", type_of(A))
	print("B: %\n", B)
}

print_type :: (info: *Type_Info) {
	using Type_Info_Tag
	tag := info.type

	if tag == INTEGER {
		integer_info := cast(*Type_Info_Integer) info
		if integer_info.signed 
			print("S%", integer_info.size_in_bits) 
		else
			print("U%", integer_info.size_in_bits) 
	}

	else if tag == POINTER {
		pointer_info := cast(*Type_Info_Pointer) info
		print("*")
		print_type(pointer_info.pointer_to)
	}

	else if tag == ALIAS {
		alias_info := cast(*Type_Info_Alias) info
		print(alias_info.name)
	}

	// TODO: Add every type
	else print("(unknown type)")
}

