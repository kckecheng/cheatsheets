#!/usr/bin/env python
from functools import wraps


# decorator w/o parameters
def decorator_wo_params(f):
	@wraps(f)
	def wrapper(*args, **kwargs):
		print('Calling decorated function from decorator_wo_params')
		return f(*args, **kwargs)
	return wrapper

# decorator w/ parameters
def decorator_w_params(arg1, arg2):
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            print("Processing decorator parameters")
            print(arg1, arg2)

            print('Calling decorated function from decorator_w_params')
            return f(*args, **kwargs)
        return wrapper
    return decorator

def decorator_class_method(arg1, arg2):
    def decorator(f):
        @wraps(f)
        def wrapper(self, *args, **kwargs):
            print("Processing class method decorator parameters")
            print(arg1, arg2)

            print('Calling decorated function from decorator_w_params')
            return f(self, *args, **kwargs)
        return wrapper
    return decorator

@decorator_wo_params
def sample1(arg1, kwarg1='kwarg1'):
    print("From sample1")
    print(arg1, kwarg1)

@decorator_w_params("d_arg1", "d_arg2")
def sample2(arg1, kwarg1='kwarg1'):
    print("From sample2")
    print(arg1, kwarg1)

class DemoC(object):
    @decorator_class_method("c_arg1", 'c_arg2')
    def sample3(self, arg1, kwarg1='kwarg1'):
        print("From class method sample3")
        print(arg1, kwarg1)

if __name__ == '__main__':
    sample1("s1_arg1", "s1_kwarg1")
    sample2("s2_arg1", "s2_kwarg1")
    DemoC().sample3("s3_arg1", "s3_kwarg1")
