import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';

class TabsPage extends StatefulWidget {
  TabsPage(this.observer);

  final FirebaseAnalyticsObserver observer;

  @override
  State<StatefulWidget> createState() => _TabsPage(observer);
}

//앱바를 이용해 탭을 만들고 탭을 눌렀을 때 페이지를 이동한다
class _TabsPage extends State<TabsPage>
    with SingleTickerProviderStateMixin, RouteAware {
  _TabsPage(this.observer);

  final FirebaseAnalyticsObserver observer;
  TabController? _controller;
  int selectedIndex = 0;

  //먼저 탭 목록을 만든 다음 initState()함수에서 TabController를 초기화 한다
  final List<Tab> tabs = <Tab>[
    const Tab(
      text: '1번',
      icon: Icon(Icons.looks_one),
    ),
    const Tab(
      text: '2번',
      icon: Icon(Icons.looks_two),
    ),
  ];

  @override
  initState() {
    super.initState();
    _controller = TabController(
      length: tabs.length,
      vsync: this,
      initialIndex: selectedIndex,
    );
    //탭을 클릭했을 때 발생하는 이벤트를 addListner()함수로 처리한다
    //탭을 클릭하면 탭 포커스가 변경되면서 다음 단계에서 작성할 _sendCurrentTab()함수를 호출한다
    _controller!.addListener(() {
      setState(() {
        if (selectedIndex != _controller!.index) {
          selectedIndex = _controller!.index;
          _sendCurrentTab();
        }
      });
    });
  }

  //_sendCurrentTab()함수는 현재 화면 이름을 파이어베이스 애널리틱스에 보낸다
  //이로써 사용자가 어떤 화면에 더 많이 접근했는지 알 수 있음
  void  _sendCurrentTab() {
    observer.analytics.setCurrentScreen(screenName: 'tab/$selectedIndex',);
  }

  //옵서버를 이용하려면 FirebaseAnalyticsObserver를 사용한다고 앱에 알려줘야 함
  //이를 구독(subscribe)라고 한다
  //옵서버는 didChangeDependencies()함수를 재정의해서 구독하고 dispose()함수를 재정의해서 구독을 해지한다
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    observer.subscribe(this, ModalRoute.of(context) as dynamic);
  }

  @override
  void dispose() {
    observer.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _controller,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: tabs.map((Tab tab) {
          return Center(child: Text(tab.text!));
    }).toList(),
    ),
    );}
}
