from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

app = FastAPI()

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
