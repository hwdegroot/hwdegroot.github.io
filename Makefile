PORT := 8888
HUGO_VERSION := 0.55.6
CONTAINER_NAME := forsure.local

serve: clean build
	docker run \
		--rm \
		--name ${CONTAINER_NAME} \
		--volume `pwd`:/src \
		--workdir /src/site \
		--publish ${PORT}:${PORT} \
		--privileged \
		registry.gitlab.com/hwdegroot/forsure.dev/hugo:${HUGO_VERSION} \
		hugo server --contentDir /src/site/content/ --bind "0.0.0.0" --port ${PORT} --buildDrafts --config config/config.yaml || echo "Run 'make build' or 'make clean' first"

stop:
	docker stop --time 0 ${CONTAINER_NAME}

build:
	docker build \
		--tag registry.gitlab.com/hwdegroot/forsure.dev/hugo:${HUGO_VERSION} \
		--tag registry.gitlab.com/hwdegroot/forsure.dev/hugo:latest \
		--build-arg HUGO_VERSION=${HUGO_VERSION} \
		--build-arg PORT=${PORT} \
		.

clean:
	sudo rm -rf site/public && \
	( \
		docker images ${CONTAINER_NAME} && docker rm -f ${CONTAINER_NAME} \
	) || true

post:
	docker exec -it ${CONTAINER_NAME} hugo new content/posts/${TITLE} --kind post && \
	sudo chown -R $(shell id -u):$(shell id -g) site/content/posts/${TITLE}
