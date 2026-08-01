import 'package:flutter/material.dart';

class ShowMessageState {
  ShowMessageState.initialState();
}

class ShowMessageAction {
  var msg;

  @override
  String toString() {
    return 'ShowMessageAction{msg: $msg}';
  }

  var color;
  ShowMessageAction({this.msg, this.color});
}

ShowMessageState? show_message_reducer(
    ShowMessageState? state, dynamic action,BuildContext context) {
  if (action is ShowMessageAction) {
    return show_message(state, action,context);
  }
  return state;
}

show_message(ShowMessageState? state, dynamic action,BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: action.color,
      content: Text(action.msg!),
    ),
  );
}
