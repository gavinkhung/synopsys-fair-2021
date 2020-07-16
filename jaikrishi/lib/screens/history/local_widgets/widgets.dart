import 'package:flutter/material.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:leaf_problem_detection/widgets/buttons.dart';
import 'package:provider/provider.dart';

Column jsonPrevDiseaseCard(
    String type,
    DateTime dt,
    String ref,
    String id,
    String uid,
    bool status,
    FlatButton yes,
    FlatButton no,
    BuildContext context) {
  dt = dt.toLocal();

  Map<String, dynamic> data =
      Provider.of<UserModel>(context, listen: false).data[type];
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Wrap(
        children: [
          Text(
            DemoLocalizations.of(context).vals["History"]["detected"],
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          Text(
            data["Disease"],
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
      ref != "" && ref != null
          ? Container(
              height: MediaQuery.of(context).size.height < 600 ? 90 : 150,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              child: Image.network(ref))
          : Container(
              height: 0,
            ),
      infoButton(context, data),
      !status ? Divider() : Container(height: 0, width: 0),
      !status
          ? Column(
              children: [
                Text(
                  DemoLocalizations.of(context).vals["History"]["work"],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Container(
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(24, 165, 123, 1),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child:
                        Center(child: yesNoButton(context, id, uid, yes, no)))
              ],
            )
          : Container(height: 0, width: 0),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              dt.day.toString() +
                  "/" +
                  dt.month.toString() +
                  "/" +
                  dt.year.toString() +
                  " ",
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.w300),
            ))
      ]),
    ],
  );
}

Row yesNoButton(BuildContext context, String id, String uid, FlatButton yes,
    FlatButton no) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Expanded(
        child: yes,
      ),
      Container(
        height: MediaQuery.of(context).size.height / 35,
        child: VerticalDivider(
          width: 5,
          color: Colors.white,
          thickness: 2,
        ),
      ),
      Expanded(
        child: no,
      ),
    ],
  );
}

Future feedbackResponse(BuildContext context, bool yes) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: ListTile(
              title: yes
                  ? Text(DemoLocalizations.of(context).vals["History"]["glad"])
                  : Text(DemoLocalizations.of(context).vals["History"]["glad"]),
              subtitle: yes
                  ? Text("")
                  : Text(DemoLocalizations.of(context).vals["History"]
                      ["thankyou"]),
            ),
            actions: <Widget>[
              FlatButton(
                child:
                    Text(DemoLocalizations.of(context).vals["History"]["ok"]),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ));
}
