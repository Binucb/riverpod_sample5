import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_example5/dataModel.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Riverpod Sample5',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Riverpod Sample5'),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context, ref) {
    //

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final dataModel = ref.watch(peopleProvider);
          return ListView.builder(
            itemCount: dataModel.count,
            itemBuilder: (context, index) {
              final person = dataModel.people[index];
              return ListTile(
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    final dataModel = ref.read(peopleProvider);
                    dataModel.removePerson(person);
                  },
                ),
                title: GestureDetector(
                    onTap: () async {
                      final updatedPerson = await createOrUpdatePersonDialog(
                        context,
                        person,
                      );
                      if (updatedPerson != null) {
                        dataModel.update(updatedPerson);
                      }
                    },
                    child: Text(person.displayName)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final person = await createOrUpdatePersonDialog(context, null);
          if (person != null) {
            final dataModel = ref.read(peopleProvider);
            dataModel.addPerson(person);
          }
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}

final nameController = TextEditingController();
final ageController = TextEditingController();

Future<Person?> createOrUpdatePersonDialog(
  BuildContext context,
  Person? existingPerson,
) {
  String? name = existingPerson?.name;
  int? age = existingPerson?.age;

  nameController.text = name ?? "";
  ageController.text = age?.toString() ?? "";

  return showDialog<Person?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create a person'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Enter name here'),
                onChanged: (value) => name = value,
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Enter age here'),
                onChanged: (value) => age = int.tryParse(value),
              )
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  if (name != null && age != null) {
                    if (existingPerson != null) {
                      final newPerson =
                          existingPerson.updated(name: name, age: age);
                      Navigator.of(context).pop(newPerson);
                    } else {
                      //no existing person, create a new one
                      Navigator.of(context).pop(Person(name: name!, age: age!));
                    }
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save')),
          ],
        );
      });
}
