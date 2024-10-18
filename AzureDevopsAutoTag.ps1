# Personal Access Token (PAT) ve gerekli değişkenler
$personalAccessToken = ""  # Azure DevOps için Personal Access Token
$organization = ""  # Azure DevOps organizasyonunuzun adı
$project = ""  # Projenizin adı
$userName = "Burak BOZ"  # İş öğesi Burak BOZ'a atanmış olanları hedefliyoruz
$repositoryId = ""  # Repo Id

# Azure DevOps URL
$baseUri = "https://dev.azure.com/$organization/$project/_apis"

# Burak BOZ'a atanmış, PR'a bağlı ve state'i Done olmayan iş öğelerini sorgulama
$workItemUri = "$baseUri/wit/wiql?api-version=6.0"

$wiqlQuery = @"
{
    "query": "SELECT [System.Id] 
              FROM workitems 
              WHERE [System.AssignedTo] = '$userName' 
              AND [System.WorkItemType] IN ('Task', 'Product Backlog Item', 'Bug', 'Defect')
              AND ([System.State] = 'Committed' OR [System.State] = 'New' OR [System.State] = 'Approved')
              AND [System.Tags] NOT CONTAINS 'Waiting Release'
              AND [System.Tags] NOT CONTAINS 'WaitingRelease'
              AND [System.Tags] NOT CONTAINS 'Waiting Test'
              AND [System.Tags] NOT CONTAINS 'In Review'
              AND [System.Tags] NOT CONTAINS 'InReview'
              AND [System.Tags] NOT CONTAINS 'WaitingTest'
              AND [System.Tags] NOT CONTAINS 'QA Tested'
              AND [System.Tags] NOT CONTAINS 'QATested'
              "
}
"@

# API'ye sorgu gönder
$workItems = Invoke-RestMethod -Uri $workItemUri -Method POST -Body $wiqlQuery -Headers @{
    Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$personalAccessToken"))
} -ContentType "application/json"

# Eğer workItems dizisi varsa, foreach ile dön
if ($workItems.workItems -ne $null) {
    foreach ($item in $workItems.workItems) {
        # İş öğesi ID'sini ve diğer bilgilerini yazdırabilirsiniz
        Write-Output "Work Item ID: $($item)"
        
        $prUri = "$baseUri/git/repositories/$($repositoryId)/pullrequests?api-version=6.0-preview.1"

        # PR'leri çek
        $pullRequests = Invoke-RestMethod -Uri $prUri -Method GET -Headers @{
            Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$personalAccessToken"))
        } -ContentType "application/json"
        
        # PR'ler varsa her bir PR'de linked work items'ı kontrol et
        if ($pullRequests -ne $null) {
            Write-Output "$($userName) tarafından oluşturulan PR'ler:"
            foreach ($pr in $pullRequests.value) {
                Write-Output "PR ID: $($pr.pullRequestId), Title: $($pr.title), Status: $($pr.status)"

                # Her PR'ye bağlı iş öğelerini sorgulama
                $workItemsUri = "$baseUri/git/repositories/$($repositoryId)/pullrequests/$($pr.pullRequestId)/workitems?api-version=6.0-preview.1"

                # İş öğeleri ile bağlantılı olup olmadığını kontrol etme
                $linkedWorkItems = Invoke-RestMethod -Uri $workItemsUri -Method GET -Headers @{
                    Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$personalAccessToken"))
                } -ContentType "application/json"
                
                # Eğer iş öğesi bağlı ise, istediğiniz iş öğesi ID'sini burada kontrol edebilirsiniz
                if ($linkedWorkItems.value.Count -gt 0) {
                    Write-Output "  PR'ye bağlı Work Item(s):"
                    foreach ($workItem in $linkedWorkItems.value) {
                        Write-Output "    Work Item ID: $($workItem.id), Title: $($workItem.fields.'System.Title')"
                        
                        # Eğer iş öğesi ile bağlı bir PR varsa, state ve tag güncellemelerini yap
                        if ($workItem.id -eq $($item.id)) {
                            Write-Output "    This PR is linked to the Work Item with ID $($item.id)."
                            
                            # İş öğesine 'In Review' tag'ini ekleme işlemleri
                            $tagUri = "$baseUri/wit/workitems/$($item.id)?api-version=6.0"
                            $tagBody = @(@{
                                op    = "add"
                                path  = "/fields/System.Tags"
                                value = "In Review"
                            })
                            
                            $jsonTagBody = ConvertTo-Json -InputObject $tagBody

                            # İş öğesine tag ekleme çağrısı
                            Invoke-RestMethod -Uri $tagUri -Method PATCH -Body $jsonTagBody -ContentType "application/json-patch+json" -Headers @{
                                Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$personalAccessToken"))
                            }

                            # İş öğesinin state'ini 'Committed' olarak değiştirme işlemi
                            $stateUri = "$baseUri/wit/workitems/$($item.id)?api-version=6.0"
                            $stateBody = @(@{
                                op    = "replace"
                                path  = "/fields/System.State"
                                value = "Committed"
                            })
                            
                            $jsonTagBodyForState = ConvertTo-Json -InputObject $stateBody

                            # İş öğesinin state'ini değiştirme çağrısı
                            Invoke-RestMethod -Uri $stateUri -Method PATCH -Body $jsonTagBodyForState -ContentType "application/json-patch+json" -Headers @{
                                Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$personalAccessToken"))
                            }

                            Write-Output "Work Item ID $($item.id) state updated to 'Committed'."
                            Write-Output "Work Item ID $($item.id) tagged as 'In Review'."
                        }else {
                    Write-Output "  linked Work Items not eq work item."
                }
                    }
                } else {
                    Write-Output "  No linked Work Items for this PR."
                }
            }
        } else {
            Write-Output "$($userName) tarafından oluşturulan PR bulunamadı."
        }
    }
} else {
    Write-Output "Work items bulunamadı."
}
