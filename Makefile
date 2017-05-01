.PHONY: clean.volumes clean.virsh clean

vm_name ?= alpine
arch ?= x86_64
iso ?= alpine-virt-3.5.2-$(arch).iso
iso_url = https://nl.alpinelinux.org/alpine/v3.5/releases/$(arch)/$(iso)

$(iso):
	wget $(iso_url)

run.virsh: clean.virsh clean.volumes
	@sudo virt-install --name $(vm_name) --memory 1024 --virt-type kvm \
		--cdrom $(iso) --network bridge=virbr0,model=virtio \
		--disk size=10 --noautoconsole
	@sudo virsh console --domain $(vm_name)

clean.virsh:
	@sudo virsh list | \
		awk '$$2 ~ /$(vm_name)/ {system("sudo virsh destroy " $$2)}'
	@sudo virsh list --all | \
		awk '$$2 ~ /$(vm_name)/ {system("sudo virsh undefine " $$2)}'

clean.volumes:
	@sudo virsh vol-list default | awk \
		'NR > 2 && NF > 0 {system("xargs sudo virsh vol-delete --pool default " $$1)}'

clean: clean.virsh clean.volumes
