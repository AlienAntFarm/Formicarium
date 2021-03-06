.PHONY: clean clean-dist clean-virsh init run

GOPATH = $(CURDIR)/colony
GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)

vm_name ?= alpine
arch ?= x86_64
iso ?= alpine-virt-3.5.2-$(arch).iso
iso_url = https://nl.alpinelinux.org/alpine/v3.5/releases/$(arch)/$(iso)

go_alien_path = $(GOPATH)/src/github.com/alienantfarm

$(iso):
	wget $(iso_url)

run: clean-virsh
	@virt-install --name $(vm_name) --memory 1024 --virt-type kvm \
		--cdrom $(iso) --network bridge=virbr0,model=virtio \
		--disk size=10 --noautoconsole
	@virsh console --domain $(vm_name)

clean-virsh:
	@virsh list | \
		awk '$$2 ~ /$(vm_name)/ {system("virsh destroy " $$2)}'
	@virsh list --all | \
		awk '$$2 ~ /$(vm_name)/ {system("virsh undefine " $$2)}'
	@virsh vol-list default | awk \
		'NR > 2 && NF > 0 {system("xargs virsh vol-delete --pool default " $$1)}'

$(go_alien_path)/%:
	git clone git@github.com:alienantfarm/$(notdir $@) $@
	cd $@ && go get -d ./...

init: $(go_alien_path)/anthive $(go_alien_path)/antling


clean-dist: clean
	rm -rf $(wildcard $(GOPATH)/src/*)
clean:
	rm -f $(wildcard $(GOPATH)/bin/*)
	rm -rf $(wildcard $(GOPATH)/pkg/*)
