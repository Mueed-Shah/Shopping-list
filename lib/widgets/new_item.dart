import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  List<GroceryItem> availableItems= [];
  var _enteredName = '';
  var _enteredQuantity = 1;
  Category? _selectedCategory = categories[Categories.vegetables];
  var isLoading = false;
  final url = Uri.https('flutter-prep-10a1f-default-rtdb.firebaseio.com','shopping-list.json');

  final _formKey = GlobalKey<FormState>();
  void _saveItems () async {
     if(_formKey.currentState!.validate()){
       setState(() {
         isLoading = true;
       });
       _formKey.currentState!.save();
       final response = await http.post(url,
       headers:{'Content-Type': 'application/json'},
         body: json.encode({'Name':_enteredName,
                'Quantity': _enteredQuantity,
                 'Category': _selectedCategory!.title
       })
       );
       final responseData = json.decode(response.body);
       print(response.body);

       if(!context.mounted){
         return ;
       }

       Navigator.of(context).pop(GroceryItem(id: responseData['name'], name: _enteredName,
           quantity: _enteredQuantity,
           category: _selectedCategory!));
     }
  }
  @override

  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              maxLength: 50,
              decoration: const InputDecoration(label: Text('Name')),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    value.trim().length <= 1 ||
                    value.trim().length >= 50) {
                  return 'Must be between 1 and 50';
                }
                return null;
              },
              onSaved: (value){
                _enteredName = value!;
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '1',
                    decoration: const InputDecoration(
                      label: Text('Quantity'),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null ||
                          int.parse(value) >= 50
                      ) {
                        return 'Must be between 1 and 50';
                      }
                      return null;

                    },
                    onSaved: (value){
                      _enteredQuantity = int.parse(value!);
                    },
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                    for (final category in categories.entries)
                      DropdownMenuItem(
                          value: category.value,

                          child: Row(
                            children: [
                              Container(
                                height: 16,
                                width: 16,
                                color: category.value.color,
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              Text(category.value.title)
                            ],
                          ))
                  ], onChanged: (value) {
                    _selectedCategory = value!;
                  }),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: isLoading ? null : () {
                  _formKey.currentState!.reset();
                }, child: const Text('Reset ')),
                ElevatedButton(onPressed: isLoading ? null:
                _saveItems, child: isLoading ? const SizedBox(height: 14,width: 14,child: CircularProgressIndicator()) :const Text('Submit'))
              ],
            )
          ]),
        ),
      ),
    );
  }
}
