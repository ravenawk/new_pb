FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
RUN mkdocs build

# Serve the static files
FROM docker.io/library/nginx:alpine
COPY --from=0 /app/site /usr/share/nginx/html
EXPOSE 80
