all: restart

restart:
	docker compose down -v 
	docker compose pull 
	docker compose up --build


docker-hub:
	docker build -t socnet-db .
	docker tag socnet-db alchemmist/socnet-db:latest
	docker push alchemmist/socnet-db:latest
