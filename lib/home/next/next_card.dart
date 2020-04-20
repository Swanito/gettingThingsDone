import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gtd/core/core_blocs/navigator_bloc.dart';
import 'package:gtd/core/models/gtd_element.dart';
import 'package:gtd/home/elements/element_bloc.dart';

class NextCard extends StatefulWidget {
  final GTDElement _processedElement;

  NextCard({GTDElement processedElement})
      : assert(processedElement != null),
        _processedElement = processedElement;

  @override
  _NextCardState createState() => _NextCardState();
}

class _NextCardState extends State<NextCard> {
  ElementBloc _elementBloc;

  @override
  Widget build(BuildContext context) {
    _elementBloc = BlocProvider.of<ElementBloc>(context);

    return Card(
      shape: Border(
          left: BorderSide(
        color: Colors.orange,
        width: 3,
      )),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0, top: 18.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                            widget._processedElement.project != null
                                ? widget._processedElement.project.title
                                : 'Sin proyecto',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600]))
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Row(
                        children: [
                          Text(widget._processedElement.summary,
                              style: TextStyle(
                                  fontSize: 18,
                                  decoration:
                                      widget._processedElement.currentStatus ==
                                              'COMPLETED'
                                          ? TextDecoration.lineThrough
                                          : null))
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 13,
                          color: Colors.grey[600],
                        ),
                        Text(
                            widget._processedElement.dueDate != null
                                ? widget._processedElement.dueDate.toString()
                                : 'Sin fecha',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600])),
                        SizedBox(
                          width: 20,
                        ),
                        Icon(Icons.assignment_ind,
                            size: 13, color: Colors.grey[600]),
                        Text(
                            widget._processedElement.contexts != null
                                ? '${widget._processedElement.contexts[0]} y ${widget._processedElement.contexts.length - 1} más'
                                : 'Sin contexto',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Checkbox(
                        checkColor: Colors.orange,
                        activeColor: Colors.white,
                        value: widget._processedElement.currentStatus ==
                                'COMPLETED'
                            ? true
                            : false,
                        onChanged: (check) => {
                              if (check)
                                {
                                  _elementBloc.add(MarkAsCompleted(
                                      widget._processedElement)),
                                }
                              else
                                {
                                  _elementBloc.add(UnmarkAsCompleted(
                                      widget._processedElement))
                                }
                            }),
                  ],
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FlatButton(
                    onPressed: () {
                      _onDeletePressed(widget._processedElement);
                    },
                    child: Text('ELIMINAR',
                        style: TextStyle(color: Colors.orange))),
                FlatButton(
                    onPressed: () {
                      _onDetailsPressed(context);
                    },
                    child: Text('DETALLES',
                        style: TextStyle(color: Colors.orange))),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _onDeletePressed(GTDElement element) {
    _elementBloc.add(MoveToDelete(element));
  }

  void _onDetailsPressed(BuildContext context) {
    String elementTitle = widget._processedElement.summary ?? 'Sin título';
    String elementDescription =
        widget._processedElement.description.isNotEmpty ? widget._processedElement.description : 'Sin descripción';
    String projectTitle = widget._processedElement.project != null
        ? widget._processedElement.project.title
        : 'Sin proyecto';
    List<dynamic> contexts = widget._processedElement.contexts ?? [];
    String dueDate = widget._processedElement.dueDate ?? 'Sin fecha prevista';
    Timestamp createdAt =
        widget._processedElement.createdAt ?? 'Sin fecha de creación';

    List<Widget> list = [];
    for (var context in contexts) {
      list.add(Chip(label: Text(context)));
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de $elementTitle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Descripción',
                textAlign: TextAlign.left,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(elementDescription),
              ),
              Text(
                'Proyecto',
                textAlign: TextAlign.left,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(projectTitle),
              ),
              Text(
                'Contexto(s)',
                textAlign: TextAlign.left,
              ),
              Row(
                children: list,
              ),
              Text(
                'Fecha prevista',
                textAlign: TextAlign.left,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(dueDate),
              ),
              Text(
                'Creado el',
                textAlign: TextAlign.left,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(createdAt.toDate().toString()),
              ),
              Text(
                'Archivos adjuntos',
                textAlign: TextAlign.left,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Sin archivos adjuntos'),
              )
            ],
          ),
          actions: [
            FlatButton(
                onPressed: () {
                  BlocProvider.of<NavigatorBloc>(context)
                      .add(NavigatorActionPop());
                },
                child: Text('Cerrar')),
          ],
        );
      },
    );
  }
}
