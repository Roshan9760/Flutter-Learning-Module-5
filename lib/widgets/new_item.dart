import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    // TODO: implement createState
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final List<GroceryItem> _groceryItems = [];

  final _formKey = GlobalKey<FormState>();
  var _enterName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSanding = false;
  FocusNode myFocusNode = FocusNode();


  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      
      setState(() {
        _isSanding = true;
      });
      _formKey.currentState!.save();

      final url = Uri.https(
          'app1-1fbc8-default-rtdb.firebaseio.com', 'shopping-list.json');
      final response = await http.post(url,
          headers: {'content-Type': 'application/json'},
          body: json.encode({
            'name': _enterName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory.title,
          }));

      print(response.body);
      print(response.statusCode);

      final Map<String, dynamic> resData = json.decode(response.body);

      if (!context.mounted) return;
      Navigator.of(context).pop(
        GroceryItem(
          id: resData['name'],
          name: _enterName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item  '),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                focusNode: myFocusNode,
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50)
                    return 'Must be between 1 and 50 characters';
                  return null;
                },
                onSaved: (value) {
                  _enterName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration:
                          const InputDecoration(label: Text('Quantity')),
                      initialValue: '1',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0)
                          return 'Must be Valid Positive  Numbers';
                        return null;
                      },
                      onSaved: (value) {
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
                            child: Row(children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: category.value.color,
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Text(category.value.title)
                            ]),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSanding
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _isSanding ? null : _saveItem,
                    child: _isSanding
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        :const  Text('Add Item'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
