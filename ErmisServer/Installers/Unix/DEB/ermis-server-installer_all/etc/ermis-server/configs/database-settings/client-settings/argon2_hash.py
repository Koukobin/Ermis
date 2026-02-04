import argon2.low_level as argon2
import base64

# Inputs
password = b"PASSWORD_HERE"
salt = b"SALT"

# Parameters
time_cost = 2        # iterations
memory_cost = 65536  # KB
parallelism = 4      # threads
hash_len = 16        # length of hash in bytes
type = argon2.Type.ID  # Argon2 Type

# Generate hash
hash_bytes = argon2.hash_secret_raw(
    secret=password,
    salt=salt,
    time_cost=time_cost,
    memory_cost=memory_cost,
    parallelism=parallelism,
    hash_len=hash_len,
    type=type
)

# Encode
encoded = base64.b64encode(hash_bytes).decode()
encoded_no_padding = encoded.rstrip("=") # Server encodes without padding
print("Base64 without padding:", encoded_no_padding)
