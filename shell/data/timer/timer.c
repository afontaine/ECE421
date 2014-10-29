#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <time.h>
#include <limits.h>
#include <ruby.h>

static VALUE mTimer;
static VALUE cTimeCannotBeNegative;
static VALUE cTimeTooLongError;
static VALUE cMessageTooLongError;

int check_args(VALUE length, VALUE message) {
	int len = 0;
	switch(TYPE(length)) {
		case T_FIXNUM:
			len = NUM2INT(length);
			break;
		case T_BIGNUM:
			rb_raise(cTimeTooLongError, "Timer length must be less than %d", INT_MAX);
			break;
		default:
			rb_raise(rb_eTypeError, "Timer length must be a number");
			break;
	}
	if(len < 0) {
		rb_raise(cTimeCannotBeNegative, "Timer length cannot be negative");
	}
	if(RSTRING_LEN(message) > 255) {
		rb_raise(cMessageTooLongError, "Message is longer than 255 characters");
	}
	return len;
}

VALUE timer(VALUE mod, VALUE length, VALUE message) {
	struct timespec time_len;
	int len = check_args(length, message); 
	time_len.tv_sec = len;
	time_len.tv_nsec = 0;
	nanosleep(&time_len, NULL);
	return message;
}

VALUE start(VALUE mod, VALUE length, VALUE message) {
	pid_t proc;
	check_args(length, message);
	proc = fork();
	if(proc == 0) {
		return timer(mod, length, message);
	}
	return Qnil;
}

void Init_timer(void) {
	mTimer = rb_define_module("Timer");
	rb_define_module_function(mTimer, "timer", timer, 2);
	rb_define_module_function(mTimer, "start", start, 2);
	cTimeCannotBeNegative = rb_define_class_under(mTimer, "TimeCannotBeNegativeError", rb_eArgError);
	cTimeTooLongError = rb_define_class_under(mTimer, "TimeTooLongError", rb_eArgError);
	cMessageTooLongError = rb_define_class_under(mTimer, "MessageTooLongError", rb_eArgError);
}
