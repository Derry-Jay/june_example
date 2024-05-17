import 'package:flutter/material.dart';
import '../../../extensions/extensions.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  Widget drawerBuilder(BuildContext context) {
    return IconButton(
      onPressed: context.openDrawerIfAny,
      icon: const Icon(
        Icons.subject,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: [Builder(builder: drawerBuilder)],
            centerTitle: true,
            leadingWidth: context.width / 10,
            backgroundColor: Colors.grey.shade600,
            foregroundColor: Colors.black,
            title: const Text('Home'),
            leading: CircleAvatar(
                radius: context.radius / 20,
                backgroundColor: Colors.grey,
                foregroundColor: Colors.black,
                child: const Text('Logo'))),
        // drawer: Drawer(
        //   child: DrawerWidget(),
        // ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: context.width / 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Search for Doctors', style: TextStyle(fontSize: 20)),
              SizedBox(height: context.height / 100),
              const TextField(
                  decoration: InputDecoration(border: OutlineInputBorder())),
              SizedBox(
                height: context.height / 80,
              ),
              const Text('Available Doctors', style: TextStyle(fontSize: 20)),
              SizedBox(height: context.height / 50),
              // Container(
              //     child: DoctorsGridItemWidget(
              //         doctor: Doctor(1, "Paul", "Pediatrician", "5", "250",
              //             "3.5", "assets/images/car_icon.png")),
              //     height: context.height / 10)
            ],
          ),
        ));
  }
}
