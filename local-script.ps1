$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$ErrorActionPreference = "stop"
$programs = ("firefox", "ultravnc", "libreoffice", "anydesk", "adobereader", "googlechrome","zoom","microsoft-teams")
$listOk = @()
$someFailed = $false
$choice = $null

function startProccess{
    Write-Output "`nverrification packages...`n"
    foreach($i in $programs){
        $result = choco find $i
        if($result.Length -gt 2){
            $listOk = $listOk + $i
            $i + ' - ok'
        }else{
            $someFailed = $true
            $i + ' - erreur'
        }
    }
    Write-Output "`n"

    if($someFailed){
        Write-Warning "Erreur pour certains packages"

        while ($choice -notmatch "[y|n]"){
            $choice = Read-Host "Voulez-vous proceder ? [y/n]:"
        }
    }

    $hasUserAccepted = $null -eq $continue -or $continue -eq 'y'

    if($hasUserAccepted){
        startInstallation
    }
    else{
        Write-Error "Verifiez la liste des packages et reessayez"
    }
}

function progressBar{
    param($percent)
    Write-Progress -Activity 'Installation en cours' -PercentComplete $percent
}

function install{
    param($item)
    choco install $item -y --acceptlicense --force
}
function startInstallation{
    try{
        Write-Output "Debut de l'installation `n"
        for ($i = 1; $i -le $listOk.length; $i++){
            progressBar(($i/$listOk.length*100))
            install($listOk[$i - 1])
        }
    }
    catch{
        Write-Error "Erreur d'installation  des packages"
    }
}

do {
    Write-Host "
        1 - Changer le nom du poste
        2 - Ajouter le poste sur un domaine
        3 - Quitter le domaine actuel
        4 - Installation de package
        5 - Redemarrer l'ordinateur
        q - Quitter le programme
    "
    Write-Host -ForegroundColor DarkCyan -NoNewline "[+] Choix: "
    $choice = Read-Host

    while ($choice -notin (1,2,3,4,5,'q')) {
        Write-Host -ForegroundColor DarkCyan -NoNewline "[+] Choix: "
        $choice = Read-Host  
    }
    switch ($choice) {
        1 { 
            Write-Host -ForegroundColor Green "[+] Nom actuel: $Env:ComputerName"
            Write-Host -ForegroundColor Green -NoNewline "[+] souhaitez vous poursuivre la modification? [y/n]: "
            $choice = Read-Host
            while ($choice -notin ('y','n')) {
                Write-Host -ForegroundColor Green "[+] Nom actuel: $Env:ComputerName"
                Write-Host -ForegroundColor Green -NoNewline "[+] souhaitez vous poursuivre la modification? [y/n]: "
                $choice = Read-Host 
            }
            switch ($choice) {
                'y' {
                    Write-Host -ForegroundColor Green -NoNewline "[+] Choisissez le nouveau nom du poste: "
                    $newname = Read-Host
                    while ($newname -eq $Env:ComputerName) {
                        Write-Host -ForegroundColor Yellow "[*] Choisissez un nom different..."
                        Write-Host -ForegroundColor Green -NoNewline "[+] Choisissez le nouveau nom du poste: "
                        $newname = Read-Host
                    }
                    try {
                        Rename-Computer -NewName $newname -Force -Restart
                    }
                    catch {
                        Write-host -ForegroundColor red "[-] Une erreur s'est produite lors du renommage du poste..."
                        Start-Sleep -Seconds 1
                    }
                }
                'no' {
                    break
                }
            }
        }
        2 {
            $domain = Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem | Select-Object Name, Domain
            Write-Host -ForegroundColor Green "[+] le poste est dans le domaine $($domain.Domain)"
            Write-Host -ForegroundColor Green -NoNewline "[+] Souhaitez-vous poursuivre ? [y/n]: "
            $choice = Read-Host
            while ($choice -notin ('y','n')) {
                Write-Host -ForegroundColor Green -NoNewline "[+] Souhaitez-vous poursuivre ? [y/n]: "
                $choice = Read-Host 
            }
            switch ($choice) {
                'y' { 

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
                            $done = 0
                            if ($Env:ComputerName -like "CA*") {
                                try {
                                    add-computer -domainname $domain -Credential $domainaccount -OUPath "ou=Agglo,ou=Postes,DC=amcmz, DC=lan"
                                    Write-Host '[+] Le poste a ete ajoute au domaine et est deplace automatiquement dans son unite organisationnelle' -ForegroundColor Green
                                    $done = 1
                                }
                                catch {
                                    Write-Host -ForegroundColor Red "[-] $_"
                                    Start-Sleep -Seconds 2
                                }
                            }
                            elseif ($Env:ComputerName -like "CM*") {
                                try {
                                    add-computer -domainname $domain -Credential $domainaccount -OUPath "ou=Mairie,ou=Postes,DC=amcmz, DC=lan"
                                    Write-Host '[+] Le poste a ete ajoute au domaine et est deplace automatiquement dans son unite organisationnelle' -ForegroundColor Green
                                    $done = 1
                                }
                                catch {
                                    Write-Host -ForegroundColor Red "[-] $_"
                                    Start-Sleep -Seconds 2
                                }
                            }
                            elseif ($Env:ComputerName -like "CC*") {
                                try {
                                    add-computer -domainname $domain -Credential $domainaccount -OUPath "ou=CCAS,ou=Postes,DC=amcmz, DC=lan"
                                    Write-Host "[+] Le poste a ete ajoute au domaine et est d??place automatiquement dans son unite organisationnelle" -ForegroundColor Green
                                    $done = 1
                                }
                                catch {
                                    Write-Host -ForegroundColor Red "[-] $_"
                                    Start-Sleep -Seconds 2
                                }
                            }else {
                                try {
                                    Add-Computer -DomainName $domain -Credential $domainaccount -Force -OUPath "ou=Postes,DC=amcmz, DC=lan"
                                    Write-Host "[+] Le poste a ete ajoute dans l'unite organisationnelle par defaut" -ForegroundColor Green
                                    $done = 1
                                }
                                catch {
                                    Write-Host -ForegroundColor Red "[-] $_"
                                    Start-Sleep -Seconds 2
                                }
                            }
                            if ($done) {
                                Write-Host -ForegroundColor Green "[+] redemarrer l'ordinateur maintenant [y/n]: "
                                $choice = Read-Host 
                                while ($choice -notin ('y','n')) {
                                    Write-Host -ForegroundColor Green "[+] redemarrer l'ordinateur maintenant [y/n]: "
                                    $choice = Read-Host  
                                }
                                switch($choice){
                                    y{Restart-computer -Force -Confirm:$false}
                                    n{break}
                                }
                            }
                        }
                        'no' {
                            break
                        }
                    }
                 }
                'n' {
                    break
                }
            }
        }
        3 {
            $domain = Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem | Select-Object Name, Domain
            Write-host -ForegroundColor Green -NoNewline "[+] Voulez vous quitter le domaine $($domain.domain) [y/n]: "
            $choice = Read-Host 
            while ($choice -notin ('y','n')) {
                Write-host -ForegroundColor Green -NoNewline "[+] Voulez vous quitter le domaine $($domain.domain) [y/n]: "
                $choice = Read-Host 
            }
            switch ($choice) {
                'y' { 
                    Write-host -ForegroundColor Green -NoNewline "Saisissez votre compte administrateur de domaine: "
                    $account = Read-Host 
                    $domainaccount = "$($domain.domain)\$account"
                    try {
                        Remove-Computer -UnjoinDomaincredential $domainaccount -Force
                        Write-Host "[+] Le poste a ete retire du domaine" -ForegroundColor Green
                        Add-Content -Path \\vmstockage\agglo$\DSI\infrastructure\AD\sortie_postes.txt -Value $Env:ComputerName           
                    }
                    catch {
                        Write-Host -ForegroundColor Red "[-] Une erreur s'est produite lors de la suppression du poste au domaine..."
                        Write-Host -ForegroundColor Red "[-] $_"
                    }
                    Write-Host -ForegroundColor Green "[+] redemarrer l'ordinateur maintenant [y/n]: "
                    $choice = Read-Host 
                    while ($choice -notin ('y','n')) {
                        Write-Host -ForegroundColor Green "[+] redemarrer l'ordinateur maintenant [y/n]: "
                        $choice = Read-Host  
                    }
                    switch($choice){
                        y{Restart-computer -Force -Confirm:$false}
                        n{break}
                    }
                }
                'n' { 
                    break
                }
                Default {
                    break
                }
            }
        }
        4{
            while  ($choice -notin ('y','n','') ) {
                Write-Host -ForegroundColor Green -NoNewline "[+] Voulez-vous proceder a l'installation des packages [y/n]: "
                $choice = Read-Host
            }
            switch ($choice) {
                'n' {  
                    "no"
                }
                default {
                    $toInstall = @()
                    foreach ($item in $programs) {
                        Write-Host -NoNewline -ForegroundColor Yellow "Voulez-vous installer $item [y/n]: "
                        $install = Read-Host
                        while ($install -notin ('y','n','')) {
                            Write-Host -NoNewline -ForegroundColor Yellow "Voulez-vous installer $item [y/n]: "
                            $install = Read-Host
                        }
                        switch ($install) {
                            'n' { 
                                break
                            }
                            Default {
                                if ($install -in ('y','') ) {       
                                    $toInstall += $item
                                }
                            }
                        }
                    }
                    $programs = $toInstall
                    startProccess
                }
            }
        }
        5{
            while  ($choice -notin ('y','n','') ) {
                Write-Host -ForegroundColor Green -NoNewline "[+] Voulez-vous redemarrer l'ordinateur maintenant [y/n]: "
                $choice = Read-Host
            }
            switch($choice){
                'n'{break}
                Default{Restart-computer -Force -Confirm:$false}
            }
        }
        Default {
            break
        }
    } 
} until ($choice -eq 'q')