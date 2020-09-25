class ClassTable {
  int week;
  String term;
  int termStart;
  List<dynamic> data; // List<Course>
  // bool cache = true;
  // String updatedAt = "";

  ClassTable.fromJson(dynamic tmp) {
    week = tmp['week'];
    term = tmp['term'];
    termStart = tmp['term_start'];
    data = tmp['data'];
    // cache = tmp['cache'];
    // updatedAt = tmp['updated_at'];
  }
}

/// courseBean对象指的是一“门”课，这门课可能在一周中多次开展，详见arrange
class CourseBean {
  String classId; // 逻辑班号
  String courseId; // 课程编号
  String courseName;
  String credit;
  String teacher;
  String campus;
  Map week; // 起止周
  List<dynamic> arrange; // 课程具体安排
  // String courseType;
  // String courseNature;
  // String college;
  // String ext;

  CourseBean.fromJson(dynamic tmp) {
    classId = tmp['classid'];
    courseId = tmp['courseid'];
    courseName = tmp['coursename'];
    credit = tmp['credit'];
    teacher = tmp['teacher'];
    campus = tmp['campus'];
    week = tmp['week'];
    arrange = tmp['arrange'];
    // courseType = tmp['coursetype'];
    // courseNature = tmp['coursenature'];
    // college = tmp['college'];
    // ext = tmp['ext'];
  }
}

class Arrange {
  String week; // 单双周、单周、双周
  String room; // 上课地点
  String start; // 第几节开始
  String end; // 第几节结束
  String day; // 周几 （1 -> 周一）

  Arrange.fromJson(dynamic tmp){
    week = tmp['week'];
    room = tmp['room'];
    start = tmp['start'];
    end = tmp['end'];
    day = tmp['day'];
  }
}

class Week {
  String start;
  String end;

  Week.fromJson(dynamic tmp) {
    start = tmp['start'];
    end = tmp['end'];
  }
}

/// schedule页面实际使用的数据类
class Schedule{
  int termStart;
  String term;
  List<Course> courses;

  Schedule(this.termStart, this.term, this.courses);
}

class Course{
  String classId;
  String courseId;
  String courseName;
  String credit;
  String teacher;
  String campus;
  Week week;
  Arrange arrange;

  Course(this.classId, this.courseId, this.courseName, this.credit,
      this.teacher, this.campus, this.week, this.arrange);
}