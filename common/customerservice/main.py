import random
from fastapi import FastAPI
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
from pydantic import BaseModel

app = FastAPI(title="Customers", description="Customers", version="v1", openapi_url="/swagger")

class Customer(BaseModel):
    id: int
    name: str
    category: str
    balance: float

class Error(BaseModel):
    message: str
    code: str    

def error(status_code: int, code: str, message: str):
    return JSONResponse(status_code = status_code, content = jsonable_encoder(Error(code = code, message = message)))

@app.get('/{customer_id}', response_model=Customer, operation_id="getCustomer", responses={404: {"model": Error}, 500: {"model": Error}})
async def root(customer_id: int):
    #Well, python is not very reliable language :P
    if random.randrange(10) == 0:
        return error(500, "simulated_error", "Simulated, randomly returned error - don't worry, everything works as expected")
    idstr = str(customer_id)
    customers = {
        "1": Customer(id = customer_id, name = "John Doe", category = "STANDARD", balance = 1653.23),
        "2": Customer(id = customer_id, name = "Robert Wright", category = "GOLD", balance = 100100.32),
        "3": Customer(id = customer_id, name = "Юрий Шевчук", category = "PLATINUM", balance = 230000.56),
        "4": Customer(id = customer_id, name = "Иосиф Кобзон", category = "STANDARD", balance = 2040.78)
    }
    if idstr in customers:
        return customers[idstr]
    else:
        return error(404, "customer_not_found", "Customer not found")
