import hashlib
import sys

personal = sys.argv[2]
  
if personal == 'ZcashSigHash':
  personal = b"ZcashSigHash\x19\x1b\xa8\x5b"
else:
  personal = personal.encode()

h = hashlib.blake2b(person = personal, digest_size=32)
h.update(bytearray.fromhex(sys.argv[1]))
print(h.hexdigest())