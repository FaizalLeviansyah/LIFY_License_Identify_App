import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/firestore_services_new.dart';

class PlateHistoryView extends StatefulWidget {
  const PlateHistoryView({super.key});

  @override
  State<PlateHistoryView> createState() => _PlateHistoryViewState();
}

class _PlateHistoryViewState extends State<PlateHistoryView> {
  late String uid;

  @override
  void initState() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<History?>(
      future: readHistory(uid: uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        } else if (snapshot.hasData) {
          final result = snapshot.data!.historyList;
          return result.isEmpty
              ? const Center(
                  child: Text(
                    'No History Yet',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Delete'),
                                content: const Text('Delete all history?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'NO',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      try {
                                        await clearHistory(uid: uid);
                                        final snackBar = SnackBar(
                                          content: const Text(
                                              'History deleted successfuly'),
                                          action: SnackBarAction(
                                            label: 'OK',
                                            onPressed: () {},
                                          ),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                        Navigator.of(context).pop();
                                        setState(() {});
                                      } catch (e) {
                                        print('Error clearing history: $e');
                                      }
                                    },
                                    child: const Text(
                                      'YES',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            backgroundColor:
                                const Color.fromARGB(255, 39, 39, 39),
                            side: const BorderSide(
                              width: 3,
                              color: Color.fromRGBO(0, 0, 0, 1),
                            )),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Delete all history',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromRGBO(0, 0, 0, 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListView.builder(
                          itemCount: snapshot.data!.historyList.length,
                          itemBuilder: (context, index) {
                            return buildUser(
                              snapshot.data!.historyList[index],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget buildUser(String resultItem) => Card(
        margin: const EdgeInsets.all(5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          tileColor: const Color.fromARGB(255, 57, 57, 57),
          contentPadding: const EdgeInsets.only(left: 20),
          title: Text(
            resultItem,
            style: const TextStyle(
              color: Color.fromRGBO(0, 0, 0, 1),
              fontSize: 17,
            ),
          ),
        ),
      );
}
