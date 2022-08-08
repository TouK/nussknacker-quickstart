FROM python:3
# remove after https://github.com/marshmallow-code/flask-smorest/issues/384 fixed
RUN pip install flask==2.1.3 flask-smorest
EXPOSE 5000
ADD app.py /
RUN mkdir /static && flask openapi print > /static/swagger.json
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]

