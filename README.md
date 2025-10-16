# MatchLang 🇬🇧🇹🇷

> Eğlenerek İngilizce kelime öğrenmenin en oyunlaştırılmış yolu!

**MatchLang**, [Flutter](https://flutter.dev) ile geliştirilmiş, zengin oyunlaştırma (gamification) mekaniklerine sahip bir İngilizce kelime öğrenme mobil uygulamasıdır.

Bu proje, **Eyüphan Zengin** tarafından **Atatürk Üniversitesi Mühendislik Fakültesi Bilgisayar Mühendisliği Bölümü** staj çalışması kapsamında sıfırdan tasarlanmış ve kodlanmıştır.


---

## 🛠️ Teknolojiler ve Mimari

Proje, modern mobil uygulama geliştirme standartları göz önünde bulundurularak inşa edilmiştir:

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=Dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth-%23FFCA28.svg?style=for-the-badge&logo=Firebase&logoColor=black)
![SQFlite](https://img.shields.io/badge/SQFlite-Local_DB-blue.svg?style=for-the-badge)
![Provider](https://img.shields.io/badge/Provider-State_Management-blue.svg?style=for-the-badge)
![Figma](https://img.shields.io/badge/Figma-%23F24E1E.svg?style=for-the-badge&logo=Figma&logoColor=white)

* **Mimari:** Proje, UI (Arayüz), State Management (Durum Yönetimi) ve Data (Veri) katmanlarını birbirinden ayırmayı hedefleyen temiz bir mimari izler.
* **Durum Yönetimi:** `provider` paketi kullanılarak uygulama durumu merkezi bir `UserDataProvider` sınıfı üzerinden yönetilmiştir.
* **Yerel Veritabanı:** `sqflite` kullanılarak oyuncu ilerlemesi, ayarları, coin/can miktarı ve zaman damgaları (son hediye, son can yenilenmesi vb.) cihazda güvenli bir şekilde saklanmıştır.

---

## ✨ Proje Özellikleri

### 🔐 Kimlik Doğrulama ve Kullanıcı Yönetimi

* **Google ile Hızlı Giriş:** [Firebase Authentication] altyapısı ile tek tıkla güvenli ve hızlı kullanıcı girişi.
* **Misafir Modu:** Kullanıcıların hesap oluşturmadan uygulamayı denemesine olanak tanır.
* **Akıllı Veri Birleştirme:** Misafir olarak ilerleyen bir kullanıcı, Google ile giriş yaptığında tüm ilerlemesi (seviye, coin, can vb.) otomatik olarak yeni hesabına aktarılır (`mergeGuestDataToNewUser`).

### 🎮 Temel Oyun Mekanikleri

* **Kelime Eşleştirme:** Sürükle-bırak veya tıklama ile İngilizce ve Türkçe kelimeleri eşleştirmeye dayalı temel oyun döngüsü.
* **Dinamik Seviye Yükleme:** Tüm kelimeler, yerel bir `assets/data/words.json` dosyasından seviyelere göre asenkron olarak yüklenir ve karıştırılır.
* **Can Sistemi ve Oyun Sonu:** Yanlış eşleştirmelerde can azalır. Seviye tamamlandığında (`LevelCompleteDialog`) veya rütbe atlandığında (`RankUpDialog`) özel ödül diyalogları gösterilir.

### 🏆 Oyunlaştırma ve Ekonomi

* **Dikey Seviye Haritası:** `ListView.builder` ile oluşturulmuş, yüzlerce seviyeyi kaldırabilen, performanstan ödün vermeyen bir ana ekran. `ScrollController` kullanılarak kullanıcının mevcut seviyesine otomatik odaklanır.
* **Rütbe Sistemi:** Kazanılan yıldızlara göre ("Boss" seviyelerinden elde edilir) "Acemi", "Çırak", "Usta" gibi rütbelerin kilidi açılır (`StarScreen`).
* **Otomatik Can Yenileme:** Canlar 5'ten azsa, uygulama ana ekranda çalışırken `Timer.periodic` ile her 10 dakikada bir otomatik olarak 1 can yenilenir.
* **Mağaza ve Günlük Hediyeler:** 24 saatlik geri sayım ile günlük hediye (coin) alınabilen ve coin karşılığı can satın alınabilen bir mağaza ekranı (`StoreScreen`).
* **İstatistik Ekranı:** `fl_chart` kütüphanesi kullanılarak oyuncunun günlük doğru/yanlış cevap oranlarını gösteren dinamik bir pasta grafik (`PieChart`).
* **Şans Çarkı:** `flutter_fortune_wheel` kütüphanesi ile 24 saatte bir çevrilebilen ve rastgele ödüller (coin veya PAS) veren bir şans çarkı.

### 🎨 Arayüz ve Kullanıcı Deniyimi (UI/UX)

* **Tasarım Odaklı Geliştirme:** Kodlamaya başlamadan önce uygulamanın tüm ekranları ve akışları Figma'da detaylıca tasarlanmıştır.
* **Responsive Tasarım:** `MediaQuery` kullanılarak tüm arayüz elemanları (yazı tipleri, boşluklar, butonlar) ekran boyutuna göre oransal olarak ayarlanmıştır. Uygulama, farklı boyuttaki telefonlarda tutarlı bir görünüm sunar.
* **Duyusal Geri Bildirim:** Doğru/yanlış eşleşmelerde, kullanıcının ayarlarına bağlı olarak ses efektleri (`SoundManager`) ve `HapticFeedback` (titreşim) kullanılır.
* **Kapsamlı Hata Yönetimi:** Tüm ağ ve veritabanı işlemleri `try-catch` blokları ile güvence altına alınmıştır. Kullanıcılara `SnackBar` aracılığıyla "Yeterli coininiz yok!", "Giriş iptal edildi." gibi anlaşılır hata mesajları gösterilir.

### 🔧 Ayarlar ve Kişiselleştirme

* **Avatar Seçimi:** Kullanıcıların `GridView` içinden önceden hazırlanmış avatarlardan birini profil resmi olarak seçmesine olanak tanır.
* **Oyun Kontrolleri:** Ses efektleri ve titreşim ayarlarını açıp kapatma.
* **Hesap Yönetimi:** İlerlemeyi sıfırlama ve hesaptan güvenli çıkış yapma (`signOut`).

---

## 🚀 Projeyi Çalıştırma

1️⃣ **Depoyu klonlayın:**
```sh
git clone [https://github.com/](https://github.com/)[KULLANICI_ADINIZ]/[REPO_ADINIZ].git
