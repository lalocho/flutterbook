import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterbook/contacts/Avatar.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'PhotosDBWorker.dart';
import 'PhotosModel.dart' show Photo, PhotosModel, photosModel;
import '../utils.dart' as utils;

class PhotosList extends StatelessWidget with Avatar {

  @override
  Widget build(BuildContext context) {
    return ScopedModel<PhotosModel>(
        model: photosModel,
        child: ScopedModelDescendant<PhotosModel>(
            builder: (BuildContext context, Widget child, PhotosModel model) {
              return Scaffold(
                  floatingActionButton: FloatingActionButton(
                      child: Icon(Icons.add, color: Colors.white),
                      onPressed: () async {
                        File avatarFile = avatarTempFile();
                        if (avatarFile.existsSync()) {
                          avatarFile.deleteSync();
                        }
                        photosModel.entityBeingEdited = Photo();
                        photosModel.setBirthday(null);
                        photosModel.setStackIndex(1);
                      }
                  ),

                  body: ListView.builder(
                      itemCount: photosModel.entryList.length,
                      itemBuilder: (BuildContext context, int index) {
                        Photo photo = photosModel.entryList[index];
                        File avatarFile = File(avatarFileName(photo.id));
                        bool avatarFileExists = avatarFile.existsSync();
                        return Column(
                            children: <Widget>[
                              Slidable(
                                delegate: SlidableDrawerDelegate(),
                                actionExtentRatio: .25,
                                child: ListTile(
                                    leading: CircleAvatar(
                                        backgroundColor: Colors.indigoAccent,
                                        foregroundColor: Colors.white,
                                        backgroundImage: avatarFileExists
                                            ? FileImage(avatarFile)
                                            : null,
                                        child: avatarFileExists ? null : Text(
                                            photo.name.substring(0, 1)
                                                .toUpperCase())
                                    ),
                                    title: Text("${photo.name}"),
                                    subtitle: photo.phone == null
                                        ? null
                                        : Text("${photo.phone}"),
                                    onTap: () async {
                                      File avatarFile = avatarTempFile();
                                      if (avatarFile.existsSync()) {
                                        avatarFile.deleteSync();
                                      }
                                      photosModel.entityBeingEdited =
                                      await PhotosDBWorker.db.get(photo.id);
                                      if (photosModel.entityBeingEdited
                                          .birthday == null) {
                                        photosModel.setBirthday(null);
                                      } else {
                                        photosModel.setBirthday(
                                            utils.toFormattedDate(
                                                photosModel.entityBeingEdited
                                                    .birthday));
                                      }
                                      photosModel.setStackIndex(1);
                                    }
                                ),
                                secondaryActions: <Widget>[
                                  IconSlideAction(
                                    caption: "Delete",
                                    color: Colors.red,
                                    icon: Icons.delete,
                                    onTap: () => _deletePhoto(context, photo),
                                  )
                                ],
                              ),
                              Divider()
                            ]
                        );
                      }
                  )
              );
            }
        )
    );
  }

  Future _deletePhoto(BuildContext context, Photo photo) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext alertContext) {
          return AlertDialog(
              title: Text('Delete Photo'),
              content: Text('Really delete ${photo.name}?'),
              actions: [
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () { Navigator.of(alertContext).pop(); },
                ),
                FlatButton(
                  child: Text('Delete'),
                  onPressed: () async {
                    await PhotosDBWorker.db.delete(photo.id);
                    Navigator.of(alertContext).pop();
                    Scaffold.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          content: Text('Photo deleted'),
                        )
                    );
                    photosModel.loadData(PhotosDBWorker.db);
                  },
                )
              ]
          );
        }
    );
  }
}