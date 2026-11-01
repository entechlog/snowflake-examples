FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
COPY schema.yaml .
COPY utils/ ./utils/

EXPOSE 8000

CMD ["python", "app.py"]