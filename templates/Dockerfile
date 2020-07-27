FROM alpine
RUN apk update
RUN apk add python3
RUN apk add py3-pip

COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt

CMD ["python3", "./app.py"]
