import 'package:flutter/material.dart';
/// This File you can create your multiple select
/// which has  labels and values

class MultiSelectDialogItem<V> {
  const MultiSelectDialogItem(this._value, this._label);
  /// Constructor with [_value] and [_label]
  final V _value;
  final String _label;
}

class MultiSelectDialog<V> extends StatefulWidget {
  MultiSelectDialog({Key key, this.items, this.initialSelectedValues}) : super(key: key);
  /// Constructor with List[items] and Set[initialSelectedValues]
  final List<MultiSelectDialogItem<V>> items;
  final Set<V> initialSelectedValues;

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<V>();
}

class _MultiSelectDialogState<V> extends State<MultiSelectDialog<V>> {
  final _selectedValues = Set<V>();

  void initState() {
    super.initState();
    if (widget.initialSelectedValues != null) {
      _selectedValues.addAll(widget.initialSelectedValues);
    }
  }

  /// when CheckboxListTile has changed something
  void _onItemCheckedChange(V itemValue, bool checked) {
    setState(() {
      if (checked) {
        _selectedValues.add(itemValue);
      } else {
        _selectedValues.remove(itemValue);
      }
    });
  }
  /// Come back to previous Page
  void _onCancelTap() {
    Navigator.pop(context);
  }
  /// sending [_selectedValues] to previous Page
  void _onSubmitTap() {
      Navigator.pop(context, _selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Wählen Sie Uhrzeit'),
      contentPadding: EdgeInsets.only(top: 12.0),
      content: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: EdgeInsets.fromLTRB(10.0, 0.0, 24.0, 0.0),
          child: ListBody(
            children: widget.items.map(_buildItem).toList(),
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('CANCEL'),
          onPressed: _onCancelTap,
        ),
        FlatButton(
          child: Text('OK'),
          onPressed: _onSubmitTap,
        )
      ],
    );
  }
  /// Display Multiple Dialog Item
  Widget _buildItem(MultiSelectDialogItem<V> item) {
    final checked = _selectedValues.contains(item._value);
    return CheckboxListTile(
      value: checked,
      title: Text(item._label),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) => _onItemCheckedChange(item._value, checked),
    );
  }
}