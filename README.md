# jwt-authn-poc
 JWT authenticator that validate a token and also accepts a validator extension.
 The POC demonstrate how you can atuhenticate a self signed simple JWT (demonstrated in `main.rb`) and simply by injecting Google's public key provider `GooglePublicKeyProvider` and GCE identity token validator extension `GCETokenValidatorExtension`, one can auhenticate GCE token using the same JWT authenticator class. (demonstrated in `gce_main.rb').
 Standard claims are validated against `TokenClaimValueProvider` 
