FROM python:3.11-alpine
WORKDIR /app
ADD requirements.txt .
RUN pip install -r requirements.txt \
    && rm -rf /root/.cache
COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]
