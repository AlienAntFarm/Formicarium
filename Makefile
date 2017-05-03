.PHONY: clean clean-dist clean-virsh init run

GOPATH = GOPATH=$(CURDIR)/colony
GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)

vm_name ?= alpine
arch ?= x86_64
iso ?= alpine-virt-3.5.2-$(arch).iso
iso_url = https://nl.alpinelinux.org/alpine/v3.5/releases/$(arch)/$(iso)

go_lxc = gopkg.in/lxc/go-lxc.v2
go_lxc_path = colony/src/$(go_lxc)
go_alien_path = colony/src/github.com/alienantfarm

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

go_lxc_files = \
		$(wildcard $(go_lxc_path)/*.go) \
		$(go_lxc_path)/lxc-binding.h \
		$(go_lxc_path)/lxc-binding.c \

colony/pkg/$(GOOS)_$(GOARCH)/$(go_lxc): $(go_lxc_path)
	sudo $(GOPATH) go install $(go_lxc)

colony/src/%:
	$(GOPATH) go get -d $(subst colony/src/,,$@)

$(go_alien_path)/%:
	git clone git@github.com:alienantfarm/$(notdir $@) $@

init: $(go_lxc_path) $(go_alien_path)/anthive $(go_alien_path)/antling

clean-dist: clean
	rm -rf $(wildcard colony/src/*)
clean:
	rm -f $(wildcard colony/bin/*)
	rm -rf $(wildcard colony/pkg/*)
