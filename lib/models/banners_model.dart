class getBannersModel {
  String? status;
  String? message;
  List<Sliders>? sliders;

  getBannersModel({this.status, this.message, this.sliders});

  getBannersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['sliders'] != null) {
      sliders = <Sliders>[];
      json['sliders'].forEach((v) {
        sliders!.add(new Sliders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.sliders != null) {
      data['sliders'] = this.sliders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Sliders {
  String? id;
  String? categoryId;
  String? image;

  Sliders({this.id, this.categoryId, this.image});

  Sliders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['category_id'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category_id'] = this.categoryId;
    data['image'] = this.image;
    return data;
  }
}
