# Cozy Focus — Figma Room Layout Kit

Bu klasör, oda yerleşimini Figma'da gözle düzenleyip kesin koordinatları daha
sonra Codex'e statik veri olarak vermek için hazırlanmıştır. Uygulamanın bütün
ana oda öğeleri ve Gentle Goal Box ödülleri dahildir.

## Referans canvas

- Frame adı: `cozy_focus_room_899x1748`
- Frame genişliği: **899 px**
- Frame yüksekliği: **1748 px**
- Arka plan: `background/empty_room_base_v2.png`
- Arka plan konumu: `X=0, Y=0, W=899, H=1748`
- Arka plan frame'e yerleştirildikten sonra kilitlenmelidir.

Bu ölçü uygulamadaki gerçek oda arka planı ile birebirdir. Figma frame'ini
telefon ekranı boyutunda değil, mutlaka 899×1748 oluştur.

## Figma'ya aktarma

1. Figma'da 899×1748 boyutunda yeni bir Frame oluştur.
2. `background/empty_room_base_v2.png` dosyasını Frame içine ekle, X/Y değerini
   0/0 yap ve kilitle.
3. `items/` klasöründeki 18 PNG dosyasını Frame içine sürükle.
4. Her layer adını dosya adıyla aynı bırak: `desk`, `chair`, `tea_cup` vb.
5. Bütün item layer'larını Frame'in **doğrudan çocuğu** olarak tut. Group,
   component veya nested frame içine alma. Aksi durumda Figma sağ panelindeki
   X/Y değerleri oda frame'ine değil parent group'a göre gösterilebilir.
6. Oranı bozmamak için resize sırasında `Constrain proportions` açık olsun.
7. Odanın tüm ürünler kazanılmış son hâlini görsel olarak düzenle.
8. Layer sıralamasını da istediğin önden/arkadan görünüşe göre Figma'da ayarla.
9. Her layer'ı sırayla seçip Design panelindeki X/Y/W/H değerlerini
   `figma_measurements.csv` dosyasına yaz.
10. Tamamlandığında CSV dosyasını ve mümkünse Frame'in PNG export'unu Codex'e
    ver. Kodlama aşamasında yeni konum tahmini yapılmayacak; bu değerler doğrudan
    responsive Flutter koordinatlarına çevrilecek.

## Anchor ve sub-item ilişkileri

Bu ilişkiler görsel gruplama için değil, kodda destek bağımlılığını korumak
içindir. Figma'da gerçek Group oluşturma; layer'ları doğrudan Frame altında tut.

| Anchor | Bağlı sub-item'lar |
|---|---|
| `desk` | `desk_lamp`, `candle`, `tea_cup`, `desk_clock` |
| `bookshelf` | `book_stack`, `tiny_vase`, `owl_figure`, `leaf_lantern` |
| `rug` | `sleeping_cat` |
| Bağımsız anchor | `chair`, `potted_plant`, `wall_art`, `hanging_plant`, `starflower`, `night_fern` |

Bir sub-item yalnız bağlı olduğu anchor kazanıldıktan/yerleştirildikten sonra
odada gösterilmelidir. Bu kural mevcut uygulama mantığıyla uyumludur.

## Önerilen çalışma sırası

1. `rug`
2. `night_fern`, `starflower`
3. `bookshelf`
4. `desk`, `potted_plant`
5. `chair`, `sleeping_cat`
6. `wall_art`, `hanging_plant`
7. Masa ve kitaplık üzerindeki küçük sub-item'lar

Bu sıra zorunlu koordinat değildir; yalnız kompozisyonu büyük parçalardan küçük
parçalara kurmayı kolaylaştırır.

## Dosyalar

- `items/*.png`: Şeffaf, kırpılmış ve kod ID'siyle adlandırılmış item assetleri
- `background/empty_room_base_v2.png`: 899×1748 boş oda
- `reference/target_completed_room.png`: Kullanıcının verdiği hedef kompozisyon
  referansı
- `reference/current_app_composition.png`: Mevcut kodun son tamamlanmış oda
  renderı; Figma çalışmasında karşılaştırma için
- `item_inventory.csv`: Eksiksiz item/anchor/layer envanteri
- `figma_measurements.csv`: Figma'dan doldurulacak X/Y/W/H tablosu
- `room_layout_manifest.json`: Codex'in daha sonra okuyabileceği makine-okunur
  aynı envanter
- `asset_dimensions.csv`: Çıkarılmış PNG'lerin doğal piksel ölçüleri
- `tool/export_figma_room_kit.sh`: Atlaslar değişirse kitin yeniden üretilmesi
  için proje kökündeki export scripti

## Ölçüm kuralları

- X/Y ölçümü Frame'in sol üst köşesine göre olmalı.
- W/H değerleri Figma'da görünen son item boyutu olmalı; doğal PNG ölçüsü olmak
  zorunda değildir.
- Ondalıklı değerleri yuvarlama; Figma ne gösteriyorsa yaz.
- Rotation kullanma. Zorunluysa ayrıca `notes` sütununa açıyı yaz; mevcut
  Flutter yerleşim sözleşmesi X/Y/W/H ve layer order kullanır.
- Item'ın görünür kısmını ayrıca crop etme; PNG dosyaları zaten alfa sınırlarına
  göre kırpılmıştır.
