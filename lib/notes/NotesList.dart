import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'NotesModel.dart';
import 'NotesDBWorker.dart';

class NotesList extends StatelessWidget {

  _deleteNote(BuildContext context, NotesModel model, Note note) {
    return showDialog(
        context : context,
        barrierDismissible : false,
        builder : (BuildContext alertContext) {
          return AlertDialog(
              title : Text("Delete Note"),
              content : Text("Are you sure you want to delete ${note.title}?"),
              actions : [
                FlatButton(child : Text("Cancel"),
                    onPressed: ()  => Navigator.of(alertContext).pop()
                ),
                FlatButton(child : Text("Delete"),
                    onPressed : () async {
//                      model.noteList.remove(note);
//                      model.setStackIndex(0);
                      await NotesDBWorker.db.delete(note.id);
                      Navigator.of(alertContext).pop();
                      Scaffold.of(context).showSnackBar(
                          SnackBar(
                              backgroundColor : Colors.red,
                              duration : Duration(seconds : 2),
                              content : Text("Note deleted")
                          )
                      );
                      model.loadData(NotesDBWorker.db);
                      model.setStackIndex(0);
                    }
                ) ] ); } ); }


  Color _toColor(var str){
    if(str=='red') return Colors.red;
    else if (str == 'green') return Colors.green;
    else if (str == 'blue') return Colors.blue;
    else if (str == 'yellow') return Colors.yellow;
    else if (str == 'grey') return Colors.grey;
    else if (str == 'purple') return Colors.purple;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<NotesModel>(
        builder: (BuildContext context, Widget child, NotesModel model) {
          return Scaffold(
              floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.add, color: Colors.white),
                  onPressed: () {model.noteBeingEdited = Note();
                  model.setColor(null);
                  model.setStackIndex(1);
                  }
              ),
              body: ListView.builder(
                  itemCount: model.noteList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Note note = model.noteList[index];
                    Color color = _toColor(note.color);
                    return Container(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Slidable(
                          delegate: SlidableDrawerDelegate(),
                          actionExtentRatio: .25,
                          secondaryActions: [
                            IconSlideAction(
                              caption: "Delete",
                              color: Colors.red,
                              icon: Icons.delete,
                              onTap: () => _deleteNote(context, model, note)
                            )
                          ],
                          child: Card(
                            elevation: 8,
                            color: color,
                            child: ListTile(
                              title: Text(note.title),
                              subtitle: Text(note.content),
                              onTap: () {model.noteBeingEdited = note;
                              model.setColor(model.noteBeingEdited.color);
                              model.setStackIndex(1);
                              },
                            ))
                        ) ); } ) ); } ); } }
