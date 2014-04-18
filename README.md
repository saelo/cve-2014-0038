Local root exploit for CVE-2014-0038
====================================

Bug:
----
The X86_X32 recvmmsg syscall does not properly sanitize the timeout pointer
passed from userspace.

Exploit primitive:
------------------
Pass a pointer to a kernel address as timeout for recvmmsg,
if the original byte at that address is known it can be overwritten
with known data.
If the least significant byte is 0xff, waiting 255 seconds will turn it into a 0x00.

Restrictions:
-------------
The first long at the passed address (tv_sec) has to be positive
and the second long (tv_nsec) has to be smaller than 1000000000.

Overview:
---------
Target the release function pointer of the ptmx_fops structure located in
non initialized (and thus writable) kernel memory. Zero out the three most
significant bytes and thus turn it into a pointer to an address mappable in
user space.
The release pointer is used as it is followed by 16 0x00 bytes (so the tv_nsec
is valid).
Open /dev/ptmx, close it and enjoy.

Not very beautiful but should be fairly reliable if symbols can be resolved.

Tested on Ubuntu 13.10

See also http://blog.includesecurity.com/2014/03/exploit-CVE-2014-0038-x32-recvmmsg-kernel-vulnerablity.html

Run:
----
Retrieve addresses from `/proc/kallsyms` and run the exploit:

    ./build.sh && ./timeoutpwn

If you would like to build the binary for a remote server, try this:

    ssh user@host 'cat /proc/kallsyms' > syms.txt
    CFLAGS=-static ./build.sh syms.txt
    scp timeoutpwn user@host:
    ...

If `ptmx_fops` cannot be found in kallsyms, try extracting it from the vmlinux
as provided with the headers package (`linux-headers` on Arch Linux):

    nm /lib/modules/$(uname -r)/build/vmlinux > syms.txt
