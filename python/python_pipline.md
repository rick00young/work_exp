### python 实现linux 管道pipline
```
class Pipe(object):
    def __init__(self, func):
        self.func = func
 
    def __ror__(self, other):
        def generator():
            for obj in other:
                if obj is not None:
                    yield self.func(obj)
        return generator()
 
@Pipe
def even_filter(num):
    return num if num % 2 == 0 else None
 
@Pipe
def multiply_by_three(num):
    return num*3
 
@Pipe
def convert_to_string(num):
    return 'The Number: %s' % num
 
@Pipe
def echo(item):
    print item
    return item
 
def force(sqs):
    for item in sqs: pass
 
nums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
 
force(nums | even_filter | multiply_by_three | convert_to_string | echo)
```



### @

```
import inspect
 
def advance_logger(loglevel):
 
    def get_line_number():
        return inspect.currentframe().f_back.f_back.f_lineno
 
    def _basic_log(fn, result, *args, **kwargs):
        print "function   = " + fn.__name__,
        print "    arguments = {0} {1}".format(args, kwargs)
        print "    return    = {0}".format(result)
 
    def info_log_decorator(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            result = fn(*args, **kwargs)
            _basic_log(fn, result, args, kwargs)
        return wrapper
 
    def debug_log_decorator(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            ts = time.time()
            result = fn(*args, **kwargs)
            te = time.time()
            _basic_log(fn, result, args, kwargs)
            print "    time      = %.6f sec" % (te-ts)
            print "    called_from_line : " + str(get_line_number())
        return wrapper
 
    if loglevel is "debug":
        return debug_log_decorator
    else:
        return info_log_decorator
```