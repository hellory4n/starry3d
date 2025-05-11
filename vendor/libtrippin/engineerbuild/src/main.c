#include "staticlib.h"
#include "sharedlib.h"
#include "test.h"

int main(void) {
	testma();
	staticlib_crap();
	sharedlib_crap();
	return 0;
}
