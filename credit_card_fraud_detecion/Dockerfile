FROM mariadb:latest

ENV MYSQL_ROOT_PASSWORD=p@ssw0rd
ENV MYSQL_DATABASE=card_fraud

COPY sql_files/database.sql /docker-entrypoint-initdb.d/
COPY csv_files/transactions.csv /docker-entrypoint-initdb.d/

EXPOSE 3308