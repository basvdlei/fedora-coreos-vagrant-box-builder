VERSION := "30.62"
URL := "https://ci.centos.org/artifacts/fedora-coreos/prod/builds/$(VERSION)/fedora-coreos-$(VERSION)-qemu.qcow2.gz"

fedora-coreos.json: fedora-coreos.box
	$(shell jq --arg version $(VERSION) --arg shasum $(shell sha256sum $< | cut -d " " -f 1) \
		'.versions[0].version = $$version | \
		.versions[0].providers[0].checksum = $$shasum | \
		.versions[0].providers[0].checksum_type = "sha256"' \
		info-template.json > $@)

fedora-coreos.box: box.img metadata.json Vagrantfile
	tar czvf $@ $?

box.img: fedora-coreos-qemu.qcow2.gz
	gunzip -c $< > $@

fedora-coreos-qemu.qcow2.gz:
	curl -Lo "$@" "$(URL)"

.PHONY: clean
clean:
	rm -f fedora-coreos-qemu.img fedora-coreos-qemu.qcow2.gz
