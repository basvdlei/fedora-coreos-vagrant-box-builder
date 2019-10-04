OUTPUT := ${OUTPUT_DIR}
STREAM := testing
ARCH := x86_64
VERSION := $(shell curl -s "https://builds.coreos.fedoraproject.org/prod/streams/$(STREAM)/builds/builds.json" | \
	jq -r --arg arch "$(ARCH)" 'first(.builds[] | select(.arches[] | contains($$arch))) | .id // empty')
URL := "https://builds.coreos.fedoraproject.org/prod/streams/testing/builds/$(VERSION)/$(ARCH)/fedora-coreos-$(VERSION)-qemu.$(ARCH).qcow2.xz"

$(OUTPUT)/fedora-coreos.json: $(OUTPUT)/fedora-coreos.box
	$(shell jq --arg version $(VERSION) --arg shasum $(shell sha256sum $< | cut -d " " -f 1) \
		'.versions[0].version = $$version | \
		.versions[0].providers[0].checksum = $$shasum | \
		.versions[0].providers[0].checksum_type = "sha256"' \
		info-template.json > $@)

$(OUTPUT)/fedora-coreos.box: box.img metadata.json Vagrantfile | $(OUTPUT)/
	tar czvf $@ $^

$(OUTPUT)/:
	mkdir -p $(OUTPUT)

box.img: fedora-coreos-qemu.qcow2.xz
	xz -d -c $< > $@

fedora-coreos-qemu.qcow2.xz:
	curl -Lo $@ $(URL)

.PHONY: clean
clean:
	-rm -f box.img fedora-coreos-qemu.img fedora-coreos-qemu.qcow2.xz
	-rm -f $(OUTPUT)/fedora-coreos.box $(OUTPUT)/fedora-coreos.json
