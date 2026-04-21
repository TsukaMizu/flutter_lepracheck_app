# ANALISIS LENGKAP USE CASE – FLUTTER LEPRACHECK APP

> **Dokumen ini dihasilkan berdasarkan analisis kode sumber repositori `flutter_lepracheck_app`.**
> Setiap use case dapat ditelusuri langsung ke file kode yang relevan.

---

## DAFTAR ISI

1. [Daftar Aktor Sistem](#1-daftar-aktor-sistem)
2. [Identifikasi Use Case](#2-identifikasi-use-case)
3. [Use Case Relationships](#3-use-case-relationships)
4. [Detail Setiap Use Case](#4-detail-setiap-use-case)
5. [Use Case Analysis Table](#5-use-case-analysis-table)

---

## 1. DAFTAR AKTOR SISTEM

### Primary Actor (Pengguna Langsung)

| Aktor | Deskripsi |
|-------|-----------|
| **User / Kader Kesehatan** | Pengguna utama aplikasi. Dapat berupa kader kesehatan komunitas, petugas puskesmas, atau individu yang ingin melakukan skrining mandiri awal kusta pada kulit. |

### Secondary Actors (Sistem / Hardware)

| Aktor | Peran |
|-------|-------|
| **Camera Hardware** | Kamera fisik perangkat (depan/belakang) yang diakses melalui plugin `camera`. Menyuplai gambar live preview dan foto. |
| **Image Gallery** | Penyimpanan foto di perangkat, diakses melalui plugin `image_picker`. Menyuplai gambar yang sudah ada. |
| **TFLite ML Engine** | Model machine learning on-device (`assets/models/model.tflite`). Menerima tensor gambar dan menghasilkan probabilitas indikasi kusta. |
| **Remote FastAPI Server** | Server inferensi ML berbasis Python (fallback). Menerima gambar multipart dan mengembalikan JSON `{label, confidence}`. |
| **GPS / Location Service** | Layanan lokasi perangkat (plugin `location`). Menyuplai koordinat latitude/longitude untuk geotagging laporan. |
| **Hive Database** | Penyimpanan lokal NoSQL on-device (plugin `hive`). Menyimpan riwayat skrining (`history_box`) dan preferensi (`app_prefs`). |
| **HTTP CMS API** | Backend CMS eksternal yang menyuplai konten edukasi (artikel & video). Diakses via `http` plugin. |
| **Google Maps** | Aplikasi peta eksternal. Menerima URL deep-link koordinat dan menampilkan lokasi di peta. |

---

## 2. IDENTIFIKASI USE CASE

### Ringkasan Use Case

| ID | Nama Use Case | Aktor Utama | Kategori |
|----|---------------|-------------|----------|
| UC-01 | Tampilkan Splash Screen | User | Onboarding |
| UC-02 | Tampilkan Halaman Welcome | User | Onboarding |
| UC-03 | Selesaikan Onboarding | User | Onboarding |
| UC-04 | Lihat Beranda | User | Navigasi Utama |
| UC-05 | Ambil Foto dengan Kamera | User | Deteksi |
| UC-06 | Pilih Foto dari Galeri | User | Deteksi |
| UC-07 | Review & Validasi Foto | User | Deteksi |
| UC-08 | Proses Inferensi ML (On-Device) | TFLite ML Engine | Deteksi |
| UC-09 | Proses Inferensi ML (Remote) | Remote FastAPI Server | Deteksi |
| UC-10 | Lihat Hasil Deteksi | User | Deteksi |
| UC-11 | Isi Form Data Pasien | User | Deteksi |
| UC-12 | Ambil Lokasi GPS | GPS/Location Service | Deteksi |
| UC-13 | Simpan Laporan Skrining | Hive Database | Deteksi |
| UC-14 | Lihat Daftar Riwayat | User | Riwayat |
| UC-15 | Filter Riwayat | User | Riwayat |
| UC-16 | Lihat Detail Riwayat | User | Riwayat |
| UC-17 | Hapus Entri Riwayat | User | Riwayat |
| UC-18 | Hapus Semua Riwayat | User | Riwayat |
| UC-19 | Buka Lokasi di Peta | User | Riwayat |
| UC-20 | Lihat Konten Edukasi | User | Edukasi |
| UC-21 | Filter Artikel Edukasi | User | Edukasi |
| UC-22 | Baca Detail Artikel | User | Edukasi |
| UC-23 | Tonton Video Edukasi | User | Edukasi |
| UC-24 | Lihat Halaman Tentang | User | Informasi |

---

## 3. USE CASE RELATIONSHIPS

### Include Relationships (Wajib dijalankan sebagai bagian dari UC lain)

| UC Utama | Include → | UC Yang Di-include | Keterangan |
|----------|-----------|--------------------|------------|
| UC-05 Ambil Foto dengan Kamera | `<<include>>` | UC-07 Review & Validasi Foto | Setelah foto diambil, selalu navigasi ke halaman validasi |
| UC-06 Pilih Foto dari Galeri | `<<include>>` | UC-07 Review & Validasi Foto | Setelah foto dipilih, selalu navigasi ke halaman validasi |
| UC-07 Review & Validasi Foto | `<<include>>` | UC-08 Proses Inferensi ML | Setelah dikonfirmasi, otomatis menjalankan inferensi |
| UC-08 Proses Inferensi ML (On-Device) | `<<include>>` | UC-10 Lihat Hasil Deteksi | Setelah inferensi selesai, otomatis navigasi ke hasil |
| UC-11 Isi Form Data Pasien | `<<include>>` | UC-13 Simpan Laporan Skrining | Tombol simpan selalu ada di form data pasien |
| UC-16 Lihat Detail Riwayat | `<<include>>` | UC-17 Hapus Entri Riwayat | Tombol hapus tersedia di halaman detail |

### Extend Relationships (Opsional / kondisional)

| UC Utama | Extend ← | UC Yang Meng-extend | Kondisi |
|----------|-----------|---------------------|---------|
| UC-08 Proses Inferensi ML (On-Device) | `<<extend>>` | UC-09 Proses Inferensi ML (Remote) | TFLite gagal (model tidak ada atau error) |
| UC-11 Isi Form Data Pasien | `<<extend>>` | UC-12 Ambil Lokasi GPS | User menekan tombol "Ambil Lokasi Saat Ini" |
| UC-16 Lihat Detail Riwayat | `<<extend>>` | UC-19 Buka Lokasi di Peta | Hanya jika data GPS tersedia di entri |
| UC-01 Tampilkan Splash Screen | `<<extend>>` | UC-02 Tampilkan Halaman Welcome | Hanya jika onboarding belum selesai |
| UC-01 Tampilkan Splash Screen | `<<extend>>` | UC-04 Lihat Beranda | Hanya jika onboarding sudah selesai |

### Generalization Relationships

| UC Umum | ← Spesialisasi | UC Spesifik |
|---------|----------------|-------------|
| UC-05/UC-06 (Sumber Foto) | generalize | UC-04 → UC-05 atau UC-06 adalah dua cara mendapatkan foto |
| UC-08/UC-09 (Inferensi ML) | generalize | Keduanya menghasilkan `MlResult(label, confidence)` |

---

## 4. DETAIL SETIAP USE CASE

---

### UC-01: Tampilkan Splash Screen

```
UC-01: Tampilkan Splash Screen
├─ Primary Actor   : User
├─ Secondary Actors: Hive Database (baca status onboarding)
├─ Precondition    : Aplikasi baru dibuka / di-launch
├─ Postcondition   : User diarahkan ke /welcome (belum onboarding)
│                    ATAU /home (sudah onboarding)
├─ Main Flow:
│  1. User membuka aplikasi (app launch)
│  2. SplashPage menampilkan logo dengan animasi fade-in + scale
│  3. Setelah 2.5 detik, AppPrefs.isOnboardingDone() dipanggil
│  4. Sistem membaca key 'onboarding_done' dari Hive box 'app_prefs'
│  5. Jika done=false → navigasi ke /welcome
│     Jika done=true  → navigasi ke /home
├─ Alternative Flow: -
├─ Error Handling  :
│  - Jika logo.png tidak ditemukan → tampilkan ikon fallback (Icons.medical_services_outlined)
├─ Notes           : Animasi berdurasi ~900ms. Total jeda ~2.5 detik.
├─ Code Reference  : lib/features/splash/splash_page.dart
│                    lib/data/app_prefs.dart
└─ Priority        : HIGH
```

---

### UC-02: Tampilkan Halaman Welcome

```
UC-02: Tampilkan Halaman Welcome
├─ Primary Actor   : User
├─ Secondary Actors: -
├─ Precondition    : Onboarding belum pernah diselesaikan (onboarding_done = false)
├─ Postcondition   : User menekan tombol "Mulai" → navigasi ke /onboarding
├─ Main Flow:
│  1. WelcomePage ditampilkan dengan judul "LepraCheck" dan tagline
│  2. User menekan tombol "Mulai"
│  3. Sistem navigasi ke /onboarding
├─ Alternative Flow: -
├─ Error Handling  : -
├─ Notes           : Hanya tampil sekali (pertama kali install / data dihapus)
├─ Code Reference  : lib/features/welcome/welcome_page.dart
└─ Priority        : HIGH
```

---

### UC-03: Selesaikan Onboarding

```
UC-03: Selesaikan Onboarding
├─ Primary Actor   : User
├─ Secondary Actors: Hive Database
├─ Precondition    : User berada di halaman /onboarding
├─ Postcondition   : onboarding_done = true di Hive, User navigasi ke /home
├─ Main Flow:
│  1. OnboardingPage menampilkan 3 slide (Peringatan, Privasi, Tindak Lanjut)
│  2. User membaca slide dan menekan "Lanjut" / "Selanjutnya"
│  3. Di slide terakhir (index 2), User menekan tombol "Selesai"
│  4. AppPrefs.setOnboardingDone(true) dipanggil → Hive menyimpan flag
│  5. Navigasi ke /home
├─ Alternative Flow:
│  A1. User menekan tombol "Lewati" (skip) di pojok kanan AppBar
│      → langsung ke langkah 4 & 5
├─ Error Handling  : -
├─ Notes           : Slide controller menggunakan PageController.
│                    Tombol Lewati tersedia di semua slide.
├─ Code Reference  : lib/features/onboarding/onboarding_page.dart
│                    lib/data/app_prefs.dart
└─ Priority        : HIGH
```

---

### UC-04: Lihat Beranda

```
UC-04: Lihat Beranda
├─ Primary Actor   : User
├─ Secondary Actors: HTTP CMS API (gambar artikel terbaru)
├─ Precondition    : Onboarding selesai, user berada di tab /home
├─ Postcondition   : User melihat dashboard beranda
├─ Main Flow:
│  1. HomePage ditampilkan dalam ShellRoute dengan bottom navigation bar
│  2. User melihat: salam, shortcut tiles (Deteksi, Edukasi, Riwayat, Klinik, Tentang),
│     kartu "Tahukah Kamu", dan "Riwayat Terakhir"
│  3. User dapat mengetuk tile untuk navigasi ke fitur terkait:
│     - "Deteksi" → context.go('/detect')
│     - "Edukasi" → context.go('/education')
│     - "Riwayat" → context.go('/history')
│     - "Tentang" → context.go('/about')
│     - "Klinik"  → SnackBar "Fitur Klinik belum tersedia (MVP)"
├─ Alternative Flow: -
├─ Error Handling  :
│  - Tile "Klinik" menampilkan SnackBar MVP notice
├─ Notes           : Shortcut FAB di AppShell juga dapat digunakan untuk
│                    navigasi cepat ke /detect
├─ Code Reference  : lib/features/home/home_page.dart
│                    lib/features/shell/app_shell.dart
└─ Priority        : HIGH
```

---

### UC-05: Ambil Foto dengan Kamera

```
UC-05: Ambil Foto dengan Kamera
├─ Primary Actor   : User
├─ Secondary Actors: Camera Hardware
├─ Precondition    : User membuka halaman /detect
│                    Izin kamera diberikan
├─ Postcondition   : Foto tersimpan di path sementara, navigasi ke /detect/validate
├─ Main Flow:
│  1. CustomCameraPage dibuka
│  2. availableCameras() dipanggil untuk mendapatkan daftar kamera
│  3. CameraController diinisialisasi dengan ResolutionPreset.high
│  4. Live camera preview ditampilkan dengan overlay target area & crosshair
│  5. User membidik lesi pada area target
│  6. User menekan tombol shutter (lingkaran putih)
│  7. controller.takePicture() dipanggil → XFile dikembalikan
│  8. Navigasi ke /detect/validate?path=<encoded_path>
├─ Alternative Flow:
│  A1. User mengetuk ikon "Putar" → kamera beralih antara depan & belakang (_flipCamera)
│  A2. User mengetuk ikon flash → toggle antara Auto / Always / Off (_toggleFlash)
│  A3. User mengetuk "Galeri" → jalankan UC-06
│  A4. User mengetuk tombol back → navigasi ke /home
├─ Error Handling  :
│  - Tidak ada kamera → pesan "Tidak ada kamera yang tersedia"
│  - Gagal inisialisasi → pesan error ditampilkan
│  - Gagal mengambil foto → SnackBar error, _isCapturing direset
│  - Flash tidak didukung (emulator) → log error, tidak crash
├─ Notes           : Instruksi overlay: "Jarak ideal: 10–20 cm" dan
│                    "Pastikan pencahayaan cukup terang"
│                    App lifecycle observer mencegah kamera bocor saat background.
├─ Code Reference  : lib/features/detect/custom_camera_page.dart
└─ Priority        : HIGH
```

---

### UC-06: Pilih Foto dari Galeri

```
UC-06: Pilih Foto dari Galeri
├─ Primary Actor   : User
├─ Secondary Actors: Image Gallery
├─ Precondition    : User berada di CustomCameraPage (/detect)
│                    Izin akses galeri diberikan
├─ Postcondition   : Foto dipilih, navigasi ke /detect/validate
├─ Main Flow:
│  1. User mengetuk tombol "Galeri"
│  2. ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90) dipanggil
│  3. System gallery terbuka
│  4. User memilih foto dari galeri
│  5. XFile path dikembalikan
│  6. Navigasi ke /detect/validate?path=<encoded_path>
├─ Alternative Flow:
│  A1. User menutup galeri tanpa memilih → fungsi return tanpa navigasi
├─ Error Handling  :
│  - Gagal membuka galeri → setState error message
│  - xfile == null (dibatalkan) → tidak melakukan apa-apa
├─ Notes           : imageQuality: 90 untuk menjaga kualitas foto yang cukup
│                    bagi model ML.
├─ Code Reference  : lib/features/detect/custom_camera_page.dart (_pickFromGallery)
└─ Priority        : HIGH
```

---

### UC-07: Review & Validasi Foto

```
UC-07: Review & Validasi Foto
├─ Primary Actor   : User
├─ Secondary Actors: -
├─ Precondition    : Foto tersedia di imagePath (dari UC-05 atau UC-06)
├─ Postcondition   : User mengkonfirmasi foto → navigasi ke /detect/generated
│                    ATAU User memilih ambil ulang → kembali ke /detect
├─ Main Flow:
│  1. ImageValidationPage ditampilkan dengan pratinjau foto
│  2. Step indicator (3 langkah) menunjukkan posisi saat ini (langkah 2/3)
│  3. Kartu "_QualityAnalysisCard" ditampilkan (analisis statis: Fokus, Pencahayaan, Area)
│  4. User mengevaluasi foto
│  5. User mengetuk "Gunakan Foto Ini"
│  6. Navigasi ke /detect/generated?path=<encoded_path>
├─ Alternative Flow:
│  A1. User mengetuk "Ambil Ulang" → context.go('/detect')
│  A2. File tidak ditemukan (_hasImage = false) → tombol "Gunakan" disabled
├─ Error Handling  :
│  - Jika imagePath kosong atau file tidak ada → tampilkan "Gambar tidak ditemukan"
│                                                  tombol "Gunakan Foto Ini" disabled
├─ Notes           : QualityAnalysisCard bersifat statis (mock UI) untuk demo.
│                    Keputusan akhir oleh model AI.
├─ Code Reference  : lib/features/detect/image_validation_page.dart
└─ Priority        : HIGH
```

---

### UC-08: Proses Inferensi ML (On-Device / TFLite)

```
UC-08: Proses Inferensi ML (On-Device)
├─ Primary Actor   : TFLite ML Engine
├─ Secondary Actors: User (menunggu), Remote FastAPI Server (fallback UC-09)
├─ Precondition    : imagePath valid, file gambar ada di perangkat
│                    Model assets/models/model.tflite tersedia
├─ Postcondition   : MlResult(label, confidence) tersedia
│                    Navigasi ke /detect/result
├─ Main Flow:
│  1. GeneratedPage ditampilkan → loading indicator + teks "Sedang memproses..."
│  2. TfliteMlService.predictImageFile(file) dipanggil:
│     a. Model dimuat (lazy) dari assets/models/model.tflite
│     b. File gambar dibaca → decode → resize 64×64 px
│     c. Normalisasi piksel R/G/B ÷ 255.0
│     d. Reshape ke tensor [1, 64, 64, 3] Float32
│     e. Interpreter.run(input, output) → output [1,1]
│     f. probability ≥ 0.5 → "tidak_indikasi"; < 0.5 → "indikasi"
│  3. MlResult(label, confidence) dikembalikan
│  4. Navigasi ke /detect/result?path=...&label=...&conf=...
├─ Alternative Flow:
│  A1. TFLite gagal → fallback ke UC-09 (Remote ML Service)
├─ Error Handling  :
│  - File tidak ada → SnackBar "Gambar tidak ditemukan", kembali ke /detect
│  - TFLite + Remote keduanya gagal → SnackBar "Gagal memproses ML: ...", kembali ke /detect
│  - Decode gambar gagal → Exception "Gagal membaca file gambar"
├─ Notes           : Offline-first. Tidak butuh koneksi internet jika model tersedia.
├─ Code Reference  : lib/features/detect/generated_page.dart
│                    lib/data/ml/tflite_ml_service.dart
└─ Priority        : HIGH
```

---

### UC-09: Proses Inferensi ML (Remote / FastAPI)

```
UC-09: Proses Inferensi ML (Remote)
├─ Primary Actor   : Remote FastAPI Server
├─ Secondary Actors: User (menunggu)
├─ Precondition    : TFLite gagal, server FastAPI berjalan di baseUrl
│                    Perangkat terhubung ke jaringan yang sama dengan server
├─ Postcondition   : MlResult(label, confidence) tersedia dari API
├─ Main Flow:
│  1. RemoteMlService.predictImageFile(file) dipanggil
│  2. Gambar dikirim via HTTP POST multipart ke <baseUrl>/predict
│  3. Server membalas JSON {"label": "...", "confidence": 0.xx}
│  4. MlResult.fromJson() parsing response
│  5. MlResult dikembalikan ke GeneratedPage → navigasi ke /detect/result
├─ Alternative Flow: -
├─ Error Handling  :
│  - statusCode ≠ 2xx → Exception "ML service error <code>: <body>"
│  - Network error → Exception disebarkan ke GeneratedPage
├─ Notes           : Hanya digunakan sebagai fallback jika TFLite gagal.
│                    baseUrl dikonfigurasi hardcoded: 'http://10.45.109.198:8000'
│                    ⚠️  Ini adalah alamat IP lokal untuk keperluan demo/development.
│                    Untuk production, baseUrl harus dieksternalisasi ke konfigurasi
│                    (misalnya environment variable atau file config).
├─ Code Reference  : lib/data/ml/remote_ml_service.dart
│                    lib/features/detect/generated_page.dart
└─ Priority        : MEDIUM
```

---

### UC-10: Lihat Hasil Deteksi

```
UC-10: Lihat Hasil Deteksi
├─ Primary Actor   : User
├─ Secondary Actors: -
├─ Precondition    : Inferensi ML selesai, label & confidence tersedia
├─ Postcondition   : User memutuskan untuk: lengkapi laporan, deteksi lagi, atau lihat riwayat
├─ Main Flow:
│  1. ResultPage ditampilkan dengan: foto (square crop), kartu hasil, tombol aksi
│  2. Kartu hasil menampilkan:
│     - Label: "Indikasi" (warna error) ATAU "Tidak ada indikasi" (warna primary)
│     - Confidence: xx% 
│     - Disclaimer: "Hasil ini hanya screening, bukan diagnosis dokter"
│  3. User memilih aksi:
│     - "Lengkapi Data Laporan" → context.push('/detect/form?...')
│     - "Deteksi Lagi" → dialog konfirmasi → context.go('/detect')
│     - "Lihat Riwayat" → dialog konfirmasi → context.go('/history')
├─ Alternative Flow:
│  A1. "Deteksi Lagi" / "Lihat Riwayat" → _showDiscardWarningDialog muncul:
│      - "Batal" → tetap di ResultPage
│      - "Ya, Tinggalkan" → navigasi ke target
├─ Error Handling  :
│  - imagePath kosong → placeholder hitam ditampilkan
├─ Notes           : Data belum tersimpan di tahap ini.
│                    Penyimpanan hanya terjadi setelah UC-11 & UC-13 selesai.
├─ Code Reference  : lib/features/detect/result_page.dart
└─ Priority        : HIGH
```

---

### UC-11: Isi Form Data Pasien

```
UC-11: Isi Form Data Pasien
├─ Primary Actor   : User
├─ Secondary Actors: GPS/Location Service (opsional via UC-12)
├─ Precondition    : User berada di /detect/form dengan data hasil deteksi
├─ Postcondition   : Data pasien (NIK, Nama, Alamat, GPS) tervalidasi,
│                    siap untuk disimpan via UC-13
├─ Main Flow:
│  1. PatientFormPage ditampilkan dengan ringkasan hasil skrining (warna dan ikon)
│  2. User mengisi field wajib:
│     - NIK: 16 digit angka (validasi regex)
│     - Nama Lengkap Pasien (tidak boleh kosong)
│     - Alamat Rumah (tidak boleh kosong, max 3 baris)
│  3. (Opsional) User menekan "Ambil Lokasi Saat Ini" → UC-12
│  4. User menekan "Simpan Laporan"
│  5. _formKey.currentState!.validate() dipanggil
│  6. Jika valid → UC-13 (Simpan Laporan)
├─ Alternative Flow:
│  A1. User menekan "Lewati, Kembali ke Beranda" → context.go('/home')
│      (tanpa menyimpan laporan)
├─ Error Handling  :
│  - NIK kosong → "NIK tidak boleh kosong"
│  - NIK bukan 16 digit → "NIK harus berisi 16 digit angka"
│  - Nama kosong → "Nama tidak boleh kosong"
│  - Alamat kosong → "Alamat tidak boleh kosong"
│  - Validasi gagal → form tidak disubmit, pesan error inline muncul
├─ Notes           : NIK dibatasi FilteringTextInputFormatter.digitsOnly + LengthLimiting(16).
│                    GPS bersifat opsional.
├─ Code Reference  : lib/features/detect/patient_form_page.dart
└─ Priority        : HIGH
```

---

### UC-12: Ambil Lokasi GPS

```
UC-12: Ambil Lokasi GPS
├─ Primary Actor   : User (memicu), GPS/Location Service (menyuplai data)
├─ Secondary Actors: GPS/Location Service
├─ Precondition    : User berada di PatientFormPage, menekan tombol "Ambil Lokasi"
│                    Layanan GPS aktif atau dapat diaktifkan
├─ Postcondition   : _latitude & _longitude diisi, tombol berubah "Perbarui Lokasi"
├─ Main Flow:
│  1. _fetchLocation() dipanggil
│  2. loc.serviceEnabled() dicek → jika tidak aktif, minta aktifkan
│  3. loc.hasPermission() dicek → jika denied, minta permission
│  4. loc.getLocation() dipanggil dengan timeout 10 detik
│  5. Koordinat lat/lng disimpan ke state
│  6. SnackBar hijau: "Lokasi berhasil diambil: xx.xxxxx, yy.yyyyy"
├─ Alternative Flow:
│  A1. Layanan GPS tidak aktif → dialog sistem → user tolak → SnackBar orange
│  A2. Permission denied → SnackBar orange "Izin lokasi ditolak"
│  A3. Permission denied forever → SnackBar orange "Buka Pengaturan > Izin Aplikasi"
│  A4. Timeout (>10 detik) → SnackBar "Gagal mendapat lokasi otomatis"
├─ Error Handling  :
│  - TimeoutException → SnackBar informatif
│  - SocketException atau error lain → SnackBar "Gagal mendapat lokasi otomatis"
├─ Notes           : Fail-gracefully. GPS opsional untuk laporan.
│                    Loading indicator ditampilkan selama pengambilan lokasi.
├─ Code Reference  : lib/features/detect/patient_form_page.dart (_fetchLocation)
└─ Priority        : MEDIUM
```

---

### UC-13: Simpan Laporan Skrining

```
UC-13: Simpan Laporan Skrining
├─ Primary Actor   : Hive Database
├─ Secondary Actors: User (memicu via tombol Simpan)
├─ Precondition    : Form data pasien tervalidasi (UC-11)
├─ Postcondition   : HistoryEntry tersimpan di Hive box 'history_box'
│                    Navigasi ke /home
├─ Main Flow:
│  1. HistoryEntry dibuat dengan:
│     - id: DateTime.now().microsecondsSinceEpoch.toString()
│     - createdAt, imagePath, label, confidence (dari deteksi)
│     - nik, patientName, address (dari form)
│     - latitude, longitude (dari GPS, jika ada)
│  2. HistoryStore.add(entry) → Hive.openBox('history_box').put(id, entry.toMap())
│  3. SnackBar hijau: "Laporan berhasil disimpan"
│  4. Navigasi ke /home
├─ Alternative Flow: -
├─ Error Handling  :
│  - Gagal menyimpan → SnackBar "Gagal menyimpan laporan: <error>"
│  - _saving flag mencegah double submit
├─ Notes           : ID unik berbasis timestamp microsecond.
│                    Data disimpan sebagai Map<String, dynamic> di Hive.
├─ Code Reference  : lib/features/detect/patient_form_page.dart (_saveReport)
│                    lib/data/history_store.dart
│                    lib/data/history_entry.dart
└─ Priority        : HIGH
```

---

### UC-14: Lihat Daftar Riwayat

```
UC-14: Lihat Daftar Riwayat
├─ Primary Actor   : User
├─ Secondary Actors: Hive Database
├─ Precondition    : User berada di tab /history
├─ Postcondition   : Daftar riwayat skrining ditampilkan
├─ Main Flow:
│  1. HistoryPage.initState → _loadHistory() dipanggil
│  2. HistoryStore.getAll() → Hive mengambil semua entri, diurutkan terbaru
│  3. Daftar ditampilkan sebagai ListView dengan card setiap item
│  4. Setiap card menampilkan: foto thumbnail, label, confidence, tanggal, nama pasien
│  5. User dapat mengetuk item → navigasi ke /history/detail/:id
├─ Alternative Flow:
│  A1. Belum ada riwayat → tampilkan Empty State dengan ikon dan teks
├─ Error Handling  :
│  - Loading state menampilkan CircularProgressIndicator
├─ Notes           : Tombol "Hapus Semua" tersedia di AppBar via IconButton.
├─ Code Reference  : lib/features/history/history_page.dart
│                    lib/data/history_store.dart
└─ Priority        : HIGH
```

---

### UC-15: Filter Riwayat

```
UC-15: Filter Riwayat
├─ Primary Actor   : User
├─ Secondary Actors: -
├─ Precondition    : HistoryPage sudah memuat daftar riwayat
├─ Postcondition   : Daftar riwayat difilter sesuai pilihan
├─ Main Flow:
│  1. User melihat chip filter: "Semua" | "Indikasi" | "Tidak Indikasi"
│  2. User mengetuk salah satu chip
│  3. _activeFilter diperbarui → setState dijalankan
│  4. _filteredItems() mengembalikan subset list sesuai filter
│  5. ListView diperbarui
├─ Alternative Flow: -
├─ Error Handling  : -
├─ Notes           : Filter bersifat client-side (data sudah di memory).
│                    Enum: _HistoryFilter { all, indikasi, tidakIndikasi }
├─ Code Reference  : lib/features/history/history_page.dart
└─ Priority        : MEDIUM
```

---

### UC-16: Lihat Detail Riwayat

```
UC-16: Lihat Detail Riwayat
├─ Primary Actor   : User
├─ Secondary Actors: Hive Database
├─ Precondition    : User mengetuk item di daftar riwayat
├─ Postcondition   : Detail lengkap skrining ditampilkan (termasuk data pasien & GPS)
├─ Main Flow:
│  1. HistoryDetailPage.initState → _loadEntry() → HistoryStore.getById(id)
│  2. Hive mengambil data berdasarkan ID
│  3. Halaman menampilkan:
│     - Foto kulit (full-width)
│     - Kartu hasil (label, confidence, warna)
│     - Tanggal & waktu pemeriksaan
│     - Kartu data pasien (NIK, Nama, Alamat) — jika ada
│     - Tombol "Buka Lokasi di Peta" — jika koordinat GPS ada
├─ Alternative Flow:
│  A1. ID tidak ditemukan → tampilkan "Data tidak ditemukan" + tombol kembali
├─ Error Handling  :
│  - Foto tidak ada di path → ikon broken_image_outlined ditampilkan
│  - Error load → state _error = true → pesan error + tombol kembali
├─ Notes           : Halaman bersifat read-only. Penghapusan via UC-17.
├─ Code Reference  : lib/features/history/history_detail_page.dart
│                    lib/data/history_store.dart
└─ Priority        : HIGH
```

---

### UC-17: Hapus Entri Riwayat

```
UC-17: Hapus Entri Riwayat
├─ Primary Actor   : User
├─ Secondary Actors: Hive Database
├─ Precondition    : User berada di HistoryPage atau HistoryDetailPage
├─ Postcondition   : Entri dihapus dari Hive, daftar/halaman diperbarui
├─ Main Flow:
│  1. User menekan ikon hapus (dari list atau AppBar detail)
│  2. AlertDialog konfirmasi muncul:
│     "Apakah Anda yakin ingin menghapus riwayat skrining ini?"
│  3. User menekan "Ya, Hapus"
│  4. HistoryStore.removeById(entry.id) dipanggil
│  5. SnackBar "Riwayat berhasil dihapus"
│  6. Di HistoryPage: item dihapus dari _allItems list
│     Di HistoryDetailPage: context.pop() kembali ke HistoryPage
├─ Alternative Flow:
│  A1. User menekan "Batal" → dialog ditutup, tidak ada perubahan
├─ Error Handling  :
│  - Gagal hapus (HistoryDetailPage) → SnackBar "Gagal menghapus riwayat. Silakan coba lagi."
├─ Notes           : Konfirmasi dua langkah mencegah penghapusan tidak sengaja.
├─ Code Reference  : lib/features/history/history_page.dart (_deleteEntry)
│                    lib/features/history/history_detail_page.dart (_showDeleteConfirmationDialog)
└─ Priority        : MEDIUM
```

---

### UC-18: Hapus Semua Riwayat

```
UC-18: Hapus Semua Riwayat
├─ Primary Actor   : User
├─ Secondary Actors: Hive Database
├─ Precondition    : User berada di HistoryPage, ada minimal 1 entri riwayat
├─ Postcondition   : Seluruh riwayat dihapus dari Hive, daftar kosong
├─ Main Flow:
│  1. User mengetuk ikon hapus semua di AppBar HistoryPage
│  2. AlertDialog konfirmasi: "Hapus Semua Riwayat"
│     "Semua data dan gambar tidak dapat dikembalikan."
│  3. User menekan "Ya, Hapus Semua"
│  4. HistoryStore.clear() dipanggil
│  5. _allItems dikosongkan → Empty State ditampilkan
│  6. SnackBar "Semua riwayat berhasil dihapus"
├─ Alternative Flow:
│  A1. User menekan "Batal" → tidak ada perubahan
├─ Error Handling  : -
├─ Notes           : Operasi irreversible. Konfirmasi dua langkah wajib.
├─ Code Reference  : lib/features/history/history_page.dart (_clearAll)
│                    lib/data/history_store.dart (clear)
└─ Priority        : MEDIUM
```

---

### UC-19: Buka Lokasi di Peta

```
UC-19: Buka Lokasi di Peta
├─ Primary Actor   : User
├─ Secondary Actors: Google Maps (aplikasi eksternal)
├─ Precondition    : HistoryEntry memiliki latitude & longitude tidak null
├─ Postcondition   : Google Maps terbuka dengan pin di koordinat yang tersimpan
├─ Main Flow:
│  1. User mengetuk "Buka Lokasi di Peta" di HistoryDetailPage
│  2. _openMap(entry) dipanggil
│  3. URL dibuat: "https://www.google.com/maps/search/?api=1&query=<lat>,<lng>"
│  4. launchUrl(uri, mode: LaunchMode.externalApplication) dipanggil
│  5. Google Maps terbuka di aplikasi eksternal
├─ Alternative Flow: -
├─ Error Handling  :
│  - Gagal buka URL → SnackBar "Tidak dapat membuka aplikasi peta"
├─ Notes           : Tombol hanya tampil jika hasCoords = true.
│                    Menggunakan plugin url_launcher.
├─ Code Reference  : lib/features/history/history_detail_page.dart (_openMap)
└─ Priority        : LOW
```

---

### UC-20: Lihat Konten Edukasi

```
UC-20: Lihat Konten Edukasi
├─ Primary Actor   : User
├─ Secondary Actors: HTTP CMS API
├─ Precondition    : User berada di tab /education
│                    Koneksi internet tersedia (atau timeout terjadi)
├─ Postcondition   : Daftar artikel dan video edukasi ditampilkan
├─ Main Flow:
│  1. EducationPage.initState → _loadData() → EducationRepository.fetchArticles() + fetchVideos()
│  2. HTTP GET ke ApiConstants.getArticles dan ApiConstants.getVideos
│  3. Response JSON di-parse menjadi List<EducationArticle> dan List<EducationVideo>
│  4. Tampilkan: artikel featured, daftar artikel dengan filter kategori, daftar video
├─ Alternative Flow:
│  A1. Tidak ada koneksi → menampilkan pesan error + tombol "Coba Lagi"
├─ Error Handling  :
│  - TimeoutException (>10 detik) → "Koneksi terputus. Pastikan WiFi sama."
│  - SocketException → "Gagal terhubung ke server."
│  - statusCode ≠ 200 → "Gagal memuat artikel/video: Server mengembalikan status <code>"
├─ Notes           : Menggunakan FutureBuilder. _retry() mereset _dataFuture.
├─ Code Reference  : lib/features/education/education_page.dart
│                    lib/features/education/education_repository.dart
│                    lib/core/constants/api_constants.dart
└─ Priority        : MEDIUM
```

---

### UC-21: Filter Artikel Edukasi

```
UC-21: Filter Artikel Edukasi
├─ Primary Actor   : User
├─ Secondary Actors: -
├─ Precondition    : Konten edukasi sudah dimuat
├─ Postcondition   : Daftar artikel difilter berdasarkan kategori yang dipilih
├─ Main Flow:
│  1. User melihat chip kategori: Semua | Gejala | Pengobatan | Mitos | FAQ
│  2. User mengetuk kategori tertentu
│  3. _selectedCategoryIndex diperbarui → setState
│  4. _filteredArticles() mengembalikan artikel sesuai kategori
│  5. ListView artikel diperbarui
├─ Alternative Flow: -
├─ Error Handling  : -
├─ Notes           : Artikel featured tidak dimasukkan ke filter reguler.
│                    Kategori di-filter client-side.
├─ Code Reference  : lib/features/education/education_page.dart
│                    lib/features/education/education_article.dart
└─ Priority        : MEDIUM
```

---

### UC-22: Baca Detail Artikel

```
UC-22: Baca Detail Artikel
├─ Primary Actor   : User
├─ Secondary Actors: -
├─ Precondition    : User mengetuk kartu artikel di EducationPage
├─ Postcondition   : Konten lengkap artikel ditampilkan
├─ Main Flow:
│  1. User mengetuk artikel
│  2. Navigator.push ke EducationDetailPage dengan objek EducationArticle
│  3. Konten artikel (judul, isi, gambar, kategori, tanggal) ditampilkan
├─ Alternative Flow: -
├─ Error Handling  : -
├─ Notes           : -
├─ Code Reference  : lib/features/education/education_detail_page.dart
└─ Priority        : MEDIUM
```

---

### UC-23: Tonton Video Edukasi

```
UC-23: Tonton Video Edukasi
├─ Primary Actor   : User
├─ Secondary Actors: Browser/YouTube (eksternal)
├─ Precondition    : User berada di EducationPage, video tersedia
├─ Postcondition   : Video dibuka di browser eksternal atau YouTube
├─ Main Flow:
│  1. User mengetuk thumbnail video di bagian Video Edukasi
│  2. url_launcher.launchUrl(videoUrl) dipanggil
│  3. Browser/YouTube terbuka dengan video yang dipilih
├─ Alternative Flow: -
├─ Error Handling  :
│  - Gagal buka URL → pesan error ditampilkan
├─ Notes           : -
├─ Code Reference  : lib/features/education/education_page.dart
└─ Priority        : LOW
```

---

### UC-24: Lihat Halaman Tentang

```
UC-24: Lihat Halaman Tentang
├─ Primary Actor   : User
├─ Secondary Actors: -
├─ Precondition    : User berada di tab /about
├─ Postcondition   : Informasi tentang aplikasi ditampilkan
├─ Main Flow:
│  1. AboutPage ditampilkan dengan:
│     - HeroCard (logo + nama app)
│     - Deskripsi LepraCheck
│     - WarningBox (disclaimer medis)
│     - AiTechCard (info teknologi ML)
│     - Versi aplikasi (v1.0.2 Build 2405)
│  2. User membaca informasi
├─ Alternative Flow: -
├─ Error Handling  : -
├─ Notes           : Halaman statis (tidak ada interaksi jaringan atau data).
├─ Code Reference  : lib/features/about/about_page.dart
└─ Priority        : LOW
```

---

## 5. USE CASE ANALYSIS TABLE

| ID | Nama Use Case | Priority | Frequency | Complexity | Dependencies | Implementation Status |
|----|---------------|----------|-----------|------------|--------------|----------------------|
| UC-01 | Tampilkan Splash Screen | HIGH | Setiap launch | LOW | Hive, AppPrefs | ✅ Done |
| UC-02 | Tampilkan Halaman Welcome | HIGH | Sekali | LOW | - | ✅ Done |
| UC-03 | Selesaikan Onboarding | HIGH | Sekali | LOW | AppPrefs, Hive | ✅ Done |
| UC-04 | Lihat Beranda | HIGH | Sangat Sering | LOW | AppShell, Router | ✅ Done |
| UC-05 | Ambil Foto dengan Kamera | HIGH | Sering | HIGH | Camera Plugin, UC-07 | ✅ Done |
| UC-06 | Pilih Foto dari Galeri | HIGH | Kadang | MEDIUM | ImagePicker, UC-07 | ✅ Done |
| UC-07 | Review & Validasi Foto | HIGH | Sering | LOW | UC-05/06, UC-08 | ✅ Done |
| UC-08 | Proses Inferensi ML (TFLite) | HIGH | Sering | HIGH | TFLite, model.tflite | ✅ Done |
| UC-09 | Proses Inferensi ML (Remote) | MEDIUM | Jarang | HIGH | FastAPI Server, UC-08 | ✅ Done |
| UC-10 | Lihat Hasil Deteksi | HIGH | Sering | LOW | UC-08/09 | ✅ Done |
| UC-11 | Isi Form Data Pasien | HIGH | Sering | MEDIUM | UC-10, UC-12, UC-13 | ✅ Done |
| UC-12 | Ambil Lokasi GPS | MEDIUM | Sering | MEDIUM | Location Plugin, UC-11 | ✅ Done |
| UC-13 | Simpan Laporan Skrining | HIGH | Sering | LOW | Hive, HistoryStore | ✅ Done |
| UC-14 | Lihat Daftar Riwayat | HIGH | Sering | LOW | Hive, HistoryStore | ✅ Done |
| UC-15 | Filter Riwayat | MEDIUM | Kadang | LOW | UC-14 | ✅ Done |
| UC-16 | Lihat Detail Riwayat | HIGH | Sering | LOW | Hive, UC-14 | ✅ Done |
| UC-17 | Hapus Entri Riwayat | MEDIUM | Kadang | LOW | Hive, UC-14/16 | ✅ Done |
| UC-18 | Hapus Semua Riwayat | MEDIUM | Jarang | LOW | Hive, UC-14 | ✅ Done |
| UC-19 | Buka Lokasi di Peta | LOW | Jarang | LOW | url_launcher, UC-16 | ✅ Done |
| UC-20 | Lihat Konten Edukasi | MEDIUM | Sering | MEDIUM | HTTP, CMS API | ✅ Done |
| UC-21 | Filter Artikel Edukasi | MEDIUM | Kadang | LOW | UC-20 | ✅ Done |
| UC-22 | Baca Detail Artikel | MEDIUM | Sering | LOW | UC-20 | ✅ Done |
| UC-23 | Tonton Video Edukasi | LOW | Kadang | LOW | url_launcher, UC-20 | ✅ Done |
| UC-24 | Lihat Halaman Tentang | LOW | Jarang | LOW | - | ✅ Done |

---

*Dokumen ini di-generate berdasarkan analisis kode sumber pada:*
- `lib/router.dart`
- `lib/features/` (semua sub-folder)
- `lib/data/` (AppPrefs, HistoryEntry, HistoryStore, ML services)
- `lib/features/shell/app_shell.dart`
