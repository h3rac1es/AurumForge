# 🏆 AurumForge – Golden Ticket Automation Tool

**AurumForge** is a Bash-based automation tool designed to streamline the creation of **Kerberos Golden Tickets** in Active Directory environments.

The tool fully automates:
- Domain SID extraction
- KRBTGT hash dumping using **DRSUAPI (DCSync)**
- Automatic fallback to **VSS** when DCSync fails
- Golden Ticket generation via Impacket

> ⚠️ **Disclaimer:**  
> This tool is intended for **authorized penetration testing, red team engagements, and CTF/lab environments only**.  
> Unauthorized use against systems you do not own or have permission to test is illegal.

---

## ✨ Features

- ✅ Automatic Domain SID extraction
- ✅ KRBTGT hash retrieval via **DCSync**
- ✅ **VSS fallback** if replication-based dumping fails
- ✅ Golden Ticket forging using Impacket Ticketer
- ✅ Clean, colored, and user-friendly CLI output
- ✅ Minimal manual interaction

---

## 🛠 Requirements

- Linux-based system
- Bash shell
- **Impacket** toolkit installed and accessible in `$PATH`
- Domain Admin credentials (NTLM hash)
- Network access to the Domain Controller

### Install Impacket
```bash
pip install impacket

```
## 🚀 Usage
Make the script executable:
```bash
chmod +x aurumforge.sh

```
Run the tool:

```bash
./aurumforge.sh
```

You will be prompted for:
Target domain (e.g. example.local)
Domain Controller IP address
Domain Admin username
Domain Admin NTLM hash

## 🧠 Workflow Overview

### 1.Domain SID Extraction

Uses impacket-lookupsid to identify the domain SID

### 2.KRBTGT Hash Dumping

+ Primary method: DRSUAPI (DCSync)
+ Fallback method: VSS

### 3.Golden Ticket Forging

Uses impacket-ticketer
Generates a Kerberos .ccache ticket

## 🎟 Using the Golden Ticket

Once the ticket is created:

```bash
export KRB5CCNAME=$(pwd)/Administrator.ccache
```

Example usage with PsExec:

```bash
impacket-psexec DOMAIN/Administrator@DC-HOSTNAME -k -no-pass
```

## 📂 Output

+ Administrator.ccache – Forged Golden Ticket
+ Ready to be used with Kerberos-authenticated Impacket tools

## 🧪 Tested On

+ Hack The Box
+ Active Directory lab environments
+ Red team simulations

## 🧑‍💻 Author

+ Created by a red team operator for automation, speed, and reliability.

## ⭐ Notes

+ Requires high-privileged credentials
+ Detection by modern EDR/SIEM is possible
+ OPSEC considerations are your responsibility
