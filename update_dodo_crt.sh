#!/bin/bash

cd crt/dodo/trusted_but_not_for_serverauth
rm *.crt

# Get a list (from the crt.sh DB) of the SHA-256 hashes of all of the roots that are currently trusted (but not for the server authentication trust purpose) by one or more of the Apple, Microsoft and Mozilla root programs.  These roots will be accepted by Dodo but not by Mammoth or Sabre.
psql -h crt.sh -p 5432 -U guest certwatch -c "\COPY (SELECT upper(encode(digest(c.CERTIFICATE, 'sha256'), 'hex')) FROM root_trust_purpose rtp, ca_certificate cac, certificate c WHERE rtp.TRUST_CONTEXT_ID IN (1, 5, 12) AND rtp.CERTIFICATE_ID = cac.CERTIFICATE_ID AND cac.CERTIFICATE_ID = c.ID GROUP BY digest(c.CERTIFICATE, 'sha256') HAVING min(TRUST_PURPOSE_ID) > 1 ORDER BY min(get_ca_name_attribute(cac.CA_ID))) TO '__roots_sha256_not_serverauth__.sh'"

sed -i "s/^/wget --content-disposition \"https:\/\/crt.sh\/?d=/g" __roots_sha256_not_serverauth__.sh
sed -i "s/$/\"/g" __roots_sha256_not_serverauth__.sh
chmod 755 __roots_sha256_not_serverauth__.sh
./__roots_sha256_not_serverauth__.sh
rm __roots_sha256_not_serverauth__.sh
