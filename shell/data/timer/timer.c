#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <time.h>

static VALUE mTimer;
static VALUE cTimeCannotBeNegative;
static VALUE cTimeTooLongError;
static VALUE cMessageTooLongError;

VALUE timer(VALUE length, VALUE message) {
	struct timespec len;
	len.tv_sec = FIX2INT(length);
	len.tv_nsec = 0;
	nanosleep(&len, NULL);
	printf("%s", StringValueCStr(message));
	return message;
}

VALUE start(VALUE length, VALUE message) {
	int len = rb_rescue(FIX2INT, length, rb_raise, cTimeTooLongError);
	if(len < 0) {
		rb_raise(cTimeCannotBeNegative, "Timer length cannot be negative");
	}
	if(RSTRING_LEN(message) > 255) {
		rb_raise(cMessageTooLongError, "Message is longer than 255 characters");
	}
	pid_t proc;
	proc = fork();
	if(proc == 0) {
		return timer(length, message);
	}
	return Qnil;
}

void Init_timer(void) {
	mTimer = rb_define_module("Timer");
	rb_define_module_function(mTimer, "timer", timer, 2);
	rb_define_module_function(mTimer, "start", start, 2);
	cTimeCannotBeNegative = rb_define_class_under(mTimer, "TimeCannotBeNegative", rb_eArgumentError);
	cTimeTooLongError = rb_define_class_under(mTimer, "TimeTooLongError", rb_eArgumentError);
	cMessageTooLongError = rb_define_class_under(mTimer, "MessageTooLongError", rb_eArgumentError);
}
