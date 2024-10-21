-- Delete previous entries

delete from login_providers;

-- Insert into login_providers table
INSERT INTO "public"."login_providers" ("name", "type", "description", "login_button_text", "login_button_image_url", "authorization_parameters", "created_at", "updated_at", "id", "active", "strategy_id") VALUES('E Signet', 'oauth2_auth_code', 'e-signet', 'PROCEED WITH NATIONAL ID', 'https://login.url', '{ "authorize_endpoint": "$authorize_endpoint",   "token_endpoint": "$token_endpoint",   "validate_endpoint": "$validate_endpoint",   "jwks_endpoint": "$jwks_endpoint",   "client_id": "$CLIENT_ID",   "client_assertion_type": "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
"client_assertion_jwk": $JWK_kEY, "response_type": "code",   "scope": "openid profile email",   "redirect_uri": "$REDIRECT_URI",   "code_verifier": "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk",   "extra_authorize_parameters": {     "acr_values":"mosip:idp:acr:generated-code mosip:idp:acr:biometrics mosip:idp:acr:linked-wallet",     "claims": "{\"userinfo\":{\"name\":{\"essential\":true},\"phone_number\":{\"essential\":false},\"email\":{\"essential\":false},\"gender\":{\"essential\":true},\"address\":{\"essential\":false},\"picture\":{\"essential\":false}},\"id_token\":{}}"   }}', '2024-04-22 12:14:52.174414', '2024-04-22 12:14:52.174414', 1, 't', 1) ON CONFLICT DO NOTHING;