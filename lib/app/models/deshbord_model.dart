class DashboardApiModel {
  String? id;
  String? studentId;
  String? taskId;
  String? callerId;
  String? stageId;
  String? createdOn;
  String? updatedOn;
  String? status;
  String? remark;
  Students? students;
  Tasks? tasks;

  DashboardApiModel(
      {this.id,
      this.studentId,
      this.taskId,
      this.callerId,
      this.stageId,
      this.createdOn,
      this.updatedOn,
      this.status,
      this.remark,
      this.students,
      this.tasks});

  DashboardApiModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    studentId = json['studentId'];
    taskId = json['taskId'];
    callerId = json['callerId'];
    stageId = json['stageId'];
    createdOn = json['createdOn'];
    updatedOn = json['updatedOn'];
    status = json['status'];
    remark = json['remark'];
    students = json['students'] != null
        ? new Students.fromJson(json['students'])
        : null;
    tasks = json['tasks'] != null ? new Tasks.fromJson(json['tasks']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['studentId'] = this.studentId;
    data['taskId'] = this.taskId;
    data['callerId'] = this.callerId;
    data['stageId'] = this.stageId;
    data['createdOn'] = this.createdOn;
    data['updatedOn'] = this.updatedOn;
    data['status'] = this.status;
    data['remark'] = this.remark;
    if (this.students != null) {
      data['students'] = this.students!.toJson();
    }
    if (this.tasks != null) {
      data['tasks'] = this.tasks!.toJson();
    }
    return data;
  }
}

class Students {
  String? name;
  String? mobile;
  String? city;
  String? school;
  String? board;
  String? father;
  String? username;
  String? email;
  String? id;
  String? createdOn;
  String? updatedOn;
  String? stageId;
  String? gender;

  Students(
      {this.name,
      this.mobile,
      this.city,
      this.school,
      this.board,
      this.father,
      this.username,
      this.email,
      this.id,
      this.createdOn,
      this.updatedOn,
      this.stageId,
      this.gender});

  Students.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    mobile = json['mobile'];
    city = json['city'];
    school = json['school'];
    board = json['board'];
    father = json['father'];
    username = json['username'];
    email = json['email'];
    id = json['id'];
    createdOn = json['createdOn'];
    updatedOn = json['updatedOn'];
    stageId = json['stageId'];
    gender = json['gender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['mobile'] = this.mobile;
    data['city'] = this.city;
    data['school'] = this.school;
    data['board'] = this.board;
    data['father'] = this.father;
    data['username'] = this.username;
    data['email'] = this.email;
    data['id'] = this.id;
    data['createdOn'] = this.createdOn;
    data['updatedOn'] = this.updatedOn;
    data['stageId'] = this.stageId;
    data['gender'] = this.gender;
    return data;
  }
}

class Tasks {
  String? id;
  String? demoId;
  String? stageId;
  String? createdOn;
  String? updatedOn;
  String? staffId;
  String? title;
  String? description;

  Tasks(
      {this.id,
      this.demoId,
      this.stageId,
      this.createdOn,
      this.updatedOn,
      this.staffId,
      this.title,
      this.description});

  Tasks.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    demoId = json['demoId'];
    stageId = json['stageId'];
    createdOn = json['createdOn'];
    updatedOn = json['updatedOn'];
    staffId = json['staffId'];
    title = json['title'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['demoId'] = this.demoId;
    data['stageId'] = this.stageId;
    data['createdOn'] = this.createdOn;
    data['updatedOn'] = this.updatedOn;
    data['staffId'] = this.staffId;
    data['title'] = this.title;
    data['description'] = this.description;
    return data;
  }
}
