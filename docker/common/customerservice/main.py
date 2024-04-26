import uvicorn
from fastapi import FastAPI
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from pydantic import BaseModel

app = FastAPI(title="Customers", description="Customers", version="v1", openapi_url="/swagger")

# Deliberately 11 names, prime number
names = ['Mietek', 'Henryk', 'Dżordż', 'Dżessika', 'Ryszard', 'Paweł', 'Rafał', 'Mateusz', 'Szymon', 'Jakub', 'Dawid']
# Deliberately 7 names, prime number different from above
city_names = ['Warszawa', 'Kraków', 'Wrocław', 'Gdańsk', 'Poznań', 'Szczecin', 'Łódź']


class InvalidMsisdn(Exception):
    pass


class CustomerResponse(BaseModel):
    status: str
    msisdn: str
    name: str
    age: int
    city_name: str


class ErrorResponse(BaseModel):
    status: str
    message: str
    code: str


def error(code: str, message: str):
    return JSONResponse(status_code=200, content=jsonable_encoder(ErrorResponse(status="error", code=code, message=message)))


def extract_base_number_from_msisdn(msisdn):
    if msisdn[0] == "+" and len(msisdn) == 12:
        msisdn = msisdn[1:len(msisdn)]
    if msisdn[0:2] == "48" and len(msisdn) == 11:
        msisdn = msisdn[2:len(msisdn)]
    if len(msisdn) == 9:
        try:
            return int(msisdn)
        except ValueError:
            raise InvalidMsisdn
    raise InvalidMsisdn


@app.get('/customer_info/{customer_msisdn}', response_model=CustomerResponse, operation_id="getCustomerInfo",
         responses={404: {"model": ErrorResponse}, 500: {"model": ErrorResponse}})
async def root(customer_msisdn: str):
    base_number = extract_base_number_from_msisdn(customer_msisdn)
    if base_number % 3 == 0:
        # Simulating that only 2/3 of numbers are our customers(It's still a big number)
        return error("customer_not_found", "Customer not found")
    else:
        return CustomerResponse(
            status="success",
            msisdn=customer_msisdn,
            name=names[base_number % len(names)],
            age=(base_number % 61) + 18,
            city_name=city_names[base_number % len(city_names)]
        )

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)