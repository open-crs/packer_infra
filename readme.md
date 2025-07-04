# Building the image
```
packer init .
packer validate ubuntu-20-04.pkr.hcl
packer build ubuntu-20-04.pkr.hcl
```

After creation use:
```
qemu-system-x86_64 \
  -m 1024 \
  -smp 1 \
  -accel kvm \
  -cpu host \
  -drive file=output/ubuntu-20-04/img,format=qcow2,if=virtio \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -device virtio-net,netdev=net0 \
  -display default \
  -name ubuntu-20-04

```