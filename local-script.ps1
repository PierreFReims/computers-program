$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$ErrorActionPreference = "stop"

Write-Host "
    1 - Changer le nom du poste
    2 - Ajouter le poste sur un domaine
    3 - Quitter le domaine actuel
    4 - Installation de package
"
Write-Host -ForegroundColor DarkCyan -NoNewline "[+] Choix: "
$choice = Read-Host

while ($choice -notin (1,2,3,4)) {
    Write-Host -ForegroundColor DarkCyan -NoNewline "[+] Choix: "
    $choice = Read-Host  
}

switch ($choice) {
    1 { 
        Write-Host -ForegroundColor DarkCyan -NoNewline "[+] Nom actuel: $Env:ComputerName
souhaitez vous poursuivre la modification? [y/n]: "
        $choice = Read-Host
        while ($choice -notin ('y','n')) {
            Write-Host -ForegroundColor DarkCyan -NoNewline "[+] Nom actuel: $Env:ComputerName
souhaitez vous poursuivre la modification? [y/n]: "
            $choice = Read-Host 
        }
        switch ($choice) {
            'y' {
                Write-Host -ForegroundColor Green -NoNewline "[+] Choisissez le nouveau nom du poste: "
                $newname = Read-Host
                while ($newname -eq $Env:ComputerName) {
                    Write-Host -ForegroundColor Green -NoNewline "[+] Choisissez le nouveau nom du poste: "
                    $newname = Read-Host
                }
                try {
                    Rename-Computer -NewName $newname -Force -Restart
                }
                catch {
                    Write-host -ForegroundColor red "[-] Une erreur s'est produite lors du renommage du poste..."
                    Start-Sleep -Seconds 10
                }
            }
            'no' {
                break
            }
        }
    }
    2 {
        Write-Host -ForegroundColor Green -NoNewline "[+] Quel domaine voulez vous rejoindre ? "
        $domain = Read-Host 
        Write-Host -ForegroundColor Green -NoNewline "[+] Saisissez votre compte administrateur de domaine: "
        $account = Read-Host
        $domainaccount = "$domain\$account" 
        Write-host -ForegroundColor Green "[+] Le poste va etre ajoute au domaine $domain avec le nom $env:computername"
        Write-Host -ForegroundColor Green -NoNewline "[+] Voulez-vous proceder ? [y/n]: "  
        $choice = Read-Host 
        while ($choice -notin ('y','n')) {
            Write-Host -ForegroundColor Green -NoNewline "[+] Voulez-vous proceder ? [y/n]: "
            $choice = Read-Host 
        }
        switch ($choice) {
            'y' {
                if ($Env:ComputerName -like "CA*") {
                    try {
                        add-computer -domainname $domain -Credential $domainaccount -OUPath "ou=Agglo,ou=Postes,DC=amcmz, DC=lan"
                        Write-Host '[+] Le poste a ete ajoute au domaine et est deplace automatiquement dans son unite organisationnelle' -ForegroundColor Green
                    }
                    catch {
                        Write-Host -ForegroundColor Red "[-] $_"
                        Start-Sleep -Seconds 10
                    }
                }
                elseif ($Env:ComputerName -like "CM*") {
                    try {
                        add-computer -domainname $domain -Credential $domainaccount -OUPath "ou=Mairie,ou=Postes,DC=amcmz, DC=lan"
                        Write-Host '[+] Le poste a ete ajoute au domaine et est deplace automatiquement dans son unite organisationnelle' -ForegroundColor Green
                    }
                    catch {
                        Write-Host -ForegroundColor Red "[-] $_"
                        Start-Sleep -Seconds 10
                    }
                }
                elseif ($Env:ComputerName -like "CC*") {
                    try {
                        add-computer -domainname $domain -Credential $domainaccount -OUPath "ou=CCAS,ou=Postes,DC=amcmz, DC=lan"
                        Write-Host "[+] Le poste a ete ajoute au domaine et est déplace automatiquement dans son unite organisationnelle" -ForegroundColor Green
                    }
                    catch {
                        Write-Host -ForegroundColor Red "[-] $_"
                        Start-Sleep -Seconds 10
                    }
                }else {
                    try {
                        Add-Computer -DomainName $domain -Credential $domainaccount -Force -OUPath "ou=Postes,DC=amcmz, DC=lan"
                        Write-Host "[+] Le poste a ete ajoute dans l'unite organisationnelle par defaut" -ForegroundColor Green
                    }
                    catch {
                        Write-Host -ForegroundColor Red "[-] $_"
                        Start-Sleep -Seconds 10
                    }
                }
                Write-Host -ForegroundColor Green "[+] redemarrer l'ordinateur maintenant [y/n]: "
                $choice = Read-Host 
                while ($choice -notin ('y','n')) {
                    Write-Host -ForegroundColor Green "[+] redemarrer l'ordinateur maintenant [y/n]: "
                    $choice = Read-Host  
                }
                switch($choice){
                    y{Restart-computer -Force -Confirm:$false}
                    n{exit}
                }
            }
            'no' {
                break
            }
        }
    }
    3 {
        $domain = Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem | Select-Object Name, Domain
        Write-host -ForegroundColor Green -NoNewline "[+] Voulez vous quitter le domaine $($domain.domain.ToLower()) [y/n]: "
        $choice = Read-Host 
        while ($choice -notin ('y','n')) {
            Write-host -ForegroundColor Green -NoNewline "[+] Voulez vous quitter le domaine $($domain.domain.ToLower()) [y/n]: "
            $choice = Read-Host 
        }
        switch ($choice) {
            'y' { 
                $account = Read-Host "Saisissez votre compte administrateur de domaine"
                $domainaccount = "$($domain.domain)\$account"
                try {
                    Remove-Computer -UnjoinDomaincredential $domainaccount -Force
                    Write-Host "[+] Le poste a ete retire du domaine" -ForegroundColor Green
                }
                catch {
                    Write-Host -ForegroundColor Red "Une erreur s'est produite lors de la suppression du poste au domaine..."
                    Write-Host -ForegroundColor Red "$_"
                }
                $choice = Read-Host "[+] redemarrer l'ordinateur maintenant [y/n]"
                while ($choice -notin ('y','n')) {
                    $choice = Read-Host "[+] redemarrer l'ordinateur maintenant [y/n]" 
                }
                switch($choice){
                    y{Restart-computer -Force -Confirm:$false}
                    n{exit}
                }
            }
            'n' { 
                break
            }
            Default {
                exit
            }
        }
    }
    4{
        Write-Warning "Fonctionnalite en cours de developpement..."
        Start-Sleep -Seconds 5
    }
    Default {
        Exit
    }
}