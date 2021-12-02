import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'tabsPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  //파이어베이스 애널리틱스를 사용하기 위한 FirebaseAnalytics객체를 선언함
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  //앱에서 페이지 이동, 클릭 등 사용자의 행동을 관찰하는 FirebaseAnalyticsObserver객체를 선언함
  //이처럼 관찰자 개념으로 사용하는 객체를 옵서버(observer)라고 부른다
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Example',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      navigatorObservers: <NavigatorObserver>[observer],
      home: FirebaseApp(
        analytics: analytics,
        observer: observer,
      ),
    );
  }
}

class FirebaseApp extends StatefulWidget {
  const FirebaseApp({Key? key, required this.analytics, required this.observer})
      : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _FirebaseAppState createState() => _FirebaseAppState(analytics, observer);
}


//_FirebaseAppState클래스에서는 버튼을 하나 만들고 이 버튼을 클릭하면 _sendAnalyticsEvent()함수를 호출해 애널리틱에 이벤트를 보내도록 함
class _FirebaseAppState extends State<FirebaseApp> {
  _FirebaseAppState(this.analytics, this.observer);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  String _message = '';

  void setMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  Future<void> _sendAnalyticsEvent() async {
    //애널리틱스에 이벤트를 보낼 때는 analytics.logEvent()함수를 이용한다
    //name에 이벤트 이름을 전달하고 parameters에 데이터를 Map형태로 전달한
    await analytics.logEvent(name: 'test_event', parameters: <String, dynamic>{
      'string': 'hello futter',
      'int': 100,
    });
    setMessage('Analytics 보내기 성공');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Example'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: _sendAnalyticsEvent,
              child: Text('test'),
            ),
            Text(
              _message,
              style: TextStyle(color: Colors.blueAccent),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.tab),
        onPressed: () {
          //기존의 pushNamed(),pushReplacementNamed()함수 등을 사용하지 않고 push()함수를 사용해 페이지를 이동했음
          //push()함수의 sttings: 에는 라우트를 설정하는 RouteSettings()함수를 이용해 라우트이름(name)과 해당 페이지에 전달할 인자(argument)등을 지정할 수 있음
          //앱에서 자주 사용하지 않는 페이지의 라우트는 이처럼 간단하게 처리할 수 있다
          Navigator.of(context).push(MaterialPageRoute<TabsPage>(
            settings: RouteSettings(name: '/tab'),
            builder: (BuildContext context) {
              return TabsPage(observer);
            }
          ));
        },
      ),
    );
  }
}
