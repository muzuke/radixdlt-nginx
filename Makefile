TAG ?= latest
BASE ?= alpine
REGISTRY_DEV ?= eu.gcr.io/dev-container-repo

all:
    $(eval GIT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD | sed 's/\//-/g'))
    $(eval GIT_COMMIT=$(shell git log -1 --format=%h ))
    TAG ?= $(GIT_BRANCH)-$(GIT_COMMIT)
    CORE_REPO ?= $(REGISTRY_DEV)/radixdlt-nginx


.PHONY: radixdlt-nginx
radixdlt-nginx:
	docker build \
		-t $(REGISTRY_DEV)/radixdlt/$@:$(TAG) \
		-f $@/Dockerfile.alpine \
		./$@

# .PHONY: radixdlt-nginx-push radixdlt-core-push
# radixdlt-nginx-push radixdlt-core-push:
# 	docker push $(REGISTRY)/radixdlt/$(subst -push,,$@):$(TAG)-$(ARCH)