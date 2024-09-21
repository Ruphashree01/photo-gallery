import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_gallery/models/photo.dart';

const String PHOTO_COLLECTION_REF = "GalleryPhotos";

class DatabaseService {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _galleryPhotosref;

  DatabaseService() {
    _galleryPhotosref =
        _firestore.collection(PHOTO_COLLECTION_REF).withConverter<Photos>(
              fromFirestore: (snapshots, _) => Photos.fromJson(
                snapshots.data()!,
              ),
              toFirestore: (photo, _) => photo.toJson(),
            );
  }

  Stream<DocumentSnapshot> getGalleryPhotos() {
    return _galleryPhotosref.doc().snapshots();
  }

  Future<void> addPhoto(Photos photo) async {
    try {
      await _galleryPhotosref.add(photo);
    } catch (e) {
      print("Error: $e");
    }
  }

  // Future<void> deletePhoto(Photos photo) async {
  //   try {
  //     await _galleryPhotosref.delete(photo);
  //   } catch (e) {
  //     print("Error: $e");
  //   }
}
// }
