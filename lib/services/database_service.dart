import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_gallery/models/photo.dart';

const String PHOTO_COLLECTION_REF = "GalleryPhotos";

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference<Photos> _galleryPhotosref;

  DatabaseService() {
    _galleryPhotosref =
        _firestore.collection(PHOTO_COLLECTION_REF).withConverter<Photos>(
              fromFirestore: (snapshots, _) => Photos.fromJson(
                snapshots.data()!,
              ),
              toFirestore: (photo, _) => photo.toJson(),
            );
  }

  Future<void> addPhoto(Photos photo) async {
    try {
      await _galleryPhotosref.add(photo);
    } catch (e) {
      print("Error adding photo: $e");
    }
  }

  Stream<QuerySnapshot<Photos>> listenToPhotos(String sortBy) {
    try {
      Query<Photos> query;

      if (sortBy == 'Time Desc') {
        query = _galleryPhotosref.orderBy('dateTime', descending: true);
      } else if (sortBy == 'Time Asc') {
        query = _galleryPhotosref.orderBy('dateTime', descending: false);
      } else if (sortBy == 'Name') {
        query = _galleryPhotosref.orderBy('name');
      } else {
        query = _galleryPhotosref;
      }

      return query.snapshots();
    } catch (e) {
      print("Error listening to photos: $e");
      return const Stream.empty();
    }
  }

  Future<void> deletePhoto(String docId) async {
    try {
      await _galleryPhotosref.doc(docId).delete();
    } catch (e) {
      print("Error deleting photo: $e");
    }
  }

  Future<void> updatePhotoLikeStatus(String docId, bool isLiked) async {
    try {
      await _galleryPhotosref.doc(docId).update({
        'isLiked': isLiked,
      });
      print("Photo $docId like status updated to $isLiked");
    } catch (e) {
      print("Error updating like status for photo $docId: $e");
    }
  }
}
