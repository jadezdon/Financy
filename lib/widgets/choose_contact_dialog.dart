import 'base_dialog.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ChooseContactDialog extends StatelessWidget {
  final String selectedContactName;
  const ChooseContactDialog({Key key, this.selectedContactName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      titleWidget: Text(tr("choose-person")),
      contentWidget: FutureBuilder<Iterable<Contact>>(
        future: ContactsService.getContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return SimpleDialogOption(
                  padding: EdgeInsets.all(0),
                  onPressed: () => Navigator.pop(context, snapshot.data.elementAt(index).displayName),
                  child: _buildAccountContainer(context, snapshot.data.elementAt(index)),
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildAccountContainer(BuildContext context, Contact contact) {
    TextStyle textStyle;
    BoxDecoration boxDecoration;
    if (contact.displayName == selectedContactName) {
      textStyle = TextStyle(color: Theme.of(context).accentColor);
      boxDecoration = BoxDecoration(
        border: Border.all(color: Theme.of(context).accentColor),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
      decoration: boxDecoration,
      child: Row(
        children: [
          (contact.avatar != null && contact.avatar.length > 0)
              ? CircleAvatar(
                  backgroundImage: MemoryImage(contact.avatar),
                )
              : CircleAvatar(
                  child: Text(contact.initials()),
                ),
          SizedBox(width: 20.0),
          Text(
            contact.displayName,
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
