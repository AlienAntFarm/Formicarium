.PHONY: clean.volumes clean.virsh clean $(go_lxc_pkg)

GOPATH = GOPATH=$(CURDIR)/go
GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)

arch ?= x86_64
vm_name ?= alpine
iso ?= alpine-virt-3.5.2-$(GOARCH).iso
iso_url = https://nl.alpinelinux.org/alpine/v3.5/releases/$(arch)/$(iso)
protoc_url = https://github.com/google/protobuf/releases/download/v3.3.0/protoc-3.3.0-$(GOOS)-$(arch).zip

go_lxc = gopkg.in/lxc/go-lxc.v2
go_grpc = google.golang.org/grpc
go_proto = github.com/golang/protobuf/proto

$(iso):
	wget $(iso_url)

run.virsh: clean.virsh clean.volumes
	@virt-install --name $(vm_name) --memory 1024 --virt-type kvm \
		--cdrom $(iso) --network bridge=virbr0,model=virtio \
		--disk size=10 --noautoconsole
	@virsh console --domain $(vm_name)

clean.virsh:
	@virsh list | \
		awk '$$2 ~ /$(vm_name)/ {system("virsh destroy " $$2)}'
	@virsh list --all | \
		awk '$$2 ~ /$(vm_name)/ {system("virsh undefine " $$2)}'

clean.volumes:
	@virsh vol-list default | awk \
		'NR > 2 && NF > 0 {system("xargs virsh vol-delete --pool default " $$1)}'

clean.bin:
	@rm $(wildcard go/bin/*)

go_lxc_files = \
		$(wildcard go/src/$(go_lxc)/*.go) \
		go/src/$(go_lxc)/lxc-binding.h \
		go/src/$(go_lxc)/lxc-binding.c \

go/pkg/$(GOOS)_$(GOARCH)/$(go_lxc): $(go_lxc_pkg)
	sudo $(GOPATH) go install $(go_lxc)

go/src/%:
	$(GOPATH) go get -d $(subst go/src/,,$@)

go/bin/protoc:
	@wget --show-progress -qO - $(protoc_url) \
		| bsdtar -xf- -C $(dir $@) -s '/^bin//' bin/protoc 2> /dev/null
	@chmod +x $@

go/bin/protoc-gen-go: go/src/$(go_proto) go/bin/protoc
	$(GOPATH) go install $(go_proto)/protoc-gen-go

clean: clean.virsh clean.volumes clean.bin
