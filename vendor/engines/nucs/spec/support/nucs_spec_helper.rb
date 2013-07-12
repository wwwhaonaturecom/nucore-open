#
# Create fake string data of variable
# length and characters
def mkstr(length=10, chars='1')
  str=''
  length.times { str += chars }
  return str
end
