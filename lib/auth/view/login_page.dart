import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast;
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';
import 'package:wei_pei_yang_demo/commons/color.dart';

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  String email = "";
  String password = "";

  _login() async {
    if (email == "" || password == "") {
      Fluttertoast.showToast(
          msg: "账号密码不能为空",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    login(email, password, onSuccess: () {
      Fluttertoast.showToast(
          msg: "登录成功",
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.pushReplacementNamed(context, '/home');
    }, onFailure: (e) {
      Fluttertoast.showToast(
          msg: e.error.toString(),
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Theme(
        ///取消label文本高亮显示
        data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
                labelStyle: TextStyle(color: Colors.grey))),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(30.0, 100.0, 30.0, 0.0),
              child: Text(
                'Welcome Back!',
                style: TextStyle(
                    color: MyColors.deepBlue,
                    fontSize: 30.0,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(40.0, 100.0, 40.0, 0.0),
              child: TextField(
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: 'username',
                  contentPadding: EdgeInsets.only(top: 5.0),
                  // suffixIcon: Padding(
                  //     padding: const EdgeInsets.only(top: 15.0),
                  //     child: Icon(Icons.check_circle,
                  //         size: email == "" ? 18.0 : 0.0))
                ),
                onChanged: (input) => setState(() => email = input),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(40.0, 30.0, 40.0, 0.0),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'password',
                  contentPadding: EdgeInsets.only(top: 5.0),
                  // suffixIcon: Padding(
                  //   padding: const EdgeInsets.only(top: 15.0),
                  //   child: Icon(Icons.check_circle,
                  //       size: password == "" ? 18.0 : 0.0),
                  // )
                ),
                onChanged: (input) => setState(() => password = input),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 50.0),
              child: GestureDetector(
                child: Text(
                  'Forget password?',
                  style: TextStyle(fontSize: 12.0, color: Colors.blue),
                ),
                onTap: () {
                  // TODO 测试用
                  Navigator.pushNamed(context, '/home');
                },
              ),
            ),
            Container(
                height: 50.0,
                width: 400.0,
                padding: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0.0),
                child: RaisedButton(
                  onPressed: _login,
                  color: MyColors.deepBlue,
                  splashColor: MyColors.brightBlue,
                  child: Text('login', style: TextStyle(color: Colors.white)),
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                )),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(50.0, 30.0, 50.0, 0.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Need an account ?',
                    style: TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: GestureDetector(
                      child: Text(
                        'signup',
                        style: TextStyle(fontSize: 12.0, color: Colors.blue),
                      ),
                      onTap: () {},
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LoginHomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(30, 50, 0, 0),
            child: Text("Hello,\n微北洋4.0",
                style: TextStyle(
                    color: Color.fromRGBO(98, 103, 124, 1),
                    fontSize: 50,
                    fontWeight: FontWeight.w300)),
          ),
          Container(
            height: 50,
            width: 200,
            margin: const EdgeInsets.only(top: 90),
            child: RaisedButton(
              onPressed: () => Navigator.pushNamed(context, '/login_pw'),
              color: MyColors.deepBlue,
              splashColor: MyColors.brightBlue,
              child: Text('天外天账号密码登录',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            ),
          ),
          Container(
            height: 50,
            width: 200,
            margin: const EdgeInsets.only(top: 30),
            child: RaisedButton(
              onPressed: () => Navigator.pushNamed(context, '/login_phone'),
              color: MyColors.deepBlue,
              splashColor: MyColors.brightBlue,
              child: Text('手机验证码登录',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(100, 20, 90, 0),
            child: Text("首次登陆微北洋4.0请使用天外天账号密码登录，在登陆后绑定手机号码即可手机验证登录。",
                style: TextStyle(
                    fontSize: 11, color: Color.fromRGBO(98, 103, 124, 1))),
          )
        ],
      ),
    );
  }
}
