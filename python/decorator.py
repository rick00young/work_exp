from functools import wraps

def decorator_name(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if not can_run:
            return "Function will not run!"
        return f(*args, **kwargs)
    return decorated

@decorator_name
def func():
    return 'Function is running!'

can_run = True
print(func())

can_run = False
print(func())

# def add_to(num, target=[]):
def add_to(num, target=None):
    if target is None:
        target = []
    target.append(num)
    return target

'''

'''

a = []
print(add_to(0))
print(add_to(1))
print(add_to(2))