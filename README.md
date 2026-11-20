# Pertemuan 8 - Manajemen Data User & Admin (Flutter CRUD)

Aplikasi Flutter untuk pengujian metode HTTP (**GET, POST, PUT, PATCH, DELETE**) pada data User dan Admin dengan integrasi REST API (`JSONPlaceholder`) dan penyimpanan data lokal persisten.

## 📌 Ketentuan Tugas & NIM
- **NIM:** 20240801085 (N = 58)
- **ID User Khusus:** $1499 + 58 =$ **1557**
- **ID Admin Khusus:** $792 + 58 =$ **850**

---

## 🚀 Fitur Utama

### 1. Tab User (CRUD Operations)
- **GET (List User):** Mengambil dan menampilkan seluruh daftar pengguna dari API / penyimpanan lokal.
- **POST (Tambah User 1557):** Menambahkan pengguna baru khusus dengan ID `1557`.
- **PUT (Update All):** Memperbarui nama dan email pengguna.
- **PATCH (Update Name):** Memperbarui nama pengguna dengan tambahan teks `" - Flutter Developer"`.
- **DELETE (Hapus User):** Menghapus pengguna berdasarkan ID.

### 2. Tab Admin
- **GET (List Admin):** Menampilkan daftar admin (termasuk **Admin ID 850**).
- **DELETE (Hapus Admin):** Menghapus admin berdasarkan ID dengan dialog konfirmasi.
- **Aksi Khusus:** Tombol khusus **"Hapus Admin ID 850"**.

### 3. Halaman Detail Data
- Menampilkan informasi detail lengkap properti User (`ID`, `Nama`, `Email`, `Kota`) dan Admin (`ID`, `Nama`, `Email`, `Departemen`).
- Menyediakan akses cepat melalui tombol **"Detail ID Saya"**.

---

## 📁 Struktur Proyek

```text
lib/
├── constants.dart            # Konstanta NIM (userId = 1557, adminId = 850) & Base URL
├── models/
│   ├── user.dart             # Data Model User (null-safe)
│   └── admin.dart            # Data Model Admin (null-safe)
├── services/
│   ├── user_service.dart     # Service CRUD Data User
│   ├── admin_service.dart    # Service Data Admin (GET & DELETE)
│   └── api_service.dart      # Re-exporter service kompatibilitas
├── screens/
│   ├── user_tab_screen.dart  # UI Tab User & Pengujian CRUD
│   ├── admin_tab_screen.dart # UI Tab Admin & Hapus Admin
│   └── detail_screen.dart    # UI Detail Data User & Admin
└── main.dart                 # Entry Point Utama (Material 3 & NavigationBar)
```

---

## 🛠️ Cara Menjalankan Aplikasi

1. **Clone repository ini:**
   ```bash
   git clone https://github.com/nadhifshoeemagoldist-wq/flutter-tugas-pertemuan8.git
   ```

2. **Masuk ke direktori proyek:**
   ```bash
   cd flutter-tugas-pertemuan8
   ```

3. **Install dependensi:**
   ```bash
   flutter pub get
   ```

4. **Jalankan aplikasi:**
   ```bash
   flutter run
   ```
