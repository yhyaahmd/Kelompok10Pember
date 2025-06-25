import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';
import 'package:intl/intl.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({Key? key}) : super(key: key);

  @override
  _PetScreenState createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  late Future<List<Pet>> _petFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  void _loadPets() {
    setState(() {
      _isLoading = true;
      _petFuture = PetService.fetchPets();
      _petFuture
          .then((_) {
            setState(() {
              _isLoading = false;
            });
          })
          .catchError((error) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading data: $error')),
            );
          });
    });
  }

  void _showAddPetDialog() {
    final namaController = TextEditingController();
    final jenisHewanController = TextEditingController();
    final jenisPerawatanController = TextEditingController();
    final tanggalController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final statusController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
          tanggalController.text = DateFormat(
            'yyyy-MM-dd',
          ).format(selectedDate);
        });
      }
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Tambah Jadwal Perawatan',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: 'Nama Hewan'),
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  TextField(
                    controller: jenisHewanController,
                    decoration: const InputDecoration(labelText: 'Jenis Hewan'),
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  TextField(
                    controller: jenisPerawatanController,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Perawatan',
                    ),
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  TextField(
                    controller: tanggalController,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Perawatan',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    readOnly: true,
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  TextField(
                    controller: statusController,
                    decoration: const InputDecoration(
                      labelText: 'Status Perawatan',
                    ),
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (namaController.text.isEmpty ||
                      jenisHewanController.text.isEmpty ||
                      jenisPerawatanController.text.isEmpty ||
                      tanggalController.text.isEmpty ||
                      statusController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Semua field harus diisi')),
                    );
                    return;
                  }

                  setState(() {
                    _isLoading = true;
                  });

                  final newPet = Pet(
                    nama_hewan: namaController.text,
                    jenis_hewan: jenisHewanController.text,
                    jenis_perawatan: jenisPerawatanController.text,
                    tanggal_perawatan: tanggalController.text,
                    status_perawtan: statusController.text,
                  );

                  try {
                    final success = await PetService.addPet(newPet);
                    setState(() {
                      _isLoading = false;
                    });

                    if (success) {
                      _loadPets();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data berhasil ditambahkan'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gagal menambahkan data. Coba lagi.'),
                        ),
                      );
                    }
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                    });
                    print('Error in add button: $e');
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child:
                    _isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'Simpan',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Pets',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                Divider(color: Colors.white, thickness: 1),
                SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name Hewan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Umur',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Warna hewan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 5),

          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : FutureBuilder<List<Pet>>(
                      future: _petFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Error: ${snapshot.error}',
                                  style: TextStyle(fontFamily: 'Poppins'),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadPets,
                                  child: Text(
                                    'Coba Lagi',
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final pets = snapshot.data ?? [];

                        if (pets.isEmpty) {
                          return Center(
                            child: Text(
                              'Belum ada data jadwal perawatan',
                              style: TextStyle(fontFamily: 'Poppins'),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: pets.length,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            final pet = pets[index];
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: Text(
                                          'Pilih Aksi',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        content: Text(
                                          'Apa yang ingin Anda lakukan dengan data ${pet.nama_hewan}?',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                context,
                                              );
                                              _showEditPetDialog(
                                                pet,
                                              );
                                            },
                                            child: Text(
                                              'Edit',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(
                                                context,
                                              ); // Tutup dialog
                                              _confirmDeletePet(
                                                pet,
                                              ); // Tampilkan konfirmasi delete
                                            },
                                            child: Text(
                                              'Delete',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                context,
                                              ); // Tutup dialog
                                            },
                                            child: Text(
                                              'Batal',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    color: Colors.blue,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 80,
                                          padding: EdgeInsets.all(8),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundColor:
                                                    Colors.grey.shade300,
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  pet.jenis_hewan,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  pet.tanggal_perawatan,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                                Text(
                                                  pet.jenis_perawatan,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                                Text(
                                                  pet.status_perawtan,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        Container(
                                          padding: EdgeInsets.all(8),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              pet.nama_hewan,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _showAddPetDialog,
        child:
            _isLoading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : const Icon(Icons.add),
        backgroundColor: Colors.blue,
        mini: true,
      ),
    );
  }

  void _showEditPetDialog(Pet pet) {
    final namaController = TextEditingController(text: pet.nama_hewan);
    final jenisHewanController = TextEditingController(text: pet.jenis_hewan);
    final jenisPerawatanController = TextEditingController(
      text: pet.jenis_perawatan,
    );
    final tanggalController = TextEditingController(
      text: pet.tanggal_perawatan,
    );
    final statusController = TextEditingController(text: pet.status_perawtan);
    DateTime selectedDate = DateTime.now();

    try {
      selectedDate = DateFormat('yyyy-MM-dd').parse(pet.tanggal_perawatan);
    } catch (e) {
      print('Error parsing date: $e');
    }

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
          tanggalController.text = DateFormat(
            'yyyy-MM-dd',
          ).format(selectedDate);
        });
      }
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Edit Jadwal Perawatan',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: 'Nama Hewan'),
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  TextField(
                    controller: jenisHewanController,
                    decoration: const InputDecoration(labelText: 'Jenis Hewan'),
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  TextField(
                    controller: jenisPerawatanController,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Perawatan',
                    ),
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  TextField(
                    controller: tanggalController,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Perawatan',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    readOnly: true,
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  TextField(
                    controller: statusController,
                    decoration: const InputDecoration(
                      labelText: 'Status Perawatan',
                    ),
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (pet.id == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ID tidak ditemukan')),
                    );
                    return;
                  }

                  setState(() {
                    _isLoading = true;
                  });

                  final updatedPet = Pet(
                    id: pet.id,
                    nama_hewan: namaController.text,
                    jenis_hewan: jenisHewanController.text,
                    jenis_perawatan: jenisPerawatanController.text,
                    tanggal_perawatan: tanggalController.text,
                    status_perawtan: statusController.text,
                  );

                  try {
                    final success = await PetService.updatePet(
                      pet.id!,
                      updatedPet,
                    );
                    setState(() {
                      _isLoading = false;
                    });

                    if (success) {
                      _loadPets();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data berhasil diperbarui'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal memperbarui data')),
                      );
                    }
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                    });
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child:
                    _isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'Update',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
              ),
            ],
          ),
    );
  }

  void _confirmDeletePet(Pet pet) {
    if (pet.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID tidak ditemukan')));
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Hapus Jadwal Perawatan',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus jadwal perawatan untuk ${pet.nama_hewan}?',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    final success = await PetService.deletePet(pet.id!);
                    setState(() {
                      _isLoading = false;
                    });

                    if (success) {
                      _loadPets();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data berhasil dihapus')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal menghapus data')),
                      );
                    }
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                    });
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child:
                    _isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'Hapus',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
              ),
            ],
          ),
    );
  }
}
