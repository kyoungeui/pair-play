import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pairplay/components/my_drawer.dart';
import 'package:pairplay/helper/helper_functions.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    if (currentUser?.email == null) {
      throw Exception("No email found for current user.");
    }
    return FirebaseFirestore.instance
      .collection("Users")
      .doc(currentUser!.email)
      .get();
  }

    void addCoin() async {
    if (currentUser?.email != null) {
      DocumentReference docRef = FirebaseFirestore.instance.collection('Users').doc(currentUser!.email);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception("User does not exist!");
        }
        int currentCoins = snapshot['coin'] ?? 0; // Assuming 'coin' field exists and is an integer
        transaction.update(docRef, {'coin': currentCoins + 1});
      }).then((result) {
        print("Coin added successfully");
      }).catchError((error) {
        print("Failed to add coin: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();
            if (user == null) {
              return const Text("No Data Available");
            }

            return Center(
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  // Display Username / Coin / Gem
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.account_circle_rounded),
                      Text(user['username']),
                      Icon(Icons.monetization_on),
                      Text(user['coin'].toString()),
                      Icon(Icons.diamond_sharp),
                      Text(user['gem'].toString()),
                    ],
                  ),
                  const SizedBox(height: 150),

                  // Trophy
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star),
                      const SizedBox(width: 10),
                      Text(user['trophy'].toString()),
                    ],
                  ),

                  const SizedBox(height: 100),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Single button
                  OutlinedButton(
                    onPressed: () {
                      if(user!['coin'] < 100){
                        displayMessage("Not Enough Coin", context); 
                      }
                      else{ Navigator.pushNamed(context, '/single_page');}
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(100, 100), // Makes the button square
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      side: BorderSide(color: Colors.blueGrey, width: 2), // BlueGrey outline
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Optional: Adjust for rounded corners
                      ),
                    ),
                    child: const Text(
                      "SINGLE",
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // Multi Button 
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/multi_page');
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(100, 100), // Makes the button square
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      side: BorderSide(color: Colors.redAccent, width: 2), // BlueGrey outline
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Optional: Adjust for rounded corners
                      ),
                    ),
                    child: const Text(
                      "MULTI",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                    ],),
                ],
              ),
            );
          } else {
            return const Text("No Data");
          }
        },
      ),
    );
  }
}
