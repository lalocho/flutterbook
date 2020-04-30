import "../BaseModel.dart";

PhotosModel photosModel = PhotosModel();

class Photo {
  int id;
  String name;
  String phone;
  String email;
  String birthday;

  String toString() {
    return "{ id=$id, name=$name, phone=$phone, email=$email, birthday=$birthday }";
  }
}

class PhotosModel extends BaseModel<Photo> with DateSelection {

  void setBirthday(String date) {
    super.setChosenDate(date);
  }

  void triggerRebuild() {
    notifyListeners();
  }
}