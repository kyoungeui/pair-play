import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; 

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

    // Log Out 
  void logout(){
    FirebaseAuth.instance.signOut(); 
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.blueGrey,
      child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
      Column(
        children: [
               // Drawer Header 
        DrawerHeader(
          child: Icon(
          Icons.favorite, 
          color: Theme.of(context).colorScheme.inversePrimary),), 
        
        const SizedBox(height: 25), 

        // Home Tile 
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: ListTile(
            leading: Icon(
              Icons.home, 
              color: Theme.of(context).colorScheme.inversePrimary),
            title: Text("H O M E"), 
            onTap: (){
              Navigator.pop(context); 
            }
              ),
        ), 
          
        // Profile Tile 
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: ListTile(
            leading: Icon(
              Icons.monetization_on_rounded, 
              color: Theme.of(context).colorScheme.inversePrimary),
            title: Text("S T O R E"), 
            onTap: (){
              // pop drawer
              Navigator.pop(context); 

              // navigate to profile page
              Navigator.pushNamed(context, '/store_page'); 
            }
              ),
        ), 

        // User Tile
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: ListTile(
            leading: Icon(
              Icons.group, 
              color: Theme.of(context).colorScheme.inversePrimary),
            title: Text("R A N K I N G"), 
            onTap: (){
              Navigator.pop(context); 
              Navigator.pushNamed(context, '/users_page'); 
            }
              ),
        ), 

        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: ListTile(
            leading: Icon(
              Icons.help_outline, 
              color: Theme.of(context).colorScheme.inversePrimary),
            title: Text("G U I D E"), 
            onTap: (){
              Navigator.pop(context); 
              Navigator.pushNamed(context, '/guide_page'); 
            }
              ),
        ), 

        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: ListTile(
            leading: Icon(
              Icons.settings, 
              color: Theme.of(context).colorScheme.inversePrimary),
            title: Text("S E T T I N G S"), 
            onTap: (){
              Navigator.pop(context); 
              Navigator.pushNamed(context, '/settings_page'); 
            }
              ),
        ), 
        
        ],), 



        // Log Out 
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: ListTile(
            leading: Icon(
              Icons.logout, 
              color: Theme.of(context).colorScheme.inversePrimary),
            title: Text("L O G O U T"), 
            onTap: (){
              Navigator.pop(context); 
              
              // logout 
              logout(); 
            }
              ),
        ), 
      ],)
    ); 
  }
}