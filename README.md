 NovelApp
Aplikasi baca novel yang dibangun dengan Flutter (Mobile) dan Laravel (Backend API). Aplikasi ini memungkinkan pengguna untuk membaca novel favorit, menyimpan progres bacaan melalui fitur bookmark, dan mengelola daftar novel favorit. Untuk sisi admin, aplikasi ini menyediakan alat manajemen konten yang lengkap untuk moderasi dan publikasi novel.

🚀 Fitur Utama
👤 Pengguna (User)
Autentikasi: Registrasi dan Login akun pengguna.

Daftar Novel: Menjelajahi berbagai novel yang tersedia.

Favorit: Menyimpan novel ke dalam daftar favorit untuk akses cepat.

Bookmark: Melacak progres bacaan per bab (chapter) sehingga pengguna bisa melanjutkan dari tempat terakhir mereka membaca.

🛡️ Admin
CRUD Novel: Membuat, membaca, memperbarui, dan menghapus data novel.

CRUD Chapter: Mengelola isi bab dari setiap novel.

Manajemen Status: Mengatur status novel antara Draft (hanya admin yang lihat) atau Published (publik).

Moderasi Konten: Menghapus novel yang tidak sesuai dengan ketentuan atau tidak wajar.

🛠️ Teknologi yang Digunakan
Frontend (Mobile):

Flutter - Framework UI.

Dio - HTTP Client untuk komunikasi API.

[Provider/GetX/Bloc] - (Pilih salah satu, sesuaikan dengan state management Anda) untuk manajemen state.

Backend (API):

Laravel - PHP Framework.

MySQL - Database.

[Laravel Sanctum/Passport] - Untuk autentikasi API.
