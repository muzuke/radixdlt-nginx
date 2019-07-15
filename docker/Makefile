ARCH ?= amd64
TAG ?= latest
BASE ?= alpine
REGISTRY ?= docker.io

.PHONY: radixdlt-nginx-all radixdlt-core-all radixdlt-emu-nginx-all
radixdlt-nginx-all radixdlt-core-all radixdlt-emu-nginx-all:
	@$(MAKE) ARCH=amd64 TAG=$(TAG) BASE=$(BASE) $(subst -all,,$@)
	@$(MAKE) ARCH=arm32v6 TAG=$(TAG) BASE=$(BASE) $(subst -all,,$@)
	@$(MAKE) ARCH=arm64v8 TAG=$(TAG) BASE=$(BASE) $(subst -all,,$@)

# docker manifest needs "experimental": "enabled" added to your ~/.docker/config.json
.PHONY: radixdlt-nginx-all-push radixdlt-core-all-push radixdlt-emu-nginx-all-push
radixdlt-nginx-all-push radixdlt-core-all-push radixdlt-emu-nginx-all-push:
	@$(MAKE) ARCH=amd64 TAG=$(TAG) BASE=$(BASE) $(subst -all,,$@)
	@$(MAKE) ARCH=arm32v6 TAG=$(TAG) BASE=$(BASE) $(subst -all,,$@)
	@$(MAKE) ARCH=arm64v8 TAG=$(TAG) BASE=$(BASE) $(subst -all,,$@)
	docker manifest create --amend $(REGISTRY)/radixdlt/$(subst -all-push,,$@):$(TAG) \
		$(REGISTRY)/radixdlt/$(subst -all-push,,$@):$(TAG)-amd64 \
		$(REGISTRY)/radixdlt/$(subst -all-push,,$@):$(TAG)-arm32v6 \
		$(REGISTRY)/radixdlt/$(subst -all-push,,$@):$(TAG)-arm64v8
	docker manifest push --purge $(REGISTRY)/radixdlt/$(subst -all-push,,$@):$(TAG)

.PHONY: radixdlt-nginx radixdlt-core radixdlt-emu-nginx
radixdlt-nginx radixdlt-core radixdlt-emu-nginx:
	docker build \
		-t $(REGISTRY)/radixdlt/$@:$(TAG)-$(ARCH) \
		--build-arg ARCH=$(ARCH) \
		-f $@/Dockerfile.$(BASE) \
		./$@

.PHONY: radixdlt-nginx-push radixdlt-core-push radixdlt-emu-nginx-push
radixdlt-nginx-push radixdlt-core-push radixdlt-emu-nginx-push:
	docker push $(REGISTRY)/radixdlt/$(subst -push,,$@):$(TAG)-$(ARCH)
