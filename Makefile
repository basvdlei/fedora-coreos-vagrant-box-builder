OUTPUT := ${OUTPUT_DIR}
VERSION := $(shell curl -s "https://builds.coreos.fedoraproject.org/prod/streams/testing/builds/builds.json" | jq -r '.builds[0]')
URL := "https://ci.centos.org/artifacts/fedora-coreos/prod/builds/$(VERSION)/fedora-coreos-$(VERSION)-qemu.qcow2.gz"

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

box.img: fedora-coreos-qemu.qcow2.gz
	gunzip -c $< > $@

fedora-coreos-qemu.qcow2.gz:
	curl -Lo $@ $(URL)

.PHONY: clean
clean:
	-rm -f box.img fedora-coreos-qemu.img fedora-coreos-qemu.qcow2.gz
	-rm -f $(OUTPUT)/fedora-coreos.box $(OUTPUT)/fedora-coreos.json
