import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';
import 'package:wei_pei_yang_demo/schedule/extension/logic_extension.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';
import 'package:wei_pei_yang_demo/schedule/model/school/school_model.dart'
    show Course;

class SliverCoursesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var week = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(30.0, 20.0, 0.0, 12.0),
            alignment: Alignment.centerLeft,
            child: Text('NO.${now.day} ${week[now.weekday - 1]}',
                style: TextStyle(
                    fontSize: 17.0,
                    color: Color.fromRGBO(53, 59, 84, 1.0),
                    fontWeight: FontWeight.bold)),
          ),
          Consumer<ScheduleNotifier>(
              builder: (context, notifier, _) => _getDisplayWidget(notifier))
        ],
      ),
    );
  }

  /// 返回首页显示课程的widget
  Widget _getDisplayWidget(ScheduleNotifier notifier) {
    List<Course> todayCourses = [];
    int today = DateTime.now().weekday - 2;
    notifier.coursesWithNotify.forEach((course) {
      if (judgeActiveInDay(
          notifier.currentWeek, today, notifier.weekCount, course)) {
        todayCourses.add(course);
      }
    });
    if (todayCourses.length == 0) // 如果今天没有课，就返回文字框
      return Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
              color: Color.fromRGBO(236, 238, 237, 1),
              borderRadius: BorderRadius.circular(15)),
          child: Center(
            child: Text("NO COURSE TODAY",
                style: TextStyle(
                    color: Color.fromRGBO(207, 208, 212, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5)),
          ));
    else // 否则返回所有今日课程
      return Container(
        height: 180.0,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: todayCourses.length,
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () {
//                        Navigator.push(context, MaterialPageRoute(builder: (context) => Text('123')));
                },
                child: Container(
                  height: 180.0,
                  width: 150.0,
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  child: Card(
                    color: MyColors.colorList[i % 5],
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 95.0,
                            alignment: Alignment.centerLeft,
                            child: Text(todayCourses[i].courseName,
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                                getCourseTime(todayCourses[i].arrange.start,
                                    todayCourses[i].arrange.end),
                                style: TextStyle(
                                    fontSize: 13.0, color: Colors.white)),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Text(
                                replaceBuildingWord(
                                    todayCourses[i].arrange.room),
                                style: TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
      );
  }
}
