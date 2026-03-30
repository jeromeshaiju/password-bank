import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Bank',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF669bbc),primary: Color(0xFF780000), brightness: Brightness.light),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme).copyWith(
      bodyMedium: GoogleFonts.oswald(textStyle: Theme.of(context).textTheme.bodyLarge),),

      ),
      darkTheme: ThemeData(
        // Dark theme configuration
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF003049),primary: Color(0xFF780000), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'password bank'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  /// A stateful widget serving as the application's home page.
  /// It holds immutable configuration values (e.g., title) provided by the parent widget and used by the State's build method.

  final String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//password class
class Password {
  final String title;
  final String password;
  Password({ required this.title,required this.password});

  Password.fromJson(Map<String, dynamic> json)
    : title = json['title'] as String,
      password = json['password'] as String;

  Map<String, dynamic> toJson() => {'title': title, 'password': password};
}



class _MyHomePageState extends State<MyHomePage> {
  final title = TextEditingController();
  final password = TextEditingController();


//dispose function to remove item after usage
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    title.dispose();
    password.dispose();
    super.dispose();
  }

//to refresh list
Future<void> refreshList() async {
  setState(() {});
}


 @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(
        title: Text("Passsword Bank"),
      ),
    body:Column(
      children: [
        Padding(padding:const EdgeInsets.all(20),
        child:TextFormField(
          decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Enter your title',
          ),
          controller: title,
          ),
         ),
     Padding(padding:const EdgeInsets.all(20),
     child: TextFormField(
          decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Enter your password',
          ),
          controller: password,
          ),
          ),
      Padding(padding:const EdgeInsets.all(20),
        child:TextButton(
  onPressed: () async{ 
    await writePass(title.text, password.text);
    title.clear();
    password.clear();
    refreshList();
  },
  child: Text('ADD PASWORD'),
  
)
         ),



        Expanded(child:FutureBuilder(
        future: readListpasswords(), 
        builder: (context,snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
              List passwords = snapshot.data ?? [];
          return  ListView.builder(
          itemCount: passwords.length,
          prototypeItem: ListTile(title: Text('item')),
          itemBuilder: (context, index) {
            var pass =passwords[index];
            return  Card(
              color: Color(0xFFC1121F),
              margin: const EdgeInsets.all(5),
              child:    InkWell(
                child: Center(
                  child: Text(pass['title']),
                ),
              // When the user taps the button, show a popup.
              onTap: () {
                showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(pass['password']),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
              );
            },
          );
        },
            onLongPress: () {
              
                showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Column (
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      Text('Do you want to delete '+pass['title'],textAlign: TextAlign.center),
                      Padding(padding:const EdgeInsets.all(20),
                      child:Center(
                        child:TextButton(
                      onPressed: () async{ await removePassword(pass['title']);
                      refreshList();
                      Navigator.of(context).pop();},
                      child: Text('DELETE')
                    ))
                    ),
                  ],
                ),
                
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
              );
            },
          );
        
            },
      ) 

    );
    
        },
        );
        
        
       
          },
        ),)
      ],
      ),); 
      }
    }
//file
Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

Future<File> get _localFile async {
  final path = await _localPath;
  final dir = Directory('$path/passwords');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  final file = File('$path/passwords/password.json');
  if (!await file.exists()) {
    await file.writeAsString('[]'); // start with empty list
  }
  return File('$path/passwords/password.json');
}


//wite passwords
Future<void> writePass( String title,String password) async {
  
  try{
      final file = await _localFile;
      List passwordList = await readListpasswords();
      Password passworddata = Password( title: title, password: password);
      passwordList.add(passworddata.toJson());
      String jsonString = jsonEncode(passwordList);
      print(jsonString);
      await file.writeAsString(jsonString);
  }
  catch(e){
      print("error is:$e");
  }
}


//return 1 item for the given index
Future<Password?> readPass(int index) async {
  
  try{
      final file = await _localFile;
      String jsonString = await file.readAsString();
      List passwordlist = jsonDecode(jsonString);
      return Password.fromJson(passwordlist[index]);
  }
  catch(e){
      print("error is$e");
      return null;
  }
}

//returns the list
Future<List> readListpasswords() async {
  
  try{
      final file = await _localFile;
      String jsonString = await file.readAsString();
      List passwordlist = jsonDecode(jsonString);
      return passwordlist;
  }
  catch(e){
      print("error is$e");
      return [];
  }
}



//remove password
Future<void> removePassword( String title) async {

  
  try{
      final file = await _localFile;
      List passwordList = await readListpasswords();
      List templist = [];
      for(int i=0;i<passwordList.length;i++){
        if(passwordList[i]['title']==title){
          continue;
        }
        templist.add(passwordList[i]);
      }
      String jsonString = jsonEncode(templist);
      print(jsonString);
      await file.writeAsString(jsonString);
  }
  catch(e){
      print("error is:$e");
  }
}