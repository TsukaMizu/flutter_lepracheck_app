# SEQUENCE DIAGRAMS – FLUTTER LEPRACHECK APP

> Semua diagram dalam format **PlantUML**.
> Untuk me-render, gunakan [PlantUML Online](https://www.plantuml.com/plantuml/uml/) atau plugin VS Code PlantUML.

---

## DAFTAR ISI

1. [SD-01: App Launch & Routing (Splash → Home/Welcome)](#sd-01-app-launch--routing-splash--homewelcome)
2. [SD-02: Alur Onboarding (Pertama Kali)](#sd-02-alur-onboarding-pertama-kali)
3. [SD-03: Alur Deteksi Lengkap (Kamera → Hasil → Simpan)](#sd-03-alur-deteksi-lengkap-kamera--hasil--simpan)
4. [SD-04: Alur Deteksi – Galeri (Pilih Foto → Hasil → Simpan)](#sd-04-alur-deteksi--galeri-pilih-foto--hasil--simpan)
5. [SD-05: Proses Inferensi ML (TFLite + Fallback Remote)](#sd-05-proses-inferensi-ml-tflite--fallback-remote)
6. [SD-06: Simpan Laporan dengan Data Pasien & GPS](#sd-06-simpan-laporan-dengan-data-pasien--gps)
7. [SD-07: Lihat & Filter Riwayat](#sd-07-lihat--filter-riwayat)
8. [SD-08: Lihat Detail Riwayat & Buka Peta](#sd-08-lihat-detail-riwayat--buka-peta)
9. [SD-09: Hapus Riwayat (Satu Entri)](#sd-09-hapus-riwayat-satu-entri)
10. [SD-10: Hapus Semua Riwayat](#sd-10-hapus-semua-riwayat)
11. [SD-11: Lihat Konten Edukasi (Artikel & Video)](#sd-11-lihat-konten-edukasi-artikel--video)
12. [SD-12: Baca Detail Artikel Edukasi](#sd-12-baca-detail-artikel-edukasi)

---

## SD-01: App Launch & Routing (Splash → Home/Welcome)

```plantuml
@startuml SD-01
!theme plain
skinparam sequenceMessageAlign center

title SD-01: App Launch & Routing

actor "User" as U
participant "SplashPage\n(lib/features/splash/splash_page.dart)" as SP
participant "AppPrefs\n(lib/data/app_prefs.dart)" as AP
database "Hive\n(app_prefs box)" as H
participant "WelcomePage" as WP
participant "HomePage" as HP

U -> SP : launch app
activate SP
  SP -> SP : _startAnimation()\n(fade-in + scale, 900ms)
  SP -> SP : await Future.delayed(2500ms)
  SP -> AP : isOnboardingDone()
  activate AP
    AP -> H : openBox('app_prefs')
    H --> AP : box
    AP -> H : box.get('onboarding_done',\ndefaultValue: false)
    H --> AP : bool value
    AP --> SP : done (true/false)
  deactivate AP

  alt done == false (Pengguna baru)
    SP -> WP : context.go('/welcome')
    activate WP
    WP --> U : Tampilkan halaman Welcome
    deactivate WP
  else done == true (Pengguna lama)
    SP -> HP : context.go('/home')
    activate HP
    HP --> U : Tampilkan Beranda
    deactivate HP
  end
deactivate SP

@enduml
```

---

## SD-02: Alur Onboarding (Pertama Kali)

```plantuml
@startuml SD-02
!theme plain
skinparam sequenceMessageAlign center

title SD-02: Alur Onboarding

actor "User" as U
participant "WelcomePage\n(lib/features/welcome/welcome_page.dart)" as WP
participant "OnboardingPage\n(lib/features/onboarding/onboarding_page.dart)" as OP
participant "AppPrefs\n(lib/data/app_prefs.dart)" as AP
database "Hive\n(app_prefs box)" as H
participant "HomePage" as Home

U -> WP : Lihat halaman Welcome
activate WP
  U -> WP : tap "Mulai"
  WP -> OP : context.go('/onboarding')
deactivate WP

activate OP
  OP -> OP : tampilkan Slide 1\n(Peringatan)
  U -> OP : tap "Lanjut"
  OP -> OP : tampilkan Slide 2\n(Privasi)
  U -> OP : tap "Lanjut"
  OP -> OP : tampilkan Slide 3\n(Tindak Lanjut)

  alt User selesai di slide terakhir
    U -> OP : tap "Selesai"
  else User skip
    U -> OP : tap "Lewati" (AppBar)
  end

  OP -> AP : setOnboardingDone(true)
  activate AP
    AP -> H : openBox('app_prefs')
    H --> AP : box
    AP -> H : box.put('onboarding_done', true)
    H --> AP : done
    AP --> OP : -
  deactivate AP

  OP -> Home : context.go('/home')
deactivate OP

activate Home
  Home --> U : Tampilkan Beranda
deactivate Home

@enduml
```

---

## SD-03: Alur Deteksi Lengkap (Kamera → Hasil → Simpan)

```plantuml
@startuml SD-03
!theme plain
skinparam sequenceMessageAlign center

title SD-03: Alur Deteksi Lengkap (Kamera)

actor "User" as U
participant "CustomCameraPage\n(custom_camera_page.dart)" as CamP
participant "CameraController\n(camera plugin)" as Cam
participant "ImageValidationPage\n(image_validation_page.dart)" as IVP
participant "GeneratedPage\n(generated_page.dart)" as GP
participant "TfliteMlService\n(tflite_ml_service.dart)" as TFLite
participant "ResultPage\n(result_page.dart)" as RP
participant "PatientFormPage\n(patient_form_page.dart)" as PFP
participant "HistoryStore\n(history_store.dart)" as HS
database "Hive\n(history_box)" as H

U -> CamP : tap FAB Deteksi (dari /home)
activate CamP
  CamP -> Cam : availableCameras()
  Cam --> CamP : List<CameraDescription>
  CamP -> Cam : CameraController.initialize()
  Cam --> CamP : preview ready
  CamP --> U : tampilkan live preview\n+ overlay target area

  U -> CamP : tap shutter button
  CamP -> Cam : controller.takePicture()
  Cam --> CamP : XFile (imagePath)
  CamP -> IVP : context.go('/detect/validate?path=...')
deactivate CamP

activate IVP
  IVP --> U : tampilkan pratinjau foto\n+ quality analysis card
  U -> IVP : tap "Gunakan Foto Ini"
  IVP -> GP : context.go('/detect/generated?path=...')
deactivate IVP

activate GP
  GP --> U : loading indicator\n"Sedang memproses..."
  GP -> TFLite : predictImageFile(File(imagePath))
  activate TFLite
    TFLite -> TFLite : loadModel() (lazy)
    TFLite -> TFLite : decode → resize 64×64\n→ normalize → reshape [1,64,64,3]
    TFLite -> TFLite : interpreter.run(input, output)
    TFLite -> TFLite : probability >= 0.5 ?\n"tidak_indikasi" : "indikasi"
    TFLite --> GP : MlResult(label, confidence)
  deactivate TFLite
  GP -> RP : context.go('/detect/result?path=...&label=...&conf=...')
deactivate GP

activate RP
  RP --> U : tampilkan: foto, label, confidence, disclaimer
  U -> RP : tap "Lengkapi Data Laporan"
  RP -> PFP : context.push('/detect/form?...')
deactivate RP

activate PFP
  PFP --> U : tampilkan form: NIK, Nama, Alamat, GPS
  U -> PFP : isi NIK (16 digit)
  U -> PFP : isi Nama Lengkap
  U -> PFP : isi Alamat
  U -> PFP : tap "Simpan Laporan"
  PFP -> PFP : _formKey.validate()
  PFP -> HS : add(HistoryEntry {...})
  activate HS
    HS -> H : openBox('history_box')
    H --> HS : box
    HS -> H : box.put(id, entry.toMap())
    H --> HS : done
    HS --> PFP : -
  deactivate HS
  PFP --> U : SnackBar "Laporan berhasil disimpan"
  PFP -> CamP : context.go('/home')
deactivate PFP

@enduml
```

---

## SD-04: Alur Deteksi – Galeri (Pilih Foto → Hasil → Simpan)

```plantuml
@startuml SD-04
!theme plain
skinparam sequenceMessageAlign center

title SD-04: Alur Deteksi – Pilih dari Galeri

actor "User" as U
participant "CustomCameraPage\n(custom_camera_page.dart)" as CamP
participant "ImagePicker\n(image_picker plugin)" as IP
participant "ImageValidationPage" as IVP
participant "GeneratedPage" as GP
participant "TfliteMlService" as TFLite
participant "ResultPage" as RP

U -> CamP : tap "Galeri"
activate CamP
  CamP -> IP : pickImage(source: gallery,\nimageQuality: 90)
  activate IP
    IP --> U : buka sistem galeri
    U -> IP : pilih foto
    IP --> CamP : XFile (imagePath)
  deactivate IP

  alt xfile != null
    CamP -> IVP : context.go('/detect/validate?path=...')
  else dibatalkan
    CamP --> U : (tidak ada aksi)
  end
deactivate CamP

activate IVP
  IVP --> U : pratinjau + quality card
  U -> IVP : tap "Gunakan Foto Ini"
  IVP -> GP : context.go('/detect/generated?path=...')
deactivate IVP

activate GP
  GP --> U : loading indicator
  GP -> TFLite : predictImageFile(file)
  TFLite --> GP : MlResult(label, confidence)
  GP -> RP : context.go('/detect/result?...')
deactivate GP

activate RP
  RP --> U : tampilkan hasil deteksi
deactivate RP

note right of RP
  Alur selanjutnya (form data + simpan)
  sama dengan SD-03
end note

@enduml
```

---

## SD-05: Proses Inferensi ML (TFLite + Fallback Remote)

```plantuml
@startuml SD-05
!theme plain
skinparam sequenceMessageAlign center

title SD-05: Proses Inferensi ML – TFLite & Fallback Remote

actor "User" as U
participant "GeneratedPage\n(generated_page.dart)" as GP
participant "TfliteMlService\n(tflite_ml_service.dart)" as TFLite
participant "RemoteMlService\n(remote_ml_service.dart)" as Remote
participant "FastAPI Server\n(local dev: 10.45.109.198:8000\n⚠️ harus diconfig untuk production)" as API
participant "ResultPage" as RP

activate GP
  GP --> U : loading indicator
  GP -> GP : file = File(imagePath)
  GP -> GP : file.exists() ?

  alt file tidak ada
    GP --> U : SnackBar "Gambar tidak ditemukan"
    GP -> GP : context.go('/detect')
  else file ada

    GP -> TFLite : predictImageFile(file)
    activate TFLite
      TFLite -> TFLite : loadModel()\nassets/models/model.tflite
      TFLite -> TFLite : decode image bytes
      TFLite -> TFLite : copyResize(64x64)
      TFLite -> TFLite : normalize to [0.0–1.0]
      TFLite -> TFLite : reshape [1,64,64,3]
      TFLite -> TFLite : interpreter.run()
      TFLite -> TFLite : probability >= 0.5\n→ tidak_indikasi\n< 0.5 → indikasi
      TFLite --> GP : MlResult(label, confidence)
    deactivate TFLite

    alt TFLite sukses
      GP -> RP : context.go('/detect/result?...')
      RP --> U : tampilkan hasil

    else TFLite gagal (Exception)
      note over GP, TFLite : Fallback ke Remote ML Service
      GP -> Remote : predictImageFile(file)
      activate Remote
        Remote -> API : POST /predict\n(multipart/form-data, file=image)
        activate API
          API -> API : model inference (server-side)
          API --> Remote : 200 OK\n{"label":"...", "confidence":0.xx}
        deactivate API
        Remote -> Remote : MlResult.fromJson(body)
        Remote --> GP : MlResult(label, confidence)
      deactivate Remote

      alt Remote sukses
        GP -> RP : context.go('/detect/result?...')
        RP --> U : tampilkan hasil
      else Remote juga gagal
        GP --> U : SnackBar "Gagal memproses ML: <error>"
        GP -> GP : context.go('/detect')
      end

    end

  end
deactivate GP

@enduml
```

---

## SD-06: Simpan Laporan dengan Data Pasien & GPS

```plantuml
@startuml SD-06
!theme plain
skinparam sequenceMessageAlign center

title SD-06: Simpan Laporan dengan Data Pasien & GPS

actor "User" as U
participant "PatientFormPage\n(patient_form_page.dart)" as PFP
participant "Location\n(location plugin)" as Loc
participant "HistoryStore\n(history_store.dart)" as HS
database "Hive\n(history_box)" as H
participant "HomePage" as Home

U -> PFP : tampilkan form
activate PFP
  U -> PFP : isi NIK, Nama, Alamat

  U -> PFP : tap "Ambil Lokasi Saat Ini"
  PFP -> Loc : serviceEnabled()
  Loc --> PFP : bool

  alt GPS tidak aktif
    Loc --> U : dialog minta aktifkan GPS
    alt user aktifkan
      Loc --> PFP : serviceEnabled = true
    else tolak
      PFP --> U : SnackBar orange "Layanan GPS tidak aktif"
      note right : GPS opsional, lanjut tanpa koordinat
    end
  end

  PFP -> Loc : hasPermission()
  Loc --> PFP : PermissionStatus

  alt permission denied
    PFP -> Loc : requestPermission()
    Loc --> PFP : granted / denied
    alt denied forever
      PFP --> U : SnackBar "Buka Pengaturan > Izin Aplikasi"
    else denied (sekali)
      PFP --> U : SnackBar "Izin lokasi ditolak"
    end
  end

  PFP -> Loc : getLocation()\ntimeout 10 detik
  activate Loc
    Loc --> PFP : LocationData(lat, lng)
  deactivate Loc

  alt berhasil
    PFP -> PFP : _latitude = lat\n_longitude = lng
    PFP --> U : SnackBar hijau "Lokasi berhasil diambil: xx, yy"
  else timeout / error
    PFP --> U : SnackBar "Gagal mendapat lokasi otomatis"
  end

  U -> PFP : tap "Simpan Laporan"
  PFP -> PFP : _formKey.currentState!.validate()

  alt validasi gagal
    PFP --> U : pesan error inline per field
  else validasi berhasil
    PFP -> PFP : buat HistoryEntry {\n  id: microsecondsSinceEpoch\n  imagePath, label, confidence\n  nik, patientName, address\n  latitude, longitude (nullable)\n}
    PFP -> HS : add(entry)
    activate HS
      HS -> H : openBox('history_box')
      H --> HS : box
      HS -> H : box.put(entry.id, entry.toMap())
      H --> HS : done
      HS --> PFP : -
    deactivate HS
    PFP --> U : SnackBar hijau "Laporan berhasil disimpan"
    PFP -> Home : context.go('/home')
  end
deactivate PFP

@enduml
```

---

## SD-07: Lihat & Filter Riwayat

```plantuml
@startuml SD-07
!theme plain
skinparam sequenceMessageAlign center

title SD-07: Lihat & Filter Riwayat

actor "User" as U
participant "HistoryPage\n(history_page.dart)" as HP
participant "HistoryStore\n(history_store.dart)" as HS
database "Hive\n(history_box)" as H

U -> HP : tab Riwayat (/history)
activate HP
  HP -> HP : initState → _loadHistory()
  HP -> HS : getAll()
  activate HS
    HS -> H : openBox('history_box')
    H --> HS : box
    HS -> H : box.values (semua entri)
    H --> HS : List<Map>
    HS -> HS : sort(descending createdAt)
    HS --> HP : List<HistoryEntry>
  deactivate HS

  alt ada data
    HP --> U : tampilkan daftar riwayat\n(foto, label, confidence, tanggal, nama)
  else kosong
    HP --> U : tampilkan Empty State
  end

  U -> HP : pilih chip filter\n(Semua/Indikasi/Tidak Indikasi)
  HP -> HP : _activeFilter = pilihan\nsetState → _filteredItems()
  HP --> U : daftar diperbarui sesuai filter

  U -> HP : tap item riwayat
  HP -> HP : context.go('/history/detail/<id>')
deactivate HP

@enduml
```

---

## SD-08: Lihat Detail Riwayat & Buka Peta

```plantuml
@startuml SD-08
!theme plain
skinparam sequenceMessageAlign center

title SD-08: Lihat Detail Riwayat & Buka Peta

actor "User" as U
participant "HistoryDetailPage\n(history_detail_page.dart)" as HDP
participant "HistoryStore\n(history_store.dart)" as HS
database "Hive\n(history_box)" as H
participant "url_launcher\n(plugin)" as URL
participant "Google Maps\n(external app)" as GMap

U -> HDP : navigasi /history/detail/:id
activate HDP
  HDP -> HDP : initState → _loadEntry()
  HDP -> HS : getById(id)
  activate HS
    HS -> H : openBox('history_box')
    H --> HS : box
    HS -> H : box.get(id)
    H --> HS : Map?
    HS -> HS : HistoryEntry.fromMap(raw)
    HS --> HDP : HistoryEntry?
  deactivate HS

  alt entry ditemukan
    HDP --> U : tampilkan:\n- Foto kulit\n- Label & confidence\n- Tanggal & waktu\n- Data pasien (jika ada)\n- Tombol "Buka Lokasi di Peta" (jika GPS ada)

    opt GPS data tersedia (latitude != null)
      U -> HDP : tap "Buka Lokasi di Peta"
      HDP -> HDP : _openMap(entry)
      HDP -> URL : launchUrl(\n  "https://maps.google.com/...?query=lat,lng",\n  mode: externalApplication\n)
      URL -> GMap : deep-link URL
      GMap --> U : Google Maps terbuka dengan pin lokasi
    end

  else entry tidak ditemukan
    HDP --> U : tampilkan "Data tidak ditemukan"\n+ tombol "Kembali ke Riwayat"
  end
deactivate HDP

@enduml
```

---

## SD-09: Hapus Riwayat (Satu Entri)

```plantuml
@startuml SD-09
!theme plain
skinparam sequenceMessageAlign center

title SD-09: Hapus Riwayat (Satu Entri)

actor "User" as U
participant "HistoryPage / HistoryDetailPage" as HP
participant "AlertDialog" as AD
participant "HistoryStore\n(history_store.dart)" as HS
database "Hive\n(history_box)" as H

U -> HP : tap ikon hapus pada item
activate HP
  HP -> AD : showDialog\n"Hapus Riwayat?"
  activate AD
    AD --> U : tampilkan dialog konfirmasi
    alt User tap "Ya, Hapus"
      U -> AD : konfirmasi
      AD --> HP : confirmed = true
    else User tap "Batal"
      U -> AD : batalkan
      AD --> HP : confirmed = false
    end
  deactivate AD

  alt confirmed == true
    HP -> HS : removeById(entry.id)
    activate HS
      HS -> H : openBox('history_box')
      H --> HS : box
      HS -> H : box.delete(entry.id)
      H --> HS : done
      HS --> HP : -
    deactivate HS

    alt dari HistoryPage
      HP -> HP : _allItems.removeWhere(e.id == id)\nsetState
      HP --> U : SnackBar "Riwayat berhasil dihapus"\nDaftar diperbarui
    else dari HistoryDetailPage
      HP -> HP : context.pop()
      HP --> U : SnackBar "Riwayat berhasil dihapus"\nKembali ke HistoryPage
    end

  else cancelled
    HP --> U : (tidak ada perubahan)
  end
deactivate HP

@enduml
```

---

## SD-10: Hapus Semua Riwayat

```plantuml
@startuml SD-10
!theme plain
skinparam sequenceMessageAlign center

title SD-10: Hapus Semua Riwayat

actor "User" as U
participant "HistoryPage\n(history_page.dart)" as HP
participant "AlertDialog" as AD
participant "HistoryStore\n(history_store.dart)" as HS
database "Hive\n(history_box)" as H

U -> HP : tap ikon "Hapus Semua" di AppBar
activate HP
  HP -> AD : showDialog\n"Hapus Semua Riwayat?\nSemua data tidak dapat dikembalikan."
  activate AD
    AD --> U : tampilkan dialog konfirmasi
    alt User tap "Ya, Hapus Semua"
      U -> AD : konfirmasi
      AD --> HP : confirmed = true
    else User tap "Batal"
      U -> AD : batalkan
      AD --> HP : confirmed = false
    end
  deactivate AD

  alt confirmed == true
    HP -> HS : clear()
    activate HS
      HS -> H : openBox('history_box')
      H --> HS : box
      HS -> H : box.clear()
      H --> HS : done
      HS --> HP : -
    deactivate HS
    HP -> HP : _allItems = []\nsetState
    HP --> U : SnackBar "Semua riwayat berhasil dihapus"\nEmpty State ditampilkan
  else cancelled
    HP --> U : (tidak ada perubahan)
  end
deactivate HP

@enduml
```

---

## SD-11: Lihat Konten Edukasi (Artikel & Video)

```plantuml
@startuml SD-11
!theme plain
skinparam sequenceMessageAlign center

title SD-11: Lihat Konten Edukasi

actor "User" as U
participant "EducationPage\n(education_page.dart)" as EP
participant "EducationRepository\n(education_repository.dart)" as ER
participant "HTTP Client\n(http plugin)" as HTTP
participant "CMS API Server" as CMS

U -> EP : tab Edukasi (/education)
activate EP
  EP -> EP : initState → _loadData()
  EP -> ER : fetchArticles()
  activate ER
    ER -> HTTP : GET ApiConstants.getArticles\ntimeout 10s
    activate HTTP
      HTTP -> CMS : HTTP GET /articles
      activate CMS
        CMS --> HTTP : 200 OK\nJSON [{ ... }]
      deactivate CMS
      HTTP --> ER : Response
    deactivate HTTP
    ER -> ER : jsonDecode → List<EducationArticle>
    ER --> EP : List<EducationArticle>
  deactivate ER

  EP -> ER : fetchVideos()
  activate ER
    ER -> HTTP : GET ApiConstants.getVideos\ntimeout 10s
    HTTP -> CMS : HTTP GET /videos
    CMS --> HTTP : 200 OK\nJSON [{ ... }]
    HTTP --> ER : Response
    ER -> ER : jsonDecode → List<EducationVideo>
    ER --> EP : List<EducationVideo>
  deactivate ER

  alt load sukses
    EP --> U : tampilkan:\n- Artikel featured\n- Chip kategori (Semua, Gejala, dll)\n- Daftar artikel\n- Daftar video
  else error (timeout/socket/server error)
    EP --> U : tampilkan pesan error + tombol "Coba Lagi"
  end

  opt User filter kategori
    U -> EP : tap chip kategori
    EP -> EP : _selectedCategoryIndex = i\nsetState → _filteredArticles()
    EP --> U : daftar artikel diperbarui
  end
deactivate EP

@enduml
```

---

## SD-12: Baca Detail Artikel Edukasi

```plantuml
@startuml SD-12
!theme plain
skinparam sequenceMessageAlign center

title SD-12: Baca Detail Artikel Edukasi

actor "User" as U
participant "EducationPage\n(education_page.dart)" as EP
participant "EducationDetailPage\n(education_detail_page.dart)" as EDP

U -> EP : tap kartu artikel
activate EP
  EP -> EDP : Navigator.push()\nkirim objek EducationArticle
  deactivate EP

activate EDP
  EDP --> U : tampilkan:\n- Gambar header artikel\n- Judul & kategori\n- Tanggal publikasi\n- Isi konten artikel\n  (teks lengkap)
  U -> EDP : scroll baca konten
  U -> EDP : tap tombol Back
  EDP -> EP : Navigator.pop()
deactivate EDP

activate EP
  EP --> U : kembali ke EducationPage
deactivate EP

@enduml
```

---

## Catatan Implementasi

| Diagram | File Utama | Library Kunci |
|---------|-----------|---------------|
| SD-01 | `splash_page.dart`, `app_prefs.dart` | hive, go_router |
| SD-02 | `welcome_page.dart`, `onboarding_page.dart` | hive, go_router |
| SD-03 | `custom_camera_page.dart` → ... → `patient_form_page.dart` | camera, go_router, tflite_flutter, hive |
| SD-04 | `custom_camera_page.dart` (galeri path) | image_picker, go_router, tflite_flutter |
| SD-05 | `generated_page.dart`, `tflite_ml_service.dart`, `remote_ml_service.dart` | tflite_flutter, http |
| SD-06 | `patient_form_page.dart`, `history_store.dart` | location, hive |
| SD-07 | `history_page.dart`, `history_store.dart` | hive |
| SD-08 | `history_detail_page.dart` | hive, url_launcher |
| SD-09 | `history_page.dart`, `history_detail_page.dart` | hive |
| SD-10 | `history_page.dart` | hive |
| SD-11 | `education_page.dart`, `education_repository.dart` | http |
| SD-12 | `education_detail_page.dart` | - |
