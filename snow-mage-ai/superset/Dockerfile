FROM apache/superset:latest

USER root

RUN pip install mysqlclient
RUN pip install snowflake-sqlalchemy
RUN apt update -y 
RUN apt install -y zip

RUN pip install --force-reinstall https://github.com/wbond/oscrypto/archive/d5f3437ed24257895ae1edd9e503cfb352e635a8.zip


ENV ADMIN_USERNAME $ADMIN_USERNAME
ENV ADMIN_EMAIL $ADMIN_EMAIL
ENV ADMIN_PASSWORD $ADMIN_PASSWORD

COPY initialize-superset.sh /initialize-superset.sh

COPY superset_config.py /app/
ENV SUPERSET_CONFIG_PATH /app/superset_config.py

USER superset
ENTRYPOINT [ "/initialize-superset.sh" ]