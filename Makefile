all: docker-hub

docker-hub:
	docker build -t socnet-db .
	docker tag socnet-db alchemmist/socnet-db:latest
	docker push alchemmist/socnet-db:latest
