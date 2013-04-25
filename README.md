DPAPI
=====
Ruby wrapper around Microsoft's DPAPI

http://msdn.microsoft.com/en-us/library/ms995355.aspx

http://en.wikipedia.org/wiki/Data_Protection_API

The DPAPI library uses the user's login password to encrypt arbitrary
plaintext, as well as decrypt the resulting ciphertext. There's a bit
more complexity there (AD integration, including support for password
changing), but that's about it. Unlike MacOS X Keychain, it doesn't
persist the ciphertext anywhere - that's the developer's
responsibility.

```
require "dpapi"

secret = "i herd u liek cryptography"

ciphertext = DPAPI.encrypt secret
ciphertext != secret or raise "OMG END OF EARTH"

[plaintext, desc] = DPAPI.decrypt ciphertext
plaintext == secret or raise "OMG DOUBLE-END OF EARTH"
```
