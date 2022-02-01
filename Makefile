PORT := 8888
HUGO_VERSION := 0.90.1
CONTAINER_NAME := forsure.local


serve: clean build
	docker run \
		--rm \
		--name $(CONTAINER_NAME) \
		--volume `pwd`:/src \
		--workdir /src/site \
		--publish $(PORT):$(PORT) \
		--privileged \
		--platform linux/x86_64 \
		registry.gitlab.com/hwdegroot/forsure.dev/hugo:$(HUGO_VERSION) \
		hugo server --contentDir content/ --bind 0.0.0.0 --port $(PORT) --buildDrafts --config config/config.yaml || echo "Run 'make build' or 'make clean' first"


%:      # thanks to chakrit
	@:    # thanks to William Pursell

bump-version:
	./bump-hugo-version.sh $(filter-out $@,$(MAKECMDGOALS))

publish:
	docker exec -it $(CONTAINER_NAME) \
		hugo --contentDir content --config config/config.yaml --destination ../public/

push_docker: clean build
	docker push registry.gitlab.com/hwdegroot/forsure.dev/hugo:$(HUGO_VERSION)


stop:
	docker stop --time 0 $(CONTAINER_NAME)

build:
	docker build \
		--tag registry.gitlab.com/hwdegroot/forsure.dev/hugo:$(HUGO_VERSION) \
		--tag registry.gitlab.com/hwdegroot/forsure.dev/hugo:latest \
		--platform linux/x86_64 \
		--build-arg HUGO_VERSION=$(HUGO_VERSION) \
		--build-arg PORT=$(PORT) \
		.

clean:
	sudo rm -rf site/public && \
	( \
		docker images $(CONTAINER_NAME) && docker rm -f $(CONTAINER_NAME) \
	) || true

NAME := $(shell echo "${TITLE}" | sed 's/ /-/g;s/[:?!.]//g;' | sed -e 's/\(.*\)/\L\1/')
preview: .check_title_defined
	@echo $(NAME)

policy: .check_title_defined
	docker exec -it $(CONTAINER_NAME) hugo new content/policy/$(NAME) --kind policy  --config config/config.yaml && \
	sudo chown -R $(shell id -u):$(shell id -g) site/content/posts/$(NAME)

presentation: .check_title_defined
	docker exec -it $(CONTAINER_NAME) hugo new content/presentations/$(NAME) --kind presentation --config config/config.yaml && \
	sudo chown -R $(shell id -u):$(shell id -g) site/content/presentations/$(NAME)

post: .check_title_defined
	docker exec -it $(CONTAINER_NAME) hugo new content/posts/$(NAME) --kind post --config config/config.yaml && \
	sudo chown -R $(shell id -u):$(shell id -g) site/content/posts/$(NAME)

.PHONY:
.check_title_defined:
	$(call check_defined TITLE)

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
