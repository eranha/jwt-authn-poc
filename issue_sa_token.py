import time
import google.auth.crypt
import google.auth.jwt
import sys
import json

def generate_jwt(sa_keyfile,
                 sa_email,
                 sub,
                 audience,
                 expiry_length=3600):

    """Generates a signed JSON Web Token using a Google API Service Account."""

    now = int(time.time())

    # build payload
    payload = {
        'iat': now,
        # expires after 'expiry_length' seconds.
        "exp": now + expiry_length,
        # iss must match 'issuer' in the security configuration in your
        # swagger spec (e.g. service account email). It can be any string.
        'iss': sa_email,
        # aud must be either your Endpoints service name, or match the value
        # specified as the 'x-google-audience' in the OpenAPI document.
        'aud':  audience,
        # sub and email should match the service account's email address
        'sub': sub,
        'email': sa_email
    }

    # sign with keyfile
    signer = google.auth.crypt.RSASigner.from_service_account_file(sa_keyfile)
    jwt = google.auth.jwt.encode(signer, payload)

    return jwt

def main():
    if len(sys.argv) < 2:
       print('missing service account key file')
       exit()
    with open(sys.argv[1], 'r') as json_file:
        data = json.load(json_file)
        sa_email = data['client_email']
        sub = data['client_id']

    jwt = generate_jwt(sys.argv[1], sa_email, sub, 'conjur/host/my_service')
    print(jwt)

#if __main__ == '__main__':
main()