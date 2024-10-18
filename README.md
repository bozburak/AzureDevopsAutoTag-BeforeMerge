English Description:
This Windows Service is designed to interact with Azure DevOps APIs and automate specific work item management tasks.

Work Item Query: The service queries Azure DevOps for work items assigned to a specific user (in this case, "Burak BOZ") that are in "Committed," "New," or "Approved" states and do not have certain tags (such as "Waiting Release" or "In Review").

Pull Request Checking: The service checks for pull requests associated with the queried work items. It retrieves pull requests and examines whether they are linked to any work items.

Work Item Updates: If a pull request is linked to a work item, the service updates the work item's state to "Committed" and adds the "In Review" tag.

Scheduled Task: The service runs automatically every 15 minutes, making it a continuous, background process that helps automate Azure DevOps task management. It ensures that work items are up-to-date and appropriately tagged without manual intervention.

Service Configuration: The service can be installed and configured to run automatically upon Windows startup.

-------------------------------------------------------------------------------------------------------------

Türkçe Açıklama:
Bu Windows Servisi, Azure DevOps API'leri ile etkileşime girerek belirli iş öğesi yönetim işlemlerini otomatikleştirir.:

İş Öğesi Sorgulama: Servis, Azure DevOps'tan belirli bir kullanıcıya (bu durumda "Burak BOZ") atanmış iş öğelerini sorgular. Sadece "Committed," "New," veya "Approved" durumunda olanlar ve belirli etiketlere sahip olmayanlar sorgulanır (örneğin, "Waiting Release" veya "In Review" etiketleri).

Pull Request Kontrolü: Servis, sorgulanan iş öğeleri ile ilişkilendirilmiş pull request'leri kontrol eder. Pull request'leri alır ve iş öğeleriyle bağlantılı olup olmadığını inceler.

İş Öğesi Güncellemeleri: Eğer bir pull request iş öğesiyle bağlantılıysa, servisin iş öğesinin durumunu "Committed" olarak günceller ve "In Review" etiketini ekler.

Zamanlanmış Görev: Servis her 15 dakikada bir otomatik olarak çalışır ve sürekli arka planda Azure DevOps görev yönetimini otomatikleştirir. İş öğelerinin güncel ve uygun şekilde etiketlendiğinden emin olur.

Servis Yapılandırması: Servis, Windows başlatıldığında otomatik olarak çalışacak şekilde kurulabilir ve yapılandırılabilir.
