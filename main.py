from fastapi import FastAPI

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/location")
async def location(lon: float):
    print("lon = ", lon)
    return {"lon" : lon}

