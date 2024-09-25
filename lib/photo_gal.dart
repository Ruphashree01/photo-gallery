import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_photo_dialog.dart';
import 'models/photo.dart';
import 'services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final DatabaseService _databaseService = DatabaseService();
  List<String> menu = ['All Photos', 'Santhos', 'Test-1'];
  List<Photos> photoList = [];
  String sortBy = 'Time -latest first';

  @override
  void initState() {
    super.initState();
    _listenToPhotos();
  }

  void _handleAddPhoto(Photos photo) {
    setState(() {
      photoList.add(photo);
    });
  }

  void _sortPhotoList(String sortOption) {
    setState(() {
      sortBy = sortOption;
      if (sortOption == 'Time -latest first') {
        photoList.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      } else if (sortOption == 'Time -latest last') {
        photoList.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      } else if (sortOption == 'Name') {
        photoList.sort((a, b) => a.name.compareTo(b.name));
      }
    });
  }

  void _deletePhoto(String docId, int index) async {
    await _databaseService.deletePhoto(docId);
    setState(() {
      photoList.removeAt(index);
    });
  }

  void _showDeleteConfirmationDialog(String docId, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text('Sure you want to delete the selected photo?'),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(
                      width: 120,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('CANCEL'),
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xffF68F50),
                          primary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    SizedBox(
                      width: 130,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _deletePhoto(photoList[index].docId!, index);
                        },
                        child: Text('DELETE'),
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xffF65050),
                          primary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _listenToPhotos() {
    _databaseService.listenToPhotos().listen((QuerySnapshot snapshot) {
      List<Photos> updatedPhotos = snapshot.docs.map((doc) {
        return Photos(
          docId: doc.id,
          name: doc['name'],
          url: doc['url'],
          description: doc['description'],
          dateTime: (doc['dateTime'] as Timestamp).toDate(),
          isLiked: doc['isLiked'],
        );
      }).toList();

      setState(() {
        photoList = updatedPhotos;
      });

      for (var photo in updatedPhotos) {
        print('TAG1: ${photo.name} => ${photo.url}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Photo Gallery',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xff4A4C50),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.filter_list_sharp,
              color: Colors.white,
            ),
            onSelected: (String value) {},
            itemBuilder: (context) {
              return menu
                  .map((e) => PopupMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ))
                  .toList();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.sort,
              color: Colors.white,
            ),
            onSelected: (String value) {
              _sortPhotoList(value);
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Time -latest first',
                  child: Text('Time -latest first'),
                ),
                const PopupMenuItem<String>(
                  value: 'Time -latest last',
                  child: Text('Time -latest last'),
                ),
                const PopupMenuItem<String>(
                  value: 'Name',
                  child: Text('Name'),
                ),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        shape: CircleBorder(),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddPhotoDialog(
                onAdd: (photo) {
                  _handleAddPhoto(photo);
                },
              );
            },
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: photoList.isEmpty
          ? Center(child: Text('No photo Added'))
          : GridView.builder(
              padding: EdgeInsets.all(9),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 9,
                mainAxisSpacing: 9,
              ),
              itemCount: photoList.length,
              itemBuilder: (context, index) {
                final photo = photoList[index];
                final formattedDate =
                    DateFormat('dd-MM-yyyy').format(photo.dateTime);
                print('a1  ${photo.isLiked}');
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        photo.url,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                photo.description,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                '$formattedDate         -by ${photo.name}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: photo.isLiked == true
                                ? Colors.red
                                : Colors.white,
                          ),
                          onPressed: () async {
                            print('a  ${photo.isLiked}');
                            setState(() {
                              photo.isLiked = !photo.isLiked;
                            });
                            print('b ${photo.isLiked}');
                            _databaseService.updatePhotoLikeStatus(
                                photo.docId!, photo.isLiked);
                            print(photo.isLiked);
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(photo.docId!, index);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
