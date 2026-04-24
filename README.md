📖 NovelHub: Modern Digital Reading Platform
NovelHub adalah aplikasi platform baca novel digital yang dirancang untuk memberikan pengalaman membaca yang mulus bagi pengguna, serta menyediakan alat manajemen konten yang komprehensif bagi penulis dan moderator (admin). Proyek ini dikembangkan dengan pendekatan full-stack menggunakan Flutter untuk sisi mobile dan Laravel untuk backend RESTful API.

🚀 Mengapa Proyek Ini?
Aplikasi ini dibangun untuk menyelesaikan masalah fragmentasi konten dalam platform bacaan, dengan menerapkan sistem Role-Based Access Control (RBAC) yang ketat untuk menjaga kualitas dan integritas konten di platform.

🛠️ Tech Stack & Arsitektur
Proyek ini mengadopsi standar pengembangan perangkat lunak modern:

Frontend (Mobile): Flutter (Dart)

Backend (API): Laravel 12 (PHP)

Database: MySQL

Authentication: Laravel Sanctum (Token-based API Authentication)

Architecture: RESTful API, MVC Pattern, 

🎯 Fitur Utama
Sistem ini dirancang dengan segmentasi akses pengguna untuk memastikan alur kerja yang efisien:

👤 Pengguna (Reader)
Content Discovery: Menjelajahi daftar novel yang tersedia.

Personalization: Menambahkan novel ke daftar Favorit pribadi.

Reading Progress: Fitur Bookmark per chapter untuk melanjutkan bacaan dari titik terakhir.

✍️ Author
Full Lifecycle Content Management: Membuat, membaca, memperbarui, dan menghapus novel serta chapter secara mandiri.



🛡️ Administrator
Content Moderation: Mengubah status novel (Draft vs Published). Draft & Publish Control: Mengelola draf novel sebelum dipublikasikan ke publik.

Quality Assurance: Menghapus novel yang dianggap tidak layak (tidak wajar) untuk menjaga integritas komunitas.

⚙️ Highlight Teknis untuk Recruiter
Secure API: Implementasi autentikasi API yang aman menggunakan Laravel Sanctum untuk melindungi endpoint sensitif.

RBAC Implementation: Middleware kustom untuk memisahkan logika akses antara User, Author, dan Admin.

Clean Database Design: Struktur database yang dinormalisasi untuk mendukung relasi kompleks antara User, Novel, Chapter, dan Favorit.

Scalable Architecture: Kode backend yang terstruktur dengan Controller-Service-Model untuk memudahkan maintenance.
