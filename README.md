# ddgziptools
Two scripts allowing users to backup and compress disks to .gzip files, and restore them to chosen disks. The scripts will first check for a Darwin-based environment (macOS), or Linux-based environment (Ubuntu, etc.), and execute accordingly.

**Warning**

Any usage of dd can be very harmful *if* you don't know what you're doing. If you do, it's an amazingly powerful tool. If you've never used dd before, please read [dd Information"](https://github.com/ymgenesis/ddgziptools#dd-information) at the bottom before fooling around with it. She's sassy, and she'll bite ya.

# Detailed Usage

## ddgzipimage.sh

This script walks you through backing up your chosen disk to a .gzip file on your machine.

1. The script lists the disks in/connected to your machine, and asks you to input which disk you'd like to backup. Using disk3 as an example here:

```
[Output of `sudo diskutil list` (macOS) or `lsblk` (Linux)]

Which disk would you like to backup (ex: sdb (Linux) disk3 (macOS). Do not include partition)?
disk3
```

Be sure to follow the examples, leaving out partition numbers (ex: disk3 for mac, sdb for Linux).

2. The script will ask you to name the .gzip backup. Don't include extensions, a file extension of img.dd.gz will be added. Using 'test' as an example here:

```
Name your backup image (A file extension of .img.dd.gz will be added.):
test

The file test.img.dd.gz will be saved to [current working directory]
```

3. The script will ask you to specify a block size. This will vary between devices, and there are arguably no steadfast ways to calculate optimal block size on the fly. 1m (macOS) or 1M (Linux, notice upper-case) is usually safe. Using 1m as an example here:

```
Specify block size. Include unit of data in Upper-Case (ex: 64K, 512K, 1M):
1m
```

4. The script shows you the command to be executed, and asks you to review it:

```
The following will be executed. Please review carefully:

dd if=/dev/disk3 bs=1m | gzip -c > test.img.dd.gz

Execute? (y/N):
```

It then asks you if you're ready to execute the command. Type y to execute, or n to abort. Hitting enter at the prompt will also default to n, and the script will abort.

In this case, `dd` will take `/dev/disk3`'s data, copy it's data `1m` at a time. The data is piped `|` towards `gzip`, which uses `-c` to write the data to standard output. `>` takes the data and redirects it into `test.img.dd.gz`. When complete, `test.img.dd.gz` will be a byte-perfect copy of `/dev/disk3`!

5. If y is chosen, the script will countdown from 8, giving you an opportunity to terminate the process, just in case. It will unmount the chosen disk, and execute the command. It will update you with disk size and .img.dd.gz size (for comparison), and show you the output of the dd command it's running.

Once complete, the script will exit.

## ddgziprestore.sh
This script walks you through restoring a chosen .img.dd.gz file to a chosen disk.

1. Much like the imaging script, you choose a disk to restore to. This time, however, **you must use an absolute disk path**. As an example, here I choose /dev/disk3 (not simply disk3):

```
[Output of `sudo diskutil list` (macOS) or `lsblk` (Linux)]

Which disk would you like to restore to (Use absolute disk path. Ex: /dev/disk3. Do not include partition)?
/dev/disk3
```

2. The script then asks you to input a path to a .img.dd.gz file you created using ddgzipimage.sh. You can use tab completion here, but have to specify absolute paths (no ~ or $HOME, etc). I use test.img.dd.gzip as an example:

```
Which .img.dd.gz would you like to use (include absolute path and file extension. Tab completion enabled)?
/Users/ymgenesis/Desktop/test.img.dd.gz
```

3. The script shows you the command to be executed, and asks you to review it:

```
sudo sh -c 'gunzip -c /Users/ymgenesis/Desktop/working/test.img.dd.gz | dd of=/dev/disk3' bs=1m

Execute? (y/N):
```

Like ddgzipimage.sh, it asks you if you're ready to execute the command. Type y to execute, or n to abort. Hitting enter at the prompt will also default to n, and the script will abort.

In this case, `sudo sh -c` is used to execute commands in a string. Within `sudo sh -c`, `gunzip` is sending data from `test.img.dd.gz` to standard input using `-c`. Data is piped `|` to the `dd` command. `of=` specifies the *out file*, which in this case will be our chosen disk `/dev/disk3`. Outside of `sudo sh -c`, a block size of `1m` is used `bs=1m`. 

4. If y is chosen, the script will countdown from 8, giving you an opportunity to terminate the process, just in case. It will unmount the chosen disk, and execute the command. It will update you with information as it executes.

Once complete, the script will exit.

# dd Information

## dd 

From BAS General Commands Manual:

>The dd utility copies the standard input to the standard output.

Commonly:

`dd in=[in file] of=[out file] bs=[size]`

Say you want to clone your internal hard drive (/dev/disk0 macOS) to an external hard drive (/dev/disk3). The following command will do what you want on macOS:

`dd in=/dev/disk0 of=/dev/disk3 bs=1m`

If you simply switch the in and out files, however, the result could be disastrous. The following command will result in the external hard drive data being cloned to your mac's internal hard drive, effectively erasing your entire operating system:

`dd in=/dev/disk3 of=/dev/disk0 bs=1m`

Take care to understand that `in=` should equal where the data is being copied ***from***, and that `of=` should equal where the data is being copied ***to***. 

## dd and gzip
`dd if=/dev/disk3 bs=1m | gzip -c > test.img.dd.gz`

Let's break it down:

- `if=` – in file, the file/location dd reads from. When backing up, it reads FROM a file/disk and spits the data OUT somewhere
- `bs=` – block size. The size of data chunks dd takes FROM a file/disk for transfer to another file/disk
- `|` – A pipe. Instead of specifying of= (out file), we use a pipe here to redirect all data coming from dd to the gzip command
- `gzip -c` – gzip then compresses the data. -c tells gzip to write the data to standard output
- `> test.img.dd.gz` – \> redirects standard output towards something, in this case a filed called test.img.dd.gz
