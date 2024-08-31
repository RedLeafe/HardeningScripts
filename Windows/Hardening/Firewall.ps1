Install-Module -Name Firewall-Manager

# Save Firewall Rules
Export-FirewallRules -CSVFile “C:\Users\Administrator\Cache\DefaultRules.csv”

# Disable all
Disable-NetFirewallRule -Name (Get-NetFirewallRule | select -ExpandProperty Name)

# Default Settings
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Set-NetFirewallProfile -DefaultOutboundProfile Block
Set-NetFirewallProfile -DefaultInboundProfile Block

New-NetFirewallRule -DisplayName “HTTP” -Direction Outbound -Protocol TCP -LocalPort 80 -Action Allow
New-NetFirewallRule -DisplayName “DNS” -Direction Outbound -Protocol TCP -LocalPort 53 -Action Allow
New-NetFirewallRule -DisplayName “SMB1” -Direction Outbound -Protocol TCP -LocalPort 445 -Action Allow
New-NetFirewallRule -DisplayName “SMB2” -Direction Outbound -Protocol TCP -LocalPort 135 -Action Allow