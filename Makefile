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

publish:
	docker exec -it ${CONTAINER_NAME} \
		hugo --contentDir content --config config/config.yaml --destination ../public/

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

policy: .post
	docker exec -it ${CONTAINER_NAME} hugo new content/policy/${TITLE} --kind policy && \
	sudo chown -R $(shell id -u):$(shell id -g) site/content/posts/${TITLE}

post: .post
	docker exec -it ${CONTAINER_NAME} hugo new content/posts/${TITLE} --kind post && \
	sudo chown -R $(shell id -u):$(shell id -g) site/content/posts/${TITLE}

.post:
	$(call check_defined TITLE, post title)

# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
        $(error Undefined $1$(if $2, ($2))$(if $(value @), \
                required by target `$@')))
