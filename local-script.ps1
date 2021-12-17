$PSDefaultParameterValues['*:Encoding'] = 'utf8'
Write-Host "
    1 - Changer le nom du poste
    2 - Ajouter le poste sur le domaine AMCMZ
    3 - Quitter le domaine actuel
"
$choice = Read-Host "[+] Choix"

while ($choice -notin (1,2,3)) {
    $choice = Read-Host "[+] Choix"    
}

switch ($choice) {
    1 { 
        $choice = Read-Host "[+] Nom actuel: $Env:ComputerName
souhaitez vous poursuivre la modification? [y/n]"
        while ($choice -notin ('y','n')) {
            $choice = Read-Host "[+] Nom actuel: $Env:ComputerName
souhaitez vous poursuivre la modification? [y/n]"
        }
        switch ($choice) {
            'y' {
                Write-Host "    [+] Changement du nom du poste"
                $newname = Read-Host "[+] Choisissez le nouveau nom du poste" 
                try {
                    Rename-Computer -NewName $newname -Force -Restart
                }
                catch {
                    Write-Warning -Message "Une erreur s'est produite lors du renommage du poste..."
                }
            }
            'no' {
                break
            }
        }
    }
    2 {
        Write-Host "    [+] Ajout du poste au domaine AMCMZ"
        $account = Read-Host "[+] Saisissez votre compte administrateur de domaine"
        $domain = "amcmz.lan"
        $domainaccount = "AMCMZ\$account"
        Write-Warning "[+] Le poste va être ajouté au domaine $domain avec le nom $env:computername"
        $choice = Read-Host "[+] Voulez-vous procéder ? [y/n]"
        while ($choice -notin ('y','n')) {
            $choice = Read-Host "[+] Voulez-vous procéder ? [y/n]"  
        }
        switch ($choice) {
            'y' {
                try {
                    if ($Env:ComputerName -like "CA%") {
                        Add-Computer -DomainName $domain -Credential $domainaccount -Force -PassThru -OUPath "ou=Agglo,ou=Postes,DC=amcmz, DC=lan" | Out-Null
                        Write-Host 'Le poste a été ajouté au domaine et est déplacé automatiquement son unité organisationnelle' -ForegroundColor Green
                    }elseif ($Env:ComputerName -like "CM%") {
                        Add-Computer -DomainName $domain -Credential $domainaccount -Force -PassThru -OUPath "ou=Mairie,ou=Postes,DC=amcmz, DC=lan" | Out-Null
                        Write-Host 'Le poste a été ajouté au domaine et est déplacé automatiquement son unité organisationnelle' -ForegroundColor Green
                    }elseif ($Env:ComputerName -like "CC%") {
                        Add-Computer -DomainName $domain -Credential $domainaccount -Force -PassThru -OUPath "ou=CCAS,ou=Postes,DC=amcmz, DC=lan" | Out-Null
                        Write-Host 'Le poste a été ajouté au domaine et est déplacé automatiquement son unité organisationnelle' -ForegroundColor Green
                    }else {
                        Add-Computer -DomainName $domain -Credential $domainaccount -Force -PassThru -OUPath "ou=Postes,DC=amcmz, DC=lan" | Out-Null
                        Write-Host "Le poste a été ajouté dans l'unité organisationnelle par défaut" -ForegroundColor Green
                    }
                    $choice = Read-Host "[+] redémarrer l'ordinateur maintenant [y/n]"
                    while ($choice -notin ('y','n')) {
                        $choice = Read-Host "[+] redémarrer l'ordinateur maintenant [y/n]" 
                    }
                    switch($choice){
                            y{Restart-computer -Force -Confirm:$false}
                            n{exit}
                    }
                }
                catch {
                    Write-Warning -Message "Une erreur s'est produite lors de l'ajout du poste au domaine..."
                }
            }
            'no' {
                break
            }
        }
    }
    3 {
        $choice = Read-Host "[+] Voulez vous quitter le domaine $($env:USERDNSDOMAIN.ToLower()) [y/n]"
        while ($choice -notin ('y','n')) {
            $choice = Read-Host "[+] Voulez vous quitter le domaine $($env:USERDNSDOMAIN.ToLower()) [y/n]"   
        }
        switch ($choice) {
            'y' { 
                try {
                    $account = Read-Host "Saisissez votre compte administrateur de domaine"
                    $domainaccount = "AMCMZ\$account"
                    Remove-Computer -UnjoinDomaincredential $domainaccount -PassThru -Verbose
                    Write-Host "[+] Le poste a été retiré du domaine" -ForegroundColor Green
                    $choice = Read-Host "[+] redémarrer l'ordinateur maintenant [y/n]"
                    while ($choice -notin ('y','n')) {
                        $choice = Read-Host "[+] redémarrer l'ordinateur maintenant [y/n]" 
                    }
                    switch($choice){
                        y{Restart-computer -Force -Confirm:$false}
                        n{exit}
                    }
                }
                catch {
                    Write-Warning -Message "Une erreur s'est produite lors de l'ajout du poste au domaine..."
                }
            }
            'n' { 
                break
            }
            Default {
                exit
            }
        }
        Write-Warning "Fonctionnalité en cours de développement..."

        Start-Sleep -Seconds 5
    }
    Default {
        Exit
    }
}