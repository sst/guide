---
layout: post
title: Apa itu Serverless?
date: 2019-04-24 15:00:00
lang: id
ref: what-is-serverless
description: Serverless refers to applications where the management and allocation of servers and resources are completely managed by the cloud provider. And the billing is based on the actual consumption of those resources.
comments_id: what-is-serverless/27
---

Secara tradisional, kami telah membangun dan menyebarkan aplikasi web di mana kami memiliki beberapa tingkat kendali atas permintaan HTTP yang dibuat untuk server kami. Aplikasi kami berjalan di server itu dan kami bertanggung jawab untuk menyediakan dan mengelola sumber daya untuk itu. Ada beberapa masalah dengan ini.

1. Kami dikenakan biaya untuk menjaga server tetap terjaga meskipun kami tidak melayani permintaan apa pun.

2. Kami bertanggung jawab atas waktu aktif dan pemeliharaan server dan semua sumber dayanya.

3. Kami juga bertanggung jawab untuk menerapkan pembaruan keamanan yang sesuai ke server.

4. Sebagai skala penggunaan kami, kami perlu mengelola peningkatan server kami juga. Dan sebagai hasilnya mengelola penurunan itu ketika kita tidak memiliki banyak penggunaan.

Untuk perusahaan yang lebih kecil dan pengembang individu ini bisa menjadi banyak untuk ditangani. Ini akhirnya mengalihkan perhatian dari pekerjaan yang lebih penting yang kita miliki; membangun dan memelihara aplikasi yang sebenarnya. Di organisasi yang lebih besar ini ditangani oleh tim infrastruktur dan biasanya itu bukan tanggung jawab pengembang individu. Namun, proses yang diperlukan untuk mendukung ini dapat memperlambat waktu pengembangan. Karena Anda tidak bisa terus maju dan membangun aplikasi tanpa bekerja dengan tim infrastruktur untuk membantu Anda bangkit dan berjalan. Sebagai pengembang, kami telah mencari solusi untuk masalah ini dan di sinilah serverless masuk.

### Komputasi Tanpa Server

Komputasi tanpa server (atau disingkat tanpa server), adalah model eksekusi di mana penyedia cloud (AWS, Azure, atau Google Cloud) bertanggung jawab untuk mengeksekusi sepotong kode dengan mengalokasikan sumber daya secara dinamis. Dan hanya pengisian untuk jumlah sumber daya yang digunakan untuk menjalankan kode. Kode ini biasanya dijalankan di dalam wadah stateless yang dapat dipicu oleh berbagai acara termasuk permintaan http, acara basis data, layanan antrian, peringatan pemantauan, unggahan file, acara terjadwal (pekerjaan cron), dll. Kode yang dikirim ke cloud penyedia untuk eksekusi biasanya dalam bentuk fungsi. Karenanya serverless kadang-kadang disebut sebagai "Functions as a Service" atau "FaaS" . Berikut ini adalah penawaran FaaS dari penyedia cloud utama:

- AWS: [AWS Lambda](https://aws.amazon.com/lambda/)
- Microsoft Azure: [Azure Functions](https://azure.microsoft.com/en-us/services/functions/)
- Google Cloud: [Cloud Functions](https://cloud.google.com/functions/)

Sementara serverless mengabstraksi infrastruktur yang mendasari jauh dari pengembang, server masih terlibat dalam menjalankan fungsi kami.

Karena kode Anda akan dieksekusi sebagai fungsi individual, ada beberapa hal yang perlu kami perhatikan.

### Layanan microser

Perubahan terbesar yang kita hadapi saat transisi ke dunia tanpa server adalah bahwa aplikasi kita perlu dirancang dalam bentuk fungsi. Anda mungkin terbiasa menggunakan aplikasi Anda sebagai aplikasi Rails tunggal atau Express monolith. Tetapi di dunia tanpa server Anda biasanya diharuskan untuk mengadopsi arsitektur yang lebih berbasis layanan mikro. Anda dapat menyiasatinya dengan menjalankan seluruh aplikasi di dalam satu fungsi sebagai monolit dan menangani perutean sendiri. Tetapi ini tidak disarankan karena lebih baik mengurangi ukuran fungsi Anda. Kami akan membicarakan ini di bawah.

### Fungsi Tanpa Kewarganegaraan

Fungsi Anda biasanya dijalankan di dalam wadah yang aman (hampir) tanpa kewarganegaraan. Ini berarti bahwa Anda tidak akan dapat menjalankan kode di server aplikasi Anda yang mengeksekusi lama setelah suatu peristiwa telah selesai atau menggunakan konteks eksekusi sebelumnya untuk melayani permintaan. Anda harus secara efektif mengasumsikan bahwa fungsi Anda dipanggil lagi setiap kali.

Ada beberapa seluk-beluk untuk ini dan kami akan membahas dalam bab [Apa itu AWS Lambda]({% link _chapters/what-is-aws-lambda.md %}).

### Mulai Dingin

Karena fungsi Anda dijalankan di dalam sebuah wadah yang muncul sesuai permintaan untuk merespons suatu acara, ada beberapa latensi yang terkait dengannya. Ini disebut sebagai _Cold Start_ . Wadah Anda mungkin disimpan sebentar setelah fungsi Anda menyelesaikan eksekusi. Jika peristiwa lain dipicu selama waktu ini, ia merespons jauh lebih cepat dan ini biasanya dikenal sebagai _Awal yang Hangat_.

Durasi cold start tergantung pada implementasi penyedia cloud tertentu. Pada AWS Lambda dapat berkisar dari mana saja antara beberapa ratus milidetik hingga beberapa detik. Itu bisa bergantung pada runtime (atau bahasa) yang digunakan, ukuran fungsi (sebagai paket), dan tentu saja penyedia cloud yang dimaksud. Awal yang dingin telah meningkat secara drastis selama bertahun-tahun karena penyedia cloud telah menjadi jauh lebih baik dalam mengoptimalkan waktu latensi yang lebih rendah.

Selain mengoptimalkan fungsi Anda, Anda dapat menggunakan trik sederhana seperti fungsi terjadwal terpisah untuk menjalankan fungsi Anda setiap beberapa menit agar tetap hangat. [Kerangka Tanpa Server](https://serverless.com) yang akan kita gunakan dalam tutorial ini memiliki beberapa plugin untuk [membantu menjaga fungsi Anda tetap hangat](https://github.com/FidelLimited/serverless-plugin-warmup).

Sekarang kami memiliki gagasan yang bagus tentang komputasi tanpa server, mari kita lihat lebih dalam apa fungsi Lambda dan bagaimana kode Anda akan dieksekusi.
