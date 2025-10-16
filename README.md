MatchLang 🇬🇧🇹🇷
MatchLang, Flutter ile geliştirilmiş, oyunlaştırma (gamification) öğeleriyle zenginleştirilmiş bir İngilizce kelime öğrenme mobil uygulamasıdır. Kullanıcıların kelime dağarcığını eğlenceli bir şekilde geliştirmesini hedefler.

Bu proje, Eyüphan Zengin tarafından Atatürk Üniversitesi Mühendislik Fakültesi Bilgisayar Mühendisliği Bölümü  staj çalışması kapsamında geliştirilmiştir.


(Bu görsel temsilidir, kendi ekran görüntünüzü ekleyebilirsiniz)

✨ Temel Özellikler
Proje, tam teşekküllü bir mobil oyunda bulunması gereken birçok modern mekaniği içermektedir:

Kimlik Doğrulama:


Google ile Giriş: Firebase Authentication kullanarak hızlı ve güvenli kullanıcı girişi.



Misafir (Guest) Modu: Kullanıcıların hesap oluşturmadan uygulamayı denemesine olanak tanır.


Akıllı Veri Birleştirme: Misafir olarak ilerleyen bir kullanıcı, Google ile giriş yaptığında tüm ilerlemesi (seviye, coin, can vb.) otomatik olarak yeni hesabına aktarılır (mergeGuestDataToNewUser).

Oyun Mekanikleri:


Kelime Eşleştirme: Sürükle-bırak veya tıklama ile İngilizce ve Türkçe kelimeleri eşleştirmeye dayalı temel oyun döngüsü .


Dinamik Seviyeler: Kelimeler, yerel bir words.json dosyasından seviyelere göre asenkron olarak yüklenir .


Can (Yaşam) Sistemi: Yanlış eşleştirmelerde can azalır. Canlar bittiğinde "Game Over" diyaloğu gösterilir.



Oyun Sonu: Seviye tamamlandığında (LevelCompleteDialog) veya rütbe atlandığında (RankUpDialog)  özel ödül diyalogları gösterilir.


Oyunlaştırma ve Ekonomi:


Ana Ekran (Seviye Haritası): ListView.builder ile oluşturulmuş, dikey olarak kaydırılabilen ve otomatik olarak mevcut seviyeye odaklanan (ScrollController) bir seviye haritası .


Rütbe Sistemi: Kazanılan yıldızlara göre "Acemi", "Çırak", "Usta" gibi rütbelerin kilidi açılır (StarScreen) .



Can Yenilenme: Canlar 5'ten azsa, uygulama arka planda çalışırken (Ana Ekran'da) her 10 dakikada bir otomatik olarak 1 can yenilenir (Timer.periodic) .



Mağaza: Günlük hediye (24 saatlik zamanlayıcı) ve coin karşılığı can satın alma.



İstatistikler: fl_chart kütüphanesi kullanılarak oyuncunun günlük doğru/yanlış cevap oranlarını gösteren dinamik bir pasta grafik (PieChart) .


Şans Çarkı: flutter_fortune_wheel kütüphanesi ile 24 saatte bir çevrilebilen ve rastgele ödüller (coin veya PAS) veren bir şans çarkı .

Kullanıcı Deneyimi (UX):


Figma ile Tasarım: Kodlamaya başlamadan önce tüm uygulama arayüzü ve kullanıcı akışı Figma'da tasarlanmıştır .


Responsive Tasarım: MediaQuery kullanılarak tüm arayüz elemanları (yazı tipleri, boşluklar) ekran boyutuna göre oransal olarak ayarlanmıştır.


Geri Bildirim: Doğru/yanlış eşleşmelerde ses efektleri (SoundManager) ve HapticFeedback (titreşim)  kullanılır.



Kapsamlı Hata Yönetimi: Tüm ağ ve veritabanı işlemleri try-catch blokları ile güvence altına alınmış, kullanıcılara SnackBar aracılığıyla anlaşılır hata mesajları ("Yeterli coininiz yok!", "Giriş iptal edildi.") gösterilmiştir .

Ayarlar ve Kişiselleştirme:


Avatar Seçimi: Kullanıcıların GridView içinden bir profil avatarı seçmesine olanak tanır.


Kontroller: Ses efektleri ve titreşim ayarlarını açıp kapatma .


Hesap Yönetimi: İlerlemeyi sıfırlama ve hesaptan güvenli çıkış yapma (signOut).


🛠️ Kullanılan Teknolojiler ve Paketler
Framework: Flutter

Dil: Dart


Tasarım Aracı: Figma 

Durum Yönetimi (State Management):


provider: Uygulama genelindeki kullanıcı verilerini (örn: UserDataProvider) yönetmek ve arayüzü güncellemek için kullanıldı.

Yerel Veritabanı:


sqflite: Kullanıcı ilerlemesi, ayarları, can durumu ve zaman damgaları gibi tüm verileri cihazda kalıcı olarak saklamak için kullanıldı.

Kimlik Doğrulama:


firebase_auth: Google ile giriş işlemleri.


google_sign_in: Google oturumunu yönetme.

Önemli Flutter Paketleri:


fl_chart: İstatistikler ekranındaki pasta grafiği için.


flutter_fortune_wheel: Şans Çarkı özelliği için.


google_fonts: Uygulama genelinde özel yazı tipleri kullanmak için.
