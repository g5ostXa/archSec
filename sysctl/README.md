## ⚙️ sysctl hardening

#### Usage:
Clone the repository:
```bash
$ git clone --depth 1 https://github.com/g5ostXa/sysctl.git
```
Copy sysctl files to `/etc/sysctl.d/`:
```bash
$ sudo cp -r sysctl/* /etc/sysctl.d/
```
Give root permissions to the directory and all it's content:
```bash
$ sudo chown -R root:root /etc/sysctl.d/; sudo chown -R root:root /etc/sysctl.d/*
```
> [!NOTE]
> - You may need to manually apply a permission set of "600" to all files in `/etc/sysctl.d/`.

To print current permissions, type the following code in your terminal:
```bash
$ stat -c "%a %n" /etc/sysctl.d/*
```
If needed, change permissions to "600" for everything in `/etc/sysctl.d/`:
```bash
$ sudo chmod 600 /etc/sysctl.d/
```
Finally, apply kernel parameters permanently:
```bash
$ sudo sysctl --system
```

