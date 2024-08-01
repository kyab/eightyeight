from fastapi import FastAPI, Request, HTTPException
from fastapi.staticfiles import StaticFiles
from jose import jwt
import requests
import time

app = FastAPI()


# Apple Sign In
APPLE_SIGN_IN_PUBLIC_KEYS_URL = "https://appleid.apple.com/auth/keys"
APPLE_SIGN_IN_AUDIENCE = "com.kyab.eightyeight.AppClip"

class ApplePublicKeyCache:
    def __init__(self, cache_duration: int = 3600):
        self.cache_duration = cache_duration
        self.keys = None
        self.last_update = 0

    def get_keys(self):
        current_time = time.time()
        if self.keys is None or current_time - self.last_update > self.cache_duration:
            response = requests.get(APPLE_SIGN_IN_PUBLIC_KEYS_URL)
            if response.status_code != 200:
                raise HTTPException(status_code=500, detail="Failed to fetch Apple public keys")
            self.keys = response.json()
            self.last_update = current_time
        return self.keys
    
key_cache = ApplePublicKeyCache()


#Static file (Apple AASA)
app.mount("/.well-known", StaticFiles(directory=".well-known"), name="well-known")

@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/location")
async def location(lon: float):
    print("lon = ", lon)
    return {"lon" : lon}

@app.get("/appclip")
async def appclip():
    return {"message" : "Hello AppClip"}

def verify_apple_token(identity_token : str):

    print("verify_apple_token()")

    header = jwt.get_unverified_header(identity_token)
    kid = header['kid']
    apple_public_keys = key_cache.get_keys()

    key = None
    for apple_key in apple_public_keys['keys']:
        if apple_key['kid'] == kid:
            key = apple_key
            break

    if key is None:
        raise HTTPException(status_code=400, detail="No matching key found")
    
    try:
        decoded_token = jwt.decode(identity_token, key, algorithms=['RS256'], audience=APPLE_SIGN_IN_AUDIENCE)
    except jwt.JWTError as e:
        raise HTTPException(status_code=400, detail=f"Token verification failed: {e}")
    
    print("verify_apple_token() return with success")
    return decoded_token


@app.post("/api/stamp")
async def api_stamp(request: Request):
    try:
        body = await request.json()
        print("request body json = ", body)
        user_identifier = body.get('userIdentifier')
        email = body.get('email')
        identity_token = body.get('identityToken')
        latitude = body.get('latitude')
        longtitude = body.get('longtitude')
        place_name = body.get('placeName')

        if not user_identifier or not identity_token:
            raise HTTPException(status_code=400, detail="Missing userIdentifier or identityToken")
        
        verified_token = verify_apple_token(identity_token)
        if verified_token['sub'] != user_identifier:
            raise HTTPException(status_code=400, detail="Invalid userIdentifier")
        
        print("verified email in JWT token = ", verified_token['email'])
        email = verified_token['email']
        print("aud = ", verified_token['aud'])
        print("sub = ", verified_token['sub'])
        print("exp = ", verified_token['exp'])
        print("dump = ", verified_token)

        return {"status" : "stamped", "userIdentifier" : user_identifier, "email" : email, "latitude" : latitude, "longtitude" : longtitude, "placeName" : place_name}
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    
