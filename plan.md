# Cozy Focus — Mevcut Durum ve Geliştirme Planı

> Son güncelleme: 17 Ağustos 2026
>
> Ana proje yolu: `/Users/sahinsanli/Desktop/Flutter_App`
>
> Git deposu: `https://github.com/sahinsanli/CozyFocus.git` — `main`

## Bu dosyanın kullanım kuralı

- Bu dosya projenin güncel durumuyla ilgili ana başvuru kaynağıdır.
- Codex, uygulamada yeni özellik geliştirmeden veya mevcut davranışı
  değiştirmeden önce bu dosyanın tamamını okumalıdır.
- Her çalışma tamamlandığında ilgili kutular güncellenmeli, yeni açık işler ve
  alınan önemli kararlar buraya eklenmelidir.
- Bir iş yalnızca kod yazıldığı için tamamlandı sayılmaz. Gerekli analiz, test
  veya gerçek servis doğrulaması yapıldıysa `[x]` olarak işaretlenir.
- Kullanıcı açıkça istemeden mevcut ürün kararları, oda koordinatları, veri
  şeması, paket adı ve yayın kimliği değiştirilmemelidir.

## 1. Kısa durum özeti

- [x] Flutter uygulamasının temel Focus, Room, Stats, Sounds, Profile ve
  Settings ekranları mevcut.
- [x] Splash ve onboarding akışı mevcut.
- [x] Uygulamanın varsayılan teması dark.
- [x] İngilizce ve Türkçe dil desteği mevcut; varsayılan dil İngilizce.
- [x] Yerel kayıt, Firebase Authentication ve Firestore senkronizasyonu mevcut.
- [x] Android release imzalama ve ilk AAB hazırlığı yapıldı.
- [x] Firestore güvenlik kuralları test edilerek Firebase'e yayımlandı.
- [x] Firebase App Check, Android release sürümünde Play Integrity kullanacak
  şekilde yapılandırıldı.
- [ ] Google Play geliştirici hesabı henüz açılmadı.
- [ ] Uygulama henüz Play Console'a yüklenmedi.
- [ ] Internal/Closed Testing ve gerçek Play Integrity doğrulaması henüz
  yapılmadı.
- [ ] Test modu production öncesinde kapatılmadı; şu anda varsayılan olarak açık.

## 2. Ürün özellikleri

### 2.1 Focus sistemi

- [x] Başlatma, duraklatma, devam ettirme ve tamamlanma akışı çalışıyor.
- [x] Focus sırasında ürünün aşamalı gelişimi gösteriliyor.
- [x] Tamamlanan oturum ödül ve claim akışına bağlanıyor.
- [x] Kazanılacak ürün sırası test modunda da normal kullanım mantığıyla
  ilerliyor.
- [x] Test modunda oturum doğrudan tamamlanabiliyor ve ara aşamalar
  görüntülenebiliyor.
- [x] Default focus duration seçenekleri 90 dakikaya kadar çıkıyor.
- [x] Daily Goal seçenekleri 8 saate kadar çıkıyor.
- [x] Kısa mola süresi ve çalışan auto-start break davranışı mevcut.
- [x] Focus Reminders ayarı Focus ekranında uygulama içi nazik hatırlatmayı
  açıp kapatıyor.
- [ ] Focus Reminders bir Android sistem bildirimi değildir; arka plan/yerel
  bildirim özelliği gerekirse ayrıca geliştirilecek.
- [ ] Production yayından önce test modunun varsayılanı `false` yapılmalı ve
  kullanıcıya görünen test kontrollerinin kaldırılıp kaldırılmayacağı
  kararlaştırılmalı.

### 2.2 Ödül, inventory ve Gentle Goal

- [x] Focus sonucunda aşamalı ürün kazanma sistemi mevcut.
- [x] Pending reward ve claim sistemi mevcut.
- [x] Inventory yerel olarak kalıcı ve hesap bazında Firestore ile eşitleniyor.
- [x] Kilitli inventory ürünleri soluk önizleme olarak gösteriliyor.
- [x] Badge tanımları, kazanma durumu ve animasyon akışı mevcut.
- [x] Daily/Gentle Goal tamamlanma ödülü mevcut.
- [x] Gentle Goal Collection ödülleri oda ürünleri olarak kullanılabiliyor.
- [x] Koleksiyon ürünlerinin görsel önizlemeleri mevcut.

### 2.3 Room sistemi

- [x] Boş oda arka planı mevcut.
- [x] Kullanıcı ürünleri serbestçe rastgele konumlandıramıyor.
- [x] Her ürünün Figma'dan alınan sabit koordinatı ve katman sırası var.
- [x] Ürünler yalnızca kendi kanonik yerlerine yerleşiyor.
- [x] Masa/sandalye/halı ve masa üstü ürünlerin katman sırası testlerle
  korunuyor.
- [x] Tamamlanmış oda bütün tanımlı ürünleri tek sahnede gösteriyor.
- [x] Oda sahnesinde ortam hareketleri ve ışık etkileşimleri mevcut.
- [x] Oda yerleşim değerleri `899 × 1748` referans canvas kullanıyor.

Odadaki güncel 12 ürün:

- [x] `desk`
- [x] `chair`
- [x] `rug`
- [x] `bookshelf`
- [x] `candle`
- [x] `wall_art`
- [x] `hanging_plant`
- [x] `sleeping_cat`
- [x] `tea_cup`
- [x] `night_fern`
- [x] `owl_figure`
- [x] `leaf_lantern`

> Oda ürünlerinin koordinatları ve katmanları, kullanıcı yeni bir Figma/CSV
> düzeni vermedikçe tahminle değiştirilmemelidir.

### 2.4 Ses sistemi

- [x] Aynı anda birden fazla ambiyans sesi çalabilen gerçek mixer mevcut.
- [x] Her kanalın bağımsız ses seviyesi var.
- [x] Stop All ve çalışan sleep timer mevcut.
- [x] `Rainy Night` ses dosyası bağlı.
- [x] `Cracking Fire` ses dosyası bağlı.
- [x] `Deep Forest` ses dosyası bağlı.
- [x] `Soft Piano` ses dosyası bağlı.
- [ ] `Quiet Cafe` için ses dosyası henüz yok; kart görseli var fakat production
  mixer'da aktif değil.
- [ ] `Moonlit Pond` için ses dosyası henüz yok; kart görseli var fakat
  production mixer'da aktif değil.
- [x] Click, putting item, claim reward, cat meow ve wood cut efektleri projede.
- [x] Wood cut sesi ürünün focus sırasındaki ara gelişimlerinde çalmıyor;
  rahatsız edici tekrar kaldırıldı.
- [x] Ses adları Türkçe dilinde de bilinçli olarak İngilizce kalıyor.

### 2.5 Profil, ayarlar ve arayüz

- [x] Profil adı düzenleme ve kaydetme çalışıyor.
- [x] Hazır avatarlar arasından profil görseli seçilebiliyor.
- [x] Profil, badge, focus hours, streak ve decoration bilgileri gösteriliyor.
- [x] Dark/light appearance seçimi çalışıyor; varsayılan dark.
- [x] English/Türkçe seçimi uygulamayı anında güncelliyor ve cihazda saklanıyor.
- [x] Splash ve onboarding tasarımları uygulamaya entegre.
- [x] İlk kez kullananlar için üç tanıtım sayfasından sonra günlük hedef,
  varsayılan odak süresi ve kısa mola süresini seçebilecekleri dördüncü bir
  kişiselleştirme sayfası mevcut.
- [x] İlk kurulum tercihleri tek işlemde yerel hesaba ve mevcut Firestore
  progress modeline kaydediliyor; aktif bir oturumun süresini değiştirmiyor.
- [x] İlk kurulum tamamen atlanabiliyor; atlandığında mevcut `120/25/5`
  varsayılanları korunuyor.
- [x] Onboarding kişiselleştirme ekranı İngilizce/Türkçe ve `320×700` dar ekran
  düzenlerinde taşmadan çalışıyor.
- [x] Android uygulama ikonu focus + room temasına göre yenilendi; loading halkası
  kaldırıldı.
- [x] Ayarlar ekranında Privacy Policy, Terms of Use, Account Deletion ve
  Support bağlantıları var.

## 3. Yerelleştirme

- [x] Flutter `gen_l10n` ve ARB altyapısı kullanılıyor.
- [x] `app_en.arb` kaynak dil.
- [x] `app_tr.arb` Türkçe çevirileri içeriyor.
- [x] Cihaz Türkçe olsa bile temiz kurulum İngilizce başlıyor.
- [x] Dil tercihi `preferred_language_code` ile yalnızca cihazda saklanıyor.
- [x] Hesap veya Firestore senkronizasyonu dil tercihini değiştirmiyor.
- [x] Süre, çoğul ve dakika/saat gösterimleri yerelleştiriliyor.
- [x] Sound Catalog isimleri çevrilmiyor.
- [x] `Cozy Focus Room` marka adı çevrilmiyor.

## 4. Veri ve backend

### 4.1 Yerel veri

- [x] SharedPreferences tabanlı versioned progress sistemi mevcut.
- [x] Eski kayıtlar için migration ve bozuk kayıt yedeği mevcut.
- [x] Yerel veriler Firebase UID bazında ayrılıyor.
- [x] Timer'ın anlık durumu, aktif sesler, sleep timer ve test modu cihazda
  tutuluyor.

### 4.2 Firebase

- [x] Firebase projesi: `cozyfocus-1ca80`.
- [x] Firestore: Standard Edition, `europe-west3` — Frankfurt.
- [x] Android package/application ID: `com.sahinsanli.cozyfocus`.
- [x] Anonymous Authentication aktif ve uygulama ilk açılışta guest kullanıcı
  oluşturuyor.
- [x] Email/password hesap oluşturma, giriş ve şifre sıfırlama mevcut.
- [x] Google ile giriş mevcut.
- [x] Guest hesabın Google/e-posta hesabına bağlanması ve ilerleme birleştirme
  mantığı mevcut.
- [x] Firestore veri yolları:
  - `users/{uid}`
  - `users/{uid}/state/progress`
  - `users/{uid}/focusSessions/{sessionId}`
- [x] Firestore yalnızca kullanıcının kendi UID yoluna erişmesine izin veriyor.
- [x] Beklenen alanlar, temel tipler ve progress schema version 3 kurallarda
  doğrulanıyor.
- [x] Firestore Rules emülatör testleri mevcut ve 4/4 geçti.
- [x] Güncel Firestore Rules gerçek Firebase projesine deploy edildi.
- [x] Hesap silme; Firestore verisi, Auth hesabı ve kullanıcıya ait yerel veriyi
  siliyor.
- [x] Firebase Analytics, Crashlytics, Storage ve reklam SDK'sı ilk sürümde yok.

### 4.3 App Check

- [x] Debug build `AndroidDebugProvider` kullanıyor.
- [x] Profile/release build `AndroidPlayIntegrityProvider` kullanıyor.
- [x] Play Integrity App Check kaydı Firebase API üzerinden doğrulandı.
- [x] Token TTL: 1 saat.
- [x] Firestore ve Authentication enforcement şu anda bilinçli olarak kapalı.
- [ ] Play Console Internal Testing'den yüklenen release ile geçerli App Check
  istekleri doğrulanmalı.
- [ ] Doğrulama sonrasında Firestore ve Authentication enforcement açılmalı.

## 5. Android ve Google Play hazırlığı

- [x] Android package ID sabit: `com.sahinsanli.cozyfocus`.
- [x] Sürüm: `1.0.0+1`.
- [x] `minSdk 24`, `targetSdk 36`.
- [x] Release build debug key kullanmıyor.
- [x] Özel upload keystore oluşturuldu.
- [x] Upload SHA-1 ve SHA-256 Firebase'e eklendi.
- [x] Güncel `google-services.json` projeye alındı.
- [x] Release AAB üretildi ve imzası doğrulandı.
- [x] Android manifestte cleartext trafik kapalı ve backup devre dışı.
- [x] 512×512 store icon hazır.
- [x] 1024×500 feature graphic hazır.
- [x] İngilizce/Türkçe store listing taslağı hazır.
- [x] Data Safety taslağı hazır.
- [x] Privacy, Terms, Delete Account ve Support sayfaları Firebase Hosting'de
  yayında.
- [ ] `android/upload-keystore.p12` ve `android/key.properties` şifreli harici
  konuma yedeklenmeli.
- [ ] Google Play geliştirici hesabı açılmalı ve kimlik doğrulaması yapılmalı.
- [ ] Play Console'da uygulama oluşturulmalı.
- [ ] Play App Signing etkinleştirilmeli ve AAB Internal Testing'e yüklenmeli.
- [ ] Play App Signing SHA-1/SHA-256 değerleri Firebase'e eklenmeli.
- [ ] Play sürümünden güncel telefon ekran görüntüleri alınmalı.
- [ ] App access, Ads, Content rating, Target audience, Privacy, Data Safety ve
  Account deletion formları tamamlanmalı.
- [ ] Internal Testing tamamlanmalı.
- [ ] Yeni kişisel geliştirici hesabı kullanılacaksa 12 tester / 14 gün Closed
  Testing gereksinimi tamamlanmalı.
- [ ] Production öncesi test modu kapatılmalı ve version code artırılmalı.

Yayın belgeleri:

- `docs/release/PLAY_STORE_CHECKLIST.md`
- `docs/release/ANDROID_SIGNING.md`
- `docs/release/APP_CHECK.md`
- `docs/release/DATA_SAFETY_DRAFT.md`
- `docs/release/STORE_LISTING.md`

## 6. Yasal ve destek sayfaları

- [x] Privacy: `https://cozyfocus-1ca80.web.app/privacy`
- [x] Terms: `https://cozyfocus-1ca80.web.app/terms`
- [x] Account deletion: `https://cozyfocus-1ca80.web.app/delete-account`
- [x] Support: `https://cozyfocus-1ca80.web.app/support`
- [x] Destek e-postası: `ganyuyku@gmail.com`.
- [ ] Veri toplama veya SDK kapsamı değişirse Privacy Policy ve Data Safety
  taslağı yeniden güncellenmeli.

## 7. Son doğrulanan test durumu

Son uygulama doğrulaması: 17 Ağustos 2026

- [x] `flutter analyze` — sorun yok.
- [x] `flutter test` — 65/65 test geçti.
- [x] Android debug APK build başarılı.
- [x] Firestore Rules emulator — 4/4 test geçti.
- [x] Rules test bağımlılıkları için `npm audit` — 0 açık.
- [x] Release AAB build başarılı.
- [x] AAB imzası upload sertifikasıyla doğrulandı.
- [x] Release manifest: package doğru, target API 36, version code 1.

> Release AAB, imza ve manifest doğrulamaları 11 Ağustos 2026 tarihindeki yayın
> hazırlığına aittir. İlk açılış kişiselleştirme değişikliği için bu turda Android
> debug APK yeniden üretildi; yeni release AAB Play Console yüklemesinden önce
> tekrar oluşturulmalıdır.

> Yeni özellik veya bağımlılık değişikliği sonrasında bu test sonuçları tekrar
> üretilmeden mevcut sonuçlar yeni kod için geçerli kabul edilmemelidir.

## 8. Bilinen açık işler ve öncelik sırası

### P0 — Play yayın akışı

- [ ] Upload anahtarı ve parolaları güvenli biçimde yedekle.
- [ ] Play Console geliştirici hesabını aç.
- [ ] Cozy Focus uygulamasını oluştur ve Play App Signing'i etkinleştir.
- [ ] AAB'yi Internal Testing'e yükle.
- [ ] Play signing SHA değerlerini Firebase'e ekle.
- [ ] Auth, Firestore ve App Check'i Play'den yüklenen sürümde doğrula.

### P1 — Production temizliği

- [ ] Test modunun varsayılanını kapat.
- [ ] Test modu kontrollerinin production sürümünde görünmemesini sağla veya
  bilinçli ürün kararı ver.
- [ ] Store ekran görüntülerini gerçek release görünümünden al.
- [ ] Production release öncesi tüm cihaz/servis test matrisini çalıştır.

### P2 — Eksik içerikler

- [ ] Quiet Cafe için lisanslı/özgün loop ses dosyası ekle.
- [ ] Moonlit Pond için lisanslı/özgün loop ses dosyası ekle.
- [ ] Android sistem/yerel focus bildirimleri isteniyorsa ayrı özellik olarak
  planla; mevcut Focus Reminders bunun yerine geçmez.

## 9. Git çalışma durumu

- Son commit: `1fd483b Add Turkish localization and refresh app icon`.
- Bu dosya oluşturulurken Play release hazırlıkları, Firestore rule
  sıkılaştırmaları, yasal ayar bağlantıları, store belgeleri ve store görselleri
  çalışma alanında **henüz commitlenmemiş/pushlanmamış değişikliklerdir**.
- [ ] Mevcut çalışma alanı gözden geçirilip tek bir release-preparation commit'i
  olarak GitHub'a pushlanmalı.

## 10. Değişiklik günlüğü

### 17 Ağustos 2026

- [x] Projenin mevcut durumu tek kaynak olarak bu `plan.md` dosyasına aktarıldı.
- [x] Tamamlanan özellikler, bilinen sınırlamalar ve Play yayınında bekleyen
  manuel adımlar ayrıştırıldı.
