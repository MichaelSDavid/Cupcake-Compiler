#import "../../modules/Print.jai"

#run main()
main :: () {
	bottles := 99
	while bottles > 0 {
	    print("% bottles of beer on the wall\n", bottles)
	    print("% bottles of beer\n", bottles)
	    print("Take one down, pass it around\n")
	    print("% bottles of beer on the wall\n\n", bottles - 1)
	    bottles -= 1;
  	}

}