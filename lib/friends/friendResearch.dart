import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lynight/services/crud.dart';

class FriendResearch extends StatefulWidget {
  final String currentUserId;
  final String userName;

  FriendResearch({@required this.currentUserId, @required this.userName});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FriendResearchState();
  }
}

class _FriendResearchState extends State<FriendResearch> {
  CrudMethods crudObj = new CrudMethods();
  List<dynamic> _friendRequestList0fRequestedFriend;
  static final formKeyAddFriend = new GlobalKey<FormState>();
  bool _alreadyRequestedFriend = false;
  String _friendID;
  bool _isLoading = false;

  Widget friendResearch() {
    // la section research est pour le moment directement un ajout avec l'ID
    return Container(
      child: Form(
        key: formKeyAddFriend,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Ajout par ID (ne pas se tromper)',
                icon: new Icon(
                  FontAwesomeIcons.plusCircle,
                  color: Colors.grey,
                ),
              ),
              validator: (String value) {
                if (value.isEmpty) {
                  return 'Saisis un ID';
                }
              },
              onSaved: (value) => _friendID = value,
            ),
            widget.userName == ''
                ? Text('Tu dois enregistrer ton nom pour ajouter des amis !')
                : _button(),
            _alreadyRequestedFriend == true
                ? Text(
                    'Une demande d\'ami a déjà été envoyée',
                    style: TextStyle(color: Colors.red),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = formKeyAddFriend.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    //TODO ajouter la submition
    if (validateAndSave()) {
      setState(() {
        _isLoading = true;
      });
      formKeyAddFriend.currentState.reset();

      crudObj.getDataFromUserFromDocumentWithID(_friendID).then((value) {
        Map<String, dynamic> dataMap = value.data;
        List friendRequestList = dataMap['friendRequest'];
        if (friendRequestList == null) {
          crudObj.updateData('user', _friendID, {
            'friendRequest': [widget.currentUserId]
          });
        } else {
          setState(() {
            _friendRequestList0fRequestedFriend = friendRequestList;
          });

          for (int i = 0; i < _friendRequestList0fRequestedFriend.length; i++) {
            if (_friendRequestList0fRequestedFriend[i] ==
                widget.currentUserId) {
              setState(() {
                _alreadyRequestedFriend = true;
              });
            }
          }

          if (_alreadyRequestedFriend == false) {
            List<String> mutableListOfRequestedFriend =
                List.from(_friendRequestList0fRequestedFriend);

            mutableListOfRequestedFriend.add(widget.currentUserId);

            crudObj.updateData('user', _friendID,
                {'friendRequest': mutableListOfRequestedFriend});
          }
        }
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  Widget _button() {
    if(_isLoading){
      return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: CircularProgressIndicator(),
      );
    }
    else{
      return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: RaisedButton(
            elevation: 5.0,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            child: Text('demande d\'ami',
                style: TextStyle(color: Colors.white, fontSize: 20.0)),
            color: Theme.of(context).primaryColor,
            textColor: Colors.black87,
            onPressed: () {
              validateAndSubmit();
//                print('friend ID : ' + _friendID);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return friendResearch();
  }
}