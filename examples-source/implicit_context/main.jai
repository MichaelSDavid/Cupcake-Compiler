#import "../../modules/Print.jai";

#run main();
main :: () {
	print("%\n", #type () -> Void);

	test_log();

	// Setup new context based of the previous one
	new_context := << context;
	new_context.logger = my_log_function;

	push_context *new_context { // push_context expects a pointer
		test_log()
	}
}

test_log :: () {
	print("Current Context: %\n%\n\n", context, << context);

	// The first time this is called (line 8) there will be nothing printed. 
	// The default log procedure ignore every log message.
	log("Everything is working correctly!", "Implicit Context", Log_Mode.VERBOSE);

	print("\n\n");
	print("---------------------------------------------\n");
}

my_log_function :: (message: String, ident: String, mode: Log_Mode, data: *Void) {
	print("[%][%]: %\n", ident, mode, message);
}
