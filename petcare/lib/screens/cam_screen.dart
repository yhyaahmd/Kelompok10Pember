import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/pet_photo_supabase.dart';
import '../services/pet_gallery_service.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  final picker = ImagePicker();
  File? _profileImage;
  List<PetPhotoSupabase> _savedPetPhotos = [];
  final PetGalleryService _galleryService = PetGalleryService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadProfileImage();
    _loadSavedPetPhotos();
  }

  Future<void> _requestPermissions() async {
    final Map<Permission, PermissionStatus> statuses =
        await [
          Permission.camera,
          Permission.location,
          Permission.storage,
          Permission.photos,
        ].request();

    if (statuses.values.any((status) => status.isDenied)) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
            'This app needs camera, location, and storage permissions to function properly. Please enable them in settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting position: $e');
      return null;
    }
  }

  Future<String> _getLocationString(Position? position) async {
    if (position == null) return "Location unavailable";

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressParts = [];

        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        String address = addressParts.join(', ');
        if (address.isEmpty) {
          return "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
        }
        return address;
      } else {
        return "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
      }
    } catch (geocodingError) {
      print('Geocoding error: $geocodingError');
      return "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
    }
  }

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _saveProfileImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Compress image
      final bytes = await _image!.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image != null) {
        // Resize to max 512x512
        img.Image resized = img.copyResize(image, width: 512, height: 512);
        final compressedBytes = img.encodeJpg(resized, quality: 85);

        // Save to local storage first
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String profileImagePath = '${appDir.path}/profile_image.jpg';
        final File localFile = File(profileImagePath);
        await localFile.writeAsBytes(compressedBytes);

        // Upload to Supabase Storage
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final response = await Supabase.instance.client.storage
            .from('pet-gallery')
            .uploadBinary(
              'profiles/$fileName',
              Uint8List.fromList(compressedBytes),
            );

        final prefs = await SharedPreferences.getInstance();

        if (response.isNotEmpty) {
          // Get public URL
          final imageUrl = Supabase.instance.client.storage
              .from('pet-gallery')
              .getPublicUrl('profiles/$fileName');

          // Save both URL and local path to SharedPreferences
          await prefs.setString('profile_image_url', imageUrl);
        }

        // Always save local path
        await prefs.setString('profile_image_path', profileImagePath);

        // Update UI
        setState(() {
          _profileImage = localFile;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto profil berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error saving profile image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan foto profil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _showCaptionDialog() async {
    String caption = '';
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambahkan Caption'),
          content: TextField(
            onChanged: (value) => caption = value,
            decoration: const InputDecoration(
              hintText: 'Masukkan caption untuk foto pet...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Skip'),
            ),
            TextButton(
              onPressed:
                  () => Navigator.of(
                    context,
                  ).pop(caption.trim().isEmpty ? null : caption),
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _captureImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get location
      final position = await _getCurrentPosition();
      final locationString = await _getLocationString(position);

      // Get caption
      final caption = await _showCaptionDialog();

      // Upload image to Supabase
      final petPhoto = await _galleryService.uploadPetPhoto(
        imageFile: _image!,
        caption: caption,
        location: locationString,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      if (petPhoto != null) {
        setState(() {
          _savedPetPhotos.insert(0, petPhoto);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto berhasil disimpan ke galeri!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear selected image
        setState(() {
          _image = null;
        });
      }
    } catch (e) {
      print('Error capturing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imageUrl = prefs.getString('profile_image_url');
      final localPath = prefs.getString('profile_image_path');

      // Prioritas: cek local file dulu, baru network image
      if (localPath != null && File(localPath).existsSync()) {
        setState(() {
          _profileImage = File(localPath);
        });
      } else if (imageUrl != null) {
        // Jika ada URL tapi tidak ada file lokal, download dan simpan
        try {
          final response = await HttpClient().getUrl(Uri.parse(imageUrl));
          final httpResponse = await response.close();
          final bytes = await consolidateHttpClientResponseBytes(httpResponse);

          // Simpan ke local storage
          final Directory appDir = await getApplicationDocumentsDirectory();
          final String profileImagePath = '${appDir.path}/profile_image.jpg';
          final File localFile = File(profileImagePath);
          await localFile.writeAsBytes(bytes);

          // Update SharedPreferences dengan path lokal
          await prefs.setString('profile_image_path', profileImagePath);

          setState(() {
            _profileImage = localFile;
          });
        } catch (e) {
          print('Error downloading profile image: $e');
        }
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  Future<void> _loadSavedPetPhotos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final photos = await _galleryService.getPetPhotos();
      setState(() {
        _savedPetPhotos = photos;
      });
    } catch (e) {
      print('Error loading pet photos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImageDialog(PetPhotoSupabase petPhoto) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  child: Image.network(
                    petPhoto.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[400],
                          size: 50,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (petPhoto.caption != null &&
                          petPhoto.caption!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            petPhoto.caption!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      if (petPhoto.location != null)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                petPhoto.location!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontFamily: 'Poppins',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            _formatDateTime(petPhoto.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close),
                            label: Text('Tutup'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await _deletePetPhoto(petPhoto);
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.delete),
                            label: Text('Hapus'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _deletePetPhoto(PetPhotoSupabase petPhoto) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _galleryService.deletePetPhoto(petPhoto.id);

      setState(() {
        _savedPetPhotos.removeWhere((photo) => photo.id == petPhoto.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foto berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting pet photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ambil Foto', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Profile Section - Fixed at top
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Profile Image
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child:
                                _profileImage != null
                                    ? Image.file(
                                      _profileImage!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    )
                                    : Container(
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Foto Profil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.blue.shade800,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        "Pilih Sumber Gambar",
                                        style: TextStyle(fontFamily: 'Poppins'),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: Icon(
                                              Icons.photo_library,
                                              color: Colors.blue,
                                            ),
                                            title: Text(
                                              "Galeri",
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            onTap: () {
                                              getImage(ImageSource.gallery);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(
                                              Icons.camera_alt,
                                              color: Colors.blue,
                                            ),
                                            title: Text(
                                              "Kamera",
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            onTap: () {
                                              getImage(ImageSource.camera);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: Icon(Icons.camera_alt),
                              label: Text(
                                'Pilih Foto',
                                style: TextStyle(fontFamily: 'Poppins'),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed:
                                  _image != null ? _saveProfileImage : null,
                              icon: Icon(Icons.save),
                              label: Text(
                                'Simpan',
                                style: TextStyle(fontFamily: 'Poppins'),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Current Selected Image Preview
                  if (_image != null)
                    Container(
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Foto yang Dipilih:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(_image!, fit: BoxFit.contain),
                            ),
                          ),
                          SizedBox(height: 15),
                          ElevatedButton.icon(
                            onPressed: _captureImage,
                            icon: Icon(Icons.add_photo_alternate),
                            label: Text(
                              'Simpan ke Galeri Pet',
                              style: TextStyle(fontFamily: 'Poppins'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Pet Gallery Section
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Galeri Pet (${_savedPetPhotos.length})',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _loadSavedPetPhotos,
                                icon: Icon(Icons.refresh),
                                label: Text('Refresh'),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child:
                                _savedPetPhotos.isEmpty
                                    ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.pets,
                                            size: 80,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Belum ada foto pet yang tersimpan',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Pilih foto dan simpan ke galeri pet',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[500],
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : GridView.builder(
                                      padding: EdgeInsets.all(8),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 12,
                                            childAspectRatio: 0.8,
                                          ),
                                      itemCount: _savedPetPhotos.length,
                                      itemBuilder: (context, index) {
                                        final petPhoto = _savedPetPhotos[index];
                                        return GestureDetector(
                                          onTap: () {
                                            _showImageDialog(petPhoto);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            12,
                                                          ),
                                                        ),
                                                    child: Image.network(
                                                      petPhoto.imageUrl,
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      loadingBuilder: (
                                                        context,
                                                        child,
                                                        loadingProgress,
                                                      ) {
                                                        if (loadingProgress ==
                                                            null)
                                                          return child;
                                                        return Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        );
                                                      },
                                                      errorBuilder: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          color:
                                                              Colors.grey[200],
                                                          child: Icon(
                                                            Icons.broken_image,
                                                            color:
                                                                Colors
                                                                    .grey[400],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (petPhoto.caption !=
                                                              null &&
                                                          petPhoto
                                                              .caption!
                                                              .isNotEmpty)
                                                        Text(
                                                          petPhoto.caption!,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'Poppins',
                                                          ),
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      SizedBox(height: 2),
                                                      if (petPhoto.location !=
                                                          null)
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.location_on,
                                                              size: 12,
                                                              color:
                                                                  Colors
                                                                      .grey[600],
                                                            ),
                                                            SizedBox(width: 2),
                                                            Expanded(
                                                              child: Text(
                                                                petPhoto
                                                                    .location!,
                                                                style: TextStyle(
                                                                  fontSize: 10,
                                                                  color:
                                                                      Colors
                                                                          .grey[600],
                                                                  fontFamily:
                                                                      'Poppins',
                                                                ),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      SizedBox(height: 2),
                                                      Text(
                                                        _formatDateTime(
                                                          petPhoto.createdAt,
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color:
                                                              Colors.grey[500],
                                                          fontFamily: 'Poppins',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
