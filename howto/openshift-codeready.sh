# Instalacion de CodeReady en un host Windonws

# 1 . Descargar CodeReady desde el sitio de Red Hat y elegir el sistema operativo host

# 2. 
{"auths":{"cloud.openshift.com":{"auth":"b3BlbnNoaWZ0LXJlbGVhc2UtZGV2K2dvbnphbG9hY29zdGFzZW1wZXJ0aTFyaTB4Y2RzOGZ3Znd5b3llcW1tNWZ0aGhzbTpETUtaWlYxU0UxU1pDWUpXNFRVQ1BMTllKVEI0MzZGVVU2QjZVWVpLV0I0VEtXOVdRS1dRMEI3OEVYTVY3SEJL","email":"gonzalo.acosta@semperti.com"},"quay.io":{"auth":"b3BlbnNoaWZ0LXJlbGVhc2UtZGV2K2dvbnphbG9hY29zdGFzZW1wZXJ0aTFyaTB4Y2RzOGZ3Znd5b3llcW1tNWZ0aGhzbTpETUtaWlYxU0UxU1pDWUpXNFRVQ1BMTllKVEI0MzZGVVU2QjZVWVpLV0I0VEtXOVdRS1dRMEI3OEVYTVY3SEJL","email":"gonzalo.acosta@semperti.com"},"registry.connect.redhat.com":{"auth":"NTI4NjUwNDh8dWhjLTFSSTB4Y0RzOGZXZldZb1llcU1NNUZ0aEhTbTpleUpoYkdjaU9pSlNVelV4TWlKOS5leUp6ZFdJaU9pSmlZV1ptTnpaa1l6TXhZV1EwTXpnMk9HTXdZekk1WVdaaE5XUTRaamhrTkNKOS5TUnkzeTNZTXVtMFpOU0RrSk5EWFBfcmR6S3pUckwySGFQQ2VHcEFuN25wOFJvUUxhb0t5ekhKTFdjTUZ0SmFROEg1a3VoV3VVN1lncmNYSGlZb1pSRjFoZ0ladC0yOHVLQXdqZXhkckt5UzVCcUswT242bVlMYWtUbDBaMnBTNVQ5TzNmeVVDYjNiMG92TFRWYm9sNEF6VTRjeDRtczc4Ti1vc2dnY1VSWXAwMXVpa3Jja0dpOGdOcnJTWHRmQkRrTDZWajBweV9PWWdfX25kMWF2N3NXWEYwdDhaNUpfSGZyMFRTT1A4YmpHN19YVGF1bllMQnRSZV94Y01KZmFnaFBWdGQ0alkzYTRaSm43WElIS045b1VCQmJERDBBODlxYW13WkJPb3g2UGpYV1VSRnZTWi12dXBiR1FmS0tpeXI5bkFFT0F3aHU0QVBXR241NW5qdDBlb1k5WGZHVmU5RnBhelRuSl9oM3JTbThMQXZSazdjV3pxVWFMc2xKOUtHZ0NxU1l1U1FnQS1rdHdMellHa01ZaFduMzFBaVd1SWhyQmxXVWlCaFc0TGlDMjljMXBtWWRPOUFYVXdlUHZrb19xZmJPcDVQS2NVcjVQRUotUG1yOHhCLUhsZXVRRnZhdjRuaEtOSXZ1VWluQWZJZ2V0d3NiZHNiX1pNQS1BbVVPTnVWay0wdXh4dUxhN3ZGUjVSYVRyWTJKRFJVR1lRVWM3bDc1ZzlKV3UyUDRfNVVVWm1DZzAwQVhGSy00bl9OWXFQeVZkbVFqd21raXVkVkVqX1oxaEtuTm1IM281NGVfOFRaV2h1RGJDSDlmN0M3MTIxNWdjVjFMMFd4ajd4elRTdXZma2ZZZ2M4dXNJc0JNOGdfUkRZcDdMUHNlMTNRQy1scjlVZnA4WQ==","email":"gonzalo.acosta@semperti.com"},"registry.redhat.io":{"auth":"NTI4NjUwNDh8dWhjLTFSSTB4Y0RzOGZXZldZb1llcU1NNUZ0aEhTbTpleUpoYkdjaU9pSlNVelV4TWlKOS5leUp6ZFdJaU9pSmlZV1ptTnpaa1l6TXhZV1EwTXpnMk9HTXdZekk1WVdaaE5XUTRaamhrTkNKOS5TUnkzeTNZTXVtMFpOU0RrSk5EWFBfcmR6S3pUckwySGFQQ2VHcEFuN25wOFJvUUxhb0t5ekhKTFdjTUZ0SmFROEg1a3VoV3VVN1lncmNYSGlZb1pSRjFoZ0ladC0yOHVLQXdqZXhkckt5UzVCcUswT242bVlMYWtUbDBaMnBTNVQ5TzNmeVVDYjNiMG92TFRWYm9sNEF6VTRjeDRtczc4Ti1vc2dnY1VSWXAwMXVpa3Jja0dpOGdOcnJTWHRmQkRrTDZWajBweV9PWWdfX25kMWF2N3NXWEYwdDhaNUpfSGZyMFRTT1A4YmpHN19YVGF1bllMQnRSZV94Y01KZmFnaFBWdGQ0alkzYTRaSm43WElIS045b1VCQmJERDBBODlxYW13WkJPb3g2UGpYV1VSRnZTWi12dXBiR1FmS0tpeXI5bkFFT0F3aHU0QVBXR241NW5qdDBlb1k5WGZHVmU5RnBhelRuSl9oM3JTbThMQXZSazdjV3pxVWFMc2xKOUtHZ0NxU1l1U1FnQS1rdHdMellHa01ZaFduMzFBaVd1SWhyQmxXVWlCaFc0TGlDMjljMXBtWWRPOUFYVXdlUHZrb19xZmJPcDVQS2NVcjVQRUotUG1yOHhCLUhsZXVRRnZhdjRuaEtOSXZ1VWluQWZJZ2V0d3NiZHNiX1pNQS1BbVVPTnVWay0wdXh4dUxhN3ZGUjVSYVRyWTJKRFJVR1lRVWM3bDc1ZzlKV3UyUDRfNVVVWm1DZzAwQVhGSy00bl9OWXFQeVZkbVFqd21raXVkVkVqX1oxaEtuTm1IM281NGVfOFRaV2h1RGJDSDlmN0M3MTIxNWdjVjFMMFd4ajd4elRTdXZma2ZZZ2M4dXNJc0JNOGdfUkRZcDdMUHNlMTNRQy1scjlVZnA4WQ==","email":"gonzalo.acosta@semperti.com"}}}
