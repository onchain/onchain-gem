import hashlib
import sys

h = hashlib.blake2b(person = sys.argv[2].encode(), digest_size=32)
h.update(bytearray.fromhex(sys.argv[1]))
print(h.hexdigest())