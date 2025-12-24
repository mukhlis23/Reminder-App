import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JadwalPage extends StatelessWidget {
  const JadwalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final jadwalRef = FirebaseFirestore.instance.collection('DatabaseApp');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _formJadwal(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: jadwalRef
            .orderBy('tanggalTimestamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada jadwal'));
          }

          return ListView(
            padding: const EdgeInsets.all(10),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Jenis Kegiatan
                      Text(
                        data['jenisKegiatan'] ?? '-',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.category, size: 16),
                          const SizedBox(width: 6),
                          Text(data['kategori'] ?? '-'),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(Icons.date_range, size: 16),
                          const SizedBox(width: 6),
                          Text(data['tanggal'] ?? '-'),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${data['jamDimulai']} - ${data['jamSelesai']}',
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 6),
                          Expanded(child: Text(data['lokasi'] ?? '-')),
                        ],
                      ),

                      const Divider(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon:
                                const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _formJadwal(context, doc),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _hapusJadwal(context, doc),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  /// ================= FITUR TAMBAH / EDIT =================
  void _formJadwal(BuildContext context,
      [QueryDocumentSnapshot? doc]) {
    final jenisKegiatan = TextEditingController();
    final lokasi = TextEditingController();
    final tanggalController = TextEditingController();
    final jamMulai = TextEditingController();
    final jamSelesai = TextEditingController();

    DateTime? selectedDate;

    final kategoriList = ['Pribadi', 'Kuliah', 'Kerja', 'Lainnya'];
    String selectedKategori = kategoriList.first;

    /// FITUR EDIT APP
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      jenisKegiatan.text = data['jenisKegiatan'];
      lokasi.text = data['lokasi'];
      tanggalController.text = data['tanggal'];
      jamMulai.text = data['jamDimulai'];
      jamSelesai.text = data['jamSelesai'];
      selectedKategori = data['kategori'];
      selectedDate = (data['tanggalTimestamp'] as Timestamp).toDate();
    }

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(doc == null
                  ? 'Tambah Jadwal'
                  : 'Edit Jadwal'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: jenisKegiatan,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Kegiatan',
                        prefixIcon: Icon(Icons.event),
                      ),
                    ),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: selectedKategori,
                      items: kategoriList
                          .map((k) => DropdownMenuItem(
                                value: k,
                                child: Text(k),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => selectedKategori = v!),
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        prefixIcon: Icon(Icons.category),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: lokasi,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 10),

/// ================= Pengaturan Tanggal(DatePicker)=================
                    TextField(
                      controller: tanggalController,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          selectedDate = picked;
                          tanggalController.text =
                              '${picked.day}-${picked.month}-${picked.year}';
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Tanggal',
                        prefixIcon: Icon(Icons.date_range),
                      ),
                    ),
                    const SizedBox(height: 10),

/// ================= Pengaturan JamMulai(timePicker)=================
                    TextField(
                      controller: jamMulai,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          jamMulai.text =
                              picked.format(context);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Jam Dimulai',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                    ),
                    const SizedBox(height: 10),

/// ================= Pengaturan JamMulai(timePicker)=================
                    TextField(
                      controller: jamSelesai,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          jamSelesai.text =
                              picked.format(context);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Jam Selesai',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  child: const Text('Simpan'),
                  onPressed: () {
                    if (jenisKegiatan.text.isEmpty ||
                        lokasi.text.isEmpty ||
                        selectedDate == null ||
                        jamMulai.text.isEmpty ||
                        jamSelesai.text.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                            content:
                                Text('Semua field wajib diisi')),
                      );
                      return;
                    }

                    final data = {
                      'jenisKegiatan': jenisKegiatan.text,
                      'kategori': selectedKategori,
                      'lokasi': lokasi.text,
                      'tanggal': tanggalController.text,
                      'jamDimulai': jamMulai.text,
                      'jamSelesai': jamSelesai.text,
                      'tanggalTimestamp':
                          Timestamp.fromDate(selectedDate!),
                      'createdAt': Timestamp.now(),
                    };

                    if (doc == null) {
                      FirebaseFirestore.instance
                          .collection('DatabaseApp')
                          .add(data);
                    } else {
                      doc.reference.update(data);
                    }

                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// ================= POP UP Peringatan HAPUS APP =================
  void _hapusJadwal(
      BuildContext context, QueryDocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content:
            const Text('Yakin ingin menghapus jadwal ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () {
              doc.reference.delete();
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
